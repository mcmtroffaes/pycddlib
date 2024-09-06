# cython: language_level=3

"""Python wrapper for Komei Fukuda's cddlib."""

# pycddlib is a Python wrapper for Komei Fukuda's cddlib
# Copyright (c) 2008-2024, Matthias C. M. Troffaes
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

# to avoid compilation errors, includes must follow this order

include "extern_preamble.pxi"
include "extern_myfloat.pxi"
include "extern_cddlib_f.pxi"

# wrapper classes to expose enums

cpdef enum AdjacencyTestType:
    COMBINATORIAL = ddf_Combinatorial
    ALGEBRAIC     = ddf_Algebraic

cpdef enum NumberType:
    UNKNOWN  = ddf_Unknown
    REAL     = ddf_Real
    RATIONAL = ddf_Rational
    INTEGER  = ddf_Integer

cpdef enum RepType:
    UNSPECIFIED = ddf_Unspecified
    INEQUALITY  = ddf_Inequality
    GENERATOR   = ddf_Generator

cpdef enum RowOrderType:
    MAX_INDEX  = ddf_MaxIndex
    MIN_INDEX  = ddf_MinIndex
    MIN_CUTOFF = ddf_MinCutoff
    MAX_CUTOFF = ddf_MaxCutoff
    MIX_CUTOFF = ddf_MixCutoff
    LEX_MIN    = ddf_LexMin
    LEX_MAX    = ddf_LexMax
    RANDOM_ROW = ddf_RandomRow

cpdef enum Error:
    DIMENSION_TOO_LARGE      = ddf_DimensionTooLarge
    IMPROPER_INPUT_FORMAT    = ddf_ImproperInputFormat
    NEGATIVE_MATRIX_SIZE     = ddf_NegativeMatrixSize
    EMPTY_V_REPRESENTATION   = ddf_EmptyVrepresentation
    EMPTY_H_REPRESENTATION   = ddf_EmptyHrepresentation
    EMPTY_REPRESENTATION     = ddf_EmptyRepresentation
    I_FILE_NOT_FOUND         = ddf_IFileNotFound
    O_FILE_NOT_FOUND         = ddf_OFileNotOpen
    NO_LP_OBJECTIVE          = ddf_NoLPObjective
    NO_REAL_NUMBER_SUPPORT   = ddf_NoRealNumberSupport
    NOT_AVAIL_FOR_H          = ddf_NotAvailForH
    NOT_AVAIL_FOR_V          = ddf_NotAvailForV
    CANNOT_HANDLE_LINEARITY  = ddf_CannotHandleLinearity
    ROW_INDEX_OUT_OF_RANGE   = ddf_RowIndexOutOfRange
    COL_INDEX_OUT_OF_RANGE   = ddf_ColIndexOutOfRange
    LP_CYCLING               = ddf_LPCycling
    NUMERICALLY_INCONSISTENT = ddf_NumericallyInconsistent
    NO_ERROR                 = ddf_NoError

cpdef enum CompStatus:
    IN_PROGRESS  = ddf_InProgress
    ALL_FOUND    = ddf_AllFound
    REGION_EMPTY = ddf_RegionEmpty

cpdef enum LPObjType:
    NONE = ddf_LPnone
    MAX  = ddf_LPmax
    MIN  = ddf_LPmin

cpdef enum LPSolverType:
    CRISS_CROSS  = ddf_CrissCross
    DUAL_SIMPLEX = ddf_DualSimplex

cpdef enum LPStatusType:
    UNDECIDED             = ddf_LPSundecided
    OPTIMAL               = ddf_Optimal
    INCONSISTENT          = ddf_Inconsistent
    DUAL_INCONSISTENT      = ddf_DualInconsistent
    STRUC_INCONSISTENT     = ddf_StrucInconsistent
    STRUC_DUAL_INCONSISTENT = ddf_StrucDualInconsistent
    UNBOUNDED             = ddf_Unbounded
    DUAL_UNBOUNDED         = ddf_DualUnbounded
