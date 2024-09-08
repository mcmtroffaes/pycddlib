.. testsetup::

   import cdd
   import cddgmp
   from fractions import Fraction

.. currentmodule:: cdd

Sets of Linear Inequalities and Generators
==========================================

.. class:: Matrix(rows, linear=False)

    A class for working with sets of linear constraints and extreme
    points.

    A matrix :math:`[b \quad -A]` in the H-representation corresponds to a
    polyhedron described by

    .. math::
       A_i x &\le b_i \qquad \forall i\in\{1,\dots,n\}\setminus L \\
       A_i x &=   b_i \qquad \forall i\in L

    where :math:`L` is :attr:`~cdd.Matrix.lin_set` and :math:`A_i`
    corresponds to the :math:`i`-th row of :math:`A`.

    A matrix :math:`[t \quad V]` in the V-representation corresponds to a polyhedron
    described by

    .. math::
       \mathrm{conv}\{V_i\colon t_i=1\}+\mathrm{nonnegspan}\{V_i\colon t_i=0,i\not\in L\}+\mathrm{linspan}\{V_i\colon t_i=0,i\in L\}

    where :math:`L` is :attr:`~cdd.Matrix.lin_set` and :math:`V_i`
    corresponds to the :math:`i`-th row of :math:`V`. Here
    :math:`\mathrm{conv}` is the convex hull operator,
    :math:`\mathrm{nonnegspan}` is the non-negative span operator, and
    :math:`\mathrm{linspan}` is the linear span operator. All entries
    of :math:`t` must be either :math:`0` or :math:`1`.

    :param rows: The rows of the matrix.
        For :module:`cdd`, each element must be a :class:`float`.
        For :module:`cddgmp`, each element must be a :class:`~fractions.Fraction`.
    :type rows: :class:`list` of :class:`list`\ s.
    :param linear: Whether to add the rows to the
        :attr:`~cdd.Matrix.lin_set` or not.
    :type linear: :class:`bool`

    .. warning::

       With :module:`cddgmp`, beware when using floats:

       >>> cddgmp.Matrix([[1.12]])[0][0]
       Traceback (most recent call last):
       TypeError: value 1.12 is not Rational

       If the float represents a fraction, it is better to pass it as a
       fraction explicitly:

       >>> print(cddgmp.Matrix([[Fraction(112, 100)]])[0][0])
       28/25
       >>> print(cddgmp.Matrix([[Fraction('1.12')]])[0][0])
       28/25

Methods and Attributes
----------------------

.. method:: Matrix.__getitem__(key)

        Return a row, or a slice of rows, of the matrix.

        :param key: The row number, or slice of row numbers, to get.
        :type key: :class:`int` or :class:`slice`
        :rtype: :class:`tuple` of :class:`float` or :class:`~fractions.Fraction`

.. method:: Matrix.canonicalize()

        Transform to canonical representation by recognizing all
        implicit linearities and all redundancies. These are returned
        as a pair of sets of row indices.

.. method:: Matrix.copy()

        Make a copy of the matrix and return that copy.

.. method:: Matrix.extend(rows, linear=False)

        Append rows to self (this corresponds to the dd_MatrixAppendTo
        function in cdd; to emulate the effect of dd_MatrixAppend, first call
        copy and then call extend on the copy).

        The column size must be equal in the two input matrices. It
        raises a ValueError if the input rows are not appropriate.

        :param rows: The rows to append.
        :type rows: :class:`list` of :class:`list`\ s
        :param linear: Whether to add the rows to the :attr:`~cdd.Matrix.lin_set` or not.
        :type linear: :class:`bool`

.. attribute:: Matrix.row_size

        Number of rows.

.. attribute:: Matrix.col_size

        Number of columns.

.. attribute:: Matrix.lin_set

        A :class:`frozenset` containing the rows of linearity
        (linear generators for the V-representation, and
        equalities for the H-representation).

.. attribute:: Matrix.rep_type

        Representation (see :class:`~cdd.RepType`).

.. attribute:: Matrix.obj_type

        Linear programming objective: maximize or minimize (see
        :class:`~cdd.LPObjType`).

.. attribute:: Matrix.obj_func

        A :class:`tuple` containing the linear programming objective
        function.

Examples
--------

Note that the following examples presume:

>>> import cdd
>>> from fractions import Fraction

Fractions
~~~~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cddgmp.Matrix([[1, 2],[3, 4]])
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
>>> mat1.extend([[5,6]]) # keeps number type!
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

Canonicalizing:

>>> mat = cddgmp.Matrix([[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]])
>>> mat.canonicalize()  # oops... must specify rep_type!
Traceback (most recent call last):
    ...
ValueError: rep_type unspecified
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> mat.canonicalize()
(frozenset(...1, 3...), frozenset(...0...))
>>> print(mat)
H-representation
linearity 1  1
begin
 2 4 rational
 0 1 2 3
 3 0 1 2
end

Large number tests:

>>> print(cddgmp.Matrix([[10 ** 100]]))
begin
 1 1 rational
 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
end
>>> print(cddgmp.Matrix([[Fraction(10 ** 100, 13 ** 102)]]))
begin
 1 1 rational
 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169
end
>>> cddgmp.Matrix([[10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000]])[0][0]
Fraction(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 1)
>>> cddgmp.Matrix([[Fraction(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169)]])[0][0]
Fraction(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, 419007633753249358163371317520192208024352885070865054318259957799640820272617869666750277036856988452476999386169)

Floats
~~~~~~

Declaring matrices, and checking some attributes:

>>> mat1 = cdd.Matrix([[1,2],[3,4]])
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

Canonicalizing:

>>> mat = cdd.Matrix([[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]])
>>> mat.canonicalize()  # oops... must specify rep_type!
Traceback (most recent call last):
    ...
ValueError: rep_type unspecified
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> mat.canonicalize()
(frozenset(...1, 3...), frozenset(...0...))
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
linearity 1  1
begin
 2 4 real
 0 1 2 3
 3 0 1 2
end
