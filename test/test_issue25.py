import cdd


# check that empty polyhedron does not cause segfault
def test_issue25() -> None:
    mat = cdd.matrix_from_array([], rep_type=cdd.RepType.INEQUALITY)
    cdd.polyhedron_from_matrix(mat)
