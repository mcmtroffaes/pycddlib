Constants
=========

.. currentmodule:: cdd

.. not used elsewhere
   .. class:: AdjacencyTestType

    Adjacency test type.

    .. attribute::
       COMBINATORIAL
       ALGEBRAIC

.. not used elsewhere
   .. class:: CompStatus

    Status of computation.

    .. attribute::
       IN_PROGRESS
       ALL_FOUND
       REGION_EMPTY

.. not used elsewhere
   .. class:: Error

    Error constants.

    .. attribute::
       DIMENSION_TOO_LARGE
       IMPROPER_INPUT_FORMAT
       NEGATIVE_MATRIX_SIZE
       EMPTY_V_REPRESENTATION
       EMPTY_H_REPRESENTATION
       EMPTY_REPRESENTATION
       I_FILE_NOT_FOUND
       O_FILE_NOT_FOUND
       NO_LP_OBJECTIVE
       NO_REAL_NUMBER_SUPPORT
       NOT_AVAIL_FOR_H
       NOT_AVAIL_FOR_V
       CANNOT_HANDLE_LINEARITY
       ROW_INDEX_OUT_OF_RANGE
       COL_INDEX_OUT_OF_RANGE
       LP_CYCLING
       NUMERICALLY_INCONSISTENT
       NO_ERROR

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

.. not used elsewhere
   .. class:: NumberType

    Number type.

    .. attribute::
       UNKNOWN
       REAL
       RATIONAL
       INTEGER

.. class:: RepType

    Type of representation. Use :attr:`INEQUALITY` for
    H-representation and :attr:`GENERATOR` for V-representation.

    .. attribute::
       UNSPECIFIED
       INEQUALITY
       GENERATOR

.. not used elsewhere
   .. class:: RowOrderType

    The row order.

    .. attribute::
       MAX_INDEX
       MIN_INDEX
       MIN_CUTOFF
       MAX_CUTOFF
       MIX_CUTOFF
       LEX_MIN
       LEX_MAX
       RANDOM_ROW
