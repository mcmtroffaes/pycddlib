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

.. method:: Polyhedron.get_generators()

        Get all generators.

        :returns: V-representation.
        :rtype: :class:`~cdd.Matrix`

.. attribute:: Polyhedron.rep_type

        Representation (see :class:`~cdd.RepType`).

.. note::

    The H-representation and/or V-representation are not guaranteed to
    be minimal, that is, they can still contain redundancy.

Example
-------

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
