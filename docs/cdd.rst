Further Examples
================

.. testsetup::

   from cdd import *
   from fractions import Fraction

For the sake of completeness, here are some more examples, using
:mod:`cdd` instead of :mod:`cddgmp`. All examples presume:

>>> from cdd import *
>>> from fractions import Fraction

Matrix
------

Declaring matrices, and checking some attributes:

>>> mat1 = Matrix([[1,2],[3,4]])
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

>>> Matrix([[1], [1, 2]]) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: rows have different lengths

>>> mat = Matrix([[1], [2]])
>>> mat.obj_func = (0, 0) # doctest: +ELLIPSIS
Traceback (most recent call last):
    ...
ValueError: objective function does not match matrix column size

Large number tests:

>>> print(Matrix([[10 ** 100]])) # doctest: +NORMALIZE_WHITESPACE
begin
 1 1 real
 1.000000000E+100
end
>>> print(Matrix([[Fraction(10 ** 100, 13 ** 90)]])) # doctest: +NORMALIZE_WHITESPACE +ELLIPSIS
begin
 1 1 real
 5.5603...E-01
end
>>> Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000']])[0][0]
1e+100
>>> Matrix([['10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000/17984638288961211871838956989189665890197130672912829203311075745019255958028927299020895173379216649']])[0][0] # doctest: +ELLIPSIS
0.55603...

LinProg
-------

This is the testlp2.c example that comes with cddlib.

>>> mat = Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]])
>>> mat.obj_type = LPObjType.MAX
>>> mat.obj_func = (0,3,4)
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
begin
 4 3 real
 1.333333333E+00 -2 -1
 6.666666667E-01 0 -1
 0 1 0
 0 0 1
end
maximize
 0 3 4
>>> print(mat.obj_func)
(0.0, 3.0, 4.0)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> lp.status == LPStatusType.OPTIMAL
True
>>> print(lp.obj_value) # doctest: +ELLIPSIS
3.66666...
>>> print(" ".join("{0}".format(val) for val in lp.primal_solution)) # doctest: +ELLIPSIS
0.33333... 0.66666...
>>> print(" ".join("{0}".format(val) for val in lp.dual_solution))
1.5 2.5

Another example.

>>> mat = Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
>>> mat.obj_type = LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1.0
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3.0
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
1.12

Polyhedron
----------

This is the sampleh1.ine example that comes with cddlib.

>>> mat = Matrix([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]])
>>> mat.rep_type = RepType.INEQUALITY
>>> poly = Polyhedron(mat)
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

>>> mat = Matrix([[7,-3,-0],[7,0,-3],[1,1,0],[1,0,1]])
>>> mat.rep_type = RepType.INEQUALITY
>>> print(mat) # doctest: +NORMALIZE_WHITESPACE
H-representation
begin
 4 3 real
 7 -3 0
 7 0 -3
 1 1 0
 1 0 1
end
>>> print(Polyhedron(mat).get_generators()) # doctest: +NORMALIZE_WHITESPACE
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
>>> print(Polyhedron(mat).get_generators()) # doctest: +NORMALIZE_WHITESPACE
V-representation
begin
 2 3 real
 1 -1 2
 1 0 2.333333333E+00
end



