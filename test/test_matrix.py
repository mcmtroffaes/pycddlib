import cdd
import nose
from fractions import Fraction

def assert_almost_equal(mat1, mat2):
    nose.tools.assert_equal(len(mat1), len(mat2))
    for (row1, row2) in zip(mat1, mat2):
        nose.tools.assert_equal(len(row1), len(row2))
        for (entry1, entry2) in zip(row1, row2):
            nose.tools.assert_almost_equal(entry1, entry2)

def test_large_number_1():
    mat = cdd.Matrix([[10 ** 100]])
    assert_almost_equal(list(mat), [[1e+100]])

def test_large_number_2():
    mat = cdd.Matrix([[Fraction(10 ** 100, 13 ** 90)]], number_type='float')
    assert_almost_equal(list(mat), [[0.556030087418433]])

def test_large_number_3():
    mat = cdd.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000']], number_type='float')
    assert_almost_equal(list(mat), [[1e+100]])

def test_large_number_4():
    mat = cdd.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/17984638288961211871838956989189665890197130672912829203311075745019255958028927299020895173379216649']], number_type='float')
    assert_almost_equal(list(mat), [[0.556030087418433]])

@nose.tools.raises(ValueError)
def test_length():
    mat = cdd.Matrix([[1], [1, 2]])

@nose.tools.raises(ValueError)
def test_obj_func():
    mat = cdd.Matrix([[1], [2]])
    mat.obj_func = (0, 0)

