from collections.abc import Sequence
from fractions import Fraction
from typing import Union

import cdd.gmp

arr: Sequence[Sequence[Union[Fraction, int]]] = [
    [-Fraction(1, 20), 0, 0, 1, 0],
    [Fraction(3, 2), 0, 0, -1, 0],
    [0, 0, -Fraction(1, 3), -Fraction(32, 30), -Fraction(2, 3)],
    [0, 0, 1, 0, 0],
    [0, 0, 0, 0, 1],
    [0, -1, 0, Fraction(3, 10), 1],
    [0, 1, Fraction(2, 3), Fraction(16, 30), Fraction(1, 3)],
    [0, 1, 0, 0, 0],
]


def test_empty_v_rep() -> None:
    mat = cdd.gmp.matrix_from_array(arr, rep_type=cdd.RepType.INEQUALITY)
    # check original system has no solution
    poly_orig = cdd.gmp.polyhedron_from_matrix(mat)
    v_rep_orig = cdd.gmp.copy_output(poly_orig)
    assert not v_rep_orig.array
    # check canonical form has no solution either
    lin_set, red_set, indices = cdd.gmp.matrix_canonicalize(mat)
    assert lin_set == {0, 1, 2, 3, 4, 5, 6, 7}
    assert not red_set
    assert indices == [0, 1, 2, 3, None, 4, None, None]
    assert mat.lin_set == {0, 1, 2, 3, 4}
    poly = cdd.gmp.polyhedron_from_matrix(mat)
    v_rep = cdd.gmp.copy_output(poly)
    assert not v_rep.array
