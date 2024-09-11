from fractions import Fraction

import cdd.gmp

from . import assert_matrix_exactly_equal


def test_gmp_large_number() -> None:
    mat = cdd.gmp.Matrix([[10**100, Fraction(10**100, 13**90)]])
    assert_matrix_exactly_equal(mat, [[10**100, Fraction(10**100, 13**90)]])
