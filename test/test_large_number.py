from fractions import Fraction
from numbers import Real, Rational

import cdd
import cdd.gmp
import pytest

from test_matrix import assert_matrix_exactly_equal, assert_matrix_almost_equal


@pytest.mark.parametrize(
    "number",
    [10 ** 100, Fraction(10 ** 100, 13 ** 90)]
)
def test_gmp_large_number(number: Rational) -> None:
    mat = cdd.gmp.Matrix([[number]])
    assert_matrix_exactly_equal(mat, [[number]])


@pytest.mark.parametrize(
    "number,expected",
    [(10 ** 100, 1e100), (Fraction(10 ** 100, 13 ** 90), 0.556030087418433)]
)
def test_large_number(number: Real, expected: float) -> None:
    mat = cdd.Matrix([[number]])
    assert_matrix_almost_equal(mat, [[expected]])
