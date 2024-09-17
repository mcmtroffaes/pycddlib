from collections.abc import Sequence, Set
from fractions import Fraction

import pytest

import cdd

from . import assert_matrix_almost_equal, assert_vector_almost_equal


def test_matrix_init_1() -> None:
    rows = [[1.1, 1.2, 1.3], [1.4, 1.5, 1.6]]
    mat = cdd.matrix_from_array(rows)
    assert isinstance(mat.array, Sequence)
    assert len(mat.array) == 2
    for row in mat.array:
        assert isinstance(row, Sequence)
        assert len(row) == 3
    assert_matrix_almost_equal(mat.array, rows)
    assert isinstance(mat.lin_set, Set)
    assert not mat.lin_set
    assert isinstance(mat.rep_type, cdd.RepType)
    assert mat.rep_type == cdd.RepType.UNSPECIFIED
    assert isinstance(mat.obj_type, cdd.LPObjType)
    assert mat.obj_type == cdd.LPObjType.NONE
    assert isinstance(mat.obj_func, Sequence)
    assert_vector_almost_equal(mat.obj_func, [0.0, 0.0, 0.0])


def test_matrix_init_2() -> None:
    array = [[1.1, 1.2], [1.3, 1.4]]
    mat = cdd.matrix_from_array(array, lin_set=[0, 1])
    assert_matrix_almost_equal(mat.array, array)
    assert mat.lin_set == {0, 1}


def test_length() -> None:
    with pytest.raises(ValueError):
        cdd.matrix_from_array([[1], [1, 2]])


def test_obj_func() -> None:
    mat = cdd.matrix_from_array([[1], [2]])
    with pytest.raises(ValueError):
        mat.obj_func = [0, 0]
    mat.obj_func = [7]
    assert_vector_almost_equal(mat.obj_func, [7.0])


def test_matrix_typing() -> None:
    cdd.matrix_from_array([[1]])
    cdd.matrix_from_array([[Fraction(1, 1)]])
    cdd.matrix_from_array([[1.0]])
    with pytest.raises(TypeError, match="must be real number"):
        cdd.matrix_from_array([["1"]])  # type: ignore


def test_matrix_various() -> None:
    mat = cdd.matrix_from_array([[1, 1]])  # 0 <= 1 + x
    cdd.matrix_append_to(mat, cdd.matrix_from_array([[2, 1]]))  # 0 <= 2 + x
    assert_matrix_almost_equal(mat.array, [[1, 1], [2, 1]])
    mat.rep_type = cdd.RepType.INEQUALITY
    cdd.matrix_canonicalize(mat)
    assert_matrix_almost_equal(mat.array, [[1, 1]])
    assert_matrix_almost_equal(cdd.matrix_copy(mat).array, [[1, 1]])


def test_doctest_1() -> None:
    # the doctest has the rational version of this, here we check the float variant
    array = [[1, 2], [3, 4]]
    mat1 = cdd.matrix_from_array(array)
    assert_matrix_almost_equal(mat1.array, array)
    cdd.matrix_append_to(mat1, cdd.matrix_from_array([[5, 6]]))
    assert_matrix_almost_equal(mat1.array, array + [[5, 6]])


def test_doctest_2() -> None:
    array = [[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]]
    mat = cdd.matrix_from_array(array)
    with pytest.raises(ValueError, match="rep_type unspecified"):
        cdd.matrix_canonicalize(mat)
    mat.rep_type = cdd.RepType.INEQUALITY
    assert cdd.matrix_canonicalize(mat) == ({1, 3}, {0})
    assert_matrix_almost_equal(mat.array, [[0, 1, 2, 3], [3, 0, 1, 2]])
