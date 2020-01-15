import cdd
from fractions import Fraction
import pytest
from test_matrix import assert_almost_equal, assert_vector_almost_equal
from test_matrix import assert_exactly_equal, assert_vector_exactly_equal

@pytest.mark.parametrize(
    "number_type,assert_value_equal,assert_vector_equal",
    [("fraction", assert_exactly_equal, assert_vector_exactly_equal),
     ("float", assert_almost_equal, assert_vector_almost_equal)])
def test_lp2(number_type, assert_value_equal, assert_vector_equal):
    mat = cdd.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]],
                     number_type=number_type)
    mat.obj_type = cdd.LPObjType.MAX
    mat.obj_func = (0,3,4)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert lp.status == cdd.LPStatusType.OPTIMAL
    assert_value_equal(lp.obj_value, Fraction(11, 3))
    assert_vector_equal(lp.primal_solution, (Fraction(1, 3), Fraction(2, 3)))
    assert_vector_equal(lp.dual_solution, (Fraction(3, 2), Fraction(5, 2)))

@pytest.mark.parametrize(
    "number_type,assert_value_equal,assert_vector_equal",
    [("fraction", assert_exactly_equal, assert_vector_exactly_equal),
     ("float", assert_almost_equal, assert_vector_almost_equal)])
def test_another(number_type, assert_value_equal, assert_vector_equal):
    mat = cdd.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]], number_type=number_type)
    mat.obj_type = cdd.LPObjType.MIN
    mat.obj_func = (0,1,2,3)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_value_equal(lp.obj_value, 1)
    mat.obj_func = (0,-1,-2,-3)
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_value_equal(lp.obj_value, -3)
    mat.obj_func = (0,'1.12','1.2','1.3')
    lp = cdd.LinProg(mat)
    lp.solve()
    assert_value_equal(lp.obj_value, Fraction(28, 25))
    assert_vector_equal(lp.primal_solution, (1, 0, 0))
