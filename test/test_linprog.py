from collections.abc import Sequence
from typing import Optional

import pytest

from cdd import (
    LPObj,
    LPSolver,
    LPStatus,
    Rep,
    linprog_from_array,
    linprog_from_matrix,
    linprog_solve,
    matrix_from_array,
)

from . import (
    assert_almost_equal,
    assert_matrix_almost_equal,
    assert_vector_almost_equal,
)


def test_lin_prog_type() -> None:
    # max 2 - x subject to -0.5 + x >= 0,  2 - x >= 0
    array: Sequence[Sequence[float]] = [[-0.5, 1], [2, -1], [2, -1]]
    lp = linprog_from_array(array, obj=LPObj.MAX)
    assert_matrix_almost_equal(lp.array, array)
    assert isinstance(lp.status, LPStatus)
    assert lp.status == LPStatus.UNDECIDED
    assert isinstance(lp.solver, LPSolver)
    assert lp.solver == LPSolver.DUAL_SIMPLEX
    assert isinstance(lp.obj_value, float)
    assert lp.obj_value == 0.0
    assert isinstance(lp.primal_solution, Sequence)
    for x in lp.primal_solution:
        assert isinstance(x, float)
        assert x == 0.0
    assert isinstance(lp.dual_solution, Sequence)
    assert not lp.dual_solution  # no variables in basis...
    linprog_solve(lp, solver=LPSolver.CRISS_CROSS)
    assert lp.solver == LPSolver.CRISS_CROSS
    assert_almost_equal(lp.obj_value, 1.5)
    assert_vector_almost_equal(lp.primal_solution, [0.5])
    assert_matrix_almost_equal(lp.dual_solution, [(0, 1.0)])


def test_lp2() -> None:
    array: Sequence[Sequence[float]] = [
        [4 / 3, -2, -1],
        [2 / 3, 0, -1],
        [0, 1, 0],
        [0, 0, 1],
        [0, 3, 4],  # objective function
    ]
    lp = linprog_from_array(array, obj=LPObj.MAX)
    linprog_solve(lp)
    assert lp.status == LPStatus.OPTIMAL
    assert_almost_equal(lp.obj_value, 11 / 3)
    assert_vector_almost_equal(lp.primal_solution, [1 / 3, 2 / 3])
    assert_matrix_almost_equal(lp.dual_solution, [(0, 3 / 2), (1, 5 / 2)])
    assert_matrix_almost_equal(lp.array, array)


def test_linprog_from_matrix() -> None:
    array = [[1, -1, -1, -1], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    lin_set = [0]
    obj_func = [0, 1, 2, 3]
    mat = matrix_from_array(
        array=array,
        lin_set=lin_set,
        obj=LPObj.MIN,
        obj_func=obj_func,
        rep=Rep.INEQUALITY,
    )
    lp = linprog_from_matrix(mat)
    assert_matrix_almost_equal(
        lp.array, array + [[-x for x in array[i]] for i in lin_set] + [mat.obj_func]
    )
    linprog_solve(lp)
    assert_almost_equal(lp.obj_value, 1)
    mat.obj_func = [0, -1, -2, -3]
    lp = linprog_from_matrix(mat)
    linprog_solve(lp)
    assert_almost_equal(lp.obj_value, -3)
    mat.obj_func = [0, 1.12, 1.2, 1.3]
    lp = linprog_from_matrix(mat)
    linprog_solve(lp)
    assert_almost_equal(lp.obj_value, 1.12)
    assert_vector_almost_equal(lp.primal_solution, [1, 0, 0])
    assert_matrix_almost_equal(lp.dual_solution, [(3, -0.18), (4, -1.12), (2, -0.08)])


def test_linprog_bad_obj() -> None:
    with pytest.raises(ValueError, match="obj must be MIN or MAX"):
        linprog_from_array([[1, 1], [1, 1]], obj=LPObj.NONE)


@pytest.mark.parametrize(
    "array,obj,status,primal_solution",
    [
        # 0 <= -2 + x, 0 <= 3 - x, obj func 0 + x
        ([[-2, 1], [3, -1], [0, 1]], LPObj.MIN, LPStatus.OPTIMAL, (2,)),
        ([[-2, 1], [3, -1], [0, 1]], LPObj.MAX, LPStatus.OPTIMAL, (3,)),
        # 0 <= 5 + x, obj func 0 + x
        ([[5, 1], [0, 1]], LPObj.MIN, LPStatus.OPTIMAL, (-5,)),
        ([[5, 1], [0, 1]], LPObj.MAX, LPStatus.DUAL_INCONSISTENT, None),
        # 0 <= x, 0 <= -1 - x, obj func 0 + x
        ([[0, 1], [-1, -1], [0, 1]], LPObj.MIN, LPStatus.INCONSISTENT, None),
        ([[0, 1], [-1, -1], [0, 1]], LPObj.MAX, LPStatus.INCONSISTENT, None),
        # corner case where constraints contain no variables
        # primal: max x s.t. 0 <= 1 -> unbounded
        # dual:   min y s.t. 0 >= 1 -> inconsistent
        ([[1, 0], [0, 1]], LPObj.MIN, LPStatus.STRUC_DUAL_INCONSISTENT, None),
        ([[1, 0], [0, 1]], LPObj.MAX, LPStatus.STRUC_DUAL_INCONSISTENT, None),
        # https://math.stackexchange.com/a/4864771
        # corner case where both primal and dual are inconsistent
        # primal: max x  s.t. 0 <= -1 -> inconsistent
        # dual:   min -y s.t. 0 >= 1  -> inconsistent
        ([[-1, 0], [0, 1]], LPObj.MAX, LPStatus.STRUC_DUAL_INCONSISTENT, None),
        ([[-1, 0], [0, -1]], LPObj.MIN, LPStatus.STRUC_DUAL_INCONSISTENT, None),
        # corner case where everything is zero
        # primal: max 0x s.t. 0 <= 0 -> optimal
        # dual:   min 0y s.t. 0 >= 0 -> optimal
        ([[0, 0], [0, 0]], LPObj.MAX, LPStatus.OPTIMAL, None),
        ([[0, 0], [0, 0]], LPObj.MIN, LPStatus.OPTIMAL, None),
    ],
)
def test_linprog_1(
    array: Sequence[Sequence[float]],
    obj: LPObj,
    status: LPStatus,
    primal_solution: Optional[Sequence[float]],
) -> None:
    lp = linprog_from_array(array, obj=obj)
    linprog_solve(lp)
    assert lp.status == status
    if primal_solution is not None:
        assert_vector_almost_equal(lp.primal_solution, primal_solution)
