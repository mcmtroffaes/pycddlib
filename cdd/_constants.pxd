"""Enums from cddlib."""

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

# to avoid compilation errors, include this first
cdef extern from "setoper.h":
    pass

cdef extern from "cdd.h":
    ctypedef enum dd_AdjacencyTestType:
        dd_Combinatorial
        dd_Algebraic

    ctypedef enum dd_NumberType:
        dd_Unknown
        dd_Real
        dd_Rational
        dd_Integer

    ctypedef enum dd_RepresentationType:
        dd_Unspecified
        dd_Inequality
        dd_Generator

    ctypedef enum dd_RowOrderType:
        dd_MaxIndex
        dd_MinIndex
        dd_MinCutoff
        dd_MaxCutoff
        dd_MixCutoff
        dd_LexMin
        dd_LexMax
        dd_RandomRow

    # not translated: dd_ConversionType, dd_IncidenceOutputType, dd_AdjacencyOutputType, dd_FileInputModeType

    ctypedef enum dd_ErrorType:
        dd_DimensionTooLarge
        dd_ImproperInputFormat
        dd_NegativeMatrixSize
        dd_EmptyVrepresentation
        dd_EmptyHrepresentation
        dd_EmptyRepresentation
        dd_IFileNotFound
        dd_OFileNotOpen
        dd_NoLPObjective
        dd_NoRealNumberSupport
        dd_NotAvailForH
        dd_NotAvailForV
        dd_CannotHandleLinearity
        dd_RowIndexOutOfRange
        dd_ColIndexOutOfRange
        dd_LPCycling
        dd_NumericallyInconsistent
        dd_NoError

    ctypedef enum dd_CompStatusType:
        dd_InProgress
        dd_AllFound
        dd_RegionEmpty

    ctypedef enum dd_LPObjectiveType:
        dd_LPnone
        dd_LPmax
        dd_LPmin

    ctypedef enum dd_LPSolverType:
        dd_CrissCross
        dd_DualSimplex

    ctypedef enum dd_LPStatusType:
        dd_LPSundecided
        dd_Optimal
        dd_Inconsistent
        dd_DualInconsistent
        dd_StrucInconsistent
        dd_StrucDualInconsistent
        dd_Unbounded
        dd_DualUnbounded

