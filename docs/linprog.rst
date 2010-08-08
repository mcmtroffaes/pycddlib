.. testsetup::

   import cdd

Solving Linear Programs
=======================

.. autoclass:: cdd.LinProg(mat)

Methods and Attributes
----------------------

.. automethod:: cdd.LinProg.solve(solver=cdd.LPSolverType.DUAL_SIMPLEX)

.. autoattribute:: cdd.LinProg.dual_solution
.. autoattribute:: cdd.LinProg.obj_type
.. autoattribute:: cdd.LinProg.obj_value
.. autoattribute:: cdd.LinProg.primal_solution
.. autoattribute:: cdd.LinProg.solver
.. autoattribute:: cdd.LinProg.status

Examples
--------

Note that the following examples presume:

>>> import cdd

Fractions
~~~~~~~~~

This is the testlp2.c example that comes with cddlib.

>>> mat = cdd.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]], number_type='fraction')
>>> mat.obj_type = cdd.LPObjType.MAX
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
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> lp.status == cdd.LPStatusType.OPTIMAL
True
>>> print(lp.obj_value)
11/3
>>> print(" ".join("{0}".format(val) for val in lp.primal_solution))
1/3 2/3
>>> print(" ".join("{0}".format(val) for val in lp.dual_solution))
3/2 5/2

Another example.

>>> mat = cdd.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]], number_type='fraction')
>>> mat.obj_type = cdd.LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
28/25

Floats
~~~~~~

This is the testlp2.c example that comes with cddlib.

>>> mat = cdd.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]], number_type='float')
>>> mat.obj_type = cdd.LPObjType.MAX
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
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> lp.status == cdd.LPStatusType.OPTIMAL
True
>>> print(lp.obj_value) # doctest: +ELLIPSIS
3.66666...
>>> print(" ".join("{0}".format(val) for val in lp.primal_solution)) # doctest: +ELLIPSIS
0.33333... 0.66666...
>>> print(" ".join("{0}".format(val) for val in lp.dual_solution))
1.5 2.5

Another example.

>>> mat = cdd.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]], number_type='float')
>>> mat.obj_type = cdd.LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1.0
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3.0
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = cdd.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
1.12
