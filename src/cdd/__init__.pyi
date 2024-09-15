import enum
from collections.abc import Container, Sequence, Set
from typing import ClassVar, Optional, SupportsFloat

NumberType = float
SupportsNumberType = SupportsFloat

class LPObjType(enum.IntEnum):
    MAX: ClassVar[LPObjType] = ...
    MIN: ClassVar[LPObjType] = ...
    NONE: ClassVar[LPObjType] = ...

class LPSolverType(enum.IntEnum):
    CRISS_CROSS: ClassVar[LPSolverType] = ...
    DUAL_SIMPLEX: ClassVar[LPSolverType] = ...

class LPStatusType(enum.IntEnum):
    DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    DUAL_UNBOUNDED: ClassVar[LPStatusType] = ...
    INCONSISTENT: ClassVar[LPStatusType] = ...
    OPTIMAL: ClassVar[LPStatusType] = ...
    STRUC_DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    STRUC_INCONSISTENT: ClassVar[LPStatusType] = ...
    UNBOUNDED: ClassVar[LPStatusType] = ...
    UNDECIDED: ClassVar[LPStatusType] = ...

class LinProg:
    @property
    def array(self) -> Sequence[Sequence[NumberType]]: ...
    @property
    def dual_solution(self) -> Sequence[tuple[int, NumberType]]: ...
    @property
    def obj_type(self) -> LPObjType: ...
    @obj_type.setter
    def obj_type(self, value: LPObjType) -> None: ...
    @property
    def obj_value(self) -> NumberType: ...
    @property
    def primal_solution(self) -> Sequence[NumberType]: ...
    @property
    def status(self) -> LPStatusType: ...
    @property
    def solver(self) -> LPSolverType: ...

class Matrix:
    @property
    def array(self) -> Sequence[Sequence[NumberType]]: ...
    @property
    def lin_set(self) -> Set[int]: ...
    @lin_set.setter
    def lin_set(self, value: Container[int]) -> None: ...
    @property
    def obj_func(self) -> Sequence[NumberType]: ...
    @obj_func.setter
    def obj_func(self, value: Sequence[NumberType]) -> None: ...
    @property
    def obj_type(self) -> LPObjType: ...
    @obj_type.setter
    def obj_type(self, value: LPObjType) -> None: ...
    @property
    def rep_type(self) -> RepType: ...
    @rep_type.setter
    def rep_type(self, value: RepType) -> None: ...

class Polyhedron:
    @property
    def rep_type(self) -> RepType: ...

class RepType(enum.IntEnum):
    GENERATOR: ClassVar[RepType] = ...
    INEQUALITY: ClassVar[RepType] = ...
    UNSPECIFIED: ClassVar[RepType] = ...

def copy_adjacency(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_generators(poly: Polyhedron) -> Matrix: ...
def copy_incidence(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_inequalities(poly: Polyhedron) -> Matrix: ...
def copy_input(poly: Polyhedron) -> Matrix: ...
def copy_input_adjacency(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_input_incidence(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_output(poly: Polyhedron) -> Matrix: ...
def linprog_from_array(
    array: Sequence[Sequence[SupportsNumberType]], obj_type: LPObjType
) -> LinProg: ...
def linprog_from_matrix(mat: Matrix) -> LinProg: ...
def linprog_solve(
    lp: LinProg, solver: LPSolverType = LPSolverType.DUAL_SIMPLEX
) -> None: ...
def matrix_append_to(mat1: Matrix, mat2: Matrix) -> None: ...
def matrix_canonicalize(mat: Matrix) -> tuple[Set[int], Set[int]]: ...
def matrix_copy(mat: Matrix) -> Matrix: ...
def matrix_from_array(
    array: Sequence[Sequence[SupportsNumberType]],
    lin_set: Container[int] = (),
    rep_type: RepType = RepType.UNSPECIFIED,
    obj_type: LPObjType = LPObjType.NONE,
    obj_func: Optional[Sequence[SupportsNumberType]] = None,
) -> Matrix: ...
def polyhedron_from_matrix(mat: Matrix) -> Polyhedron: ...
