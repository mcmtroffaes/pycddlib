import numpy as np
import numpy.typing as npt

import cdd


def test_issue20() -> None:
    arr: npt.NDArray[np.float16] = np.array(
        [[1, 0, 0], [1, 1, 0], [1, 0, 1]], dtype=np.float16
    )
    ref_ineq: npt.NDArray[np.float16] = np.array(
        [[1, -1, -1], [0, 1, 0], [0, 0, 1]], dtype=np.float16
    )
    mat = cdd.matrix_from_array(arr)  # type: ignore
    mat.rep = cdd.Rep.GENERATOR
    cdd_poly = cdd.polyhedron_from_matrix(mat)
    ineq = np.array(cdd.copy_inequalities(cdd_poly).array)
    assert ((ref_ineq - ineq) == 0).all()
