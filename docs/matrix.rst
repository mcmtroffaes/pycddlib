Sets of Linear Inequalities and Generators
==========================================

.. currentmodule:: pycddlib

.. autoclass:: Matrix(self, rows, linear=False)

Methods
-------

.. automethod:: Matrix.__getitem__(self, key)
.. automethod:: Matrix.copy(self)
.. automethod:: Matrix.extend(self, rows, linear=False)

Attributes
----------

.. autoattribute:: Matrix.row_size
.. autoattribute:: Matrix.col_size
.. autoattribute:: Matrix.lin_set
.. autoattribute:: Matrix.rep_type
.. autoattribute:: Matrix.obj_type
.. autoattribute:: Matrix.obj_func

Examples
--------

>>> import pycddlib
>>> mat1 = pycddlib.Matrix([[1,2],[3,4]])
>>> print mat1
begin
 2 2 rational
 1 2
 3 4
end
>>> mat1.row_size
2
>>> mat1.col_size
2
>>> print(mat1[0])
(1, 2)
>>> print(mat1[1])
(3, 4)
>>> print(mat1[2]) # doctest: +ELLIPSIS
Traceback (most recent call last):
  ...
IndexError: row index out of range
>>> mat2 = mat1.copy()
>>> mat1.extend([[5,6]])
>>> mat1.row_size
3
>>> print mat1
begin
 3 2 rational
 1 2
 3 4
 5 6
end
>>> print(mat1[0])
(1, 2)
>>> print(mat1[1])
(3, 4)
>>> print(mat1[2])
(5, 6)
>>> mat1[1:3]
((3, 4), (5, 6))
>>> mat1[:-1]
((1, 2), (3, 4))
>>> print mat2
begin
 2 2 rational
 1 2
 3 4
end

.. warning::

   Beware when you use floats:

   >>> import pycddlib
   >>> print(pycddlib.Matrix([[1.12]]))
   begin
    1 1 rational
    1261007895663739/1125899906842624
   end

   If the float represents a fraction, it is better to pass it as a
   string, so it gets automatically converted to its exact fraction
   representation:

   >>> import pycddlib
   >>> print(pycddlib.Matrix([['1.12']]))
   begin
    1 1 rational
    28/25
   end

Some regression tests:

>>> pycddlib.Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = pycddlib.Matrix([[1], [2]])
>>> mat.obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size
