from collections.abc import Sequence
from fractions import Fraction
from typing import Union

import pytest

import cdd

# https://peps.python.org/pep-0484/#the-numeric-tower
# numbers.Real is broken with mypy
Real = Union[float, Fraction]


def assert_almost_equal(x: Real, y: Real) -> None:
    assert x == pytest.approx(y)


def assert_exactly_equal(x: Real, y: Real) -> None:
    assert x == y


def assert_vector_almost_equal(vec1: Sequence[Real], vec2: Sequence[Real]) -> None:
    assert list(vec1) == pytest.approx(list(vec2))


def assert_vector_exactly_equal(vec1: Sequence[Real], vec2: Sequence[Real]) -> None:
    assert list(vec1) == list(vec2)


def assert_matrix_almost_equal(
    mat1: Sequence[Sequence[Real]], mat2: Sequence[Sequence[Real]]
) -> None:
    assert len(mat1) == len(mat2)
    for row1, row2 in zip(mat1, mat2):
        assert_vector_almost_equal(row1, row2)


def assert_matrix_exactly_equal(
    mat1: Sequence[Sequence[Real]], mat2: Sequence[Sequence[Real]]
) -> None:
    assert [list(row1) for row1 in mat1] == [list(row2) for row2 in mat2]


def test_length() -> None:
    with pytest.raises(ValueError):
        cdd.Matrix([[1], [1, 2]])


def test_obj_func() -> None:
    mat = cdd.Matrix([[1], [2]])
    with pytest.raises(ValueError):
        mat.obj_func = (0, 0)
