from fractions import Fraction

import cdd

from . import assert_matrix_almost_equal


def test_large_number() -> None:
    mat = cdd.matrix_from_array([[10**100, Fraction(10**100, 13**90)]])
    assert_matrix_almost_equal(mat.array, [[1e100, 0.556030087418433]])
