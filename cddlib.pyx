"""The cddlib module wraps the cdd.h header file from Komei Fukuda's cddlib.

Matrix functions
================

>>> import cddlib
>>> mat1 = cddlib.Matrix([[1,2],[3,4]])
>>> print mat1
[  1.000  2.000 ]
[  3.000  4.000 ]
objective: None
<BLANKLINE>
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
>>> print mat1
[  1.000  2.000 ]
[  3.000  4.000 ]
[  5.000  6.000 ]
objective: None
<BLANKLINE>
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

    ctypedef int dd_boolean
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
    ctypedef mytype **dd_Bmatrix
    ctypedef set_type *dd_Aincidence

# enums

cdef extern from "cdd.h":
    ctypedef enum dd_AdjacencyTestType:
        dd_Combinatorial
        dd_Algebraic

ADJ_COMBINATORIAL = dd_Combinatorial
ADJ_ALGEBRAIC     = dd_Algebraic

cdef extern from "cdd.h":
    ctypedef enum dd_NumberType:
        dd_Unknown
        dd_Real
        dd_Rational
        dd_Integer

NUMTYPE_UNKNOWN  = dd_Unknown
NUMTYPE_REAL     = dd_Real
NUMTYPE_RATIONAL = dd_Rational
NUMTYPE_INTEGER  = dd_Integer

cdef extern from "cdd.h":
    ctypedef enum dd_RepresentationType:
        dd_Unspecified
        dd_Inequality
        dd_Generator

REP_UNSPECIFIED = dd_Unspecified
REP_INEQUALITY  = dd_Inequality
REP_GENERATOR   = dd_Generator

cdef extern from "cdd.h":
    ctypedef enum dd_RowOrderType:
        dd_MaxIndex
        dd_MinIndex
        dd_MinCutoff
        dd_MaxCutoff
        dd_MixCutoff
        dd_LexMin
        dd_LexMax
        dd_RandomRow

ROWORDER_MAXINDEX  = dd_MaxIndex
ROWORDER_MININDEX  = dd_MinIndex
ROWORDER_MINCUTOFF = dd_MinCutoff
ROWORDER_MAXCUTOFF = dd_MaxCutoff
ROWORDER_MIXCUTOFF = dd_MixCutoff
ROWORDER_LEXMIN    = dd_LexMin
ROWORDER_LEXMAX    = dd_LexMax
ROWORDER_RANDOMROW = dd_RandomRow

    # not translated: dd_ConversionType, dd_IncidenceOutputType, dd_AdjacencyOutputType, dd_FileInputModeType

cdef extern from "cdd.h":
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

ERR_DIMENSION_TOO_LARGE      = dd_DimensionTooLarge
ERR_IMPROPER_INPUT_FORMAT    = dd_ImproperInputFormat
ERR_NEGATIVE_MATRIX_SIZE     = dd_NegativeMatrixSize
ERR_EMPTY_V_REPRESENTATION   = dd_EmptyVrepresentation
ERR_EMPTY_H_REPRESENTATION   = dd_EmptyHrepresentation
ERR_EMPTY_REPRESENTATION     = dd_EmptyRepresentation
ERR_I_FILE_NOT_FOUND         = dd_IFileNotFound
ERR_O_FILE_NOT_FOUND         = dd_OFileNotOpen
ERR_NO_LP_OBJECTIVE          = dd_NoLPObjective
ERR_NO_REAL_NUMBER_SUPPORT   = dd_NoRealNumberSupport
ERR_NOT_AVAIL_FOR_H          = dd_NotAvailForH
ERR_NOT_AVAIL_FOR_V          = dd_NotAvailForV
ERR_CANNOT_HANDLE_LINEARITY  = dd_CannotHandleLinearity
ERR_ROW_INDEX_OUT_OF_RANGE   = dd_RowIndexOutOfRange
ERR_COL_INDEX_OUT_OF_RANGE   = dd_ColIndexOutOfRange
ERR_LP_CYCLING               = dd_LPCycling
ERR_NUMERICALLY_INCONSISTENT = dd_NumericallyInconsistent
ERR_NO_ERROR                 = dd_NoError

cdef extern from "cdd.h":
    ctypedef enum dd_CompStatusType:
        dd_InProgress
        dd_AllFound
        dd_RegionEmpty

COMPSTATUS_INPROGRESS  = dd_InProgress
COMPSTATUS_ALLFOUND    = dd_AllFound
COMPSTATUS_REGIONEMPTY = dd_RegionEmpty

cdef extern from "cdd.h":
    ctypedef enum dd_LPObjectiveType:
        dd_LPnone
        dd_LPmax
        dd_LPmin

LPOBJ_NONE = dd_LPnone
LPOBJ_MAX  = dd_LPmax
LPOBJ_MIN  = dd_LPmin

cdef extern from "cdd.h":
    ctypedef enum dd_LPSolverType:
        dd_CrissCross
        dd_DualSimplex

LPSOLVER_CRISSCROSS  = dd_CrissCross
LPSOLVER_DUALSIMPLEX = dd_DualSimplex

cdef extern from "cdd.h":
    ctypedef enum dd_LPStatusType:
        dd_LPSundecided
        dd_Optimal
        dd_Inconsistent
        dd_DualInconsistent
        dd_StrucInconsistent
        dd_StrucDualInconsistent
        dd_Unbounded
        dd_DualUnbounded

LPSTATUS_UNDECIDED             = dd_LPSundecided
LPSTATUS_OPTIMAL               = dd_Optimal
LPSTATUS_INCONSISTENT          = dd_Inconsistent
LPSTATUS_DUALINCONSISTENT      = dd_DualInconsistent
LPSTATUS_STRUCINCONSISTENT     = dd_StrucInconsistent
LPSTATUS_STRUCDUALINCONSISTENT = dd_StrucDualInconsistent
LPSTATUS_UNBOUNDED             = dd_Unbounded
LPSTATUS_DUALUNBOUNDED         = dd_DualUnbounded

# structures

cdef extern from "cdd.h":
    ctypedef struct matrixdata:
        dd_rowrange rowsize
        dd_rowset linset
        dd_colrange colsize
        dd_RepresentationType representation
        dd_NumberType numbtype
        dd_Amatrix matrix
        dd_LPObjectiveType objective
        dd_Arow rowvec

    #ctypedef struct dd_SetFamily:
    #    # not used so far
    #    pass

    #ctypedef struct dd_LPSolution:
    #    dd_LPStatusType LPS
    #    mytype optvalue
    #    # there are more fields but so far they are not used

    ctypedef struct dd_lpdata:
        dd_LPObjectiveType objective
        dd_LPSolverType solver
        dd_boolean Homogeneous
        dd_rowrange m
        dd_colrange d
        dd_Amatrix A
        dd_Bmatrix B
        dd_rowrange objrow
        dd_colrange rhscol
        dd_NumberType numbtype
        dd_rowrange eqnumber # number of equalities
        dd_rowset equalityset
        dd_LPStatusType LPS
        mytype optvalue
        dd_Arow sol

    ctypedef matrixdata *dd_MatrixPtr
    ctypedef dd_lpdata *dd_LPPtr
    #ctypedef dd_SetFamily *dd_SetFamilyPtr
    #ctypedef dd_LPSolution *dd_SetLPSolutionPtr

    # functions
    # not everything is defined here, just most common operations
    # add more as needed...

    cdef void dd_set_d(mytype, double)
    cdef void dd_set_si(mytype, signed long)
    cdef void dd_set_si2(mytype, signed long, unsigned long)
    cdef double dd_get_d(mytype)

    cdef dd_MatrixPtr dd_CreateMatrix(dd_rowrange, dd_colrange)
    cdef void dd_FreeMatrix(dd_MatrixPtr)
    cdef dd_MatrixPtr dd_CopyMatrix(dd_MatrixPtr)
    cdef int dd_MatrixAppendTo(dd_MatrixPtr*, dd_MatrixPtr)
    cdef int dd_MatrixRowRemove(dd_MatrixPtr *M, dd_rowrange r)

    cdef dd_LPPtr dd_Matrix2LP(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_LPSolve(dd_LPPtr, dd_LPSolverType, dd_ErrorType *)
    cdef void dd_FreeLPData(dd_LPPtr)

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

    #property representation:
    #    def __get__(self):
    #        return self.thisptr.representation

    #property objType:
    #    def __get__(self):
    #        return self.thisptr.objective
    #    def __set__(self, dd_LPObjectiveType obj):
    #        self.thisptr.objective = obj

    def __str__(self):
        """Print the matrix data."""
        s = ""
        for rowindex in xrange(self.rowsize):
            s += "[ "
            for colindex in xrange(self.colsize):
                s += "%6.3f " % dd_get_d(self.thisptr.matrix[rowindex][colindex])
            s += "]\n"
        if self.thisptr.objective != dd_LPnone:
            s += "%s\n" % ({dd_LPmin: "minimize", dd_LPmax: "maximize"}[self.thisptr.objective])
            s += "[ "
            for colindex in xrange(self.colsize):
                s += "%6.3f " % dd_get_d(self.thisptr.rowvec[colindex])
            s += "]\n"
        return s

    def __cinit__(self, rows):
        """Load matrix data from the rows (which is a list of lists)."""
        # determine dimension
        numrows = len(rows)
        if numrows > 0:
            numcols = len(rows[0])
        else:
            numcols = 0
        # create new matrix
        self.thisptr = dd_CreateMatrix(numrows, numcols)
        # load data
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

    def setObjType(self, objtype):
        """Set linear programming objective type."""
        self.thisptr.objective = objtype

    def setObjFunc(self, objfunc):
        """Set objective function."""
        if len(objfunc) != self.colsize:
            raise ValueError("objective function does not match matrix column size")
        for colindex, value in enumerate(objfunc):
            dd_set_d(self.thisptr.rowvec[colindex], value)

    def solveLinProg(self):
        """Solve linear program. Returns status (one of the LPSTATUS_*
        constants) and optimal value."""
        cdef dd_LPPtr linprog
        cdef dd_ErrorType error
        error = dd_NoError
        linprog = dd_Matrix2LP(self.thisptr, &error)
        if linprog == NULL or error != dd_NoError:
            if linprog != NULL:
                dd_FreeLPData(linprog)
            raise ValueError("failed to load linear program (error code %i)" % error)
        error = ERR_NO_ERROR
        dd_LPSolve(linprog, dd_DualSimplex, &error)
        if error != dd_NoError:
            raise RuntimeError("failed to solve linear program (error code %i)" % error)
        solution = (linprog.LPS, dd_get_d(linprog.optvalue))
        dd_FreeLPData(linprog)
        return solution

def setGlobalConstants():
    """Call this before using cdd."""
    dd_set_global_constants()

def freeGlobalConstants():
    """Call this when finished using cdd."""
    dd_free_global_constants()

