import numpy as np
import numpy.typing as npt

import cdd


def test_issue20() -> None:
    arr: npt.NDArray[np.float64] = np.array(
        [[1, 0, 0], [1, 1, 0], [1, 0, 1]], dtype=np.float64
    )
    ref_ineq: npt.NDArray[np.float64] = np.array(
        [[1, -1, -1], [0, 1, 0], [0, 0, 1]], dtype=np.float64
    )
    mat = cdd.Matrix(arr)  # type: ignore
    mat.rep_type = cdd.RepType.GENERATOR
    cdd_poly = cdd.Polyhedron(mat)
    ineq = np.array(cdd_poly.get_inequalities())
    assert ((ref_ineq - ineq) == 0).all()
