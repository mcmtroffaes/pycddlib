import cdd


# check that empty polyhedron does not cause segfault
def test_issue25() -> None:
    mat = cdd.Matrix([])
    cdd.Polyhedron(mat)
