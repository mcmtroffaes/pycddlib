.. testsetup::

   import cdd

.. currentmodule:: cdd

Solving Linear Programs
=======================

.. class:: LinProg(mat)

    A class for solving linear programs.

    Bases: :class:`~cdd.NumberTypeable`

    :param mat: The matrix to load the linear program from.
    :type mat: :class:`~cdd.Matrix`

Methods and Attributes
----------------------

.. method:: LinProg.solve(solver=cdd.LPSolverType.DUAL_SIMPLEX)

        Solve linear program.

        :param solver: The method of solution (see :class:`~cdd.LPSolverType`).
        :type solver: :class:`int`

.. attribute:: LinProg.dual_solution

        A :class:`tuple` containing the dual solution.

.. attribute:: LinProg.obj_type

        Whether we are minimizing or maximizing (see
        :class:`~cdd.LPObjType`).

.. attribute:: LinProg.obj_value

        The optimal value of the objective function.

.. attribute:: LinProg.primal_solution

        A :class:`tuple` containing the primal solution.

.. attribute:: LinProg.solver

        The type of solver to use (see :class:`~cdd.LPSolverType`).

.. attribute:: LinProg.status

        The status of the linear program (see
        :class:`~cdd.LPStatusType`).


Example
-------

>>> import cdd
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
