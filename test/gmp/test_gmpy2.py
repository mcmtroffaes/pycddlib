from collections.abc import Sequence
from test.gmp import assert_matrix_exactly_equal

from gmpy2 import mpq

import cdd
import cdd.gmp


def test_numpy() -> None:
    q0 = mpq(0)
    q1 = mpq(1)
    arr: Sequence[Sequence[mpq]] = [[q1, q0, q0], [q1, q1, q0], [q1, q0, q1]]
    ref_ineq: Sequence[Sequence[mpq]] = [[q1, -q1, -q1], [q0, q1, q0], [q0, q0, q1]]
    mat = cdd.gmp.matrix_from_array(arr)
    mat.rep_type = cdd.RepType.GENERATOR
    cdd_poly = cdd.gmp.polyhedron_from_matrix(mat)
    ineq = cdd.gmp.copy_inequalities(cdd_poly).array
    assert_matrix_exactly_equal(ref_ineq, ineq)
