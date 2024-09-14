.. testsetup::

   import cdd

.. currentmodule:: cdd

Working With Polyhedron Representations
=======================================

.. class:: Polyhedron

    Representation of a polyhedron.

    .. attribute:: rep_type: RepType

        Representation type.

.. function:: polyhedron_from_matrix(mat: Matrix) -> Polyhedron

    Run the double description method to convert a matrix representation into a
    polyhedron.

.. function:: copy_input(poly: Polyhedron) -> Matrix

    Returns the original matrix that the polyhedron was constructed from.

    .. versionadded:: 3.0.0

.. function:: copy_output(poly: Polyhedron) -> Matrix

    Returns the dual representation of the original matrix.
    If the original was a H-representation, this will return its V-representation,
    and vice versa.

    .. note::

        The H-representation and/or V-representation are not guaranteed to
        be minimal, that is, they can still contain redundancy.

    .. versionadded:: 3.0.0

.. function:: copy_inequalities(poly: Polyhedron) -> Matrix

    Copy a H-representation of the inequalities.

    For a polyhedron described as `P = {x | A x <= b}`, the
    H-representation is the matrix `[b -A]`.

.. function:: copy_generators(poly: Polyhedron) -> Matrix

    Copy a V-representation of all the generators.

    For a polyhedron described as
    `P = conv(v_1, ..., v_n) + nonneg(r_1,..., r_s)`,
    the V-representation matrix is `[t V]` where `t` is the
    column vector with `n` ones followed by `s` zeroes, and `V` is the
    stacked matrix of `n` vertex row vectors on top of `s` ray row vectors.

.. function:: copy_adjacency(poly: Polyhedron) -> Sequence[Set[int]]

    Get the adjacencies.

    H-representation: For each vertex, list adjacent vertices.
    V-representation: For each face, list adjacent faces.

.. function:: copy_input_adjacency(poly: Polyhedron) -> Sequence[Set[int]]

    Get the input adjacencies.

    H-representation: For each face, list adjacent faces.
    V-representation: For each vertex, list adjacent vertices.

.. function:: copy_incidence(poly: Polyhedron) -> Sequence[Set[int]]

    Get the incidences.

    H-representation: For each vertex, list adjacent faces.
    V-representation: For each face, list adjacent vertices.

.. function:: copy_input_incidence(poly: Polyhedron) -> Sequence[Set[int]]

    Get the input incidences.

    H-representation: For each face, list adjacent vertices.
    V-representation: For each vertex, list adjacent faces.

Examples
--------

This is the sampleh1.ine example that comes with cddlib.

>>> mat = cdd.matrix_from_array([[2, -1, -1, 0],[0, 1, 0, 0],[0, 0, 1, 0]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.polyhedron_from_matrix(mat)
>>> print(poly) # doctest: +NORMALIZE_WHITESPACE
begin
 3 4 real
 2 -1 -1 0
 0 1 0 0
 0 0 1 0
end
>>> ext = cdd.copy_generators(poly)
>>> print(ext) # doctest: +NORMALIZE_WHITESPACE
V-representation
linearity 1  4
begin
 4 4 real
 1 0 0 0
 1 2 0 0
 1 0 2 0
 0 0 0 1
end
>>> print(list(ext.lin_set)) # note: first row is 0, so fourth row is 3
[3]


The following example illustrates how to get adjacencies and incidences.

>>> # We start with the H-representation for a square
>>> # 0 <= 1 + x1 (face 0)
>>> # 0 <= 1 + x2 (face 1)
>>> # 0 <= 1 - x1 (face 2)
>>> # 0 <= 1 - x2 (face 3)
>>> mat = cdd.matrix_from_array([[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.polyhedron_from_matrix(mat)
>>> # The V-representation can be printed in the usual way:
>>> gen = cdd.copy_generators(poly)
>>> print(gen) # doctest: +NORMALIZE_WHITESPACE
V-representation
begin
 4 3 real
 1 1 -1
 1 1 1
 1 -1 1
 1 -1 -1
end
>>> # graphical depiction of vertices and faces:
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
>>> print([list(x) for x in cdd.copy_adjacency(poly)])
[[1, 3], [0, 2], [1, 3], [0, 2]]
>>> # vertex 0 is the intersection of faces (1) and (2)
>>> # vertex 1 is the intersection of faces (2) and (3)
>>> # vertex 2 is the intersection of faces (0) and (3)
>>> # vertex 3 is the intersection of faces (0) and (1)
>>> print([list(x) for x in cdd.copy_incidence(poly)])
[[1, 2], [2, 3], [0, 3], [0, 1]]
>>> # face (0) is adjacent to faces (1) and (3)
>>> # face (1) is adjacent to faces (0) and (2)
>>> # face (2) is adjacent to faces (1) and (3)
>>> # face (3) is adjacent to faces (0) and (2)
>>> print([list(x) for x in cdd.copy_input_adjacency(poly)])
[[1, 3], [0, 2], [1, 3], [0, 2], []]
>>> # face (0) intersects with vertices 2 and 3
>>> # face (1) intersects with vertices 0 and 3
>>> # face (2) intersects with vertices 0 and 1
>>> # face (3) intersects with vertices 1 and 2
>>> print([list(x) for x in cdd.copy_input_incidence(poly)])
[[2, 3], [0, 3], [0, 1], [1, 2], []]
>>> # add a vertex, and construct new polyhedron
>>> cdd.matrix_append_to(gen, cdd.matrix_from_array([[1, 0, 2]]))
>>> vpoly = cdd.polyhedron_from_matrix(gen)
>>> print(cdd.copy_inequalities(vpoly)) # doctest: +NORMALIZE_WHITESPACE
H-representation
begin
 5 3 real
 1 0 1
 2 1 -1
 1 1 0
 2 -1 -1
 1 -1 0
end
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
>>> print([list(x) for x in cdd.copy_adjacency(vpoly)])
[[2, 4], [2, 3], [0, 1], [1, 4], [0, 3]]
>>> # for each face, list adjacent vertices
>>> print([list(x) for x in cdd.copy_incidence(vpoly)])
[[0, 3], [2, 4], [2, 3], [1, 4], [0, 1]]
>>> # for each vertex, list adjacent vertices
>>> print([list(x) for x in cdd.copy_input_adjacency(vpoly)])
[[1, 3], [0, 4], [3, 4], [0, 2], [1, 2]]
>>> # for each vertex, list adjacent faces
>>> print([list(x) for x in cdd.copy_input_incidence(vpoly)])
[[0, 4], [3, 4], [1, 2], [0, 2], [1, 3]]
