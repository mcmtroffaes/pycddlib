import cdd


def test_set_float_polyhedron_rep_type():
    mat = cdd.Matrix([[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]])
    mat.rep_type = cdd.RepType.GENERATOR

    poly = cdd.Polyhedron(mat)

    poly.rep_type = cdd.RepType.INEQUALITY
    assert poly.rep_type == cdd.RepType.INEQUALITY
    poly.rep_type = cdd.RepType.GENERATOR
    assert poly.rep_type == cdd.RepType.GENERATOR


def test_set_frac_polyhedron_rep_type():
    mat = cdd.Matrix([[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]])
    mat.rep_type = cdd.RepType.GENERATOR

    poly = cdd.Polyhedron(mat)

    poly.rep_type = cdd.RepType.INEQUALITY
    assert poly.rep_type == cdd.RepType.INEQUALITY
    poly.rep_type = cdd.RepType.GENERATOR
    assert poly.rep_type == cdd.RepType.GENERATOR
