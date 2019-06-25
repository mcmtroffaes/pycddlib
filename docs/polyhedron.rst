.. testsetup::

   import cdd

.. currentmodule:: cdd

Working With Polyhedron Representations
=======================================

.. class:: Polyhedron(mat)

    A class for converting between representations of a polyhedron.

    Bases: :class:`~cdd.NumberTypeable`

    :param mat: The matrix to load the polyhedron from.
    :type mat: :class:`~cdd.Matrix`

Methods and Attributes
----------------------

.. method:: Polyhedron.get_inequalities()

        Get all inequalities.

        :returns: H-representation.
        :rtype: :class:`~cdd.Matrix`

        For a polyhedron described as `P = {x | A x <= b}`, the
        H-representation is the matrix `[b -A]`.

.. method:: Polyhedron.get_generators()

        Get all generators.

        :returns: V-representation.
        :rtype: :class:`~cdd.Matrix`

        For a polyhedron described as `P = conv(v_1, ..., v_n) + nonneg(r_1,
        ..., r_s)`, the V-representation matrix is `[t V]` where `t` is the
        column vector with `n` ones followed by `s` zeroes, and `V` is the
        stacked matrix of `n` vertex row vectors on top of `s` ray row vectors.

.. method:: Polyhedron.get_adjacency_list()

        Get the adjacency list for the polyhedron.

        :returns: Adjacency list.
        :rtype: :class:`~cdd.SetFamily`

	The adjacency list of a polyhedron is the list of sets of vertices
	which are adjacent to each vertex.

.. attribute:: Polyhedron.rep_type

        Representation (see :class:`~cdd.RepType`).

.. note::

    The H-representation and/or V-representation are not guaranteed to
    be minimal, that is, they can still contain redundancy.

Examples
--------

1) This is the sampleh1.ine example that comes with cddlib.

>>> import cdd
>>> mat = cdd.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]], number_type='fraction')
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.Polyhedron(mat)
>>> print(poly)
begin
 3 4 rational
 2 -1 -1 0
 0 1 0 0
 0 0 1 0
end
>>> ext = poly.get_generators()
>>> print(ext)
V-representation
linearity 1  4
begin
 4 4 rational
 1 0 0 0
 1 2 0 0
 1 0 2 0
 0 0 0 1
end
>>> print(list(ext.lin_set)) # note: first row is 0, so fourth row is 3
[3]


2) The following example illustrates the use of the get_adjacency_list method.

>>> import cdd
>>> # We start with the H-representation for a square
>>> mat = cdd.Matrix([[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.Polyhedron(mat)
>>> adjacency_list = poly.get_adjacency_list()
>>> # We can output to screen as done by cddlib
>>> print(adjacency_list)
begin
  4    4
 1 2 : 2 4
 2 2 : 1 3
 3 2 : 2 4
 4 2 : 1 3
end
>>> # We can also use some attributes of the SetFamily class
>>> print(adjacency_list.family_size)
4
>>> print(adjacency_list.set_size)
4
>>> # The adjacencies are stored as a tuple of frozensets
>>> # The numbering in the sets starts from zero,
>>> # so the vertices adjacent to the first vertex (vertex 0)
>>> # have indices 1 and 3:
>>> print(adjacency_list[0])
frozenset([1, 3])
>>> # Finally, we can output the vertex adjacency matrix
>>> print(adjacency_list.set_family_matrix)
[[0, 1, 0, 1], [1, 0, 1, 0], [0, 1, 0, 1], [1, 0, 1, 0]]
