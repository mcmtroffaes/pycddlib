Solving Linear Programs
=======================

.. currentmodule:: pycddlib

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

This is the testlp2.c example that comes with cddlib.

>>> import pycddlib
>>> mat = pycddlib.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]])
>>> mat.obj_type = pycddlib.LPObjType.MAX
>>> mat.obj_func = (0,3,4)
>>> print mat
begin
 4 3 rational
 4/3 -2 -1
 2/3 0 -1
 0 1 0
 0 0 1
end
maximize
 0 3 4
<BLANKLINE>
>>> print(mat.obj_func)
(0, 3, 4)
>>> lp = pycddlib.LinProg(mat)
>>> lp.solve()
>>> lp.status == pycddlib.LPStatusType.OPTIMAL
True
>>> print(lp.obj_value)
11/3
>>> print(" ".join("{0}".format(val) for val in lp.primal_solution))
1/3 2/3
>>> print(" ".join("{0}".format(val) for val in lp.dual_solution))
3/2 5/2
