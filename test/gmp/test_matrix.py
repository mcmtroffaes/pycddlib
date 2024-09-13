from fractions import Fraction

import pytest

import cdd.gmp


def test_gmp_matrix_typing() -> None:
    cdd.gmp.Matrix([[1]])
    cdd.gmp.Matrix([[Fraction(1, 1)]])
    with pytest.raises(TypeError, match="is not Rational"):
        cdd.gmp.Matrix([[1.0]])  # type: ignore
    with pytest.raises(TypeError, match="is not Rational"):
        cdd.gmp.Matrix([["1"]])  # type: ignore
