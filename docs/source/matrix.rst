.. testsetup::

   import cdd
   import cdd.gmp
   from fractions import Fraction

Sets of Linear Inequalities and Generators
==========================================

.. function:: cdd.matrix_from_array(
        array: Sequence[Sequence[SupportsFloat]],
        lin_set: Container[int] = (),
        rep_type: RepType = RepType.UNSPECIFIED,
        obj_type: LPObjType = LPObjType.NONE,
        obj_func: Optional[Sequence[SupportsFloat]] = None,
    ) -> Matrix: ...

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

    .. warning::

       With :mod:`cdd.gmp`, passing a :class:`float` will result in a :exc:`TypeError`:

       >>> cdd.gmp.matrix_from_array([[1.12]])
       Traceback (most recent call last):
           ...
       TypeError: value 1.12 is not Rational

       If the float represents a fraction, you must pass it as a fraction explicitly:

       >>> print(cdd.gmp.matrix_from_array([[Fraction(112, 100)]]).array)
       [[Fraction(28, 25)]]

       If you really must use a float as a fraction,
       pass it explicitly to the :class:`~fractions.Fraction` constructor:

       >>> print(cdd.gmp.matrix_from_array([[Fraction(1.12)]]).array)
       [[Fraction(1261007895663739, 1125899906842624)]]

       As you can see from the output above, for typical use cases,
       you will not want to do this.

.. function:: matrix_canonicalize(matrix: Matrix) -> tuple[Set[int], Set[int]]

        Transform to canonical representation by recognizing all
        implicit linearities and all redundancies. These are returned
        as a pair of sets of row indices.

.. function:: matrix_copy(matrix: Matrix) -> Matrix

        Make a copy of *matrix* and return it.

.. function:: matrix_append_to(matrix1: Matrix, matrix2: Matrix) -> None

        Append *matrix2* to *matrix1*.

        The column size must be equal in the two input matrices. It
        raises a :exc:`ValueError` otherwise.

.. attribute:: Matrix.lin_set

        A :class:`Set` containing the rows of linearity
        (linear generators for the V-representation, and
        equalities for the H-representation).

.. attribute:: Matrix.rep_type

        Representation (see :class:`~cdd.RepType`).

.. attribute:: Matrix.obj_type

        Linear programming objective: maximize or minimize (see
        :class:`~cdd.LPObjType`).

.. attribute:: Matrix.obj_func

        A :class:`Sequence` containing the linear programming objective
        function.

Examples
--------

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
