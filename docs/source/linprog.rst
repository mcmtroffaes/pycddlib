.. testsetup::

   import cdd
   import cdd.gmp
   from fractions import Fraction

.. currentmodule:: cdd

Solving Linear Programs
=======================

.. class:: LinProg(mat)

    A class for solving linear programs.

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
