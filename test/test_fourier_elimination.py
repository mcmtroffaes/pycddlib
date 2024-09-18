import pytest

import cdd

from . import assert_matrix_almost_equal


def test_fourier_elimination_1() -> None:
    # 0 <= 1 + x + y, 0 <= 1 + 3x - y
    array = [[1, 1, 1], [1, 3, -1]]
    mat1 = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    mat2 = cdd.fourier_elimination(mat1)
    # 0 <= 1 + 2x
    assert_matrix_almost_equal(mat2.array, [[1, 2]])
    assert mat2.lin_set == set()


def test_fourier_elimination_2() -> None:
    # https://en.wikipedia.org/wiki/Fourier%E2%80%93Motzkin_elimination#Example
    array = [
        [10, -2, 5, -4],  # 2x-5y+4z<=10
        [9, -3, 6, -3],  # 3x-6y+3z<=9
        [-7, 1, -5, 2],  # -x+5y-2z<=-7
        [12, 3, -2, -6],  # -3x+2y+6z<=12
    ]
    mat1 = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    mat2 = cdd.fourier_elimination(mat1)
    assert_matrix_almost_equal(
        mat2.array,
        [
            [-4 / 4, 0, -5 / 4],  # 5y<=-4
            [-1, -1, -1],  # x+y<=-1
            [-9 / 6, 6 / 6, -17 / 6],  # -6x+17y<=-9
        ],
    )


def test_fourier_elimination_3() -> None:
    array = [[1, 1, 1]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY, lin_set=[0])
    with pytest.raises(RuntimeError, match="cannot handle linearity"):
        cdd.fourier_elimination(mat)
