Matrix
======

.. module:: pycddlib

.. autoclass:: Matrix

Methods
-------

.. method:: Matrix.__init__(self, rows, linear=False)

   Load matrix data from the *rows*.

   :param rows: The rows of the matrix.
   :type rows: ``list`` of ``list`` of ``float``
   :param linear: Whether to add the rows to the :attr:`lin_set` or not.
   :type linear: ``bool``

.. automethod:: Matrix.__getitem__(self, item)

.. method:: Matrix.__len__(self)

   Number of rows.

.. automethod:: Matrix.__str__(self)
.. automethod:: Matrix.copy(self)
.. automethod:: Matrix.extend(self, rows, linear=False)

Attributes
----------

.. autoattribute:: Matrix.row_size
.. autoattribute:: Matrix.col_size
.. autoattribute:: Matrix.lin_set
.. autoattribute:: Matrix.rep_type
.. autoattribute:: Matrix.lp_obj_type
.. autoattribute:: Matrix.lp_obj_func

Examples
--------

>>> import pycddlib
>>> mat1 = pycddlib.Matrix([[1,2],[3,4]])
>>> print mat1
begin
 2 2 real
  1  2
  3  4
end
<BLANKLINE>
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
>>> print mat1
begin
 3 2 real
  1  2
  3  4
  5  6
end
<BLANKLINE>
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
>>> print mat2
begin
 2 2 real
  1  2
  3  4
end
<BLANKLINE>

Regression Tests
----------------

>>> pycddlib.Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = pycddlib.Matrix([[1], [2]])
>>> mat.lp_obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size
