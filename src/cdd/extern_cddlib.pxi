# this is an include file for "cdd.h"

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

cdef extern from "cddlib/cdd.h" nogil:

    # typedefs
    ###########

    ctypedef int dd_boolean
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
    ########

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

    # structures
    #############

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
    ctypedef struct dd_matrixdata
    ctypedef dd_matrixdata *dd_MatrixPtr
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
        time_t starttime
        time_t endtime

    ctypedef struct dd_matrixdata:
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
        time_t starttime, endtime

    # functions
    ############

    # not everything is defined here, just most common operations
    # add more as needed...

    cdef void dd_set_global_constants()
    cdef void dd_free_global_constants()

    cdef void dd_WriteErrorMessages(libc.stdio.FILE *, dd_ErrorType)

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
    cdef dd_MatrixPtr dd_PolyFile2Matrix(libc.stdio.FILE *f, dd_ErrorType *)
    
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

    cdef void dd_WriteAmatrix(libc.stdio.FILE *, dd_Amatrix, dd_rowrange, dd_colrange)
    cdef void dd_WriteArow(libc.stdio.FILE *f, dd_Arow a, dd_colrange)
    cdef void dd_WriteBmatrix(libc.stdio.FILE *, dd_colrange, dd_Bmatrix T)
    cdef void dd_WriteMatrix(libc.stdio.FILE *, dd_MatrixPtr)
    cdef void dd_MatrixIntegerFilter(dd_MatrixPtr)
    cdef void dd_WriteReal(libc.stdio.FILE *, mytype)
    cdef void dd_WriteNumber(libc.stdio.FILE *f, mytype x)
    cdef void dd_WritePolyFile(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteRunningMode(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteErrorMessages(libc.stdio.FILE *, dd_ErrorType)
    cdef void dd_WriteSetFamily(libc.stdio.FILE *, dd_SetFamilyPtr)
    cdef void dd_WriteSetFamilyCompressed(libc.stdio.FILE *, dd_SetFamilyPtr)
    cdef void dd_WriteProgramDescription(libc.stdio.FILE *)
    cdef void dd_WriteDDTimes(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteTimes(libc.stdio.FILE *, time_t, time_t)
    cdef void dd_WriteIncidence(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteAdjacency(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputAdjacency(libc.stdio.FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputIncidence(libc.stdio.FILE *, dd_PolyhedraPtr)

    cdef dd_LPPtr dd_Matrix2LP(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_LPSolve(dd_LPPtr, dd_LPSolverType, dd_ErrorType *)
    cdef void dd_FreeLPData(dd_LPPtr)
    cdef void dd_WriteLP(libc.stdio.FILE *f, dd_LPPtr lp)
    cdef void dd_WriteLPResult(libc.stdio.FILE *f, dd_LPPtr lp, dd_ErrorType err)

# wrapper classes to expose enums

cpdef enum AdjacencyTestType:
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC     = dd_Algebraic

cpdef enum NumberType:
    UNKNOWN  = dd_Unknown
    REAL     = dd_Real
    RATIONAL = dd_Rational
    INTEGER  = dd_Integer

cpdef enum RepType:
    UNSPECIFIED = dd_Unspecified
    INEQUALITY  = dd_Inequality
    GENERATOR   = dd_Generator

cpdef enum RowOrderType:
    MAX_INDEX  = dd_MaxIndex
    MIN_INDEX  = dd_MinIndex
    MIN_CUTOFF = dd_MinCutoff
    MAX_CUTOFF = dd_MaxCutoff
    MIX_CUTOFF = dd_MixCutoff
    LEX_MIN    = dd_LexMin
    LEX_MAX    = dd_LexMax
    RANDOM_ROW = dd_RandomRow

cpdef enum Error:
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

cpdef enum CompStatus:
    IN_PROGRESS  = dd_InProgress
    ALL_FOUND    = dd_AllFound
    REGION_EMPTY = dd_RegionEmpty

cpdef enum LPObjType:
    NONE = dd_LPnone
    MAX  = dd_LPmax
    MIN  = dd_LPmin

cpdef enum LPSolverType:
    CRISS_CROSS  = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

cpdef enum LPStatusType:
    UNDECIDED             = dd_LPSundecided
    OPTIMAL               = dd_Optimal
    INCONSISTENT          = dd_Inconsistent
    DUAL_INCONSISTENT      = dd_DualInconsistent
    STRUC_INCONSISTENT     = dd_StrucInconsistent
    STRUC_DUAL_INCONSISTENT = dd_StrucDualInconsistent
    UNBOUNDED             = dd_Unbounded
    DUAL_UNBOUNDED         = dd_DualUnbounded

# helper functions

### begin windows hack (broken libc.stdio.tmpfile)
cdef extern from * nogil:
     cdef void _emit_ifdef_msc_ver "#ifdef _MSC_VER //" ()
     cdef void _emit_else "#else //" ()
     cdef void _emit_endif "#endif //" ()
cdef extern from "stdio.h" nogil:
    char *_tempnam(char *dir, char *prefix)
cdef libc.stdio.FILE *libc_stdio_tmpfile() except NULL:
     cdef libc.stdio.FILE *result
     cdef char *name
     _emit_ifdef_msc_ver()
     name = _tempnam(NULL, NULL)
     if name == NULL:
         raise RuntimeError("failed to create temporary file name")
     result = libc.stdio.fopen(name, "wb+TD");
     libc.stdlib.free(name)
     _emit_else()
     result = libc.stdio.tmpfile()
     _emit_endif()
     return result
### end windows hack (broken libc.stdio.tmpfile)

cdef libc.stdio.FILE *_tmpfile() except NULL:
     cdef libc.stdio.FILE *result
     # libc.stdio.tmpfile() is broken on windows
     result = libc_stdio_tmpfile()
     if result == NULL:
         raise RuntimeError("failed to create temporary file")
     return result

cdef _tmpread(libc.stdio.FILE *pfile):
    cdef size_t length
    cdef size_t num_bytes
    cdef void *buffer
    result = ""
    libc.stdio.fseek(pfile, 0, libc.stdio.SEEK_END)
    length = libc.stdio.ftell(pfile)
    buffer = cpython.mem.PyMem_RawMalloc(length)
    try:
        libc.stdio.fseek(pfile, 0, libc.stdio.SEEK_SET)
        num_bytes = libc.stdio.fread(buffer, 1, length, pfile)
        result = cpython.unicode.PyUnicode_DecodeUTF8(<char*>buffer, num_bytes, 'strict')
    finally:
        libc.stdio.fclose(pfile)
        cpython.mem.PyMem_RawFree(buffer)
    return result

cdef _get_set(set_type set_):
    """Create Python set from given set_type."""
    cdef unsigned long elem
    return frozenset(
        elem for elem from 0 <= elem < set_[0] if set_member(elem + 1, set_)
    )

cdef _set_set(set_type set_, pset):
    """Set elements of set_type by elements from Python set."""
    cdef unsigned long elem
    for elem from 0 <= elem < set_[0]:
        if elem in pset:
            set_addelem(set_, elem + 1)
        else:
            set_delelem(set_, elem + 1)

cdef _get_dd_setfam(dd_SetFamilyPtr setfam):
    """Create list of Python sets from dd_SetFamilyPtr, and
    free the pointer. The indexing of the sets start at 0, unlike the
    string output from cddlib, which starts at 1.
    """
    cdef long elem
    if setfam == NULL:
        raise ValueError("failed to get set family")
    # note: must return immutable object
    result = tuple(
        frozenset(
            elem
            for elem from 0 <= elem < setfam.setsize
            if set_member(elem + 1, setfam.set[i])
        )
        for i from 0 <= i < setfam.famsize
    )
    dd_FreeSetFamily(setfam)
    return result

cdef _raise_error(dd_ErrorType error, msg):
    """Convert error into string and raise it."""
    cdef libc.stdio.FILE *pfile
    pfile = _tmpfile()
    dd_WriteErrorMessages(pfile, error)
    raise RuntimeError(msg + "\n" + _tmpread(pfile).rstrip('\n'))

cdef _make_dd_matrix(dd_MatrixPtr dd_mat):
    """Create matrix from given pointer."""
    # we must "cdef Matrix mat" because otherwise pyrex will not
    # recognize mat.thisptr as a C pointer
    cdef Matrix mat
    if dd_mat == NULL:
        raise ValueError("failed to make matrix")
    mat = Matrix([[]])
    dd_FreeMatrix(mat.dd_mat)
    mat.dd_mat = dd_mat
    return mat

# extension classes to wrap matrix, linear program, and polyhedron

cdef class Matrix:

    cdef dd_MatrixPtr dd_mat

    property row_size:
        def __get__(self):
            return self.dd_mat.rowsize

    def __len__(self):
        return self.dd_mat.rowsize


    property col_size:
        def __get__(self):
            return self.dd_mat.colsize

    property lin_set:
        def __get__(self):
            return _get_set(self.dd_mat.linset)
        def __set__(self, value):
            _set_set(self.dd_mat.linset, value)

    property rep_type:
        def __get__(self):
            return self.dd_mat.representation
        def __set__(self, dd_RepresentationType value):
            self.dd_mat.representation = value

    property obj_type:
        def __get__(self):
            return self.dd_mat.objective
        def __set__(self, dd_LPObjectiveType value):
            self.dd_mat.objective = value

    property obj_func:
        def __get__(self):
            # return an immutable tuple to prohibit item assignment
            cdef int colindex
            return tuple([_get_mytype(self.dd_mat.rowvec[colindex])
                          for 0 <= colindex < self.dd_mat.colsize])
        def __set__(self, obj_func):
            cdef int colindex
            if len(obj_func) != self.dd_mat.colsize:
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                _set_mytype(self.dd_mat.rowvec[colindex], value)

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WriteMatrix(pfile, self.dd_mat)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, rows, linear=False):
        """Load matrix data from the rows (which is a list of lists)."""
        cdef Py_ssize_t numrows, numcols, rowindex, colindex
        # reset pointers
        self.dd_mat = NULL
        # determine dimension
        numrows = len(rows)
        if numrows > 0:
            numcols = len(rows[0])
        else:
            numcols = 0
        # create new matrix, safely casting ranges
        cdef dd_rowrange numrows2 = <dd_rowrange>numrows
        cdef dd_colrange numcols2 = <dd_colrange>numcols
        if numrows2 != numrows or numcols2 != numcols:
            raise ValueError("matrix too large")
        self.dd_mat = dd_CreateMatrix(numrows2, numcols2)
        # load data
        for rowindex, row in enumerate(rows):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                _set_mytype(self.dd_mat.matrix[rowindex][colindex], value)
        if linear:
            # set all constraints as linear
            set_compl(self.dd_mat.linset, self.dd_mat.linset)
        # debug
        #dd_WriteMatrix(stdout, self.dd_mat)

    def __dealloc__(self):
        """Deallocate matrix."""
        dd_FreeMatrix(self.dd_mat)
        self.dd_mat = NULL

    def copy(self):
        return _make_dd_matrix(dd_CopyMatrix(self.dd_mat))

    def extend(self, rows, linear=False):
        cdef Matrix other
        cdef int success
        # create matrix with given rows
        other = Matrix(rows, linear=linear)
        # call dd_AppendToMatrix
        success = dd_MatrixAppendTo(&self.dd_mat, other.dd_mat)
        # check result
        if success != 1:
            raise ValueError("cannot append because column sizes differ")

    def __getitem__(self, key):
        cdef dd_rowrange rownum
        cdef dd_rowrange j
        # check if we are slicing
        if isinstance(key, slice):
            indices = key.indices(len(self))
            # XXX once generators are supported in cython, this should
            # return (self.__getitem__(i) for i in xrange(*indices))
            return tuple([self.__getitem__(i) for i in xrange(*indices)])
        else:
            rownum = key
            if rownum < 0 or rownum >= self.dd_mat.rowsize:
                raise IndexError("row index out of range")
            # return an immutable tuple to prohibit item assignment
            return tuple([_get_mytype(self.dd_mat.matrix[rownum][j])
                          for 0 <= j < self.dd_mat.colsize])

    def canonicalize(self):
        cdef dd_rowset impl_linset
        cdef dd_rowset redset
        cdef dd_rowindex newpos
        cdef dd_ErrorType error = dd_NoError
        cdef int m
        cdef dd_boolean success
        if self.rep_type == dd_Unspecified:
            raise ValueError("rep_type unspecified")
        m = self.dd_mat.rowsize
        success = dd_MatrixCanonicalize(&self.dd_mat, &impl_linset, &redset, &newpos, &error)
        result = (_get_set(impl_linset), _get_set(redset))
        set_free(impl_linset)
        set_free(redset)
        libc.stdlib.free(newpos)
        if not success or error != dd_NoError:
            _raise_error(error, "failed to canonicalize matrix")
        return result

cdef class LinProg:

    cdef dd_LPPtr dd_lp

    property obj_type:
        def __get__(self):
            return self.dd_lp.objective
        def __set__(self, dd_LPObjectiveType value):
            self.dd_lp.objective = value

    property status:
        def __get__(self):
            return self.dd_lp.LPS

    property obj_value:
        def __get__(self):
            return _get_mytype(self.dd_lp.optvalue)

    property primal_solution:
        def __get__(self):
            cdef int colindex
            return tuple([_get_mytype(self.dd_lp.sol[colindex])
                          for 1 <= colindex < self.dd_lp.d])

    property dual_solution:
        def __get__(self):
            cdef int colindex
            return tuple([_get_mytype(self.dd_lp.dsol[colindex])
                          for 1 <= colindex < self.dd_lp.d])

    def __str__(self):
        """Print the linear program data."""
        cdef libc.stdio.FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        dd_WriteLPResult(pfile, self.dd_lp, dd_NoError)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, Matrix mat):
        """Initialize linear program solution from solved linear program in
        the given matrix.
        """
        cdef dd_ErrorType error = dd_NoError
        self.dd_lp = NULL
        # read matrix
        self.dd_lp = dd_Matrix2LP(mat.dd_mat, &error)
        if self.dd_lp == NULL or error != dd_NoError:
            if self.dd_lp != NULL:
                dd_FreeLPData(self.dd_lp)
            _raise_error(error, "failed to load linear program")
        # debug
        #dd_WriteLP(stdout, self.dd_lp)

    def __dealloc__(self):
        """Deallocate solution memory."""
        dd_FreeLPData(self.dd_lp)
        self.dd_lp = NULL

    def solve(self, dd_LPSolverType solver=dd_DualSimplex):
        cdef dd_ErrorType error = dd_NoError
        dd_LPSolve(self.dd_lp, solver, &error)
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

cdef class Polyhedron:

    cdef dd_PolyhedraPtr dd_poly

    def __str__(self):
        """Print the polyhedra data."""
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.dd_poly)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, Matrix mat):
        """Initialize polyhedra from given matrix."""
        cdef dd_ErrorType error = dd_NoError
        # initialize pointers
        self.dd_poly = NULL
        # read matrix
        self.dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
        if self.dd_poly == NULL or error != dd_NoError:
            # Do not clean up data: see issue #7.
            #if self.dd_poly != NULL:
            #    dd_FreePolyhedra(self.dd_poly)
            _raise_error(error, "failed to load polyhedra")
        # debug
        #dd_WritePolyFile(stdout, self.dd_poly)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.dd_poly:
            dd_FreePolyhedra(self.dd_poly)
        self.dd_poly = NULL

    def get_inequalities(self):
        return _make_dd_matrix(dd_CopyInequalities(self.dd_poly))

    def get_generators(self):
        return _make_dd_matrix(dd_CopyGenerators(self.dd_poly))

    def get_adjacency(self):
        return _get_dd_setfam(dd_CopyAdjacency(self.dd_poly))

    def get_input_adjacency(self):
        return _get_dd_setfam(dd_CopyInputAdjacency(self.dd_poly))

    def get_incidence(self):
        return _get_dd_setfam(dd_CopyIncidence(self.dd_poly))

    def get_input_incidence(self):
        return _get_dd_setfam(dd_CopyInputIncidence(self.dd_poly))

# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...
