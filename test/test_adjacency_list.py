import cdd
import pytest


@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_make_vertex_adjacency_list(number_type):
    # The following lines test that poly.get_adjacency_list()
    # returns the correct adjacencies.

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
    adjacency_list = poly.get_adjacency()

    # Family size should equal the number of vertices of the cube (8)
    assert len(adjacency_list) == 8

    # All the vertices of the cube should be connected by three other vertices
    assert [len(adj) for adj in adjacency_list] == [3]*8

    # The vertices must be numbered consistently
    # The first vertex is adjacent to the second, fourth and eighth
    # (note the conversion to a pythonic numbering system)
    adjacencies = [[1, 3, 7],
                   [0, 2, 6],
                   [1, 3, 4],
                   [0, 2, 5],
                   [2, 5, 6],
                   [3, 4, 7],
                   [1, 4, 7],
                   [0, 5, 6]]
    for i in range(8):
        assert list(adjacency_list[i]) == adjacencies[i]


@pytest.mark.parametrize("number_type", ["fraction", "float"])
def test_make_facet_adjacency_list(number_type):
    # This matrix is the same as in vtest_vo.ine
    mat = cdd.Matrix([[0, 0, 0, 1],
                      [5, -4, -2, 1],
                      [5, -2, -4, 1],
                      [16, -8, 0, 1],
                      [16, 0, -8, 1],
                      [32, -8, -8, 1]], number_type=number_type)

    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.Polyhedron(mat)

    adjacencies = [[1, 2, 3, 4, 6],
                   [0, 2, 3, 5],
                   [0, 1, 4, 5],
                   [0, 1, 5, 6],
                   [0, 2, 5, 6],
                   [1, 2, 3, 4, 6],
                   [0, 3, 4, 5]]

    adjacency_list = poly.get_input_adjacency()
    for i in range(7):
        assert list(adjacency_list[i]) == adjacencies[i]
