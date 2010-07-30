.. testsetup::

   from pycddlib import *

Working With Polyhedron Representations
=======================================

.. currentmodule:: pycddlib

.. autoclass:: Polyhedron(self, mat)

Methods
-------

.. automethod:: Polyhedron.get_inequalities(self)
.. automethod:: Polyhedron.get_generators(self)

Attributes
----------

.. autoattribute:: Polyhedron.rep_type

Examples
--------

Note that the following examples presume:

>>> from pycddlib import *

This is the sampleh1.ine example that comes with cddlib.

>>> mat = Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]])
>>> mat.rep_type = RepType.INEQUALITY
>>> poly = Polyhedron(mat)
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
>>> print(ext.lin_set) # note: first row is 0, so fourth row is 3
frozenset([3])

This is the testcdd2.c example that comes with cddlib.

>>> mat = Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]])
>>> mat.rep_type = RepType.INEQUALITY
>>> print(mat)
H-representation
begin
 4 3 rational
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
end
>>> print(Polyhedron(mat).get_generators())
V-representation
begin
 4 3 rational
 1 7/3 -1
 1 -1 -1
 1 -1 7/3
 1 7/3 7/3
end
>>> # add an equality and an inequality
>>> mat.extend([[7, 1, -3]], linear=True)
>>> mat.extend([[7, -3, 1]])
>>> print(mat)
H-representation
linearity 1  5
begin
 6 3 rational
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
 7 1 -3
 7 -3 1
end
>>> print(Polyhedron(mat).get_generators())
V-representation
begin
 2 3 rational
 1 -1 2
 1 0 7/3
end
