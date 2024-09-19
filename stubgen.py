# stubgen patch to make it play nice with Cython
import inspect
import typing
from collections.abc import Callable, Iterable
from unittest import mock

from mypy.stubgen import main
from mypy.stubgenc import ArgSig, FunctionContext, FunctionSig, InspectionStubGenerator
from mypy.stubutil import ClassInfo


def get_annotation_fullname(gen: InspectionStubGenerator, annotation: object) -> str:
    if annotation is inspect.Parameter.empty:
        return "_typeshed.Incomplete"
    elif annotation is inspect.Signature.empty:
        return "_typeshed.Incomplete"
    elif isinstance(annotation, str):
        return annotation
    elif orig := typing.get_origin(annotation):
        if not (args := typing.get_args(annotation)):
            return gen.get_type_fullname(orig)
        else:
            return (
                gen.get_type_fullname(orig)
                + "["
                + ", ".join(get_annotation_fullname(gen, arg) for arg in args)
                + "]"
            )
    elif isinstance(annotation, type):
        return gen.get_type_fullname(annotation)
    else:
        return "_typeshed.Incomplete"


class CythonInspectionStubGenerator(InspectionStubGenerator):
    def get_obj_module(self, obj: object) -> str | None:
        module = getattr(obj, "__module__", None)
        if isinstance(module, str) and module.endswith(".__init__"):
            # for __init__.pyd files, Cython has inconsistent __module__ attributes
            # between classes and functions... fix it here
            return module[:-9]
        else:
            return module

    def is_function(self, func: object) -> bool:
        return (
            super().is_function(func)
            or type(func).__name__ == "cython_function_or_method"
        )

    def get_default_function_sig(
        self,
        func: object,
        ctx: FunctionContext,
    ) -> FunctionSig:
        if type(func).__name__ != "cython_function_or_method":
            return super().get_default_function_sig(func, ctx)

        # inspect.signature requires Callable but base class uses just "object"
        sig = inspect.signature(func)  # type: ignore
        args = [
            ArgSig(
                param.name,
                get_annotation_fullname(self, param.annotation),
                default=param.default != param.empty,
                default_value=(
                    str(param.default) if param.default != param.empty else ""
                ),
            )
            for param in sig.parameters.values()
        ]
        return FunctionSig(
            ctx.name, args, get_annotation_fullname(self, sig.return_annotation)
        )

    def generate_property_stub(
        self,
        name: str,
        raw_obj: object,
        obj: object,
        static_properties: list[str],
        rw_properties: list[str],
        ro_properties: list[str],
        class_info: ClassInfo | None = None,
    ) -> None:
        if not inspect.isgetsetdescriptor(obj):
            return super().generate_property_stub(
                name,
                raw_obj,
                obj,
                static_properties,
                rw_properties,
                ro_properties,
                class_info,
            )
        # TODO fetch getter_type from obj, if Cython ever exposes it?
        # workaround: use __annotations__ dict from class
        getter_type: str = self.strip_or_import(
            get_annotation_fullname(
                self, inspect.get_annotations(class_info.cls).get(name)
            )
            if class_info is not None and class_info.cls is not None
            else "_typeshed.Incomplete"
        )
        # TODO fetch setter_type from obj, if Cython ever exposes it?
        setter_type: str | None = getter_type  # or None, but better generate too much?

        def getter_properties() -> Iterable[str]:
            yield f"{self._indent}@property"
            yield FunctionSig(name, [ArgSig("self")], getter_type).format_sig(
                indent=self._indent
            )

        def setter_properties() -> Iterable[str]:
            yield f"{self._indent}@{name}.setter"
            yield FunctionSig(
                name, [ArgSig("self"), ArgSig("value", setter_type)], "None"
            ).format_sig(indent=self._indent)

        def attribute_properties() -> Iterable[str]:
            assert getter_type == setter_type
            yield f"{self._indent}{name}: {getter_type}"

        if setter_type is not None and setter_type != getter_type:
            rw_properties.extend(getter_properties())
            rw_properties.extend(setter_properties())
        elif setter_type is not None and setter_type == getter_type:
            rw_properties.extend(attribute_properties())
        else:
            ro_properties.extend(getter_properties())


if __name__ == "__main__":
    with mock.patch(
        "mypy.stubgenc.InspectionStubGenerator", CythonInspectionStubGenerator
    ):
        main()
