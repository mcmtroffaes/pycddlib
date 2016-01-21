import cdd

def test_set_float_polyhedron_rep_type():
    mat = cdd.Matrix([[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]],
                     number_type='float')
    mat.rep_type = cdd.RepType.GENERATOR

    poly = cdd.Polyhedron(mat)

    poly.rep_type = cdd.RepType.INEQUALITY
    assert(poly.rep_type == cdd.RepType.INEQUALITY)
    poly.rep_type = cdd.RepType.GENERATOR
    assert(poly.rep_type == cdd.RepType.GENERATOR)

def test_set_frac_polyhedron_rep_type():
    mat = cdd.Matrix([[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]],
                     number_type='fraction')
    mat.rep_type = cdd.RepType.GENERATOR

    poly = cdd.Polyhedron(mat)

    poly.rep_type = cdd.RepType.INEQUALITY
    assert(poly.rep_type == cdd.RepType.INEQUALITY)
    poly.rep_type = cdd.RepType.GENERATOR
    assert(poly.rep_type == cdd.RepType.GENERATOR)
