import cdd
import pytest
from fractions import Fraction
from test_matrix import assert_matrix_almost_equal, assert_matrix_exactly_equal

@pytest.mark.parametrize(
    "number_type,assert_matrix_equal",
    [("fraction", assert_matrix_exactly_equal),
     ("float", assert_matrix_almost_equal)])
def test_sampleh1(number_type, assert_matrix_equal):
    mat = cdd.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    ext = poly.get_generators()
    assert ext.rep_type == cdd.RepType.GENERATOR
    assert_matrix_equal(
        list(ext),
        [(1, 0, 0, 0), (1, 2, 0, 0), (1, 0, 2, 0), (0, 0, 0, 1)])
    # note: first row is 0, so fourth row is 3
    assert list(ext.lin_set) == [3]

@pytest.mark.parametrize(
    "number_type,assert_matrix_equal",
    [("fraction", assert_matrix_exactly_equal),
     ("float", assert_matrix_almost_equal)])
def test_testcdd2(number_type, assert_matrix_equal):
    mat = cdd.Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    assert_matrix_equal(
        list(mat), [(7,-3,-0),(7,0,-3),(1,1,0),(1,0,1)])
    gen = cdd.Polyhedron(mat).get_generators()
    assert gen.rep_type == cdd.RepType.GENERATOR
    assert_matrix_equal(
        list(gen),
        [(1, Fraction(7, 3), -1),
         (1, -1, -1,),
         (1, -1, Fraction(7, 3)),
         (1, Fraction(7, 3), Fraction(7, 3))])
    # add an equality and an inequality
    mat.extend([[7, 1, -3]], linear=True)
    mat.extend([[7, -3, 1]])
    assert_matrix_equal(
        list(mat), [(7,-3,-0),(7,0,-3),(1,1,0),(1,0,1),(7,1,-3),(7,-3,1)])
    assert list(mat.lin_set) == [4]
    gen2 = cdd.Polyhedron(mat).get_generators()
    assert gen2.rep_type == cdd.RepType.GENERATOR
    assert_matrix_equal(
        list(gen2),
        [(1, -1, 2), (1, 0, Fraction(7, 3))])
