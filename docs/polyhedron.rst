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

.. method:: Polyhedron.get_adjacency()

        Get the adjacencies.

        :returns: Adjacency list.
        :rtype: :class:`tuple`

        The adjacency of a polyhedron in the H-representation is the
        list of sets of vertices which are adjacent to each face.

        The adjacency of a polyhedron in the V-representation is the
        list of sets of faces which are adjacent to each vertex.

.. method:: Polyhedron.get_input_adjacency()

        Get the input adjacencies.

        :returns: Input adjacency list.
        :rtype: :class:`tuple`

        The input adjacency of a polyhedron in the H-representation is the
        list of sets of faces which are adjacent to each face.

        The input adjacency of a polyhedron in the V-representation is the
        list of sets of vertices which are adjacent to each vertex.

.. method:: Polyhedron.get_incidence()

        Get the incidences.

        :returns: Incidence list.
        :rtype: :class:`tuple`

        TODO

.. method:: Polyhedron.get_input_incidence()

        Get the incidences for the polyhedron.

        :returns: Input incidence list.
        :rtype: :class:`tuple`

	TODO

.. attribute:: Polyhedron.rep_type

        Representation (see :class:`~cdd.RepType`).

.. note::

    The H-representation and/or V-representation are not guaranteed to
    be minimal, that is, they can still contain redundancy.

Examples
--------

This is the sampleh1.ine example that comes with cddlib.

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


The following example illustrates the use of the get_adjacency method.

>>> import cdd
>>> # We start with the H-representation for a square
>>> mat = cdd.Matrix([[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.Polyhedron(mat)
>>> adjacency_list = poly.get_adjacency()
>>> # We can output to screen as done by cddlib
>>> print(adjacency_list)
begin
  4    4
 1 2 : 2 4
 2 2 : 1 3
 3 2 : 2 4
 4 2 : 1 3
end

The following example illustrates the use of the get_incidence method.

>>> import cdd
>>> # We again start with the H-representation for a square
>>> mat = cdd.Matrix([[1, 1, 0], [1, 0, 1], [1, -1, 0], [1, 0, -1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd.Polyhedron(mat)
>>> # The V-representation can be printed in the usual way:
>>> print(poly.get_generators())
V-representation
begin
 4 3 rational
 1 1 -1
 1 1 1
 1 -1 1
 1 -1 -1
end
>>> vertex_incidence = poly.get_incidence()
>>> # We can output to screen as done by cddlib
>>> print(vertex_incidence)
begin
  4    5
 1 2 : 2 3
 2 2 : 3 4
 3 2 : 1 4
 4 2 : 1 2
end
