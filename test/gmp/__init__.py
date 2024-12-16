from collections.abc import Iterable
from typing import Any, Protocol


class Rational(Protocol):
    @property
    def numerator(self) -> int: ...
    @property
    def denominator(self) -> int: ...
    def __eq__(self, other: Any) -> bool: ...


def assert_exactly_equal(x: Rational, y: Rational) -> None:
    assert x == y


def assert_vector_exactly_equal(
    vec1: Iterable[Rational], vec2: Iterable[Rational]
) -> None:
    assert list(vec1) == list(vec2)


def assert_matrix_exactly_equal(
    mat1: Iterable[Iterable[Rational]], mat2: Iterable[Iterable[Rational]]
) -> None:
    assert [list(row1) for row1 in mat1] == [list(row2) for row2 in mat2]
