import pytest

import cdd

from . import assert_matrix_almost_equal


def test_matrix_canonicalize_1() -> None:
    array = [[1, 1], [2, 1]]  # 0 <= 1 + x, 0 <= 2 + x
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_canonicalize(mat)
    assert_matrix_almost_equal(mat.array, [[1, 1]])
    assert not mat.lin_set


def test_matrix_canonicalize_2() -> None:
    array = [[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]]
    mat = cdd.matrix_from_array(array)
    with pytest.raises(ValueError, match="rep_type unspecified"):
        cdd.matrix_canonicalize(mat)
    mat.rep_type = cdd.RepType.INEQUALITY
    assert cdd.matrix_canonicalize(mat) == ({1, 3}, {0}, [None, 0, 1, None])
    assert_matrix_almost_equal(mat.array, [[0, 1, 2, 3], [3, 0, 1, 2]])


def test_matrix_canonicalize_3() -> None:
    # test on an inconsistent system
    array = [[1, 1], [1, -1]]  # 0 = 1 + x, 0 = 1 - x
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY, lin_set={0, 1})
    assert cdd.matrix_canonicalize(mat) == (set(), set(), [0, 1])
    assert_matrix_almost_equal(mat.array, [[1, 1], [1, -1]])
    assert mat.lin_set == {0, 1}
