"""The cddlib module wraps the cdd.h header file from Komei Fukuda's cddlib.

Matrix functions
================

>>> import cddlib
>>> mat1 = cddlib.Matrix([[1,2],[3,4]])
>>> mat1.rowsize
2
>>> mat1.colsize
2
>>> mat1.objective
0
>>> mat2 = cddlib.Matrix([[5,6]])
>>> mat1.appendRows(mat2)
>>> mat1.rowsize
3
"""

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

# include setoper.h to avoid compiler errors
cdef extern from "setoper.h":
    ctypedef unsigned long *set_type

# now include cdd.h
cdef extern from "cdd.h":

    ctypedef double mytype[1]
    ctypedef long dd_rowrange
    ctypedef long dd_colrange
    ctypedef long dd_bigrange
    ctypedef set_type dd_rowset
    ctypedef set_type dd_colset
    ctypedef long *dd_rowindex
    ctypedef int *dd_rowflag
    ctypedef long *dd_colindex
    ctypedef mytype **dd_Amatrix
    ctypedef mytype *dd_Arow
    ctypedef set_type *dd_SetVector

    # enums

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
        dd_NoRealNumberSupport,
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

    # structures

    ctypedef struct matrixdata:
        dd_rowrange rowsize
        dd_rowset linset
        dd_colrange colsize
        dd_RepresentationType representation
        dd_NumberType numbtype
        dd_Amatrix matrix
        dd_LPObjectiveType objective
        dd_Arow rowvec

    ctypedef struct dd_SetFamily
    ctypedef struct dd_LPSolution

    ctypedef matrixdata *dd_MatrixPtr
    ctypedef dd_SetFamily *dd_SetFamilyPtr
    ctypedef dd_LPSolution *dd_SetLPSolutionPtr

    # functions
    # not everything is defined here, just most common operations
    # add more as needed...

    cdef void dd_set_d(mytype, double)
    cdef void dd_set_si(mytype, signed long)
    cdef void dd_set_si2(mytype, signed long, unsigned long)

    cdef dd_MatrixPtr dd_CreateMatrix(dd_rowrange, dd_colrange)
    cdef void dd_FreeMatrix(dd_MatrixPtr)
    cdef dd_MatrixPtr dd_CopyMatrix(dd_MatrixPtr)
    cdef int dd_MatrixAppendTo(dd_MatrixPtr*, dd_MatrixPtr)
    cdef int dd_MatrixRowRemove(dd_MatrixPtr *M, dd_rowrange r)

# matrix class
cdef class Matrix:
    # pointer cointaining the matrix data
    cdef dd_MatrixPtr thisptr

    property rowsize:
        def __get__(self):
            return self.thisptr.rowsize

    property colsize:
        def __get__(self):
            return self.thisptr.colsize

    property representation:
        def __get__(self):
            return self.thisptr.representation

    property objective:
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType obj):
            self.thisptr.objective = obj

    def __cinit__(self, rows = None, numrows = None, numcols = None):
        """If matrixlist is None then create a numrows times numcols matrix
        with all elements zero. Otherwise load matrixlist (which is a Python
        list of Python lists) into the matrix."""
        # determine dimension
        if not rows is None:
            numrows = len(rows)
            if numrows > 0:
                numcols = len(rows[0])
            else:
                numcols = 0
        elif numrows is None or numcols is None:
            numrows = 0
            numcols = 0
        # create new matrix
        self.thisptr = dd_CreateMatrix(numrows, numcols)
        # load data
        if not rows is None:
            for rowindex, row in enumerate(rows):
                for colindex, value in enumerate(row):
                    dd_set_d(self.thisptr.matrix[rowindex][colindex], value)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.thisptr != NULL:
            dd_FreeMatrix(self.thisptr)
        self.thisptr = NULL

    def copy(self):
        """Make a copy of the matrix and return that copy."""
        # this hack fools pyrex into creating a Matrix object with NULL
        # thisptr; we must "cdef Matrix mat" because otherwise pyrex will not
        # recognize mat.thisptr as a C pointer
        cdef Matrix mat
        mat = Matrix(1, 1)
        mat.__dealloc__()
        # now assign to a copy
        mat.thisptr = dd_CopyMatrix(self.thisptr)
        # return the copy
        return mat

    def appendRows(self, Matrix other):
        """Append other to self (this corresponds to the dd_MatrixAppendTo
        function in cdd; to emulate the effect of dd_MatrixAppend, first call
        self.copy and then call append on the copy).

        The colsize must be equal in the two input matrices. It
        raises a ValueError if the input matrices are not appropriate. The new
        rowsize is set to the sum of the rowsizes of the original self and
        other. The matrixdata keeps everything else (i.e. numbertype,
        representation, etc) from self."""
        # call dd_AppendToMatrix
        success = dd_MatrixAppendTo(&self.thisptr, other.thisptr)
        # check result
        if success != 1:
            raise ValueError(
                "cannot append matrix because column sizes differ")

    def removeRow(self, dd_rowrange rownum):
        """Remove a row. Raises ValueError on failure."""
        # remove the row
        success = dd_MatrixRowRemove(&self.thisptr, rownum)
        # check the result
        if success != 1:
            raise ValueError(
                "cannot remove row %i" % rownum)

def setGlobalConstants():
    """Call this before using cdd."""
    dd_set_global_constants()

def freeGlobalConstants():
    """Call this when finished using cdd."""
    dd_free_global_constants()

