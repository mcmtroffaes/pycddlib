from fractions import Fraction

import pytest

import cdd.gmp


def test_gmp_matrix_typing() -> None:
    cdd.gmp.matrix_from_array([[1]])
    cdd.gmp.matrix_from_array([[Fraction(1, 1)]])
    with pytest.raises(
        AttributeError, match="'float' object has no attribute 'numerator'"
    ):
        cdd.gmp.matrix_from_array([[1.0]])  # type: ignore
    with pytest.raises(
        AttributeError, match="'str' object has no attribute 'numerator'"
    ):
        cdd.gmp.matrix_from_array([["1"]])  # type: ignore
