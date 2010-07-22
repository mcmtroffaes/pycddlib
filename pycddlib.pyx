"""pycddlib is a Python wrapper for Komei Fukuda's cddlib.

`cddlib <http://www.ifor.math.ethz.ch/~fukuda/cdd_home/cdd.html>`_ is
an implementation of the Double Description Method of Motzkin et
al. for generating all vertices (i.e. extreme points) and extreme rays
of a general convex polyhedron given by a system of linear
inequalities.

The program also supports the reverse operation (i.e. convex hull
computation). This means that one can move back and forth between an
inequality representation and a generator (i.e. vertex and ray)
representation of a polyhedron with cdd.  Also, it can solve a linear
programming problem, i.e. a problem of maximizing and minimizing a
linear function over a polyhedron.
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

cimport python_unicode

__version__ = "1.0.1"

# some of cdd's functions read and write files
cdef extern from "stdio.h" nogil:
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
    cdef int fclose(FILE *stream)

cdef extern from "time.h":
    ctypedef long time_t

# get object as file
cdef extern from "Python.h":
    FILE *PyFile_AsFile(object)

# set operations (need to include this before cdd.h to avoid compile errors)
cdef extern from "setoper.h" nogil:
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

cdef class AdjacencyTestType:
    """Adjacency test type.

    .. attribute::
       COMBINATORIAL
       ALGEBRAIC
    """
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC     = dd_Algebraic

cdef extern from "cdd.h":
    ctypedef enum dd_NumberType:
        dd_Unknown
        dd_Real
        dd_Rational
        dd_Integer

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

cdef extern from "cdd.h":
    ctypedef enum dd_RepresentationType:
        dd_Unspecified
        dd_Inequality
        dd_Generator

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

cdef extern from "cdd.h":
    ctypedef enum dd_CompStatusType:
        dd_InProgress
        dd_AllFound
        dd_RegionEmpty

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

cdef extern from "cdd.h":
    ctypedef enum dd_LPObjectiveType:
        dd_LPnone
        dd_LPmax
        dd_LPmin

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

cdef extern from "cdd.h":
    ctypedef enum dd_LPSolverType:
        dd_CrissCross
        dd_DualSimplex

cdef class LPSolverType:
    """Type of solver for a linear program.

    .. attribute::
       CRISS_CROSS
       DUAL_SIMPLEX
    """
    CRISS_CROSS  = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

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

# structures

cdef extern from "cdd.h" nogil:

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
        time_t starttime
        time_t endtime

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
        time_t starttime, endtime

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
    cdef void dd_WriteTimes(FILE *, time_t, time_t)
    cdef void dd_WriteIncidence(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteAdjacency(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputAdjacency(FILE *, dd_PolyhedraPtr)
    cdef void dd_WriteInputIncidence(FILE *, dd_PolyhedraPtr)

    cdef dd_LPPtr dd_Matrix2LP(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_LPSolve(dd_LPPtr, dd_LPSolverType, dd_ErrorType *)
    cdef void dd_FreeLPData(dd_LPPtr)
    cdef void dd_WriteLP(FILE *f, dd_LPPtr lp)
    cdef void dd_WriteLPResult(FILE *f, dd_LPPtr lp, dd_ErrorType err)

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

cdef _raise_error(dd_ErrorType error, msg):
    """Convert error into string and raise it."""
    cdef FILE *pfile
    pfile = _tmpfile()
    dd_WriteErrorMessages(pfile, error)
    raise RuntimeError(msg + "\n" + _tmpread(pfile))

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

# matrix class
cdef class Matrix:
    """A class for working with matrices, sets of linear constraints,
    and extreme points.

    :param rows: The rows of the matrix.
    :type rows: ``list`` of ``list`` of ``float``
    :param linear: Whether to add the rows to the :attr:`lin_set` or not.
    :type linear: ``bool``
    """

    # pointer containing the matrix data
    cdef dd_MatrixPtr thisptr

    property row_size:
        """Number of rows."""
        def __get__(self):
            return self.thisptr.rowsize

    def __len__(self):
        """Number of rows."""
        return self.thisptr.rowsize

    property col_size:
        """Number of columns."""
        def __get__(self):
            return self.thisptr.colsize

    property lin_set:
        """A ``frozenset`` containing the rows of linearity
        (generators of linearity space for V-representation, and
        equations for H-representation).
        """
        def __get__(self):
            return _get_set(self.thisptr.linset)
        def __set__(self, value):
            _set_set(self.thisptr.linset, value)

    property rep_type:
        """Representation (see :class:`RepType`)."""
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    property obj_type:
        """Linear programming objective: maximize or minimize (see
        :class:`LPObjType`).
        """
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

    property obj_func:
        """A ``tuple`` containing the linear programming objective
        function.
        """
        def __get__(self):
            # return an immutable tuple to prohibit item assignment
            cdef int colindex
            return tuple([dd_get_d(self.thisptr.rowvec[colindex])
                          for 0 <= colindex < self.thisptr.colsize])
        def __set__(self, obj_func):
            cdef int colindex
            cdef double value
            if len(obj_func) != self.thisptr.colsize:
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                dd_set_d(self.thisptr.rowvec[colindex], value)

    def __str__(self):
        """Print the matrix data."""
        cdef FILE *pfile
        pfile = _tmpfile()
        dd_WriteMatrix(pfile, self.thisptr)
        return _tmpread(pfile)

    def __cinit__(self, rows, linear=False):
        """Load matrix data from the rows (which is a list of lists)."""
        cdef int numrows, numcols, rowindex, colindex
        cdef double value
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
        self.thisptr.numbtype = dd_Real
        # load data
        for rowindex, row in enumerate(rows):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                dd_set_d(self.thisptr.matrix[rowindex][colindex], value)
        if linear:
            # set all constraints as linear
            set_compl(self.thisptr.linset, self.thisptr.linset)
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

    def extend(self, rows, linear=False):
        """Append rows to self (this corresponds to the dd_MatrixAppendTo
        function in cdd; to emulate the effect of dd_MatrixAppend, first call
        copy and then call extend on the copy).

        The column size must be equal in the two input matrices. It
        raises a ValueError if the input rows are not appropriate.

        :param rows: The rows to append.
        :type rows: ``list`` of ``list`` of ``float``
        :param linear: Whether to add the rows to the :attr:`lin_set` or not.
        :type linear: ``bool``
        """
        cdef Matrix other
        cdef int success
        # create matrix with given rows
        other = Matrix(rows, linear=linear)
        # call dd_AppendToMatrix
        success = dd_MatrixAppendTo(&self.thisptr, other.thisptr)
        # check result
        if success != 1:
            raise ValueError(
                "cannot append because column sizes differ")

    def __delitem__(self, dd_rowrange rownum):
        """Remove a row. Raises ValueError on failure."""
        cdef int success
        # remove the row
        success = dd_MatrixRowRemove(&self.thisptr, rownum)
        # check the result
        if success != 1:
            raise ValueError(
                "cannot remove row %i" % rownum)

    def __getitem__(self, key):
        """Return a row, or a slice of rows, of the matrix.

        :param key: The row number, or slice of row numbers, to get.
        :type key: ``int`` or ``slice``
        :rtype: ``tuple`` of ``float``, or ``tuple`` of ``tuple`` of ``float``
        """
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
            if rownum < 0 or rownum >= self.thisptr.rowsize:
                raise IndexError("row index out of range")
            # return an immutable tuple to prohibit item assignment
            return tuple([dd_get_d(self.thisptr.matrix[rownum][j])
                          for 0 <= j < self.thisptr.colsize])

cdef class LinProg:
    """A class for solving linear programs.

    :param mat: The matrix to load the linear program from.
    :type mat: :class:`Matrix`
    """
    # pointer to linear program
    cdef dd_LPPtr thisptr

    property solver:
        """The type of solver to use (see :class:`LPSolverType`)."""
        def __get__(self):
            return self.thisptr.solver

    property obj_type:
        """Whether we are minimizing or maximizing (see
        :class:`LPObjType`).
        """
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

    property status:
        """The status of the linear program (see
        :class:`LPStatusType`).
        """
        def __get__(self):
            return self.thisptr.LPS

    property obj_value:
        """The optimal value of the objective function."""
        def __get__(self):
            return dd_get_d(self.thisptr.optvalue)

    property primal_solution:
        """A ``tuple`` containing the primal solution."""
        def __get__(self):
            cdef int colindex
            return tuple([dd_get_d(self.thisptr.sol[colindex])
                          for 1 <= colindex < self.thisptr.d])

    property dual_solution:
        """A ``tuple`` containing the dual solution."""
        def __get__(self):
            cdef int colindex
            return tuple([dd_get_d(self.thisptr.dsol[colindex])
                          for 1 <= colindex < self.thisptr.d])

    def __str__(self):
        """Print the linear program data."""
        cdef FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        dd_WriteLPResult(pfile, self.thisptr, dd_NoError)
        return _tmpread(pfile)

    def __cinit__(self, Matrix mat):
        """Initialize linear program solution from solved linear program in
        the given matrix.
        """
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

    def solve(self, dd_LPSolverType solver=dd_DualSimplex):
        """Solve linear program.

        :param solver: The method of solution (see :class:`LPSolverType`).
        :type solver: ``int``
        """
        cdef dd_ErrorType error
        error = dd_NoError
        dd_LPSolve(self.thisptr, solver, &error)
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

cdef class Polyhedron:
    """A class for converting between representations of a polyhedron.

    :param mat: The matrix to load the polyhedron from.
    :type mat: :class:`Matrix`
    """

    # pointer to polyhedra
    cdef dd_PolyhedraPtr thisptr

    property rep_type:
        """Representation (see :class:`RepType`)."""
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    def __str__(self):
        """Print the polyhedra data."""
        cdef FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.thisptr)
        return _tmpread(pfile)

    def __cinit__(self, Matrix mat):
        """Initialize polyhedra from given matrix."""
        cdef dd_ErrorType error
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
        """Get all inequalities.

        :returns: H-representation.
        :rtype: :class:`Matrix`
        """
        return _make_matrix(dd_CopyInequalities(self.thisptr))

    def get_generators(self):
        """Get all generators.

        :returns: V-representation.
        :rtype: :class:`Matrix`
        """
        return _make_matrix(dd_CopyGenerators(self.thisptr))

# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...


