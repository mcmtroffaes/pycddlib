from fractions import Fraction

import pytest

import cdd


def test_length() -> None:
    with pytest.raises(ValueError):
        cdd.Matrix([[1], [1, 2]])


def test_obj_func() -> None:
    mat = cdd.Matrix([[1], [2]])
    with pytest.raises(ValueError):
        mat.obj_func = (0, 0)


def test_matrix_typing() -> None:
    cdd.Matrix([[1]])
    cdd.Matrix([[Fraction(1, 1)]])
    cdd.Matrix([[1.0]])
    with pytest.raises(TypeError, match="must be real number"):
        cdd.Matrix([["1"]])  # type: ignore


def test_matrix_extend_typing() -> None:
    mat: cdd.Matrix = cdd.Matrix([[1]])
    mat.extend([[1]])
    mat.extend([[Fraction(1, 1)]])
    mat.extend([[1.0]])
    with pytest.raises(TypeError, match="must be real number"):
        mat.extend([["1"]])  # type: ignore
