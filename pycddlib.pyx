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
>>> print(mat1[0])
[1.0, 2.0]
>>> print(mat1[1])
[3.0, 4.0]
>>> print(mat1[2]) # doctest: +ELLIPSIS
Traceback (most recent call last):
  ...
IndexError: row index out of range
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
>>> print(mat1[0])
[1.0, 2.0]
>>> print(mat1[1])
[3.0, 4.0]
>>> print(mat1[2])
[5.0, 6.0]
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
>>> print("%6.3f" % lp.opt_value)
 3.667
>>> print(["%6.3f" % val for val in lp.primal_solution])
[' 0.333', ' 0.667']
>>> print(["%6.3f" % val for val in lp.dual_solution])
[' 1.500', ' 2.500']

Polyhedra
=========

>>> import pycddlib
>>> poly = pycddlib.Polyhedra([[2,-1,-1,0],[0,1,0,0],[0,0,1,0]], REP_INEQUALITY)
>>> print(poly)
begin
 3 4 real
  2 -1 -1  0
  0  1  0  0
  0  0  1  0
end
<BLANKLINE>
>>> ext = poly.get_generators()
>>> print(ext.linset)
set([4])
>>> print(ext)
V-representation
linearity 1  4
begin
 4 4 real
  1  0  0  0
  1  2  0  0
  1  0  2  0
  0  0  0  1
end
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

    # forward, pointer, and alias declarations
    ctypedef struct dd_raydata
    ctypedef dd_raydata *dd_RayPtr
    ctypedef struct dd_adjacencydata
    ctypedef dd_adjacencydata *dd_AdjacencyPtr
    ctypedef dd_adjacencydata dd_AdjacencyType
    ctypedef struct dd_lpsolution
    ctypedef dd_lpsolution *dd_LPSolutionPtr
    ctypedef struct dd_lpdata
    ctypedef dd_lpdata *dd_LPPtr
    ctypedef struct matrixdata
    ctypedef matrixdata *dd_MatrixPtr
    ctypedef struct dd_setfamily
    ctypedef dd_setfamily *dd_SetFamilyPtr
    ctypedef struct dd_nodedata
    ctypedef dd_nodedata *dd_NodePtr
    ctypedef struct dd_graphdata
    ctypedef dd_graphdata *dd_GraphPtr
    ctypedef struct dd_polyhedradata
    ctypedef dd_polyhedradata *dd_PolyhedraPtr
    ctypedef struct dd_conedata
    ctypedef dd_conedata *dd_ConePtr

    ctypedef struct dd_raydata:
        mytype *Ray
        dd_rowset ZeroSet
        dd_rowrange FirstInfeasIndex
        dd_boolean feasible
        mytype ARay
        dd_RayPtr Next

    ctypedef struct dd_adjacencydata:
        dd_RayPtr Ray1, Ray2
        dd_AdjacencyPtr Next

    ctypedef struct dd_lpsolution:
        #dd_DataFileType filename
        dd_LPObjectiveType objective
        dd_LPSolverType solver
        dd_rowrange m
        dd_colrange d
        dd_NumberType numbtype
        dd_LPStatusType LPS
        mytype optvalue
        dd_Arow sol
        dd_Arow dsol
        dd_colindex nbindex
        dd_rowrange re
        dd_colrange se
        long pivots[5]
        long total_pivots

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
        dd_boolean redcheck_extensive
        dd_rowrange ired
        dd_rowset redset_extra
        dd_rowset redset_accum
        dd_rowset posset_extra
        dd_boolean lexicopivot
        dd_LPStatusType LPS
        dd_rowrange m_alloc
        dd_colrange d_alloc
        mytype optvalue
        dd_Arow sol
        dd_Arow dsol
        dd_colindex nbindex
        dd_rowrange re
        dd_colrange se
        long pivots[5]
        long total_pivots
        int use_given_basis
        dd_colindex given_nbindex
        #time_t starttime
        #time_t endtime

    ctypedef struct matrixdata:
        dd_rowrange rowsize
        dd_rowset linset
        dd_colrange colsize
        dd_RepresentationType representation
        dd_NumberType numbtype
        dd_Amatrix matrix
        dd_LPObjectiveType objective
        dd_Arow rowvec

    ctypedef struct dd_setfamily:
        dd_bigrange famsize
        dd_bigrange setsize
        dd_SetVector set

    ctypedef struct dd_nodedata:
        dd_bigrange key
        dd_NodePtr next

    ctypedef struct dd_graphdata:
        dd_bigrange vsize
        dd_NodePtr *adjlist

    ctypedef struct dd_polyhedradata:
        dd_RepresentationType representation
        dd_boolean homogeneous
        dd_colrange d
        dd_rowrange m
        dd_Amatrix A
        dd_NumberType numbtype
        dd_ConePtr child
        dd_rowrange m_alloc
        dd_colrange d_alloc
        dd_Arow c
        dd_rowflag EqualityIndex
        dd_boolean IsEmpty
        dd_boolean NondegAssumed
        dd_boolean InitBasisAtBottom
        dd_boolean RestrictedEnumeration
        dd_boolean RelaxedEnumeration
        dd_rowrange m1
        dd_boolean AincGenerated
        dd_colrange ldim
        dd_bigrange n
        dd_Aincidence Ainc
        dd_rowset Ared
        dd_rowset Adom

    ctypedef struct dd_conedata:
        dd_RepresentationType representation
        dd_rowrange m
        dd_colrange d
        dd_Amatrix A
        dd_NumberType numbtype
        dd_PolyhedraPtr parent
        dd_rowrange m_alloc
        dd_colrange d_alloc
        dd_rowrange Iteration
        dd_RowOrderType HalfspaceOrder
        dd_RayPtr FirstRay, LastRay, ArtificialRay
        dd_RayPtr PosHead, ZeroHead, NegHead, PosLast, ZeroLast, NegLast
        dd_AdjacencyType **Edges
        unsigned int rseed
        dd_boolean ColReduced
        dd_bigrange LinearityDim 
        dd_colrange d_orig
        dd_colindex newcol
        dd_colindex InitialRayIndex
        dd_rowindex OrderVector
        dd_boolean RecomputeRowOrder
        dd_boolean PreOrderedRun
        dd_rowset GroundSet, EqualitySet, NonequalitySet, AddedHalfspaces, WeaklyAddedHalfspaces, InitialHalfspaces
        long RayCount, FeasibleRayCount, WeaklyFeasibleRayCount, TotalRayCount, ZeroRayCount
        long EdgeCount, TotalEdgeCount
        long count_int, count_int_good, count_int_bad
        dd_Bmatrix B
        dd_Bmatrix Bsave
        dd_ErrorType Error
        dd_CompStatusType CompStatus
        #time_t starttime, endtime # ignored for now, as time_t has no standard implementation

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

    cdef void dd_InitializeArow(dd_colrange,dd_Arow *)
    cdef void dd_InitializeAmatrix(dd_rowrange,dd_colrange,dd_Amatrix *)
    cdef void dd_InitializeBmatrix(dd_colrange, dd_Bmatrix *)
    cdef dd_SetFamilyPtr dd_CreateSetFamily(dd_bigrange,dd_bigrange)
    cdef void dd_FreeSetFamily(dd_SetFamilyPtr)
    cdef dd_MatrixPtr dd_CreateMatrix(dd_rowrange,dd_colrange)
    cdef void dd_FreeAmatrix(dd_rowrange,dd_colrange,dd_Amatrix)
    cdef void dd_FreeArow(dd_colrange, dd_Arow)
    cdef void dd_FreeBmatrix(dd_colrange,dd_Bmatrix)
    cdef void dd_FreeDDMemory(dd_PolyhedraPtr)
    cdef void dd_FreePolyhedra(dd_PolyhedraPtr)
    cdef void dd_FreeMatrix(dd_MatrixPtr)
    cdef void dd_SetToIdentity(dd_colrange, dd_Bmatrix)

    cdef dd_MatrixPtr dd_CopyInput(dd_PolyhedraPtr)
    cdef dd_MatrixPtr dd_CopyOutput(dd_PolyhedraPtr)
    cdef dd_MatrixPtr dd_CopyInequalities(dd_PolyhedraPtr)
    cdef dd_MatrixPtr dd_CopyGenerators(dd_PolyhedraPtr)
    cdef dd_SetFamilyPtr dd_CopyIncidence(dd_PolyhedraPtr)
    cdef dd_SetFamilyPtr dd_CopyAdjacency(dd_PolyhedraPtr)
    cdef dd_SetFamilyPtr dd_CopyInputIncidence(dd_PolyhedraPtr)
    cdef dd_SetFamilyPtr dd_CopyInputAdjacency(dd_PolyhedraPtr)
    cdef dd_boolean dd_DDFile2File(char *ifile, char *ofile, dd_ErrorType *err)
    cdef dd_boolean dd_DDInputAppend(dd_PolyhedraPtr*, dd_MatrixPtr, dd_ErrorType*)
    cdef dd_MatrixPtr dd_PolyFile2Matrix(FILE *f, dd_ErrorType *)
    
    cdef dd_PolyhedraPtr dd_DDMatrix2Poly(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_PolyhedraPtr dd_DDMatrix2Poly2(dd_MatrixPtr, dd_RowOrderType, dd_ErrorType *)
    cdef dd_boolean dd_Redundant(dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *)
    cdef dd_rowset dd_RedundantRows(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_SRedundant(dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *)
    cdef dd_rowset dd_SRedundantRows(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_rowset dd_RedundantRowsViaShooting(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_rowrange dd_RayShooting(dd_MatrixPtr, dd_Arow intpt, dd_Arow direction)
    cdef dd_boolean dd_ImplicitLinearity(dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *)
    cdef dd_rowset dd_ImplicitLinearityRows(dd_MatrixPtr, dd_ErrorType *)
    cdef int dd_FreeOfImplicitLinearity(dd_MatrixPtr, dd_Arow, dd_rowset *, dd_ErrorType *)
    cdef dd_boolean dd_MatrixCanonicalizeLinearity(dd_MatrixPtr *, dd_rowset *,dd_rowindex *, dd_ErrorType *)
    cdef dd_boolean dd_MatrixCanonicalize(dd_MatrixPtr *, dd_rowset *, dd_rowset *, dd_rowindex *, dd_ErrorType *)
    cdef dd_boolean dd_MatrixRedundancyRemove(dd_MatrixPtr *M, dd_rowset *redset,dd_rowindex *newpos, dd_ErrorType *)
    cdef dd_boolean dd_FindRelativeInterior(dd_MatrixPtr, dd_rowset *, dd_rowset *, dd_LPSolutionPtr *, dd_ErrorType *)
    cdef dd_boolean dd_ExistsRestrictedFace(dd_MatrixPtr, dd_rowset, dd_rowset, dd_ErrorType *)
    cdef dd_boolean dd_ExistsRestrictedFace2(dd_MatrixPtr, dd_rowset, dd_rowset, dd_LPSolutionPtr *, dd_ErrorType *)
    
    cdef dd_SetFamilyPtr dd_Matrix2Adjacency(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_SetFamilyPtr dd_Matrix2WeakAdjacency(dd_MatrixPtr, dd_ErrorType *)
    cdef long dd_MatrixRank(dd_MatrixPtr, dd_rowset, dd_colset, dd_rowset *, dd_colset *)

    cdef dd_MatrixPtr dd_CopyMatrix(dd_MatrixPtr)
    cdef int dd_MatrixAppendTo(dd_MatrixPtr*, dd_MatrixPtr)
    cdef int dd_MatrixRowRemove(dd_MatrixPtr *M, dd_rowrange r)

    cdef void dd_WriteAmatrix(FILE *, dd_Amatrix, dd_rowrange, dd_colrange)
    cdef void dd_WriteArow(FILE *f, dd_Arow a, dd_colrange)
    cdef void dd_WriteBmatrix(FILE *, dd_colrange, dd_Bmatrix T)
    cdef void dd_WriteMatrix(FILE *, dd_MatrixPtr)
    cdef void dd_MatrixIntegerFilter(dd_MatrixPtr)
    cdef void dd_WriteReal(FILE *, mytype)
    cdef void dd_WriteNumber(FILE *f, mytype x)
    cdef void dd_WritePolyFile(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteRunningMode(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteErrorMessages(FILE *, dd_ErrorType)
    cdef void dd_WriteSetFamily(FILE *, dd_SetFamilyPtr)
    cdef void dd_WriteSetFamilyCompressed(FILE *, dd_SetFamilyPtr)
    cdef void dd_WriteProgramDescription(FILE *)
    cdef void dd_WriteDDTimes(FILE *, dd_PolyhedraPtr)
    #cdef void dd_WriteTimes(FILE *, time_t, time_t)
    cdef void dd_WriteIncidence(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteAdjacency(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputAdjacency(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputIncidence(FILE *, dd_PolyhedraPtr)

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

cdef _make_matrix(dd_MatrixPtr matptr):
    """Create matrix from given pointer."""
    # we must "cdef Matrix mat" because otherwise pyrex will not
    # recognize mat.thisptr as a C pointer
    cdef Matrix mat
    if matptr == NULL:
        raise ValueError("failed to make matrix")
    mat = Matrix([[0]])
    dd_FreeMatrix(mat.thisptr)
    mat.thisptr = matptr
    return mat

cdef _make_set(set_type set_):
    """Create Python set from given set_type."""
    cdef int elem
    result = set()
    for elem from 1 <= elem <= set_[0]:
        if set_member(elem, set_):
            result.add(elem)
    return result

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

    property linset:
        def __get__(self):
            return _make_set(self.thisptr.linset)

    property representation:
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    property objective:
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

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
        return _make_matrix(dd_CopyMatrix(self.thisptr))

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

    def __getitem__(self, dd_rowrange rownum):
        """Return a given row of the matrix."""
        if rownum < 0 or rownum >= self.thisptr.rowsize:
            raise IndexError("row index out of range")
        return [dd_get_d(self.thisptr.matrix[rownum][j])
                for 0 <= j < self.thisptr.colsize]

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

    property opt_value:
        def __get__(self):
            return dd_get_d(self.thisptr.optvalue)

    property primal_solution:
        def __get__(self):
            cdef int colindex
            return [dd_get_d(self.thisptr.sol[colindex])
                    for 1 <= colindex < self.thisptr.d]

    property dual_solution:
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

cdef class Polyhedra:
    # pointer to polyhedra
    cdef dd_PolyhedraPtr thisptr

    property representation:
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    def __str__(self):
        """Print the polyhedra data."""
        cdef FILE *pfile
        # open file for writing the data
        tmp = tempfile.TemporaryFile()
        pfile = PyFile_AsFile(tmp)
        dd_WritePolyFile(pfile, self.thisptr)
        # read the file into a buffer
        tmp.seek(0)
        result = tmp.read(-1)
        # close the file
        tmp.close()
        return result

    def __cinit__(self, rows, dd_RepresentationType representation):
        """Initialize polyhedra from given matrix."""
        cdef dd_ErrorType error
        cdef Matrix mat

        mat = Matrix(rows)
        mat.representation = representation
        error = dd_NoError
        self.thisptr = NULL
        # read matrix
        self.thisptr = dd_DDMatrix2Poly(mat.thisptr, &error)
        if self.thisptr == NULL or error != dd_NoError:
            if self.thisptr != NULL:
                dd_FreePolyhedra(self.thisptr)
            _raise_error(error, "failed to load polyhedra")
        # debug
        #dd_WritePolyFile(stdout, self.thisptr)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.thisptr != NULL:
            dd_FreePolyhedra(self.thisptr)
        self.thisptr = NULL

    def get_inequalities(self):
        """Return matrix containing all inequalities."""
        return _make_matrix(dd_CopyInequalities(self.thisptr))

    def get_generators(self):
        """Return matrix containing all generators."""
        return _make_matrix(dd_CopyGenerators(self.thisptr))

# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...


