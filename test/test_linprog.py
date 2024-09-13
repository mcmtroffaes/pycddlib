from collections.abc import Sequence
from fractions import Fraction

import cdd

from . import assert_almost_equal, assert_vector_almost_equal


def test_lin_prog_type() -> None:
    # -0.5 + x >= 0,  2 - x >= 0
    mat = cdd.matrix_from_array([[-0.5, 1], [2, -1]])
    mat.rep_type = cdd.RepType.INEQUALITY
    mat.obj_type = cdd.LPObjType.MAX
    mat.obj_func = [2.0, -1.0]
    lp = cdd.LinProg(mat)
    assert isinstance(lp.status, cdd.LPStatusType)
    assert lp.status == cdd.LPStatusType.UNDECIDED
    assert isinstance(lp.obj_value, float)
    assert lp.obj_value == 0.0
    for xs in [lp.primal_solution, lp.dual_solution]:
        assert isinstance(xs, Sequence)
        for x in xs:
            assert isinstance(x, float)
            assert x == 0.0
    lp.solve(solver=cdd.LPSolverType.CRISS_CROSS)
    assert_almost_equal(lp.obj_value, 1.5)
    assert_vector_almost_equal(lp.primal_solution, [0.5])


def test_lp2() -> None:
    mat = cdd.matrix_from_array([[4 / 3, -2, -1], [2 / 3, 0, -1], [0, 1, 0], [0, 0, 1]])
    mat.obj_type = cdd.LPObjType.MAX
    mat.obj_func = (0, 3, 4)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert lp.status == cdd.LPStatusType.OPTIMAL
    assert_almost_equal(lp.obj_value, Fraction(11, 3))
    assert_vector_almost_equal(lp.primal_solution, (Fraction(1, 3), Fraction(2, 3)))
    assert_vector_almost_equal(lp.dual_solution, (Fraction(3, 2), Fraction(5, 2)))


def test_another() -> None:
    mat = cdd.matrix_from_array(
        [[1, -1, -1, -1], [-1, 1, 1, 1], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    )
    mat.obj_type = cdd.LPObjType.MIN
    mat.obj_func = (0, 1, 2, 3)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_almost_equal(lp.obj_value, 1)
    mat.obj_func = (0, -1, -2, -3)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_almost_equal(lp.obj_value, -3)
    mat.obj_func = (0, 1.12, 1.2, 1.3)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_almost_equal(lp.obj_value, Fraction(28, 25))
    assert_vector_almost_equal(lp.primal_solution, [1, 0, 0])
