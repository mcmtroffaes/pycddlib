from collections.abc import Container, Sequence, Set
from fractions import Fraction
from typing import Optional, Union

from cdd import LPObjType, LPSolverType, LPStatusType, RepType, RowOrderType

NumberType = Fraction
SupportsNumberType = Union[Fraction, int]

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
    array: Sequence[Sequence[SupportsNumberType]], obj_type: LPObjType
) -> LinProg: ...
def linprog_from_matrix(mat: Matrix) -> LinProg: ...
def linprog_solve(
    lp: LinProg, solver: LPSolverType = LPSolverType.DUAL_SIMPLEX
) -> None: ...
def matrix_adjacency(mat: Matrix) -> Sequence[Set[int]]: ...
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
def matrix_rank(
    mat: Matrix, ignored_rows: Container[int] = (), ignored_cols: Container[int] = ()
) -> tuple[Set[int], Set[int], int]: ...
def matrix_weak_adjacency(mat: Matrix) -> Sequence[Set[int]]: ...
def polyhedron_from_matrix(
    mat: Matrix, row_order: Optional[RowOrderType] = None
) -> Polyhedron: ...
def redundant(
    mat: Matrix, row: int, strong: bool = False
) -> tuple[bool, Sequence[NumberType]]: ...
