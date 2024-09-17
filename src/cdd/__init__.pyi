import enum
from collections.abc import Container, Sequence, Set
from typing import ClassVar, Optional, SupportsFloat

Number = float
SupportsNumber = SupportsFloat

class LPObj(enum.IntEnum):
    MAX: ClassVar[LPObj] = ...
    MIN: ClassVar[LPObj] = ...
    NONE: ClassVar[LPObj] = ...

class LPSolver(enum.IntEnum):
    CRISS_CROSS: ClassVar[LPSolver] = ...
    DUAL_SIMPLEX: ClassVar[LPSolver] = ...

class LPStatus(enum.IntEnum):
    DUAL_INCONSISTENT: ClassVar[LPStatus] = ...
    DUAL_UNBOUNDED: ClassVar[LPStatus] = ...
    INCONSISTENT: ClassVar[LPStatus] = ...
    OPTIMAL: ClassVar[LPStatus] = ...
    STRUC_DUAL_INCONSISTENT: ClassVar[LPStatus] = ...
    STRUC_INCONSISTENT: ClassVar[LPStatus] = ...
    UNBOUNDED: ClassVar[LPStatus] = ...
    UNDECIDED: ClassVar[LPStatus] = ...

class LinProg:
    @property
    def array(self) -> Sequence[Sequence[Number]]: ...
    @property
    def dual_solution(self) -> Sequence[tuple[int, Number]]: ...
    @property
    def obj(self) -> LPObj: ...
    @obj.setter
    def obj(self, value: LPObj) -> None: ...
    @property
    def obj_value(self) -> Number: ...
    @property
    def primal_solution(self) -> Sequence[Number]: ...
    @property
    def status(self) -> LPStatus: ...
    @property
    def solver(self) -> LPSolver: ...

class Matrix:
    @property
    def array(self) -> Sequence[Sequence[Number]]: ...
    @property
    def lin_set(self) -> Set[int]: ...
    @lin_set.setter
    def lin_set(self, value: Container[int]) -> None: ...
    @property
    def obj_func(self) -> Sequence[Number]: ...
    @obj_func.setter
    def obj_func(self, value: Sequence[Number]) -> None: ...
    @property
    def obj(self) -> LPObj: ...
    @obj.setter
    def obj(self, value: LPObj) -> None: ...
    @property
    def rep(self) -> Rep: ...
    @rep.setter
    def rep(self, value: Rep) -> None: ...

class Polyhedron:
    @property
    def rep(self) -> Rep: ...

class Rep(enum.IntEnum):
    GENERATOR: ClassVar[Rep] = ...
    INEQUALITY: ClassVar[Rep] = ...
    UNSPECIFIED: ClassVar[Rep] = ...

class RowOrder(enum.IntEnum):
    LEX_MAX: ClassVar[RowOrder] = ...
    LEX_MIN: ClassVar[RowOrder] = ...
    MAX_CUTOFF: ClassVar[RowOrder] = ...
    MAX_INDEX: ClassVar[RowOrder] = ...
    MIN_CUTOFF: ClassVar[RowOrder] = ...
    MIN_INDEX: ClassVar[RowOrder] = ...
    MIX_CUTOFF: ClassVar[RowOrder] = ...
    RANDOM_ROW: ClassVar[RowOrder] = ...

def block_elimination(mat: Matrix, col_set: Container[int]) -> Matrix: ...
def copy_adjacency(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_generators(poly: Polyhedron) -> Matrix: ...
def copy_incidence(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_inequalities(poly: Polyhedron) -> Matrix: ...
def copy_input(poly: Polyhedron) -> Matrix: ...
def copy_input_adjacency(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_input_incidence(poly: Polyhedron) -> Sequence[Set[int]]: ...
def copy_output(poly: Polyhedron) -> Matrix: ...
def fourier_elimination(mat: Matrix) -> Matrix: ...
def linprog_from_array(
    array: Sequence[Sequence[SupportsNumber]], obj: LPObj
) -> LinProg: ...
def linprog_from_matrix(mat: Matrix) -> LinProg: ...
def linprog_solve(
    lp: LinProg, solver: LPSolver = LPSolver.DUAL_SIMPLEX
) -> None: ...
def matrix_append_to(mat1: Matrix, mat2: Matrix) -> None: ...
def matrix_canonicalize(mat: Matrix) -> tuple[Set[int], Set[int]]: ...
def matrix_copy(mat: Matrix) -> Matrix: ...
def matrix_from_array(
    array: Sequence[Sequence[SupportsNumber]],
    lin_set: Container[int] = (),
    rep: Rep = Rep.UNSPECIFIED,
    obj: LPObj = LPObj.NONE,
    obj_func: Optional[Sequence[SupportsNumber]] = None,
) -> Matrix: ...
def polyhedron_from_matrix(
    mat: Matrix, row_order_type: Optional[RowOrder] = None
) -> Polyhedron: ...
