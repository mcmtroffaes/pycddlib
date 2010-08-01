.. testsetup::

   from cddgmp import *

Solving Linear Programs
=======================

.. currentmodule:: cddgmp

.. autoclass:: LinProg(self, mat)

Methods
-------

.. automethod:: LinProg.solve(self, solver=LPSolverType.DUAL_SIMPLEX)

Attributes
----------

.. autoattribute:: LinProg.dual_solution
.. autoattribute:: LinProg.obj_type
.. autoattribute:: LinProg.obj_value
.. autoattribute:: LinProg.primal_solution
.. autoattribute:: LinProg.solver
.. autoattribute:: LinProg.status

Examples
--------

Note that the following examples presume:

>>> from cddgmp import *

This is the testlp2.c example that comes with cddlib.

>>> mat = Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]])
>>> mat.obj_type = LPObjType.MAX
>>> mat.obj_func = (0,3,4)
>>> print(mat)
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
(0, 3, 4)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> lp.status == LPStatusType.OPTIMAL
True
>>> print(lp.obj_value)
11/3
>>> print(" ".join("{0}".format(val) for val in lp.primal_solution))
1/3 2/3
>>> print(" ".join("{0}".format(val) for val in lp.dual_solution))
3/2 5/2

Another example.

>>> mat = Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
>>> mat.obj_type = LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
28/25
