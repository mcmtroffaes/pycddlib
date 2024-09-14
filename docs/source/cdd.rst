The :mod:`cdd` module
=====================

.. module:: cdd

.. currentmodule:: cdd

Enums
-----

.. autoclass has trouble finding attributes of enums, so list explicitly

.. autoclass:: LPObjType(value)
    :show-inheritance:

    .. attribute::
        NONE
        MAX
        MIN

.. autoclass:: LPSolverType(value)
    :show-inheritance:

    .. attribute::
        CRISS_CROSS
        DUAL_SIMPLEX

.. autoclass:: LPStatusType(value)
    :show-inheritance:

    .. attribute::
        UNDECIDED
        OPTIMAL
        INCONSISTENT
        DUAL_INCONSISTENT
        STRUC_INCONSISTENT
        STRUC_DUAL_INCONSISTENT
        UNBOUNDED
        DUAL_UNBOUNDED

.. autoclass:: RepType(value)
    :show-inheritance:

    .. attribute::
        UNSPECIFIED
        INEQUALITY
        GENERATOR

Classes
-------

.. autoclass:: Matrix
.. autoclass:: LinProg
.. autoclass:: Polyhedron

Factories
---------

.. autofunction:: matrix_from_array
.. autofunction:: linprog_from_array
.. autofunction:: linprog_from_matrix
.. autofunction:: polyhedron_from_matrix

Functions
---------

.. autofunction:: matrix_append_to
.. autofunction:: matrix_canonicalize
.. autofunction:: matrix_copy

.. autofunction:: linprog_solve

.. autofunction:: copy_input
.. autofunction:: copy_output
.. autofunction:: copy_inequalities
.. autofunction:: copy_generators
.. autofunction:: copy_adjacency
.. autofunction:: copy_incidence
.. autofunction:: copy_input_adjacency
.. autofunction:: copy_input_incidence
