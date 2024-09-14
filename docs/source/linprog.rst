.. testsetup::

   import cdd.gmp
   from fractions import Fraction

Solving Linear Programs
=======================

>>> array = [[Fraction(4, 3),-2,-1],[Fraction(2, 3),0,-1],[0,1,0],[0,0,1],[0,3,4]]
>>> lp = cdd.gmp.linprog_from_array(array, obj_type=cdd.LPObjType.MAX)
>>> cdd.gmp.linprog_solve(lp)
>>> lp.status == cdd.LPStatusType.OPTIMAL
True
>>> lp.obj_value
Fraction(11, 3)
>>> lp.primal_solution
[Fraction(1, 3), Fraction(2, 3)]
>>> lp.dual_solution
[(0, Fraction(3, 2)), (1, Fraction(5, 2))]
