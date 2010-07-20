Polyhedra
=========

.. module:: pycddlib

Class
-----

.. autoclass:: Polyhedra
   :members:

Examples
--------

This is the sampleh1.ine example that comes with cddlib.

>>> import pycddlib
>>> mat = pycddlib.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]])
>>> mat.representation = pycddlib.RepType.INEQUALITY
>>> poly = pycddlib.Polyhedra(mat)
>>> print(poly)
begin
 3 4 real
  2 -1 -1  0
  0  1  0  0
  0  0  1  0
end
<BLANKLINE>
>>> ext = poly.get_generators()
>>> print(ext)
V-representation
linearity 1  4
begin
 4 4 real
  1  0  0  0
  1  2  0  0
  1  0  2  0
  0  0  0  1
end
<BLANKLINE>
>>> print(ext.linset) # note: first row is 0, so fourth row is 3
frozenset([3])

This is the testcdd2.c example that comes with cddlib.

>>> import pycddlib
>>> mat = pycddlib.Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]])
>>> mat.representation = pycddlib.RepType.INEQUALITY
>>> print(mat)
H-representation
begin
 4 3 real
  7 -3  0
  7  0 -3
  1  1  0
  1  0  1
end
<BLANKLINE>
>>> print(pycddlib.Polyhedra(mat).get_generators())
V-representation
begin
 4 3 real
  1  2.333333333E+00 -1
  1 -1 -1
  1 -1  2.333333333E+00
  1  2.333333333E+00  2.333333333E+00
end
<BLANKLINE>
>>> # add an equality and an inequality
>>> mat.extend([[7, 1, -3]], linear=True)
>>> mat.extend([[7, -3, 1]])
>>> print(mat)
H-representation
linearity 1  5
begin
 6 3 real
  7 -3  0
  7  0 -3
  1  1  0
  1  0  1
  7  1 -3
  7 -3  1
end
<BLANKLINE>
>>> print(pycddlib.Polyhedra(mat).get_generators())
V-representation
begin
 2 3 real
  1 -1  2
  1  0  2.333333333E+00
end
<BLANKLINE>
