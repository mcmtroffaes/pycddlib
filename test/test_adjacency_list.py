import cdd
import nose
from fractions import Fraction

# The following lines test that poly.get_adjacency_list()
# returns the correct adjacencies.

# We start with the H-representation for a cube
mat = cdd.Matrix([[1, 1, 0 ,0],
                  [1, 0, 1, 0],
                  [1, 0, 0, 1],
                  [1, -1, 0, 0],
                  [1, 0, -1, 0],
                  [1, 0, 0, -1]],
                 number_type=None)
mat.rep_type = cdd.RepType.INEQUALITY
poly = cdd.Polyhedron(mat)
adjacency_list = poly.get_adjacency_list()

# Family size should equal the number of vertices of the cube (8)
nose.tools.assert_equal(adjacency_list.family_size, len(adjacency_list))
nose.tools.assert_equal(adjacency_list.family_size, 8)

# Set size should also equal the number of vertices of the cube (8)
nose.tools.assert_equal(adjacency_list.set_size, 8)

# All the vertices of the cube should be connected by three other vertices
nose.tools.assert_equal([len(adj) for adj in adjacency_list], [3]*8)

# The vertices must be numbered consistently
# The first vertex is adjacent to the second, fourth and eighth
# (note the conversion to a pythonic numbering system)
adjacencies = [frozenset([1, 3, 7]),
               frozenset([0, 2, 6]),
               frozenset([1, 3, 4]),
               frozenset([0, 2, 5]),
               frozenset([2, 5, 6]),
               frozenset([3, 4, 7]),
               frozenset([1, 4, 7]),
               frozenset([0, 5, 6])]
for i in range(8):
    nose.tools.assert_equal(adjacency_list[i], adjacencies[i])
    nose.tools.assert_equal(adjacency_list.set_family_matrix[i],
                            [1 if j in adjacencies[i] else 0 for j in range(8)])
