from collections.abc import Sequence
from fractions import Fraction

import cdd

from . import (
    assert_almost_equal,
    assert_matrix_almost_equal,
    assert_vector_almost_equal,
)


def test_lin_prog_type() -> None:
    # max 2 - x subject to -0.5 + x >= 0,  2 - x >= 0
    array: Sequence[Sequence[float]] = [[-0.5, 1], [2, -1], [2, -1]]
    lp = cdd.linprog_from_array(array, obj_type=cdd.LPObjType.MAX)
    assert_matrix_almost_equal(lp.array, array)
    assert isinstance(lp.status, cdd.LPStatusType)
    assert lp.status == cdd.LPStatusType.UNDECIDED
    assert isinstance(lp.solver, cdd.LPSolverType)
    assert lp.solver == cdd.LPSolverType.DUAL_SIMPLEX
    assert isinstance(lp.obj_value, float)
    assert lp.obj_value == 0.0
    assert isinstance(lp.primal_solution, Sequence)
    for x in lp.primal_solution:
        assert isinstance(x, float)
        assert x == 0.0
    assert isinstance(lp.dual_solution, Sequence)
    assert not lp.dual_solution  # no variables in basis...
    cdd.linprog_solve(lp, solver=cdd.LPSolverType.CRISS_CROSS)
    assert lp.solver == cdd.LPSolverType.CRISS_CROSS
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
    lp = cdd.linprog_from_array(array, obj_type=cdd.LPObjType.MAX)
    cdd.linprog_solve(lp)
    assert lp.status == cdd.LPStatusType.OPTIMAL
    assert_almost_equal(lp.obj_value, 11 / 3)
    assert_vector_almost_equal(lp.primal_solution, [1 / 3, 2 / 3])
    assert_matrix_almost_equal(lp.dual_solution, [(0, 3 / 2), (1, 5 / 2)])
    assert_matrix_almost_equal(lp.array, array)


def test_linprog_from_matrix() -> None:
    array = [[1, -1, -1, -1], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    lin_set = [0]
    obj_func = [0, 1, 2, 3]
    mat = cdd.matrix_from_array(array=array, lin_set=lin_set)
    mat.obj_type = cdd.LPObjType.MIN
    mat.obj_func = obj_func
    mat.rep_type = cdd.RepType.INEQUALITY
    lp = cdd.linprog_from_matrix(mat)
    assert_matrix_almost_equal(
        lp.array, array + [[-x for x in array[i]] for i in lin_set] + [mat.obj_func]
    )
    cdd.linprog_solve(lp)
    assert_almost_equal(lp.obj_value, 1)
    mat.obj_func = (0, -1, -2, -3)
    lp = cdd.linprog_from_matrix(mat)
    cdd.linprog_solve(lp)
    assert_almost_equal(lp.obj_value, -3)
    mat.obj_func = (0, 1.12, 1.2, 1.3)
    lp = cdd.linprog_from_matrix(mat)
    cdd.linprog_solve(lp)
    assert_almost_equal(lp.obj_value, Fraction(28, 25))
    assert_vector_almost_equal(lp.primal_solution, [1, 0, 0])
    assert_matrix_almost_equal(lp.dual_solution, [(3, -0.18), (4, -1.12), (2, -0.08)])
