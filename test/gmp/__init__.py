from collections.abc import Sequence
from fractions import Fraction
from typing import Union

Rational = Union[int, Fraction]


def assert_exactly_equal(x: Rational, y: Rational) -> None:
    assert x == y


def assert_vector_exactly_equal(
    vec1: Sequence[Rational], vec2: Sequence[Rational]
) -> None:
    assert list(vec1) == list(vec2)


def assert_matrix_exactly_equal(
    mat1: Sequence[Sequence[Rational]], mat2: Sequence[Sequence[Rational]]
) -> None:
    assert [list(row1) for row1 in mat1] == [list(row2) for row2 in mat2]
