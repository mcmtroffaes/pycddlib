.. testsetup::

   import cdd
   import cdd._fraction
   import cdd._float

Solving Linear Programs
=======================

.. class:: cdd._float.LinProg(mat)
.. autoclass:: cdd._fraction.LinProg(mat)

Methods and Attributes
----------------------

.. automethod:: cdd._fraction.LinProg.solve(solver=cdd.LPSolverType.DUAL_SIMPLEX)

.. autoattribute:: cdd._fraction.LinProg.dual_solution
.. autoattribute:: cdd._fraction.LinProg.obj_type
.. autoattribute:: cdd._fraction.LinProg.obj_value
.. autoattribute:: cdd._fraction.LinProg.primal_solution
.. autoattribute:: cdd._fraction.LinProg.solver
.. autoattribute:: cdd._fraction.LinProg.status

The :class:`cdd._float.Matrix` class has similar methods and
attributes.

Wrapper
-------

.. autoclass:: cdd.LinProg(mat)

.. attribute:: cdd.LinProg.data

   A :class:`cdd._fraction.LinProg` or :class:`cdd._float.LinProg`
   instance.

Examples
--------

Note that the following examples presume:

>>> import cdd
>>> import cdd._fraction
>>> import cdd._float

Wrapper
~~~~~~~

>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='float')
>>> lp = cdd.LinProg(mat)
>>> type(lp.data)
<type 'cdd._float.LinProg'>
>>> mat = cdd.Matrix([[1, 2, 3], [2, 1, 9]], number_type='fraction')
>>> lp = cdd.LinProg(mat)
>>> type(lp.data)
<type 'cdd._fraction.LinProg'>

Fractions
~~~~~~~~~

This is the testlp2.c example that comes with cddlib.

>>> mat = cdd._fraction.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]])
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
>>> lp = cdd._fraction.LinProg(mat)
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

>>> mat = cdd._fraction.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
>>> mat.obj_type = cdd.LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = cdd._fraction.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = cdd._fraction.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = cdd._fraction.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
28/25

Floats
~~~~~~

This is the testlp2.c example that comes with cddlib.

>>> mat = cdd._float.Matrix([['4/3',-2,-1],['2/3',0,-1],[0,1,0],[0,0,1]])
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
>>> lp = cdd._float.LinProg(mat)
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

>>> mat = cdd._float.Matrix([[1,-1,-1,-1],[-1,1,1,1],[0,1,0,0],[0,0,1,0],[0,0,0,1]])
>>> mat.obj_type = cdd.LPObjType.MIN
>>> mat.obj_func = (0,1,2,3)
>>> lp = cdd._float.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
1.0
>>> mat.obj_func = (0,-1,-2,-3)
>>> lp = cdd._float.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value)
-3.0
>>> mat.obj_func = (0,'1.12','1.2','1.3')
>>> lp = cdd._float.LinProg(mat)
>>> lp.solve()
>>> print(lp.obj_value) # 28/25 is 1.12
1.12
