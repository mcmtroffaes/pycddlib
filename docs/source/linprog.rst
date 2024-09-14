.. testsetup::

   import cdd
   import cdd.gmp
   from fractions import Fraction

Solving Linear Programs
=======================

>>> mat = cdd.gmp.matrix_from_array([[Fraction(4, 3),-2,-1],[Fraction(2, 3),0,-1],[0,1,0],[0,0,1]])
>>> mat.obj_type = cdd.LPObjType.MAX
>>> mat.obj_func = (0,3,4)
>>> mat.rep_type = cdd.RepType.INEQUALITY
>>> print(mat)
H-representation
begin
 4 3 rational
 4/3 -2 -1
 2/3 0 -1
 0 1 0
 0 0 1
end
maximize
 0 3 4
>>> print(mat.obj_func)
[Fraction(0, 1), Fraction(3, 1), Fraction(4, 1)]
>>> lp = cdd.gmp.linprog_from_matrix(mat)
>>> cdd.gmp.linprog_solve(lp)
>>> lp.status == cdd.LPStatusType.OPTIMAL
True
>>> lp.obj_value
Fraction(11, 3)
>>> lp.primal_solution
[Fraction(1, 3), Fraction(2, 3)]
>>> lp.dual_solution
[(0, Fraction(3, 2)), (1, Fraction(5, 2))]
