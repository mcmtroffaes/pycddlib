import cdd


# this should not segfault
def test_issue35_2() -> None:
    mat = cdd.matrix_from_array([[0, 0, 0]], rep_type=cdd.RepType.INEQUALITY)
    cdd.matrix_redundancy_remove(mat)
