from collections.abc import Sequence, Set
from enum import IntFlag
from typing import ClassVar, SupportsFloat, overload

class LPObjType(IntFlag):
    MAX: ClassVar[LPObjType] = ...
    MIN: ClassVar[LPObjType] = ...
    NONE: ClassVar[LPObjType] = ...

class LPSolverType(IntFlag):
    CRISS_CROSS: ClassVar[LPSolverType] = ...
    DUAL_SIMPLEX: ClassVar[LPSolverType] = ...

class LPStatusType(IntFlag):
    DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    DUAL_UNBOUNDED: ClassVar[LPStatusType] = ...
    INCONSISTENT: ClassVar[LPStatusType] = ...
    OPTIMAL: ClassVar[LPStatusType] = ...
    STRUC_DUAL_INCONSISTENT: ClassVar[LPStatusType] = ...
    STRUC_INCONSISTENT: ClassVar[LPStatusType] = ...
    UNBOUNDED: ClassVar[LPStatusType] = ...
    UNDECIDED: ClassVar[LPStatusType] = ...

class RepType(IntFlag):
    GENERATOR: ClassVar[RepType] = ...
    INEQUALITY: ClassVar[RepType] = ...
    UNSPECIFIED: ClassVar[RepType] = ...

class Matrix(Sequence[Sequence[float]]):
    @property
    def col_size(self) -> int: ...
    @property
    def row_size(self) -> int: ...
    lin_set: Set[int]
    obj_func: Sequence[float]
    obj_type: LPObjType
    rep_type: RepType

    def __init__(
        self, rows: Sequence[Sequence[SupportsFloat]], linear: bool = False
    ) -> None: ...
    def canonicalize(self) -> None: ...
    def copy(self) -> Matrix: ...
    def extend(
        self, rows: Sequence[Sequence[SupportsFloat]], linear: bool = False
    ) -> None: ...
    @overload
    def __getitem__(self, index: int) -> Sequence[float]: ...
    @overload
    def __getitem__(self, index: slice) -> Sequence[Sequence[float]]: ...
    def __len__(self) -> int: ...

class LinProg:
    obj_type: LPObjType

    @property
    def dual_solution(self) -> Sequence[float]: ...
    @property
    def obj_value(self) -> float: ...
    @property
    def primal_solution(self) -> Sequence[float]: ...
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
