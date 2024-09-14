import cdd


def test_vertex_incidence_cube() -> None:
    # The following lines test that cdd.copy_vertex_incidence(poly)
    # returns the correct incidences.

    # We start with the H-representation for a cube
    mat = cdd.matrix_from_array(
        [
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, 0, 0, 1],
            [1, -1, 0, 0],
            [1, 0, -1, 0],
            [1, 0, 0, -1],
        ]
    )
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)
    incidence = cdd.copy_incidence(poly)

    # Family size should equal the number of vertices of the cube (8)
    assert len(incidence) == 8

    # All the vertices of the cube should mark the incidence of 3 facets
    assert [len(inc) for inc in incidence] == [3] * 8

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    incidence_list = [
        {1, 2, 3},
        {1, 3, 5},
        {3, 4, 5},
        {2, 3, 4},
        {0, 4, 5},
        {0, 2, 4},
        {0, 1, 5},
        {0, 1, 2},
    ]
    assert incidence == incidence_list


def test_vertex_incidence_vtest_vo() -> None:
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.matrix_from_array(
        [
            [0, 0, 0, 1],
            [5, -4, -2, 1],
            [5, -2, -4, 1],
            [16, -8, 0, 1],
            [16, 0, -8, 1],
            [32, -8, -8, 1],
        ]
    )

    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)

    incidence_list = [
        {0, 4, 6},
        {0, 2, 4},
        {0, 1, 2},
        {0, 1, 3},
        {0, 3, 6},
        {1, 2, 5},
        {1, 3, 5},
        {3, 5, 6},
        {4, 5, 6},
        {2, 4, 5},
    ]

    incidence = cdd.copy_incidence(poly)
    assert incidence == incidence_list


def test_facet_incidence_cube() -> None:
    # We start with the H-representation for a cube
    mat = cdd.matrix_from_array(
        [
            [1, 1, 0, 0],
            [1, 0, 1, 0],
            [1, 0, 0, 1],
            [1, -1, 0, 0],
            [1, 0, -1, 0],
            [1, 0, 0, -1],
        ]
    )
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)
    incidence = cdd.copy_input_incidence(poly)

    # Family size should equal the number of facets of the cube (6),
    # plus 1 (the empty infinite ray)
    assert len(incidence) == 7

    # All the facets of the cube should have 4 vertices.
    # The polyhedron is closed, so the last set should be empty
    assert [len(inc) for inc in incidence] == [4, 4, 4, 4, 4, 4, 0]

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    incidence_list = [
        {4, 5, 6, 7},
        {0, 1, 6, 7},
        {0, 3, 5, 7},
        {0, 1, 2, 3},
        {2, 3, 4, 5},
        {1, 2, 4, 6},
        set(),
    ]
    assert incidence == incidence_list


def test_facet_incidence_vtest_vo() -> None:
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.matrix_from_array(
        [
            [0, 0, 0, 1],
            [5, -4, -2, 1],
            [5, -2, -4, 1],
            [16, -8, 0, 1],
            [16, 0, -8, 1],
            [32, -8, -8, 1],
        ]
    )

    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)

    incidence_list = [
        {0, 1, 2, 3, 4},
        {2, 3, 5, 6},
        {1, 2, 5, 9},
        {3, 4, 6, 7},
        {0, 1, 8, 9},
        {5, 6, 7, 8, 9},
        {0, 4, 7, 8},
    ]

    assert cdd.copy_input_incidence(poly) == incidence_list
