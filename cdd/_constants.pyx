"""Common declarations for both float and fraction versions of cddlib."""

# pycddlib is a Python wrapper for Komei Fukuda's cddlib
# Copyright (c) 2008, Matthias Troffaes
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# utility functions

cdef FILE *_tmpfile() except NULL:
     cdef FILE *result
     result = tmpfile()
     if result == NULL:
         raise RuntimeError("failed to create temporary file")
     return result

cdef _tmpread(FILE *pfile):
    cdef char result[1024]
    cdef size_t num_bytes
    # read the file
    fseek(pfile, 0, SEEK_SET)
    num_bytes = fread(result, 1, 1024, pfile)
    # close the file
    fclose(pfile)
    # return result
    return python_unicode.PyUnicode_DecodeUTF8(result, num_bytes, 'strict')

cdef _get_set(set_type set_):
    """Create Python frozenset from given set_type."""
    cdef long elem
    return frozenset([elem - 1
                      for elem from 1 <= elem <= set_[0]
                      if set_member(elem, set_)])

cdef _set_set(set_type set_, pset):
    """Set elements of set_type by elements from Python set."""
    cdef long elem
    for elem from 1 <= elem <= set_[0]:
        if elem - 1 in pset:
            set_addelem(set_, elem)
        else:
            set_delelem(set_, elem)

# extension types to wrap the cddlib enums

cdef class AdjacencyTestType:
    """Adjacency test type.

    .. attribute::
       COMBINATORIAL
       ALGEBRAIC
    """
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC     = dd_Algebraic

cdef class NumberType:
    """Number type.

    .. attribute::
       UNKNOWN
       REAL
       RATIONAL
       INTEGER
    """
    UNKNOWN  = dd_Unknown
    REAL     = dd_Real
    RATIONAL = dd_Rational
    INTEGER  = dd_Integer

cdef class RepType:
    """Type of representation. Use :attr:`INEQUALITY` for
    H-representation and :attr:`GENERATOR` for V-representation.

    .. attribute::
       UNSPECIFIED
       INEQUALITY
       GENERATOR
    """

    UNSPECIFIED = dd_Unspecified
    INEQUALITY  = dd_Inequality
    GENERATOR   = dd_Generator

cdef class RowOrderType:
    """The row order.

    .. attribute::
       MAX_INDEX
       MIN_INDEX
       MIN_CUTOFF
       MAX_CUTOFF
       MIX_CUTOFF
       LEX_MIN
       LEX_MAX
       RANDOM_ROW
    """
    MAX_INDEX  = dd_MaxIndex
    MIN_INDEX  = dd_MinIndex
    MIN_CUTOFF = dd_MinCutoff
    MAX_CUTOFF = dd_MaxCutoff
    MIX_CUTOFF = dd_MixCutoff
    LEX_MIN    = dd_LexMin
    LEX_MAX    = dd_LexMax
    RANDOM_ROW = dd_RandomRow

cdef class Error:
    """Error constants.

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
    """
    DIMENSION_TOO_LARGE      = dd_DimensionTooLarge
    IMPROPER_INPUT_FORMAT    = dd_ImproperInputFormat
    NEGATIVE_MATRIX_SIZE     = dd_NegativeMatrixSize
    EMPTY_V_REPRESENTATION   = dd_EmptyVrepresentation
    EMPTY_H_REPRESENTATION   = dd_EmptyHrepresentation
    EMPTY_REPRESENTATION     = dd_EmptyRepresentation
    I_FILE_NOT_FOUND         = dd_IFileNotFound
    O_FILE_NOT_FOUND         = dd_OFileNotOpen
    NO_LP_OBJECTIVE          = dd_NoLPObjective
    NO_REAL_NUMBER_SUPPORT   = dd_NoRealNumberSupport
    NOT_AVAIL_FOR_H          = dd_NotAvailForH
    NOT_AVAIL_FOR_V          = dd_NotAvailForV
    CANNOT_HANDLE_LINEARITY  = dd_CannotHandleLinearity
    ROW_INDEX_OUT_OF_RANGE   = dd_RowIndexOutOfRange
    COL_INDEX_OUT_OF_RANGE   = dd_ColIndexOutOfRange
    LP_CYCLING               = dd_LPCycling
    NUMERICALLY_INCONSISTENT = dd_NumericallyInconsistent
    NO_ERROR                 = dd_NoError

cdef class CompStatus:
    """Status of computation.

    .. attribute::
       IN_PROGRESS
       ALL_FOUND
       REGION_EMPTY
    """
    IN_PROGRESS  = dd_InProgress
    ALL_FOUND    = dd_AllFound
    REGION_EMPTY = dd_RegionEmpty

cdef class LPObjType:
    """Type of objective for a linear program.

    .. attribute::
       NONE
       MAX
       MIN
    """
    NONE = dd_LPnone
    MAX  = dd_LPmax
    MIN  = dd_LPmin

cdef class LPSolverType:
    """Type of solver for a linear program.

    .. attribute::
       CRISS_CROSS
       DUAL_SIMPLEX
    """
    CRISS_CROSS  = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

cdef class LPStatusType:
    """Status of a linear program.

    .. attribute::
       UNDECIDED
       OPTIMAL
       INCONSISTENT
       DUAL_INCONSISTENT
       STRUC_INCONSISTENT
       STRUC_DUAL_INCONSISTENT
       UNBOUNDED
       DUAL_UNBOUNDED
    """
    UNDECIDED             = dd_LPSundecided
    OPTIMAL               = dd_Optimal
    INCONSISTENT          = dd_Inconsistent
    DUALINCONSISTENT      = dd_DualInconsistent
    STRUCINCONSISTENT     = dd_StrucInconsistent
    STRUCDUALINCONSISTENT = dd_StrucDualInconsistent
    UNBOUNDED             = dd_Unbounded
    DUALUNBOUNDED         = dd_DualUnbounded
