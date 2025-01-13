import cdd

arr = [
    [-0.05, -0.0, -0.0, 1.0, -0.0],
    [1.5, -0.0, -0.0, -1.0, -0.0],
    [0.0, -0.0, -0.3333333333333333, -1.0666666666666667, -0.6666666666666666],
    [0.0, -0.0, 1.0, -0.0, -0.0],
    [0.0, -0.0, -0.0, -0.0, 1.0],
    [0.0, -1.0, -0.0, 0.3, 1.0],
    [0.0, 1.0, 0.6666666666666666, 0.5333333333333333, 0.3333333333333333],
    [0.0, 1.0, -0.0, -0.0, -0.0],
]


def test_empty_v_rep() -> None:
    mat = cdd.matrix_from_array(arr, rep_type=cdd.RepType.INEQUALITY)
    lin_set, red_set, indices = cdd.matrix_canonicalize(mat)
    assert lin_set == {0, 1, 2, 3, 4, 5, 6, 7}
    assert not red_set
    assert indices == [0, 1, 2, 3, None, 4, None, None]
    assert mat.lin_set == {0, 1, 2, 3, 4}
    poly = cdd.polyhedron_from_matrix(mat)
    v_rep = cdd.copy_output(poly)
    assert not v_rep.array
