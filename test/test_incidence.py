import cdd
import pytest
from fractions import Fraction


@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_vertex_incidence_cube(number_type):
    # The following lines test that poly.get_vertex_incidence()
    # returns the correct incidences.

    # We start with the H-representation for a cube
    mat = cdd.Matrix([[1, 1, 0 ,0],
                      [1, 0, 1, 0],
                      [1, 0, 0, 1],
                      [1, -1, 0, 0],
                      [1, 0, -1, 0],
                      [1, 0, 0, -1]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    incidence = poly.get_incidence()

    # Family size should equal the number of vertices of the cube (8)
    assert len(incidence) == 8

    # All the vertices of the cube should mark the incidence of 3 facets
    assert [len(inc) for inc in incidence] == [3]*8

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    incidence_list = [[1, 2, 3],
                      [1, 3, 5],
                      [3, 4, 5],
                      [2, 3, 4],
                      [0, 4, 5],
                      [0, 2, 4],
                      [0, 1, 5],
                      [0, 1, 2]]
    for i in range(8):
        assert sorted(list(incidence[i])) == incidence_list[i]


@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_vertex_incidence_vtest_vo(number_type):
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.Matrix([[0, 0, 0, 1],
                      [5, -4, -2, 1],
                      [5, -2, -4, 1],
                      [16, -8, 0, 1],
                      [16, 0, -8, 1],
                      [32, -8, -8, 1]], number_type=number_type)

    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)

    incidence_list = [[0, 4, 6],
                      [0, 2, 4],
                      [0, 1, 2],
                      [0, 1, 3],
                      [0, 3, 6],
                      [1, 2, 5],
                      [1, 3, 5],
                      [3, 5, 6],
                      [4, 5, 6],
                      [2, 4, 5]]

    incidence = poly.get_incidence()
    for i in range(10):
        assert sorted(list(incidence[i])) == incidence_list[i]


@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_facet_incidence_cube(number_type):
    # We start with the H-representation for a cube
    mat = cdd.Matrix([[1, 1, 0 ,0],
                      [1, 0, 1, 0],
                      [1, 0, 0, 1],
                      [1, -1, 0, 0],
                      [1, 0, -1, 0],
                      [1, 0, 0, -1]],
                     number_type=number_type)
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)
    incidence = poly.get_input_incidence()

    # Family size should equal the number of facets of the cube (6), plus 1 (the empty infinite ray)
    assert len(incidence) == 7

    # All the facets of the cube should have 4 vertices.
    # The polyhedron is closed, so the last set should be empty
    assert [len(inc) for inc in incidence] == [4, 4, 4, 4, 4, 4, 0]

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    incidence_list = [[4, 5, 6, 7],
                      [0, 1, 6, 7],
                      [0, 3, 5, 7],
                      [0, 1, 2, 3],
                      [2, 3, 4, 5],
                      [1, 2, 4, 6],
                      []]
    for i in range(7):
        assert sorted(list(incidence[i])) == incidence_list[i]

@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_facet_incidence_vtest_vo(number_type):
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.Matrix([[0, 0, 0, 1],
                      [5, -4, -2, 1],
                      [5, -2, -4, 1],
                      [16, -8, 0, 1],
                      [16, 0, -8, 1],
                      [32, -8, -8, 1]], number_type=number_type)

    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)

    incidence_list = [[0, 1, 2, 3, 4],
                      [2, 3, 5, 6],
                      [1, 2, 5, 9],
                      [3, 4, 6, 7],
                      [0, 1, 8, 9],
                      [5, 6, 7, 8, 9],
                      [0, 4, 7, 8]]

    incidence = poly.get_input_incidence()
    for i in range(7):
        assert sorted(list(incidence[i])) == incidence_list[i]
