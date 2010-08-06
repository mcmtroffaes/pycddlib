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

# some of cdd's functions read and write files
cdef extern from "stdio.h" nogil:
    ctypedef struct FILE
    ctypedef int size_t
    FILE *stdout
    FILE *tmpfile()
    size_t fread(void *ptr, size_t size, size_t count, FILE *stream)
    size_t fwrite(void *ptr, size_t size, size_t count, FILE *stream)
    int SEEK_SET
    int SEEK_CUR
    int SEEK_END
    int fseek(FILE *stream, long int offset, int origin)
    long int ftell(FILE *stream)
    int fclose(FILE *stream)

cdef extern from "time.h":
    ctypedef long time_t

# actual cddlib imports

# to avoid compilation errors, include this first
cdef extern from "setoper.h":
    ctypedef unsigned long *set_type
    cdef unsigned long set_blocks(long len)
    cdef void set_initialize(set_type *setp,long len)
    cdef void set_free(set_type set)
    cdef void set_emptyset(set_type set)
    cdef void set_copy(set_type setcopy,set_type set)
    cdef void set_addelem(set_type set, long elem)
    cdef void set_delelem(set_type set, long elem)
    cdef void set_int(set_type set,set_type set1,set_type set2)
    cdef void set_uni(set_type set,set_type set1,set_type set2)
    cdef void set_diff(set_type set,set_type set1,set_type set2)
    cdef void set_compl(set_type set,set_type set1)
    cdef int set_subset(set_type set1,set_type set2)
    cdef int set_member(long elem, set_type set)
    cdef long set_card(set_type set)
    cdef long set_groundsize(set_type set)
    cdef void set_write(set_type set)
    cdef void set_fwrite(FILE *f,set_type set)
    cdef void set_fwrite_compl(FILE *f,set_type set)
    cdef void set_binwrite(set_type set)
    cdef void set_fbinwrite(FILE *f,set_type set)

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

# common utility functions

cdef FILE *_tmpfile() except NULL
cdef _tmpread(FILE *pfile)
cdef _get_set(set_type set_)
cdef _set_set(set_type set_, pset)
