from collections.abc import Sequence, Set
from enum import IntEnum
from fractions import Fraction
from typing import ClassVar, Union, overload

class LPObjType(IntEnum):
    MAX: ClassVar[LPObjType] = ...
    MIN: ClassVar[LPObjType] = ...
    NONE: ClassVar[LPObjType] = ...

class LPSolverType(IntEnum):
    CRISS_CROSS: ClassVar[LPSolverType] = ...
    DUAL_SIMPLEX: ClassVar[LPSolverType] = ...

class LPStatusType(IntEnum):
    DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    DUAL_UNBOUNDED: ClassVar[LPStatusType] = ...
    INCONSISTENT: ClassVar[LPStatusType] = ...
    OPTIMAL: ClassVar[LPStatusType] = ...
    STRUC_DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    STRUC_INCONSISTENT: ClassVar[LPStatusType] = ...
    UNBOUNDED: ClassVar[LPStatusType] = ...
    UNDECIDED: ClassVar[LPStatusType] = ...

class RepType(IntEnum):
    GENERATOR: ClassVar[RepType] = ...
    INEQUALITY: ClassVar[RepType] = ...
    UNSPECIFIED: ClassVar[RepType] = ...

class Matrix(Sequence[Sequence[Fraction]]):
    @property
    def col_size(self) -> int: ...
    @property
    def row_size(self) -> int: ...
    lin_set: Set[int]
    obj_func: Sequence[Fraction]
    obj_type: LPObjType
    rep_type: RepType

    def __init__(
        self, rows: Sequence[Sequence[Union[Fraction, int]]], linear: bool = False
    ) -> None: ...
    def canonicalize(self) -> None: ...
    def copy(self) -> "Matrix": ...
    def extend(
        self, rows: Sequence[Sequence[Union[Fraction, int]]], linear: bool = False
    ) -> None: ...
    @overload
    def __getitem__(self, index: int) -> Sequence[Fraction]: ...
    @overload
    def __getitem__(self, index: slice) -> Sequence[Sequence[Fraction]]: ...
    def __len__(self) -> int: ...

class LinProg:
    obj_type: LPObjType

    @property
    def dual_solution(self) -> Sequence[Fraction]: ...
    @property
    def obj_value(self) -> Fraction: ...
    @property
    def primal_solution(self) -> Sequence[Fraction]: ...
    @property
    def status(self) -> LPStatusType: ...
    @property
    def solver(self) -> LPSolverType: ...
    def __init__(self, mat: Matrix) -> None: ...
    def solve(self, solver: LPSolverType = LPSolverType.DUAL_SIMPLEX) -> None: ...

class Polyhedron:
    @property
    def rep_type(self) -> RepType: ...
    def __init__(self, mat: Matrix) -> None: ...
    def get_generators(self) -> Matrix: ...
    def get_inequalities(self) -> Matrix: ...
    def get_adjacency(self) -> Sequence[Set[int]]: ...
    def get_incidence(self) -> Sequence[Set[int]]: ...
    def get_input_adjacency(self) -> Sequence[Set[int]]: ...
    def get_input_incidence(self) -> Sequence[Set[int]]: ...
