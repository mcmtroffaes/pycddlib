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

.. autoclass:: RowOrderType(value)
    :show-inheritance:

    .. attribute::
        MAX_INDEX
        MIN_INDEX
        MIN_CUTOFF
        MAX_CUTOFF
        MIX_CUTOFF
        LEX_MIN
        LEX_MAX
        RANDOM_ROW


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

Basic Operations
----------------

.. autofunction:: matrix_append_to
.. autofunction:: matrix_copy
.. autofunction:: matrix_rank

Adjacency
---------

.. autofunction:: matrix_adjacency
.. autofunction:: matrix_weak_adjacency

Canonicalization
----------------

.. autofunction:: matrix_canonicalize
.. autofunction:: matrix_canonicalize_linearity
.. autofunction:: matrix_redundancy_remove

Redundancy Checks
-----------------

.. autofunction:: redundant
.. autofunction:: s_redundant
.. autofunction:: implicit_linearity

.. autofunction:: redundant_rows
.. autofunction:: s_redundant_rows
.. autofunction:: implicit_linearity_rows

Linear Programming
------------------

.. autofunction:: linprog_solve

Polyhedron Operations
---------------------

.. autofunction:: copy_input
.. autofunction:: copy_output
.. autofunction:: copy_inequalities
.. autofunction:: copy_generators
.. autofunction:: copy_adjacency
.. autofunction:: copy_incidence
.. autofunction:: copy_input_adjacency
.. autofunction:: copy_input_incidence

Elimination
-----------

.. autofunction:: fourier_elimination
.. autofunction:: block_elimination
