import cdd
import nose
from fractions import Fraction

def assert_almost_equal(mat1, mat2):
    nose.tools.assert_equal(len(mat1), len(mat2))
    for (row1, row2) in zip(mat1, mat2):
        nose.tools.assert_equal(len(row1), len(row2))
        for (entry1, entry2) in zip(row1, row2):
            nose.tools.assert_almost_equal(entry1, entry2)

def _test_sampleh1(number_type=None, assert_matrix_equal=None):
    mat = cdd.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    ext = poly.get_generators()
    nose.tools.assert_equal(ext.rep_type, cdd.RepType.GENERATOR)
    assert_matrix_equal(
        list(ext),
        [(1, 0, 0, 0), (1, 2, 0, 0), (1, 0, 2, 0), (0, 0, 0, 1)])
    # note: first row is 0, so fourth row is 3
    nose.tools.assert_list_equal(list(ext.lin_set), [3])

def _test_testcdd2(number_type=None, assert_matrix_equal=None):
    mat = cdd.Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    assert_matrix_equal(
        list(mat), [(7,-3,-0),(7,0,-3),(1,1,0),(1,0,1)])
    gen = cdd.Polyhedron(mat).get_generators()
    nose.tools.assert_equal(gen.rep_type, cdd.RepType.GENERATOR)
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
    nose.tools.assert_list_equal(list(mat.lin_set), [4])
    gen2 = cdd.Polyhedron(mat).get_generators()
    nose.tools.assert_equal(gen2.rep_type, cdd.RepType.GENERATOR)
    assert_matrix_equal(
        list(gen2),
        [(1, -1, 2), (1, 0, Fraction(7, 3))])

def test_fraction_sampleh1():
    _test_sampleh1('fraction', nose.tools.assert_list_equal) 

def test_float_sampleh1():
    _test_sampleh1('float', assert_almost_equal)

def test_fraction_testcdd2():
    _test_testcdd2('fraction', nose.tools.assert_list_equal) 

def test_float_testcdd2():
    _test_testcdd2('float', assert_almost_equal)
