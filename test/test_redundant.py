from collections.abc import Sequence
from test import assert_vector_almost_equal

import pytest

import cdd


def assert_redundant_equal(
    mat: cdd.Matrix, row: int, exp_is_redundant: bool, exp_certificate: Sequence[float]
) -> None:
    is_redundant, certificate = cdd.redundant(mat, row)
    assert is_redundant == exp_is_redundant
    assert_vector_almost_equal(certificate, exp_certificate)


def test_redundant_1() -> None:
    with pytest.raises(ValueError, match="rep_type"):
        cdd.redundant(cdd.matrix_from_array([[0]]), 0)


def test_redundant_inequalities_1() -> None:
    mat = cdd.matrix_from_array([[1, 1]], rep_type=cdd.RepType.INEQUALITY, lin_set={0})
    assert cdd.redundant(mat, 0) == (False, [0])


def test_redundant_inequalities_2() -> None:
    # row 0: 0 <= 1 + x
    # row 1: 0 <= 3 + x
    mat = cdd.matrix_from_array([[1, 1], [3, 1]], rep_type=cdd.RepType.INEQUALITY)
    # x = -2 violates only row 0
    assert_redundant_equal(mat, 0, False, [-2])
    # x = -1 satisfies both rows
    assert_redundant_equal(mat, 1, True, [-1])


def test_redundant_inequalities_3() -> None:
    # row 0: 0 <= 1 + 2x + 3y
    # row 1: 0 <= 4 - x - 2y
    # row 2: 0 <= 5 + x + y (sum of row 0 and row 1)
    mat = cdd.matrix_from_array(
        [[1, 2, 3], [4, -1, -2], [5, 1, 1]], rep_type=cdd.RepType.INEQUALITY
    )
    # 0 > 1 - 26 + 24, 0 <= 4 + 13 - 16, 0 <= 5 - 13 + 8
    assert_redundant_equal(mat, 0, False, [-13, 8])
    # 0 <= 1 - 30 + 30, 0 > 4 + 15 - 20, 0 <= 5 - 15 + 10
    assert_redundant_equal(mat, 1, False, [-15, 10])
    # 0 <= 1 - 28 + 27, 0 <= 4 + 14 - 18, 0 <= 5 - 14 + 9
    assert_redundant_equal(mat, 2, True, [-14, 9])
