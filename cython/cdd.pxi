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

# this is an include file for "cdd.h"

cimport libc.stdio

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

    # not translated: dd_ConversionType, dd_IncidenceOutputType,
    # dd_AdjacencyOutputType, dd_FileInputModeType

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
        # dd_DataFileType filename
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
        dd_rowrange eqnumber  # number of equalities
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
        dd_rowset GroundSet, EqualitySet, NonequalitySet
        dd_rowset AddedHalfspaces, WeaklyAddedHalfspaces, InitialHalfspaces
        long RayCount, FeasibleRayCount, WeaklyFeasibleRayCount
        long TotalRayCount, ZeroRayCount
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

    cdef void dd_InitializeArow(dd_colrange, dd_Arow *)
    cdef void dd_InitializeAmatrix(dd_rowrange, dd_colrange, dd_Amatrix *)
    cdef void dd_InitializeBmatrix(dd_colrange, dd_Bmatrix *)
    cdef dd_SetFamilyPtr dd_CreateSetFamily(dd_bigrange, dd_bigrange)
    cdef void dd_FreeSetFamily(dd_SetFamilyPtr)
    cdef dd_MatrixPtr dd_CreateMatrix(dd_rowrange, dd_colrange)
    cdef void dd_FreeAmatrix(dd_rowrange, dd_colrange, dd_Amatrix)
    cdef void dd_FreeArow(dd_colrange, dd_Arow)
    cdef void dd_FreeBmatrix(dd_colrange, dd_Bmatrix)
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
    cdef dd_PolyhedraPtr dd_DDMatrix2Poly2(
        dd_MatrixPtr, dd_RowOrderType, dd_ErrorType *
    )
    cdef dd_boolean dd_Redundant(dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *)
    cdef dd_rowset dd_RedundantRows(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_SRedundant(dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *)
    cdef dd_rowset dd_SRedundantRows(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_rowset dd_RedundantRowsViaShooting(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_rowrange dd_RayShooting(dd_MatrixPtr, dd_Arow intpt, dd_Arow direction)
    cdef dd_boolean dd_ImplicitLinearity(
        dd_MatrixPtr, dd_rowrange, dd_Arow, dd_ErrorType *
    )
    cdef dd_rowset dd_ImplicitLinearityRows(dd_MatrixPtr, dd_ErrorType *)
    cdef int dd_FreeOfImplicitLinearity(
        dd_MatrixPtr, dd_Arow, dd_rowset *, dd_ErrorType *
    )
    cdef dd_boolean dd_MatrixCanonicalizeLinearity(
        dd_MatrixPtr *, dd_rowset *, dd_rowindex *, dd_ErrorType *
    )
    cdef dd_boolean dd_MatrixCanonicalize(
        dd_MatrixPtr *, dd_rowset *, dd_rowset *, dd_rowindex *, dd_ErrorType *
    )
    cdef dd_boolean dd_MatrixRedundancyRemove(
        dd_MatrixPtr *M, dd_rowset *redset, dd_rowindex *newpos, dd_ErrorType *
    )
    cdef dd_boolean dd_FindRelativeInterior(
        dd_MatrixPtr, dd_rowset *, dd_rowset *, dd_LPSolutionPtr *, dd_ErrorType *
    )
    cdef dd_boolean dd_ExistsRestrictedFace(
        dd_MatrixPtr, dd_rowset, dd_rowset, dd_ErrorType *
    )
    cdef dd_boolean dd_ExistsRestrictedFace2(
        dd_MatrixPtr, dd_rowset, dd_rowset, dd_LPSolutionPtr *, dd_ErrorType *
    )

    cdef dd_SetFamilyPtr dd_Matrix2Adjacency(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_SetFamilyPtr dd_Matrix2WeakAdjacency(dd_MatrixPtr, dd_ErrorType *)
    cdef long dd_MatrixRank(
        dd_MatrixPtr, dd_rowset, dd_colset, dd_rowset *, dd_colset *
    )

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

    cdef dd_LPPtr dd_CreateLPData(
        dd_LPObjectiveType, dd_NumberType, dd_rowrange, dd_colrange
    )
    cdef dd_LPPtr dd_Matrix2LP(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_boolean dd_LPSolve(dd_LPPtr, dd_LPSolverType, dd_ErrorType *)
    cdef void dd_FreeLPData(dd_LPPtr)
    cdef void dd_WriteLP(libc.stdio.FILE *f, dd_LPPtr lp)
    cdef void dd_WriteLPResult(libc.stdio.FILE *f, dd_LPPtr lp, dd_ErrorType err)

    cdef dd_MatrixPtr dd_FourierElimination(dd_MatrixPtr, dd_ErrorType *)
    cdef dd_MatrixPtr dd_BlockElimination(dd_MatrixPtr, dd_colset, dd_ErrorType *)
