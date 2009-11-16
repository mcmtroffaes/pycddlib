"""The pycddlib module wraps the cdd.h header file from Komei Fukuda's cddlib.

Matrix functions
================

>>> import pycddlib
>>> mat1 = pycddlib.Matrix([[1,2],[3,4]])
>>> print mat1
begin
 2 2 real
  1  2
  3  4
end
<BLANKLINE>
>>> mat1.rowsize
2
>>> mat1.colsize
2
>>> mat2 = mat1.copy()
>>> mat1.append_rows([[5,6]])
>>> mat1.rowsize
3
>>> print mat1
begin
 3 2 real
  1  2
  3  4
  5  6
end
<BLANKLINE>
>>> print mat2
begin
 2 2 real
  1  2
  3  4
end
<BLANKLINE>

Linear Programming
==================

This is the testlp2.c example that comes with cddlib.

>>> import pycddlib
>>> mat = pycddlib.Matrix([[4.0/3.0,-2,-1],[2.0/3.0,0,-1],[0,1,0],[0,0,1]])
>>> mat.set_lp_obj_type(LPOBJ_MAX)
>>> mat.set_lp_obj_func([0,3,4])
>>> print mat
begin
 4 3 real
  1.333333333E+00 -2 -1
  6.666666667E-01  0 -1
  0  1  0
  0  0  1
end
maximize
  0  3  4
<BLANKLINE>
>>> lp = pycddlib.LinProg(mat)
>>> lp.solve()
>>> lp.status
1
>>> print("%6.3f" % lp.optValue)
 3.667
>>> print(["%6.3f" % val for val in lp.primalSolution])
[' 0.333', ' 0.667']
>>> print(["%6.3f" % val for val in lp.dualSolution])
[' 1.500', ' 2.500']
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

import tempfile

# some of cdd's functions read and write files
cdef extern from "stdio.h":
    ctypedef struct FILE
    ctypedef int size_t
    cdef FILE *stdout
    cdef FILE *tmpfile()
    cdef size_t fread(void *ptr, size_t size, size_t count, FILE *stream)
    cdef size_t fwrite(void *ptr, size_t size, size_t count, FILE *stream)
    cdef int SEEK_SET
    cdef int SEEK_CUR
    cdef int SEEK_END
    cdef int fseek(FILE *stream, long int offset, int origin)
    cdef long int ftell(FILE *stream)

# get object as file
cdef extern from "Python.h":
    FILE *PyFile_AsFile(object)

# set operations (need to include this before cdd.h to avoid compile errors)
cdef extern from "setoper.h":
    ctypedef unsigned long *set_type

# now include cdd.h declarations for main implementation
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
        dd_Arow dsol

    ctypedef matrixdata *dd_MatrixPtr
    ctypedef dd_lpdata *dd_LPPtr

    # functions
    # not everything is defined here, just most common operations
    # add more as needed...

    cdef void dd_set_d(mytype, double)
    cdef void dd_set_si(mytype, signed long)
    cdef void dd_set_si2(mytype, signed long, unsigned long)
    cdef double dd_get_d(mytype)

    cdef void dd_set_global_constants()
    cdef void dd_free_global_constants()

    cdef void dd_WriteErrorMessages(FILE *, dd_ErrorType)

    cdef dd_MatrixPtr dd_CreateMatrix(dd_rowrange, dd_colrange)
    cdef void dd_FreeMatrix(dd_MatrixPtr)
    cdef dd_MatrixPtr dd_CopyMatrix(dd_MatrixPtr)
    cdef int dd_MatrixAppendTo(dd_MatrixPtr*, dd_MatrixPtr)
    cdef int dd_MatrixRowRemove(dd_MatrixPtr *M, dd_rowrange r)
    cdef void dd_WriteMatrix(FILE *, dd_MatrixPtr)

    cdef dd_LPPtr dd_Matrix2LP(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_LPSolve(dd_LPPtr, dd_LPSolverType, dd_ErrorType *)
    cdef void dd_FreeLPData(dd_LPPtr)
    cdef void dd_WriteLP(FILE *f, dd_LPPtr lp)
    cdef void dd_WriteLPResult(FILE *f, dd_LPPtr lp, dd_ErrorType err)

cdef _raise_error(dd_ErrorType error, msg):
    """Convert error into string and raise it."""
    cdef FILE *pfile
    # open file for writing the matrix data
    tmp = tempfile.TemporaryFile()
    pfile = PyFile_AsFile(tmp)
    dd_WriteErrorMessages(pfile, error)
    # read the file into a buffer
    tmp.seek(0)
    cddmsg = tmp.read(-1)
    # close the file
    tmp.close()
    # raise it
    raise RuntimeError(msg + "\n" + cddmsg)

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

    def __str__(self):
        """Print the matrix data."""
        cdef FILE *pfile
        # open file for writing the matrix data
        tmp = tempfile.TemporaryFile()
        pfile = PyFile_AsFile(tmp)
        dd_WriteMatrix(pfile, self.thisptr)
        # read the file into a buffer
        tmp.seek(0)
        result = tmp.read(-1)
        # close the file
        tmp.close()
        return result

    def __cinit__(self, rows):
        """Load matrix data from the rows (which is a list of lists)."""
        # reset pointer
        self.thisptr = NULL
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
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                dd_set_d(self.thisptr.matrix[rowindex][colindex], value)
        # debug
        #dd_WriteMatrix(stdout, self.thisptr)

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
        mat = Matrix([[0]])
        dd_FreeMatrix(mat.thisptr)
        mat.thisptr = NULL
        # now assign to a copy
        mat.thisptr = dd_CopyMatrix(self.thisptr)
        # return the copy
        return mat

    def append_rows(self, rows):
        """Append rows to self (this corresponds to the dd_MatrixAppendTo
        function in cdd; to emulate the effect of dd_MatrixAppend, first call
        self.copy and then call append on the copy).

        The column size must be equal in the two input matrices. It
        raises a ValueError if the input rows are not appropriate."""
        # create matrix with given rows
        cdef Matrix other
        other = Matrix(rows)
        # call dd_AppendToMatrix
        success = dd_MatrixAppendTo(&self.thisptr, other.thisptr)
        # check result
        if success != 1:
            raise ValueError(
                "cannot append because column sizes differ")

    def remove_row(self, dd_rowrange rownum):
        """Remove a row. Raises ValueError on failure."""
        # remove the row
        success = dd_MatrixRowRemove(&self.thisptr, rownum)
        # check the result
        if success != 1:
            raise ValueError(
                "cannot remove row %i" % rownum)

    def set_rep_type(self, reptype):
        """Set type of representation (use the REP_* constants)."""
        self.thisptr.representation = reptype

    def set_lp_obj_type(self, objtype):
        """Set linear programming objective type (use the LPOBJ_* constants)."""
        self.thisptr.objective = objtype

    def set_lp_obj_func(self, objfunc):
        """Set objective function."""
        if len(objfunc) != self.colsize:
            raise ValueError(
                "objective function does not match matrix column size")
        for colindex, value in enumerate(objfunc):
            dd_set_d(self.thisptr.rowvec[colindex], value)

cdef class LinProg:
    """Solves a linear program."""
    # pointer to linear program
    cdef dd_LPPtr thisptr

    property solver:
        def __get__(self):
            return self.thisptr.solver

    property objective:
        def __get__(self):
            return self.thisptr.objective

    property status:
        def __get__(self):
            return self.thisptr.LPS

    property optValue:
        def __get__(self):
            return dd_get_d(self.thisptr.optvalue)

    property primalSolution:
        def __get__(self):
            cdef int colindex
            return [dd_get_d(self.thisptr.sol[colindex])
                    for 1 <= colindex < self.thisptr.d]

    property dualSolution:
        def __get__(self):
            cdef int colindex
            return [dd_get_d(self.thisptr.dsol[colindex])
                    for 1 <= colindex < self.thisptr.d]

    def __str__(self):
        """Print the linear program data."""
        cdef FILE *pfile
        # open file for writing the data
        tmp = tempfile.TemporaryFile()
        pfile = PyFile_AsFile(tmp)
        # note: if lp has an error, then exception is raised
        # so pass ERR_NO_ERROR
        dd_WriteLPResult(pfile, self.thisptr, ERR_NO_ERROR)
        # read the file into a buffer
        tmp.seek(0)
        result = tmp.read(-1)
        # close the file
        tmp.close()
        return result

    def __cinit__(self, Matrix mat):
        """Initialize linear program solution from solved linear program in
        the given matrix."""
        cdef dd_ErrorType error
        error = dd_NoError
        self.thisptr = NULL
        # read matrix
        self.thisptr = dd_Matrix2LP(mat.thisptr, &error)
        if self.thisptr == NULL or error != dd_NoError:
            if self.thisptr != NULL:
                dd_FreeLPData(self.thisptr)
            _raise_error(error, "failed to load linear program")
        # debug
        #dd_WriteLP(stdout, self.thisptr)

    def __dealloc__(self):
        """Deallocate solution memory."""
        if self.thisptr != NULL:
            dd_FreeLPData(self.thisptr)
        self.thisptr = NULL

    def solve(self, solver = LPSOLVER_DUALSIMPLEX):
        """Solve linear program. Returns status (one of the LPSTATUS_*
        constants) and optimal value."""
        cdef dd_ErrorType error
        error = ERR_NO_ERROR
        dd_LPSolve(self.thisptr, solver, &error)
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...


