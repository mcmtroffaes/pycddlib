LinProg
=======

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
>>> mat = pycddlib.Matrix([[4.0/3.0,-2,-1],[2.0/3.0,0,-1],[0,1,0],[0,0,1]])
>>> mat.obj_type = pycddlib.LPObjType.MAX
>>> mat.obj_func = (0,3,4)
>>> print mat
begin
 4 3 real
  1.333333333E+00 -2 -1
  6.666666667E-01  0 -1
  0  1  0
  0  0  1
end
maximize
  0  3  4
<BLANKLINE>
>>> print(mat.obj_func)
(0.0, 3.0, 4.0)
>>> lp = pycddlib.LinProg(mat)
>>> lp.solve()
>>> lp.status == pycddlib.LPStatusType.OPTIMAL
True
>>> print("{0:.3f}".format(lp.obj_value))
3.667
>>> print(" ".join("{0:.3f}".format(val) for val in lp.primal_solution))
0.333 0.667
>>> print(" ".join("{0:.3f}".format(val) for val in lp.dual_solution))
1.500 2.500
