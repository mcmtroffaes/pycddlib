Examples
========

The following examples presume:

>>> import cdd
>>> from pprint import pprint

.. testsetup::

    import cdd
    from pprint import pprint

Checking and Removing Redundancies
----------------------------------

>>> array = [[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> cdd.redundant(mat, 0) is None
True
>>> cdd.redundant(mat, 1)
[5.0, -3.0, 0.0]
>>> cdd.redundant(mat, 2)
[8.0, -4.0, 0.0]
>>> cdd.redundant(mat, 3)
[6.4999..., -3.0, 0.0]
>>> cdd.redundant_rows(mat)
{0}
>>> cdd.matrix_canonicalize(mat)
({1, 3}, {0}, [None, 0, 1, None])
>>> pprint(mat.array)
[[0.0, 1.0, 2.0, 3.0], [3.0, 0.0, 1.0, 2.0]]
>>> mat.lin_set
{0}

Solving Linear Programs
-----------------------

>>> array = [
...     [4 / 3, -2, -1],  # 0 <= 4/3-2x-y
...     [2 / 3, 0, -1],  # 0 <= 2/3-y
...     [0, 1, 0],  # 0 <= x
...     [0, 0, 1],  # 0 <= y
...     [0, 3, 4],  # obj func: 3x+4y
... ]
>>> lp = cdd.linprog_from_array(array, obj_type=cdd.LPObjType.MAX)
>>> cdd.linprog_solve(lp)
>>> lp.status == cdd.LPStatusType.OPTIMAL
True
>>> lp.obj_value
3.666666...
>>> lp.primal_solution
[0.333333..., 0.666666...]
>>> lp.dual_solution
[(0, 1.5), (1, 2.5)]

Calculating Extreme Points / Rays
---------------------------------

This is the :file:`sampleh1.ine` example that comes with cddlib.

>>> array = [[2, -1, -1, 0], [0, 1, 0, 0], [0, 0, 1, 0]]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> poly = cdd.polyhedron_from_matrix(mat)
>>> ext = cdd.copy_generators(poly)
>>> ext.rep_type
<RepType.GENERATOR: 2>
>>> pprint(ext.array) # doctest: +NORMALIZE_WHITESPACE
[[1.0, 0.0, 0.0, 0.0],
 [1.0, 2.0, 0.0, 0.0],
 [1.0, 0.0, 2.0, 0.0],
 [0.0, 0.0, 0.0, 1.0]]
>>> ext.lin_set # note: first row is 0, so fourth row is 3
{3}

Matrix Rank
-----------

>>> # row 3 = row 1 - row 2
>>> # col 2 = 2 * col 1
>>> array = [[1, 2, 0, 1], [1, 2, 1, 3], [0, 0, -1, -2]]
>>> mat = cdd.matrix_from_array(array)
>>> row_basis, col_basis, rank = cdd.matrix_rank(mat)
>>> row_basis
{0, 1}
>>> col_basis
{0, 2}
>>> rank
2

Matrix Adjacencies
------------------

>>> # H-representation of a square
>>> # 0 <= 1 + x1 (face 0)
>>> # 0 <= 1 + x2 (face 1)
>>> # 0 <= 1 - x1 (face 2)
>>> # 0 <= 1 - x2 (face 3)
>>> #
>>> #   +---(3)---+
>>> #   |         |
>>> #   |         |
>>> #  (0)       (2)
>>> #   |         |
>>> #   |         |
>>> #   +---(1)---+
>>> array = [[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> cdd.matrix_adjacency(mat)
[{1, 3}, {0, 2}, {1, 3}, {0, 2}]

>>> # V-representation of a square
>>> #
>>> #   1-----3
>>> #   |     |
>>> #   |     |
>>> #   0-----2
>>> array = [[1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.GENERATOR)
>>> cdd.matrix_adjacency(mat)
[{1, 2}, {0, 3}, {0, 3}, {1, 2}]

Polyhedron Adjacencies and Incidences
-------------------------------------

>>> # H-representation of a square
>>> # 0 <= 1 + x1 (face 0)
>>> # 0 <= 1 + x2 (face 1)
>>> # 0 <= 1 - x1 (face 2)
>>> # 0 <= 1 - x2 (face 3)
>>> array = [[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> poly = cdd.polyhedron_from_matrix(mat)
>>> gen = cdd.copy_generators(poly)
>>> gen.rep_type
<RepType.GENERATOR: 2>
>>> pprint(gen.array, width=40)
[[1.0, 1.0, -1.0],
 [1.0, 1.0, 1.0],
 [1.0, -1.0, 1.0],
 [1.0, -1.0, -1.0]]
>>> gen.lin_set
set()
>>> # V-representation of this square
>>> #
>>> #   2---(3)---1
>>> #   |         |
>>> #   |         |
>>> #  (0)       (2)
>>> #   |         |
>>> #   |         |
>>> #   3---(1)---0
>>> #
>>> # vertex 0 is adjacent to vertices 1 and 3
>>> # vertex 1 is adjacent to vertices 0 and 2
>>> # vertex 2 is adjacent to vertices 1 and 3
>>> # vertex 3 is adjacent to vertices 0 and 2
>>> cdd.copy_adjacency(poly)
[{1, 3}, {0, 2}, {1, 3}, {0, 2}]
>>> # vertex 0 is the intersection of faces (1) and (2)
>>> # vertex 1 is the intersection of faces (2) and (3)
>>> # vertex 2 is the intersection of faces (0) and (3)
>>> # vertex 3 is the intersection of faces (0) and (1)
>>> cdd.copy_incidence(poly)
[{1, 2}, {2, 3}, {0, 3}, {0, 1}]
>>> # face (0) is adjacent to faces (1) and (3)
>>> # face (1) is adjacent to faces (0) and (2)
>>> # face (2) is adjacent to faces (1) and (3)
>>> # face (3) is adjacent to faces (0) and (2)
>>> cdd.copy_input_adjacency(poly)
[{1, 3}, {0, 2}, {1, 3}, {0, 2}, set()]
>>> # face (0) intersects with vertices 2 and 3
>>> # face (1) intersects with vertices 0 and 3
>>> # face (2) intersects with vertices 0 and 1
>>> # face (3) intersects with vertices 1 and 2
>>> cdd.copy_input_incidence(poly)
[{2, 3}, {0, 3}, {0, 1}, {1, 2}, set()]
>>> # add a vertex, and construct new polyhedron
>>> cdd.matrix_append_to(gen, cdd.matrix_from_array([[1, 0, 2]]))
>>> vpoly = cdd.polyhedron_from_matrix(gen)
>>> vmat = cdd.copy_inequalities(vpoly)
>>> vmat.rep_type
<RepType.INEQUALITY: 1>
>>> pprint(vmat.array)
[[1.0, 0.0, 1.0],
 [2.0, 1.0, -1.0],
 [1.0, 1.0, 0.0],
 [2.0, -1.0, -1.0],
 [1.0, -1.0, 0.0]]
>>> vmat.lin_set
set()
>>> # so now we have:
>>> # 0 <= 1 + x2
>>> # 0 <= 2 + x1 - x2
>>> # 0 <= 1 + x1
>>> # 0 <= 2 - x1 - x2
>>> # 0 <= 1 - x1
>>> #
>>> # graphical depiction of vertices and faces:
>>> #
>>> #        4
>>> #       / \
>>> #      /   \
>>> #    (1)   (3)
>>> #    /       \
>>> #   2         1
>>> #   |         |
>>> #   |         |
>>> #  (2)       (4)
>>> #   |         |
>>> #   |         |
>>> #   3---(0)---0
>>> #
>>> # for each face, list adjacent faces
>>> cdd.copy_adjacency(vpoly)
[{2, 4}, {2, 3}, {0, 1}, {1, 4}, {0, 3}]
>>> # for each face, list adjacent vertices
>>> cdd.copy_incidence(vpoly)
[{0, 3}, {2, 4}, {2, 3}, {1, 4}, {0, 1}]
>>> # for each vertex, list adjacent vertices
>>> cdd.copy_input_adjacency(vpoly)
[{1, 3}, {0, 4}, {3, 4}, {0, 2}, {1, 2}]
>>> # for each vertex, list adjacent faces
>>> cdd.copy_input_incidence(vpoly)
[{0, 4}, {3, 4}, {1, 2}, {0, 2}, {1, 3}]

Fourier and Block Elimination
-----------------------------

The next example is taken from
`Wikipedia <https://en.wikipedia.org/wiki/Fourier%E2%80%93Motzkin_elimination#Example>`_.

>>> array = [
...     [10, -2, 5, -4],  # 2x-5y+4z<=10
...     [9, -3, 6, -3],  # 3x-6y+3z<=9
...     [-7, 1, -5, 2],  # -x+5y-2z<=-7
...     [12, 3, -2, -6],  # -3x+2y+6z<=12
... ]
>>> mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> cdd.fourier_elimination(mat).array
[[-1.0, 0.0, -1.25], [-1.0, -1.0, -1.0], [-1.5, 1.0, -2.833333...]]
>>> cdd.block_elimination(mat, {3}).array
[[-4.0, 0.0, -5.0], [-1.5, -1.5, -1.5], [-9.0, 6.0, -17.0]]
