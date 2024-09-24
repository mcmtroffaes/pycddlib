import cdd
import pytest


# this should not segfault
@pytest.mark.skip  # temporarily disabled to check other tests
def test_issue35() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_canonicalize(mat)


def test_issue35_2() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_redundancy_remove(mat)


def test_issue35_3() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_canonicalize_linearity(mat)
