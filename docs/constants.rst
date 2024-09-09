Constants
=========

.. currentmodule:: cdd

.. class:: LPObjType

    Type of objective for a linear program.

    .. attribute::
       NONE
       MAX
       MIN

.. class:: LPSolverType

    Type of solver for a linear program.

    .. attribute::
       CRISS_CROSS
       DUAL_SIMPLEX

.. class:: LPStatusType

    Status of a linear program.

    .. attribute::
       UNDECIDED
       OPTIMAL
       INCONSISTENT
       DUAL_INCONSISTENT
       STRUC_INCONSISTENT
       STRUC_DUAL_INCONSISTENT
       UNBOUNDED
       DUAL_UNBOUNDED

.. class:: RepType

    Type of representation. Use :attr:`INEQUALITY` for
    H-representation and :attr:`GENERATOR` for V-representation.

    .. attribute::
       UNSPECIFIED
       INEQUALITY
       GENERATOR
