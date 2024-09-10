from fractions import Fraction

import cdd
import cdd.gmp

from .test_matrix import assert_matrix_almost_equal, assert_matrix_exactly_equal


def test_gmp_large_number() -> None:
    mat = cdd.gmp.Matrix([[10**100, Fraction(10**100, 13**90)]])
    assert_matrix_exactly_equal(mat, [[10**100, Fraction(10**100, 13**90)]])


def test_large_number() -> None:
    mat = cdd.Matrix([[10**100, Fraction(10**100, 13**90)]])
    assert_matrix_almost_equal(mat, [[1e100, 0.556030087418433]])
