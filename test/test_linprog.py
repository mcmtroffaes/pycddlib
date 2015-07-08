import cdd
import nose
from fractions import Fraction
from test_matrix import assert_vector_almost_equal

def _test_lp2(number_type=None,
              assert_value_equal=None, assert_vector_equal=None):
    mat = cdd.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]],
                     number_type=number_type)
    mat.obj_type = cdd.LPObjType.MAX
    mat.obj_func = (0,3,4)
    lp = cdd.LinProg(mat)
    lp.solve()
    nose.tools.assert_equal(lp.status, cdd.LPStatusType.OPTIMAL)
    assert_value_equal(lp.obj_value, Fraction(11, 3))
    assert_vector_equal(lp.primal_solution, (Fraction(1, 3), Fraction(2, 3)))
    assert_vector_equal(lp.dual_solution, (Fraction(3, 2), Fraction(5, 2)))

def _test_another(number_type=None,
                  assert_value_equal=None, assert_vector_equal=None):
    mat = cdd.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]], number_type='fraction')
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

def test_fraction_lp2():
    _test_lp2('fraction', nose.tools.assert_equal, nose.tools.assert_equal)

def test_float_lp2():
    _test_lp2('float', nose.tools.assert_almost_equal, assert_vector_almost_equal)

def test_fraction_another():
    _test_another('fraction', nose.tools.assert_equal, nose.tools.assert_equal)

def test_float_another():
    _test_another('float', nose.tools.assert_almost_equal, assert_vector_almost_equal)
