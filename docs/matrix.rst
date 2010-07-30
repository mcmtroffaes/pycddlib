.. testsetup::

   from pycddlib import *

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

Note that the following examples presume:

>>> from pycddlib import *

Declaring matrices, and checking some attributes:

>>> mat1 = Matrix([[1,2],[3,4]])
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

Some regression tests:

>>> Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = Matrix([[1], [2]])
>>> mat.obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size
