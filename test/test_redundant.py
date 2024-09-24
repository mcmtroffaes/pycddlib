from collections.abc import Sequence
from test import assert_vector_almost_equal
from typing import Optional

import pytest

import cdd


def assert_certificate_equal(
    certificate: Optional[Sequence[float]],
    exp_certificate: Optional[Sequence[float]],
) -> None:
    if exp_certificate is None:
        assert certificate is None
    else:
        assert certificate is not None
        assert_vector_almost_equal(certificate, exp_certificate)


def test_redundant_1() -> None:
    mat = cdd.matrix_from_array([[0]])
    with pytest.raises(ValueError, match="rep_type"):
        cdd.redundant(mat, 0)


def test_redundant_2() -> None:
    mat = cdd.matrix_from_array([[0]], rep_type=cdd.RepType.INEQUALITY)
    with pytest.raises(IndexError):
        cdd.redundant(mat, 1)


def test_redundant_3() -> None:
    mat = cdd.matrix_from_array([[0]], rep_type=cdd.RepType.INEQUALITY, lin_set={0})
    with pytest.raises(ValueError, match="row must not be in lin_set"):
        cdd.redundant(mat, 0)


def test_redundant_inequalities_2() -> None:
    # row 0: 0 <= 1 + x
    # row 1: 0 <= 3 + x
    mat = cdd.matrix_from_array([[1, 1], [3, 1]], rep_type=cdd.RepType.INEQUALITY)
    # x = -2 violates only row 0
    assert_certificate_equal(cdd.redundant(mat, 0), [-2])
    # x = -1 satisfies both rows
    assert_certificate_equal(cdd.redundant(mat, 1), None)


def test_redundant_inequalities_3() -> None:
    # row 0: 0 <= 1 + 2x + 3y
    # row 1: 0 <= 4 - x - 2y
    # row 2: 0 <= 5 + x + y (sum of row 0 and row 1)
    mat = cdd.matrix_from_array(
        [[1, 2, 3], [4, -1, -2], [5, 1, 1]], rep_type=cdd.RepType.INEQUALITY
    )
    # 0 > 1 - 26 + 24, 0 <= 4 + 13 - 16, 0 <= 5 - 13 + 8
    assert_certificate_equal(cdd.redundant(mat, 0), [-13, 8])
    # 0 <= 1 - 30 + 30, 0 > 4 + 15 - 20, 0 <= 5 - 15 + 10
    assert_certificate_equal(cdd.redundant(mat, 1), [-15, 10])
    # 0 <= 1 - 28 + 27, 0 <= 4 + 14 - 18, 0 <= 5 - 14 + 9
    assert_certificate_equal(cdd.redundant(mat, 2), None)


def test_redundant_inequalities_4() -> None:
    # row 0: 0 <= 1 + x
    # row 1: 0 <= 2 + 2x
    mat = cdd.matrix_from_array([[1, 1], [2, 2]], rep_type=cdd.RepType.INEQUALITY)
    assert_certificate_equal(cdd.redundant(mat, 0), None)
    assert_certificate_equal(cdd.redundant(mat, 1), None)
    assert_certificate_equal(cdd.s_redundant(mat, 0), [-1])
    assert_certificate_equal(cdd.s_redundant(mat, 1), [-1])


def test_redundant_generators_1() -> None:
    mat = cdd.matrix_from_array([[1, 1]], rep_type=cdd.RepType.GENERATOR, lin_set={0})
    with pytest.raises(ValueError, match="row must not be in lin_set"):
        cdd.redundant(mat, 0)


def test_redundant_generators_2() -> None:
    mat = cdd.matrix_from_array(
        [[1, 1], [1, 2], [1, 3]], rep_type=cdd.RepType.GENERATOR
    )
    assert_certificate_equal(cdd.redundant(mat, 0), [-2, 1])
    assert_certificate_equal(cdd.redundant(mat, 1), None)
    assert_certificate_equal(cdd.redundant(mat, 2), [2, -1])


def test_redundant_generators_3() -> None:
    mat = cdd.matrix_from_array(
        [[1, 1, 3], [1, 5, 1], [1, 3, 2]], rep_type=cdd.RepType.GENERATOR
    )
    assert_certificate_equal(cdd.redundant(mat, 0), [-1.5, 0.5, 0])
    assert_certificate_equal(cdd.redundant(mat, 1), [1.5, -0.5, 0])
    assert_certificate_equal(cdd.redundant(mat, 2), None)


def test_redundant_generators_4() -> None:
    mat = cdd.matrix_from_array(
        [[1, 2], [1, 2], [1, 4]], rep_type=cdd.RepType.GENERATOR
    )
    assert_certificate_equal(cdd.redundant(mat, 0), None)
    assert_certificate_equal(cdd.redundant(mat, 1), None)
    assert_certificate_equal(cdd.redundant(mat, 2), [1, -0.5])
    # TODO bug in cddlib... needs https://github.com/cddlib/cddlib/pull/73
    # assert_certificate_equal(cdd.s_redundant(mat, 0), [-1, 0.5])
    # assert_certificate_equal(cdd.s_redundant(mat, 1), [-1, 0.5])
    assert_certificate_equal(cdd.s_redundant(mat, 2), [1, -0.5])


def test_implicit_linearity_1() -> None:
    array = [[0, 1, 0], [0, 0, 1]]  # 0 <= x1, 0 <= x2
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    assert_certificate_equal(cdd.implicit_linearity(mat, 0), [1, 0])  # 0 < 1, 0 <= 0
    assert_certificate_equal(cdd.implicit_linearity(mat, 1), [0, 1])  # 0 <= 0, 0 < 1


def test_implicit_linearity_2() -> None:
    array = [[1, 2, 3], [-1, -2, -3]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    assert_certificate_equal(cdd.implicit_linearity(mat, 0), None)
    assert_certificate_equal(cdd.implicit_linearity(mat, 1), None)


def test_implicit_linearity_3() -> None:
    array = [[0, 1, 0], [0, -1, 0], [1, 1, 1]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.GENERATOR)
    assert_certificate_equal(cdd.implicit_linearity(mat, 0), None)
    assert_certificate_equal(cdd.implicit_linearity(mat, 1), None)
    assert_certificate_equal(cdd.implicit_linearity(mat, 2), [1, 0, 0])


def test_redundant_rows_1() -> None:
    array = [[1, 2], [1, 4], [1, 3], [0, -1]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    assert cdd.redundant_rows(mat) == {0, 2}
    assert cdd.s_redundant_rows(mat) == {0, 2}


def test_redundant_rows_2() -> None:
    array = [[1, 2, 1], [1, 2, 1], [1, 4, 1], [1, 3, 1], [0, 1, -3], [0, 2, -6]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    assert cdd.redundant_rows(mat) == {1, 3, 5}
    assert cdd.s_redundant_rows(mat) == set()


def test_redundant_rows_3() -> None:
    array = [[1, 2, 1], [1, 2, 1], [1, 4, 1], [1, 3, 1]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.GENERATOR)
    assert cdd.redundant_rows(mat) == {1, 3}
    assert cdd.s_redundant_rows(mat) == {3}
