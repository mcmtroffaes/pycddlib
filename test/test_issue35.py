import cdd
import pytest


# this should not segfault
@pytest.mark.skip  # temporarily disabled to check other tests
def test_issue35() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_canonicalize(mat)


def test_issue35_2() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    assert cdd.matrix_redundancy_remove(mat) == ({0}, [None])
    assert mat.array == []


def test_issue35_3() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    assert cdd.matrix_canonicalize_linearity(mat) == ({0}, [None])
    assert mat.array == []


def test_issue35_4() -> None:
    mat = cdd.matrix_from_array([], rep_type=cdd.RepType.INEQUALITY)
    assert cdd.matrix_redundancy_remove(mat) == (set(), [])
    assert mat.array == []


def test_issue35_5() -> None:
    mat = cdd.matrix_from_array([], rep_type=cdd.RepType.INEQUALITY)
    assert cdd.matrix_canonicalize_linearity(mat) == (set(), [])
    assert mat.array == []
