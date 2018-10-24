import cdd


# check that empty polyhedron does not cause segfault
def test_issue25():
    mat = cdd.Matrix([])
    cdd_poly = cdd.Polyhedron(mat)
