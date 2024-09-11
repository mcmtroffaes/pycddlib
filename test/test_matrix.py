from collections.abc import Set, Sequence
from fractions import Fraction

import pytest

import cdd

from . import assert_vector_almost_equal, assert_matrix_almost_equal


def test_matrix_init_1() -> None:
    rows = [[1.1, 1.2], [1.3, 1.4]]
    mat = cdd.Matrix(rows)
    assert_matrix_almost_equal(mat, rows)
    assert isinstance(mat.lin_set, Set)
    assert not mat.lin_set
    assert isinstance(mat.rep_type, cdd.RepType)
    assert mat.rep_type == cdd.RepType.UNSPECIFIED
    # FIXME assert isinstance(mat.obj_type, cdd.LPObjType)
    assert mat.obj_type == cdd.LPObjType.NONE
    assert isinstance(mat.obj_func, Sequence)
    assert_vector_almost_equal(mat.obj_func, [0.0, 0.0])


def test_matrix_init_2() -> None:
    rows = [[1.1, 1.2], [1.3, 1.4]]
    mat = cdd.Matrix(rows, linear=True)
    assert_matrix_almost_equal(mat, rows)
    assert mat.lin_set == {0, 1}


def test_length() -> None:
    with pytest.raises(ValueError):
        cdd.Matrix([[1], [1, 2]])


def test_obj_func() -> None:
    mat = cdd.Matrix([[1], [2]])
    with pytest.raises(ValueError):
        mat.obj_func = [0, 0]
    mat.obj_func = [7]
    assert_vector_almost_equal(mat.obj_func, [7.0])


def test_matrix_typing() -> None:
    cdd.Matrix([[1]])
    cdd.Matrix([[Fraction(1, 1)]])
    cdd.Matrix([[1.0]])
    with pytest.raises(TypeError, match="must be real number"):
        cdd.Matrix([["1"]])  # type: ignore


def test_matrix_extend_typing() -> None:
    mat: cdd.Matrix = cdd.Matrix([[1]])
    mat.extend([[1]])
    mat.extend([[Fraction(1, 1)]])
    mat.extend([[1.0]])
    with pytest.raises(TypeError, match="must be real number"):
        mat.extend([["1"]])  # type: ignore
