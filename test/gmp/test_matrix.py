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


def test_gmp_matrix_extend_typing() -> None:
    mat = cdd.gmp.Matrix([[Fraction(1, 1)]])
    mat.extend([[1]])
    mat.extend([[Fraction(1, 1)]])
    with pytest.raises(TypeError, match="is not Rational"):
        mat.extend([[1.0]])  # type: ignore
    with pytest.raises(TypeError, match="is not Rational"):
        mat.extend([["1"]])  # type: ignore
