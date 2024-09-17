import cdd


def test_fourier_elimination() -> None:
    # https://en.wikipedia.org/wiki/Fourier%E2%80%93Motzkin_elimination#Example
    array = [
        [10, -2, 5, -4],  # 2x-5y+4z<=10
        [9, -3, 6, -3],  # 3x-6y+3z<=9
        [-7, 1, -5, 2],  # -x+5y-2z<=-7
        [12, 3, -2, -6],  # -3x+2y+6z<=12
    ]
    mat1 = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    mat2 = cdd.fourier_elimination(mat1)
    assert mat2.array == [
        [-4 / 4, 0, -5 / 4],  # 5y<=-4
        [-1, -1, -1],  # x+y<=-1
        [-9 / 6, 6 / 6, -17 / 6],  # -6x+17y<=-9
    ]
