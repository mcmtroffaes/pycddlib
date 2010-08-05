.. testsetup::

   import cdd
   import cdd._fraction
   import cdd._float
   from fractions import Fraction

Sets of Linear Inequalities and Generators
==========================================

.. class:: cdd._float.Matrix(rows, linear=False)
.. autoclass:: cdd._fraction.Matrix(rows, linear=False)

Methods and Attributes
----------------------

.. automethod:: cdd._fraction.Matrix.__getitem__(key)
.. automethod:: cdd._fraction.Matrix.copy()
.. automethod:: cdd._fraction.Matrix.extend(rows, linear=False)

.. autoattribute:: cdd._fraction.Matrix.row_size
.. autoattribute:: cdd._fraction.Matrix.col_size
.. autoattribute:: cdd._fraction.Matrix.lin_set
.. autoattribute:: cdd._fraction.Matrix.rep_type
.. autoattribute:: cdd._fraction.Matrix.obj_type
.. autoattribute:: cdd._fraction.Matrix.obj_func

The :class:`cdd._float.Matrix` class has similar methods and
attributes.

Wrapper
-------

.. autoclass:: cdd.Matrix(rows, linear=False, number_type='float')

.. attribute:: cdd.Matrix.data

   A :class:`cdd._fraction.Matrix` or :class:`cdd._float.Matrix`
   instance.

Examples
--------

Note that the following examples presume:

>>> import cdd
>>> import cdd._fraction
>>> import cdd._float
>>> from fractions import Fraction

Wrapper
~~~~~~~

>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='float')
>>> type(mat.data)
<type 'cdd._float.Matrix'>
>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='fraction')
>>> type(mat.data)
<type 'cdd._fraction.Matrix'>

Fractions
~~~~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cdd._fraction.Matrix([[1,2],[3,4]])
>>> print(mat1)
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
>>> print(mat1)
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
>>> print(mat2)
begin
 2 2 rational
 1 2
 3 4
end

Some regression tests:

>>> cdd._fraction.Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = cdd._fraction.Matrix([[1], [2]])
>>> mat.obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size

Large number tests:

>>> print(cdd._fraction.Matrix([[10 ** 100]]))
begin
 1 1 rational
 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
end
>>> print(cdd._fraction.Matrix([[Fraction(10 ** 100, 13 ** 102)]]))
begin
 1 1 rational
 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169
end
>>> cdd._fraction.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000']])[0][0]
Fraction(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 1)
>>> cdd._fraction.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169']])[0][0]
Fraction(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169)

Floats
~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cdd._float.Matrix([[1,2],[3,4]])
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 2 2 real
 1 2
 3 4
end
>>> mat1.row_size
2
>>> mat1.col_size
2
>>> print(mat1[0])
(1.0, 2.0)
>>> print(mat1[1])
(3.0, 4.0)
>>> print(mat1[2]) # doctest: +ELLIPSIS
Traceback (most recent call last):
  ...
IndexError: row index out of range
>>> mat2 = mat1.copy()
>>> mat1.extend([[5,6]])
>>> mat1.row_size
3
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 3 2 real
 1 2
 3 4
 5 6
end
>>> print(mat1[0])
(1.0, 2.0)
>>> print(mat1[1])
(3.0, 4.0)
>>> print(mat1[2])
(5.0, 6.0)
>>> mat1[1:3]
((3.0, 4.0), (5.0, 6.0))
>>> mat1[:-1]
((1.0, 2.0), (3.0, 4.0))
>>> print(mat2) # doctest: +NORMALIZE_WHITESPACE
begin
 2 2 real
 1 2
 3 4
end

Some regression tests:

>>> cdd._float.Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = cdd._float.Matrix([[1], [2]])
>>> mat.obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size

Large number tests:

>>> print(cdd._float.Matrix([[10 ** 100]])) # doctest: +NORMALIZE_WHITESPACE
begin
 1 1 real
 1.000000000E+100
end
>>> print(cdd._float.Matrix([[Fraction(10 ** 100, 13 ** 90)]])) # doctest: +NORMALIZE_WHITESPACE +ELLIPSIS
begin
 1 1 real
 5.5603...E-01
end
>>> cdd._float.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000']])[0][0]
1e+100
>>> cdd._float.Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/17984638288961211871838956989189665890197130672912829203311075745019255958028927299020895173379216649']])[0][0] # doctest: +ELLIPSIS
0.55603...


