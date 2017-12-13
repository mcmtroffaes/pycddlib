import cdd
import numpy as np


def test_issue20():
    A = np.array([[1, 0, 0],
                  [1, 1, 0],
                  [1, 0, 1]])

    ref_ineq = np.array([[1, -1, -1],
                         [0, 1, 0],
                         [0, 0, 1]])

    mat = cdd.Matrix(A, number_type='fraction')
    mat.rep_type = cdd.RepType.GENERATOR

    cdd_poly = cdd.Polyhedron(mat)

    ineq = np.array(cdd_poly.get_inequalities())

    assert(((ref_ineq - ineq) == 0).all())
