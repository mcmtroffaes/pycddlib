import cdd
import numpy as np


def test_issue20():
    arr = np.array([[1, 0, 0],
                    [1, 1, 0],
                    [1, 0, 1]])

    ref_ineq = np.array([[1, -1, -1],
                         [0, 1, 0],
                         [0, 0, 1]])

    mat = cdd.Matrix(arr)
    mat.rep_type = cdd.RepType.GENERATOR
    assert mat.number_type == 'fraction'

    cdd_poly = cdd.Polyhedron(mat)

    ineq = np.array(cdd_poly.get_inequalities())

    assert ((ref_ineq - ineq) == 0).all()
