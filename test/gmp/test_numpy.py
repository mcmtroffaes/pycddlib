import numpy as np
import numpy.typing as npt

import cdd.gmp


def test_numpy() -> None:
    arr: npt.NDArray[np.int32] = np.array(
        [[1, 0, 0], [1, 1, 0], [1, 0, 1]], dtype=np.int32
    )
    ref_ineq: npt.NDArray[np.int32] = np.array(
        [[1, -1, -1], [0, 1, 0], [0, 0, 1]], dtype=np.int32
    )
    mat = cdd.gmp.matrix_from_array(arr)  # type: ignore
    mat.rep_type = cdd.RepType.GENERATOR
    cdd_poly = cdd.polyhedron_from_matrix(mat)
    ineq = np.array(cdd.copy_inequalities(cdd_poly).array)
    assert ((ref_ineq - ineq) == 0).all()
