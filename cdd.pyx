# cython: language_level=3

"""Python wrapper for Komei Fukuda's cddlib."""


# pycddlib is a Python wrapper for Komei Fukuda's cddlib
# Copyright (c) 2008-2015, Matthias C. M. Troffaes
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

cimport cpython.bytes
cimport cpython.mem
cimport cpython.unicode
cimport libc.stdio
cimport libc.stdlib

from fractions import Fraction
import numbers

__version__ = "3.0.0a0"

# also need time_t
cdef extern from "time.h":
    ctypedef long time_t

# actual cddlib imports (to avoid compilation errors, include setoper.h first)

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
    cdef void set_fwrite(libc.stdio.FILE *f,set_type set)
    cdef void set_fwrite_compl(libc.stdio.FILE *f,set_type set)
    cdef void set_binwrite(set_type set)
    cdef void set_fbinwrite(libc.stdio.FILE *f,set_type set)

cdef extern from "cdd.h" nogil:
    ctypedef double mytype[1]

include "cddlib.pxi"

# helper functions

### begin windows hack (broken libc.stdio.tmpfile)
cdef extern from *:
     cdef void _emit_ifdef_msc_ver "#ifdef _MSC_VER //" ()
     cdef void _emit_else "#else //" ()
     cdef void _emit_endif "#endif //" ()
cdef extern from "stdio.h":
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
    """Create Python frozenset from given set_type."""
    cdef unsigned long elem
    return frozenset([elem
                      for elem from 0 <= elem < set_[0]
                      if set_member(elem + 1, set_)])

cdef _set_set(set_type set_, pset):
    """Set elements of set_type by elements from Python set."""
    cdef unsigned long elem
    for elem from 0 <= elem < set_[0]:
        if elem in pset:
            set_addelem(set_, elem + 1)
        else:
            set_delelem(set_, elem + 1)

cdef _get_dd_setfam(dd_SetFamilyPtr setfam):
    """Create tuple of Python frozensets from dd_SetFamilyPtr, and
    free the pointer. The indexing of the sets start at 0, unlike the
    string output from cddlib, which starts at 1.
    """
    cdef long elem
    if setfam == NULL:
        raise ValueError("failed to get set family")
    result = tuple(frozenset([elem
                              for elem from 0 <= elem < setfam.setsize
                              if set_member(elem + 1, setfam.set[i])])
                   for i in range(setfam.famsize))
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

# extension types to wrap the cddlib enums

cdef class AdjacencyTestType:
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC     = dd_Algebraic

cdef class NumberType:
    UNKNOWN  = dd_Unknown
    REAL     = dd_Real
    RATIONAL = dd_Rational
    INTEGER  = dd_Integer

cdef class RepType:
    UNSPECIFIED = dd_Unspecified
    INEQUALITY  = dd_Inequality
    GENERATOR   = dd_Generator

cdef class RowOrderType:
    MAX_INDEX  = dd_MaxIndex
    MIN_INDEX  = dd_MinIndex
    MIN_CUTOFF = dd_MinCutoff
    MAX_CUTOFF = dd_MaxCutoff
    MIX_CUTOFF = dd_MixCutoff
    LEX_MIN    = dd_LexMin
    LEX_MAX    = dd_LexMax
    RANDOM_ROW = dd_RandomRow

cdef class Error:
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

cdef class CompStatus:
    IN_PROGRESS  = dd_InProgress
    ALL_FOUND    = dd_AllFound
    REGION_EMPTY = dd_RegionEmpty

cdef class LPObjType:
    NONE = dd_LPnone
    MAX  = dd_LPmax
    MIN  = dd_LPmin

cdef class LPSolverType:
    CRISS_CROSS  = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

cdef class LPStatusType:
    UNDECIDED             = dd_LPSundecided
    OPTIMAL               = dd_Optimal
    INCONSISTENT          = dd_Inconsistent
    DUAL_INCONSISTENT      = dd_DualInconsistent
    STRUC_INCONSISTENT     = dd_StrucInconsistent
    STRUC_DUAL_INCONSISTENT = dd_StrucDualInconsistent
    UNBOUNDED             = dd_Unbounded
    DUAL_UNBOUNDED         = dd_DualUnbounded

# extension classes to wrap matrix, linear program, and polyhedron

cdef class Matrix:

    cdef dd_MatrixPtr dd_mat

    cdef int _get_row_size(self):
        """Quick implementation of row_size property, for Cython use."""
        return self.dd_mat.rowsize

    cdef int _get_col_size(self):
        """Quick implementation of col_size property, for Cython use."""
        return self.dd_mat.colsize

    property row_size:
        def __get__(self):
            return self._get_row_size()

    def __len__(self):
        return self._get_row_size()


    property col_size:
        def __get__(self):
            return self._get_col_size()

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
            return tuple([dd_get_d(self.dd_mat.rowvec[colindex])
                          for 0 <= colindex < self.dd_mat.colsize])
        def __set__(self, obj_func):
            cdef int colindex
            if len(obj_func) != self._get_col_size():
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                dd_set_d(self.dd_mat.rowvec[colindex], value)

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WriteMatrix(pfile, self.dd_mat)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self, *args, **kwargs):
        # overriding this to prevent base class constructor to be called
        pass

    def __cinit__(self, rows, linear=False):
        """Load matrix data from the rows (which is a list of lists)."""
        cdef int numrows, numcols, rowindex, colindex
        # reset pointers
        self.dd_mat = NULL
        # determine dimension
        numrows = len(rows)
        if numrows > 0:
            numcols = len(rows[0])
        else:
            numcols = 0
        # create new matrix
        self.dd_mat = dd_CreateMatrix(numrows, numcols)
        # load data
        for rowindex, row in enumerate(rows):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                dd_set_d(self.dd_mat.matrix[rowindex][colindex], value)
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
            if rownum < 0 or rownum >= self._get_row_size():
                raise IndexError("row index out of range")
            # return an immutable tuple to prohibit item assignment
            return tuple([dd_get_d(self.dd_mat.matrix[rownum][j])
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

    property solver:
        def __get__(self):
            return self.dd_lp.solver

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
            return dd_get_d(self.dd_lp.optvalue)

    property primal_solution:
        def __get__(self):
            cdef int colindex
            return tuple([dd_get_d(self.dd_lp.sol[colindex])
                          for 1 <= colindex < self.dd_lp.d])

    property dual_solution:
        def __get__(self):
            cdef int colindex
            return tuple([dd_get_d(self.dd_lp.dsol[colindex])
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

    def __init__(self, *args, **kwargs):
        # overriding this to prevent base class constructor to be called
        pass

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

    property rep_type:
        def __get__(self):
            return self.dd_poly.representation

        def __set__(self, dd_RepresentationType value):
            self.dd_poly.representation = value

    def __str__(self):
        """Print the polyhedra data."""
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.dd_poly)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self, *args, **kwargs):
        # overriding this to prevent base class constructor to be called
        pass

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

