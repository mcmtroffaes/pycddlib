from fractions import Fraction

import cdd

from .test_matrix import assert_almost_equal, assert_vector_almost_equal


def test_lp2() -> None:
    mat = cdd.Matrix([[4 / 3, -2, -1], [2 / 3, 0, -1], [0, 1, 0], [0, 0, 1]])
    mat.obj_type = cdd.LPObjType.MAX
    mat.obj_func = (0, 3, 4)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert lp.status == cdd.LPStatusType.OPTIMAL
    assert_almost_equal(lp.obj_value, Fraction(11, 3))
    assert_vector_almost_equal(lp.primal_solution, (Fraction(1, 3), Fraction(2, 3)))
    assert_vector_almost_equal(lp.dual_solution, (Fraction(3, 2), Fraction(5, 2)))


def test_another() -> None:
    mat = cdd.Matrix(
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
