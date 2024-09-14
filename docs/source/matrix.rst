.. testsetup::

   import cdd
   import cdd.gmp
   from fractions import Fraction

Sets of Linear Inequalities and Generators
==========================================

Note that the following examples presume:

>>> import cdd
>>> import cdd.gmp
>>> from fractions import Fraction

Fractions
~~~~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cdd.gmp.matrix_from_array([[1, 2],[3, 4]])
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 2 2 rational
 1 2
 3 4
end
>>> print(mat1.array)
[[Fraction(1, 1), Fraction(2, 1)], [Fraction(3, 1), Fraction(4, 1)]]
>>> cdd.gmp.matrix_append_to(mat1, cdd.gmp.matrix_from_array([[5,6]]))
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 3 2 rational
 1 2
 3 4
 5 6
end
>>> print(mat1.array)
[[Fraction(1, 1), Fraction(2, 1)], [Fraction(3, 1), Fraction(4, 1)], [Fraction(5, 1), Fraction(6, 1)]]

Canonicalizing:

>>> mat = cdd.gmp.matrix_from_array([[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]])
>>> cdd.gmp.matrix_canonicalize(mat)  # oops... must specify rep_type!
Traceback (most recent call last):
    ...
ValueError: rep_type unspecified
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> cdd.gmp.matrix_canonicalize(mat)
(frozenset(...1, 3...), frozenset(...0...))
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
linearity 1  1
begin
 2 4 rational
 0 1 2 3
 3 0 1 2
end

Floats
~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cdd.matrix_from_array([[1,2],[3,4]])
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 2 2 real
 1 2
 3 4
end
>>> print(mat1.array)
[[1.0, 2.0], [3.0, 4.0]]
>>> cdd.matrix_append_to(mat1, cdd.matrix_from_array([[5,6]]))
>>> print(mat1) # doctest: +NORMALIZE_WHITESPACE
begin
 3 2 real
 1 2
 3 4
 5 6
end
>>> print(mat1.array)
[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]

Canonicalizing:

>>> mat = cdd.matrix_from_array([[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]])
>>> cdd.matrix_canonicalize(mat)  # oops... must specify rep_type!
Traceback (most recent call last):
    ...
ValueError: rep_type unspecified
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> cdd.matrix_canonicalize(mat)
(frozenset(...1, 3...), frozenset(...0...))
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
linearity 1  1
begin
 2 4 real
 0 1 2 3
 3 0 1 2
end
