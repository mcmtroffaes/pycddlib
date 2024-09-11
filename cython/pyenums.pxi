# pycddlib is a Python wrapper for Komei Fukuda's cddlib
# Copyright (c) 2008-2024, Matthias Troffaes
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

# wrapper classes to expose enums
# currently unused enums are marked as private

cpdef enum _AdjacencyTestType:
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC = dd_Algebraic

cpdef enum _NumberType:
    UNKNOWN = dd_Unknown
    REAL = dd_Real
    RATIONAL = dd_Rational
    INTEGER = dd_Integer

cpdef enum RepType:
    UNSPECIFIED = dd_Unspecified
    INEQUALITY = dd_Inequality
    GENERATOR = dd_Generator

cpdef enum _RowOrderType:
    MAX_INDEX = dd_MaxIndex
    MIN_INDEX = dd_MinIndex
    MIN_CUTOFF = dd_MinCutoff
    MAX_CUTOFF = dd_MaxCutoff
    MIX_CUTOFF = dd_MixCutoff
    LEX_MIN = dd_LexMin
    LEX_MAX = dd_LexMax
    RANDOM_ROW = dd_RandomRow

cpdef enum _Error:
    DIMENSION_TOO_LARGE = dd_DimensionTooLarge
    IMPROPER_INPUT_FORMAT = dd_ImproperInputFormat
    NEGATIVE_MATRIX_SIZE = dd_NegativeMatrixSize
    EMPTY_V_REPRESENTATION = dd_EmptyVrepresentation
    EMPTY_H_REPRESENTATION = dd_EmptyHrepresentation
    EMPTY_REPRESENTATION = dd_EmptyRepresentation
    I_FILE_NOT_FOUND = dd_IFileNotFound
    O_FILE_NOT_FOUND = dd_OFileNotOpen
    NO_LP_OBJECTIVE = dd_NoLPObjective
    NO_REAL_NUMBER_SUPPORT = dd_NoRealNumberSupport
    NOT_AVAIL_FOR_H = dd_NotAvailForH
    NOT_AVAIL_FOR_V = dd_NotAvailForV
    CANNOT_HANDLE_LINEARITY = dd_CannotHandleLinearity
    ROW_INDEX_OUT_OF_RANGE = dd_RowIndexOutOfRange
    COL_INDEX_OUT_OF_RANGE = dd_ColIndexOutOfRange
    LP_CYCLING = dd_LPCycling
    NUMERICALLY_INCONSISTENT = dd_NumericallyInconsistent
    NO_ERROR = dd_NoError

cpdef enum _CompStatus:
    IN_PROGRESS = dd_InProgress
    ALL_FOUND = dd_AllFound
    REGION_EMPTY = dd_RegionEmpty

cpdef enum LPObjType:
    NONE = dd_LPnone
    MAX = dd_LPmax
    MIN = dd_LPmin

cpdef enum LPSolverType:
    CRISS_CROSS = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

cpdef enum LPStatusType:
    UNDECIDED = dd_LPSundecided
    OPTIMAL = dd_Optimal
    INCONSISTENT = dd_Inconsistent
    DUAL_INCONSISTENT = dd_DualInconsistent
    STRUC_INCONSISTENT = dd_StrucInconsistent
    STRUC_DUAL_INCONSISTENT = dd_StrucDualInconsistent
    UNBOUNDED = dd_Unbounded
    DUAL_UNBOUNDED = dd_DualUnbounded
