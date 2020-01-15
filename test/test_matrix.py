import cdd
import pytest
from fractions import Fraction

def assert_almost_equal(x, y):
    assert x == pytest.approx(y)

def assert_exactly_equal(x, y):
    assert x == y

def assert_vector_almost_equal(vec1, vec2):
    assert len(vec1) == len(vec2)
    for (entry1, entry2) in zip(vec1, vec2):
        assert entry1 == pytest.approx(entry2)

def assert_vector_exactly_equal(vec1, vec2):
    assert list(vec1) == list(vec2)

def assert_matrix_almost_equal(mat1, mat2):
    assert len(mat1) == len(mat2)
    for (row1, row2) in zip(mat1, mat2):
        assert_vector_almost_equal(row1, row2)

def assert_matrix_exactly_equal(mat1, mat2):
    assert list(mat1) == list(mat2)

def test_large_number_1():
    mat = cdd.Matrix([[10 ** 100]])
    assert_matrix_almost_equal(list(mat), [[1e+100]])

def test_large_number_2():
    mat = cdd.Matrix([[Fraction(10 ** 100, 13 ** 90)]], number_type='float')
    assert_matrix_almost_equal(list(mat), [[0.556030087418433]])

def test_large_number_3():
    mat = cdd.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000']], number_type='float')
    assert_matrix_almost_equal(list(mat), [[1e+100]])

def test_large_number_4():
    mat = cdd.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/17984638288961211871838956989189665890197130672912829203311075745019255958028927299020895173379216649']], number_type='float')
    assert_matrix_almost_equal(list(mat), [[0.556030087418433]])

def test_length():
    with pytest.raises(ValueError):
        mat = cdd.Matrix([[1], [1, 2]])

def test_obj_func():
    mat = cdd.Matrix([[1], [2]])
    with pytest.raises(ValueError):
        mat.obj_func = (0, 0)

