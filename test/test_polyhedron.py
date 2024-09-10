from fractions import Fraction

from test_matrix import assert_matrix_almost_equal

import cdd


def test_sampleh1() -> None:
    mat = cdd.Matrix([[2, -1, -1, 0], [0, 1, 0, 0], [0, 0, 1, 0]])
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    ext = poly.get_generators()
    assert ext.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(
        ext, [[1, 0, 0, 0], [1, 2, 0, 0], [1, 0, 2, 0], [0, 0, 0, 1]]
    )
    # note: first row is 0, so fourth row is 3
    assert ext.lin_set == {3}


def test_testcdd2() -> None:
    mat = cdd.Matrix([[7, -3, -0], [7, 0, -3], [1, 1, 0], [1, 0, 1]])
    mat.rep_type = cdd.RepType.INEQUALITY
    assert_matrix_almost_equal(mat, [(7, -3, -0), (7, 0, -3), (1, 1, 0), (1, 0, 1)])
    gen = cdd.Polyhedron(mat).get_generators()
    assert gen.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(
        gen,
        [
            (1, Fraction(7, 3), -1),
            (1, -1, -1),
            (1, -1, Fraction(7, 3)),
            (1, Fraction(7, 3), Fraction(7, 3)),
        ],
    )
    # add an equality and an inequality
    mat.extend([[7, 1, -3]], linear=True)
    mat.extend([[7, -3, 1]])
    assert_matrix_almost_equal(
        mat,
        [(7, -3, -0), (7, 0, -3), (1, 1, 0), (1, 0, 1), (7, 1, -3), (7, -3, 1)],
    )
    assert mat.lin_set == {4}
    gen2 = cdd.Polyhedron(mat).get_generators()
    assert gen2.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(gen2, [(1, -1, 2), (1, 0, Fraction(7, 3))])
