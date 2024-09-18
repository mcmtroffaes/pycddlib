import cdd


def test_vertex_adjacency_1() -> None:
    # cube
    mat = cdd.matrix_from_array(
        [
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, 0, 0, 1],
            [1, -1, 0, 0],
            [1, 0, -1, 0],
            [1, 0, 0, -1],
        ],
        rep_type=cdd.RepType.INEQUALITY,
    )
    assert mat.rep_type == cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)
    assert poly.rep_type == cdd.RepType.INEQUALITY
    adjacency = cdd.copy_adjacency(poly)
    assert len(adjacency) == 8  # adjacency for each of 8 vertices
    assert [len(adj) for adj in adjacency] == [3] * 8  # each vertex has 3 neighbours
    expected_adjacency = [
        {1, 3, 7},
        {0, 2, 6},
        {1, 3, 4},
        {0, 2, 5},
        {2, 5, 6},
        {3, 4, 7},
        {1, 4, 7},
        {0, 5, 6},
    ]
    assert adjacency == expected_adjacency
    expected_input_adjacency = [
        {1, 2, 4, 5},
        {0, 2, 3, 5},
        {0, 1, 3, 4},
        {1, 2, 4, 5},
        {0, 2, 3, 5},
        {0, 1, 3, 4},
        set(),
    ]
    assert cdd.copy_input_adjacency(poly) == expected_input_adjacency
    assert cdd.matrix_adjacency(mat) == expected_input_adjacency[:-1]
    assert cdd.matrix_weak_adjacency(mat) == expected_input_adjacency[:-1]


def test_facet_adjacency_1() -> None:
    mat = cdd.matrix_from_array(
        [
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, -1, 0, 0],
            [1, 0, -1, 0],
            [0, 0, 0, 1],
            [1, 0, 0, 1],  # redundant
        ],
        rep_type=cdd.RepType.INEQUALITY,
    )
    poly = cdd.polyhedron_from_matrix(mat)
    assert cdd.copy_input_adjacency(poly) == [
        {1, 3, 4},
        {0, 2, 4},
        {1, 3, 4},
        {0, 2, 4},
        {0, 1, 2, 3},
        set(),
        set(),
    ]
    assert cdd.matrix_adjacency(mat) == [
        {1, 3, 4},
        {0, 2, 4},
        {1, 3, 4},
        {0, 2, 4},
        {0, 1, 2, 3},
        {4},
    ]
    assert cdd.matrix_weak_adjacency(mat) == [
        {1, 3, 4},
        {0, 2, 4},
        {1, 3, 4},
        {0, 2, 4},
        {0, 1, 2, 3},
        {0, 1, 2, 3, 4},
    ]


def test_facet_adjacency_2() -> None:
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.matrix_from_array(
        [
            [0, 0, 0, 1],
            [5, -4, -2, 1],
            [5, -2, -4, 1],
            [16, -8, 0, 1],
            [16, 0, -8, 1],
            [32, -8, -8, 1],
        ],
        rep_type=cdd.RepType.INEQUALITY,
    )
    poly = cdd.polyhedron_from_matrix(mat)
    expected_input_adjacency = [
        {1, 2, 3, 4, 6},
        {0, 2, 3, 5},
        {0, 1, 4, 5},
        {0, 1, 5, 6},
        {0, 2, 5, 6},
        {1, 2, 3, 4, 6},
        {0, 3, 4, 5},
    ]
    assert cdd.copy_input_adjacency(poly) == expected_input_adjacency
    expected_matrix_adjacency = [adj - {6} for adj in expected_input_adjacency[:-1]]
    assert cdd.matrix_adjacency(mat) == expected_matrix_adjacency
    assert cdd.matrix_weak_adjacency(mat) == expected_matrix_adjacency
