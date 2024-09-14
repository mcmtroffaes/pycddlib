.. testsetup::

    import cdd.gmp
    from fractions import Fraction
    from pprint import pprint

Sets of Linear Inequalities and Generators
==========================================

Declaring matrices, and checking some attributes:

>>> mat1 = cdd.gmp.matrix_from_array([[1, 2],[3, 4]])
>>> pprint(mat1.array)
[[Fraction(1, 1), Fraction(2, 1)], [Fraction(3, 1), Fraction(4, 1)]]
>>> cdd.gmp.matrix_append_to(mat1, cdd.gmp.matrix_from_array([[5,6]]))
>>> pprint(mat1.array)
[[Fraction(1, 1), Fraction(2, 1)],
 [Fraction(3, 1), Fraction(4, 1)],
 [Fraction(5, 1), Fraction(6, 1)]]

Canonicalizing:

>>> array = [[2, 1, 2, 3], [0, 1, 2, 3], [3, 0, 1, 2], [0, -2, -4, -6]]
>>> mat = cdd.gmp.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
>>> cdd.gmp.matrix_canonicalize(mat)
({1, 3}, {0})
>>> pprint(mat.array)
[[Fraction(0, 1), Fraction(1, 1), Fraction(2, 1), Fraction(3, 1)],
 [Fraction(3, 1), Fraction(0, 1), Fraction(1, 1), Fraction(2, 1)]]
