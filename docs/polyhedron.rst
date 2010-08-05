.. testsetup::

   import cdd
   import cdd._fraction
   import cdd._float

Working With Polyhedron Representations
=======================================

.. class:: cdd._float.Polyhedron(mat)
.. autoclass:: cdd._fraction.Polyhedron(mat)

Methods and Attributes
----------------------

.. automethod:: cdd._fraction.Polyhedron.get_inequalities()
.. automethod:: cdd._fraction.Polyhedron.get_generators()

.. autoattribute:: cdd._fraction.Polyhedron.rep_type

The :class:`cdd._float.Polyhedron` class has similar methods and
attributes.

Wrapper
-------

.. autoclass:: cdd.Polyhedron(rows, linear=False, number_type='float')

.. attribute:: cdd.Polyhedron.data

   A :class:`cdd._fraction.Polyhedron` or :class:`cdd._float.Polyhedron`
   instance.

Examples
--------

Note that the following examples presume:

>>> import cdd
>>> import cdd._fraction
>>> import cdd._float

Wrapper
~~~~~~~

>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='float')
>>> poly = cdd.Polyhedron(mat)
>>> type(poly.data)
<type 'cdd._float.Polyhedron'>
>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='fraction')
>>> poly = cdd.Polyhedron(mat)
>>> type(poly.data)
<type 'cdd._fraction.Polyhedron'>

Fractions
~~~~~~~~~

This is the sampleh1.ine example that comes with cddlib.

>>> mat = cdd._fraction.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd._fraction.Polyhedron(mat)
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

This is the testcdd2.c example that comes with cddlib.

>>> mat = cdd._fraction.Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> print(mat)
H-representation
begin
 4 3 rational
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
end
>>> print(cdd._fraction.Polyhedron(mat).get_generators())
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
>>> print(cdd._fraction.Polyhedron(mat).get_generators())
V-representation
begin
 2 3 rational
 1 -1 2
 1 0 7/3
end

Floats
~~~~~~

This is the sampleh1.ine example that comes with cddlib.

>>> mat = cdd._float.Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> poly = cdd._float.Polyhedron(mat)
>>> print(poly) # doctest: +NORMALIZE_WHITESPACE
begin
 3 4 real
 2 -1 -1 0
 0 1 0 0
 0 0 1 0
end
>>> ext = poly.get_generators()
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

This is the testcdd2.c example that comes with cddlib.

>>> mat = cdd._float.Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]])
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
begin
 4 3 real
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
end
>>> print(cdd._float.Polyhedron(mat).get_generators()) # doctest: +NORMALIZE_WHITESPACE
V-representation
begin
 4 3 real
 1 2.333333333E+00 -1
 1 -1 -1
 1 -1 2.333333333E+00
 1 2.333333333E+00 2.333333333E+00
end
>>> # add an equality and an inequality
>>> mat.extend([[7, 1, -3]], linear=True)
>>> mat.extend([[7, -3, 1]])
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
linearity 1  5
begin
 6 3 real
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
 7 1 -3
 7 -3 1
end
>>> print(cdd._float.Polyhedron(mat).get_generators()) # doctest: +NORMALIZE_WHITESPACE
V-representation
begin
 2 3 real
 1 -1 2
 1 0 2.333333333E+00
end
