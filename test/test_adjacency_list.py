import cdd


def test_make_vertex_adjacency_list() -> None:
    # The following lines test that cdd.copy_adjacency_list(poly)
    # returns the correct adjacencies.

    # We start with the H-representation for a cube
    mat = cdd.matrix_from_array(
        [
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, 0, 0, 1],
            [1, -1, 0, 0],
            [1, 0, -1, 0],
            [1, 0, 0, -1],
        ],
        rep=cdd.Rep.INEQUALITY,
    )
    assert mat.rep == cdd.Rep.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)
    assert poly.rep == cdd.Rep.INEQUALITY
    adjacency = cdd.copy_adjacency(poly)

    # Family size should equal the number of vertices of the cube (8)
    assert len(adjacency) == 8

    # All the vertices of the cube should be connected by three other vertices
    assert [len(adj) for adj in adjacency] == [3] * 8

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    adjacency_list = [
        {1, 3, 7},
        {0, 2, 6},
        {1, 3, 4},
        {0, 2, 5},
        {2, 5, 6},
        {3, 4, 7},
        {1, 4, 7},
        {0, 5, 6},
    ]
    assert adjacency == adjacency_list


def test_make_facet_adjacency_list() -> None:
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
        rep=cdd.Rep.INEQUALITY,
    )
    poly = cdd.polyhedron_from_matrix(mat)

    adjacency_list = [
        {1, 2, 3, 4, 6},
        {0, 2, 3, 5},
        {0, 1, 4, 5},
        {0, 1, 5, 6},
        {0, 2, 5, 6},
        {1, 2, 3, 4, 6},
        {0, 3, 4, 5},
    ]

    adjacency = cdd.copy_input_adjacency(poly)
    assert adjacency == adjacency_list
