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
cimport cpython.unicode
cimport libc.stdio
cimport libc.stdlib

from fractions import Fraction
import numbers

__version__ = "2.1.0"

# also need time_t
cdef extern from "time.h":
    ctypedef long time_t

# gmp integer and rational functions
# note: mpir.h/gmp.h will be included via cdd.h later, so use from * form
cdef extern from * nogil:
    ctypedef struct mpz_t:
        pass
    signed long int mpz_get_si(mpz_t op)
    unsigned long int mpz_get_ui(mpz_t op)
    int mpz_fits_slong_p(mpz_t op)
    int mpz_fits_ulong_p(mpz_t op)
    size_t mpz_sizeinbase(mpz_t op, int base)

    # note: need to add this internal detail to the header (compilation
    # fails otherwise)
    ctypedef struct __mpq_struct:
        pass
    ctypedef __mpq_struct mpq_t[1]

    mpz_t mpq_numref(mpq_t op)
    mpz_t mpq_denref(mpq_t op)
    char *mpq_get_str(char *str, int base, mpq_t op)
    int mpq_set_str(mpq_t rop, char *str, int base)

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
    ctypedef mpq_t mytype

cdef extern from "cdd_f.h" nogil:
    ctypedef double myfloat[1]

include "cddlib.pxi"

include "cddlib_f.pxi"

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

DEF MAX_STR_LEN = 20000

cdef _tmpread(libc.stdio.FILE *pfile):
    cdef char result[MAX_STR_LEN]
    cdef size_t num_bytes
    # read the file
    libc.stdio.fseek(pfile, 0, libc.stdio.SEEK_SET)
    num_bytes = libc.stdio.fread(result, 1, MAX_STR_LEN, pfile)
    # close the file
    libc.stdio.fclose(pfile)
    # return result
    return cpython.unicode.PyUnicode_DecodeUTF8(result, num_bytes, 'strict')

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
    mat = Matrix([[]], number_type='fraction')
    dd_FreeMatrix(mat.dd_mat)
    mat.dd_mat = dd_mat
    return mat

cdef _make_ddf_matrix(ddf_MatrixPtr ddf_mat):
    """Create matrix from given pointer."""
    # we must "cdef Matrix mat" because otherwise pyrex will not
    # recognize mat.thisptr as a C pointer
    cdef Matrix mat
    if ddf_mat == NULL:
        raise ValueError("failed to make matrix")
    mat = Matrix([[]], number_type='float')
    ddf_FreeMatrix(mat.ddf_mat)
    mat.ddf_mat = ddf_mat
    return mat

cdef _get_mytype(mytype target):
    """Get :class:`~fractions.Fraction` or :class:`int` from target."""
    cdef signed long int num
    cdef unsigned long int den
    cdef char *buf_ptr
    if mpz_fits_slong_p(mpq_numref(target)) and mpz_fits_ulong_p(mpq_denref(target)):
        num = mpz_get_si(mpq_numref(target))
        den = mpz_get_ui(mpq_denref(target))
        if den == 1:
            # calling int() makes that we don't return a long unless needed
            return int(num)
        else:
            return Fraction(num, den)
    else:
        buf = cpython.bytes.PyBytes_FromStringAndSize(NULL, mpz_sizeinbase(mpq_numref(target), 10) + mpz_sizeinbase(mpq_denref(target), 10) + 3)
        buf_ptr = cpython.bytes.PyBytes_AsString(buf)
        mpq_get_str(buf_ptr, 10, target)
        # trick: bytes(buf_ptr) removes everything after the null
        return Fraction(bytes(buf_ptr).decode('ascii'))

cdef _set_mytype(mytype target, value):
    """Set target to given value (:class:`str`, :class:`int`,
    :class:`long`, :class:`float`, or :class:`~fractions.Fraction`). A
    :class:`str` is automatically converted to a
    :class:`~fractions.Fraction` using its constructor.
    """
    # convert string to fraction
    if isinstance(value, str):
        value = Fraction(value)
    # set target to value
    if isinstance(value, numbers.Rational):
        try:
            dd_set_si2(target, value.numerator, value.denominator)
        except OverflowError:
            # in case of overflow, set it using mpq_set_str
            buf = str(value).encode('ascii')
            if mpq_set_str(target, buf, 10) == -1:
                raise ValueError('could not convert %s to mpq_t' % value)
    elif isinstance(value, numbers.Real):
        dd_set_d(target, float(value))

cdef _get_myfloat(myfloat target):
    return target[0]

cdef _set_myfloat(myfloat target, value):
    if isinstance(value, str) and '/' in value:
        num, den = value.split('/')
        target[0] = float(num) / float(den)
    else:
        target[0] = float(value)

# NumberTypeable class implementation

DEF FLOAT = 1
DEF FRACTION = 2

cdef int _get_number_type(str number_type) except -1:
    if number_type == 'float':
        return FLOAT
    elif number_type == 'fraction':
        return FRACTION
    else:
        raise ValueError(
            "number type must be 'float' or 'fraction' (got %s)" % repr(number_type))

def get_number_type_from_value(value):
    if isinstance(value, (numbers.Rational, str)):
        return 'fraction'
    else:
        return 'float'

def get_number_type_from_sequences(*data):
    for row in data:
        for elem in row:
            if not isinstance(elem, (numbers.Rational, str)):
                return 'float'
    return 'fraction'

cdef inline _invalid_number_type(int number_type):
    raise RuntimeError("invalid number type %i" % number_type)

cdef class NumberTypeable:

    cdef int _number_type

    def __init__(self, str number_type='float'):
        self._number_type = _get_number_type(number_type)

    property number_type:
        def __get__(self):
            if self._number_type == FLOAT:
                return 'float'
            elif self._number_type == FRACTION:
                return 'fraction'
            else:
                _invalid_number_type(self._number_type)

    property NumberType:
        def __get__(self):
            if self._number_type == FLOAT:
                return float
            elif self._number_type == FRACTION:
                return Fraction
            else:
                _invalid_number_type(self._number_type)

    def make_number(self, value):
        if self._number_type == FLOAT:
            if isinstance(value, str) and '/' in value:
                numerator, denominator = value.split('/')
                return float(numerator) / int(denominator) # result is float
            else:
                return float(value)
        elif self._number_type == FRACTION:
            # for python 2.6 compatibility, we handle float separately
            if isinstance(value, float):
                return Fraction.from_float(value)
            else:
                return Fraction(value)
        else:
            _invalid_number_type(self._number_type)

    def number_str(self, value):
        if self._number_type == FLOAT:
            if not isinstance(value, float):
                raise TypeError(
                    'expected float but got {0}'
                    .format(value.__class__.__name__))
            return str(value)
        elif self._number_type == FRACTION:
            if not isinstance(value, Fraction):
                raise TypeError(
                    'expected fractions.Fraction but got {0}'
                    .format(value.__class__.__name__))
            return str(value)
        else:
            _invalid_number_type(self._number_type)

    def number_repr(self, value):
        if self._number_type == FLOAT:
            if not isinstance(value, float):
                raise TypeError(
                    'expected float but got {0}'
                    .format(value.__class__.__name__))
            return repr(value)
        elif self._number_type == FRACTION:
            if not isinstance(value, Fraction):
                raise TypeError(
                    'expected fractions.Fraction but got {0}'
                    .format(value.__class__.__name__))
            if value.denominator == 1:
                # integer: "x"
                return str(value.numerator)
            # anything else: "'x/y'"
            return repr(str(value))
        else:
            _invalid_number_type(self._number_type)

    def number_cmp(self, num1, num2=None):
        cdef double f1, f2, fdiff
        if self._number_type == FLOAT:
            if num2 is not None:
                # converting to double first, so substraction is faster
                f1 = num1
                f2 = num2
                fdiff = f1 - f2
            else:
                fdiff = num1
            if fdiff < -1e-6:
                return -1
            elif fdiff > 1e-6:
                return 1
            else:
                return 0
        elif self._number_type == FRACTION:
            # XXX no type checking, for speed!!
            if num2 is not None:
                diff = num1 - num2
            else:
                diff = num1
            if diff < 0:
                return -1
            elif diff > 0:
                return 1
            else:
                return 0

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

cdef class Matrix(NumberTypeable):

    cdef dd_MatrixPtr dd_mat
    cdef ddf_MatrixPtr ddf_mat

    cdef int _get_row_size(self):
        """Quick implementation of row_size property, for Cython use."""
        if self.dd_mat:
            return self.dd_mat.rowsize
        else:
            return self.ddf_mat.rowsize

    cdef int _get_col_size(self):
        """Quick implementation of col_size property, for Cython use."""
        if self.dd_mat:
            return self.dd_mat.colsize
        else:
            return self.ddf_mat.colsize

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
            if self.dd_mat:
                return _get_set(self.dd_mat.linset)
            else:
                return _get_set(self.ddf_mat.linset)
        def __set__(self, value):
            if self.dd_mat:
                _set_set(self.dd_mat.linset, value)
            else:
                _set_set(self.ddf_mat.linset, value)

    property rep_type:
        def __get__(self):
            if self.dd_mat:
                return self.dd_mat.representation
            else:
                return self.ddf_mat.representation
        def __set__(self, dd_RepresentationType value):
            if self.dd_mat:
                self.dd_mat.representation = value
            else:
                self.ddf_mat.representation = <ddf_RepresentationType>value

    property obj_type:
        def __get__(self):
            if self.dd_mat:
                return self.dd_mat.objective
            else:
                return self.ddf_mat.objective
        def __set__(self, dd_LPObjectiveType value):
            if self.dd_mat:
                self.dd_mat.objective = value
            else:
                self.ddf_mat.objective = <ddf_LPObjectiveType>value

    property obj_func:
        def __get__(self):
            # return an immutable tuple to prohibit item assignment
            cdef int colindex
            if self.dd_mat:
                return tuple([_get_mytype(self.dd_mat.rowvec[colindex])
                              for 0 <= colindex < self.dd_mat.colsize])
            else:
                return tuple([_get_myfloat(self.ddf_mat.rowvec[colindex])
                              for 0 <= colindex < self.ddf_mat.colsize])
        def __set__(self, obj_func):
            cdef int colindex
            if len(obj_func) != self._get_col_size():
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                if self.dd_mat:
                    _set_mytype(self.dd_mat.rowvec[colindex], value)
                else:
                    _set_myfloat(self.ddf_mat.rowvec[colindex], value)

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        if self.dd_mat:
            dd_WriteMatrix(pfile, self.dd_mat)
        else:
            ddf_WriteMatrix(pfile, self.ddf_mat)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self, *args, **kwargs):
        # overriding this to prevent base class constructor to be called
        pass

    def __cinit__(self, rows, linear=False, str number_type=None):
        """Load matrix data from the rows (which is a list of lists)."""
        cdef int numrows, numcols, rowindex, colindex
        # set number type
        if number_type is not None:
            self._number_type = _get_number_type(number_type)
        else:
            self._number_type = _get_number_type(get_number_type_from_sequences(*rows))
        # reset pointers
        self.dd_mat = NULL
        self.ddf_mat = NULL
        # determine dimension
        numrows = len(rows)
        if numrows > 0:
            numcols = len(rows[0])
        else:
            numcols = 0
        # create new matrix
        if self._number_type == FRACTION:
            self.dd_mat = dd_CreateMatrix(numrows, numcols)
        else: # must be FLOAT
            self.ddf_mat = ddf_CreateMatrix(numrows, numcols)
        # load data
        for rowindex, row in enumerate(rows):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                if self.dd_mat:
                    _set_mytype(self.dd_mat.matrix[rowindex][colindex], value)
                else:
                    _set_myfloat(self.ddf_mat.matrix[rowindex][colindex], value)
        if linear:
            # set all constraints as linear
            if self.dd_mat:
                set_compl(self.dd_mat.linset, self.dd_mat.linset)
            else:
                set_compl(self.ddf_mat.linset, self.ddf_mat.linset)
        # debug
        #dd_WriteMatrix(stdout, self.dd_mat)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.dd_mat:
            dd_FreeMatrix(self.dd_mat)
        self.dd_mat = NULL
        if self.ddf_mat:
            ddf_FreeMatrix(self.ddf_mat)
        self.ddf_mat = NULL

    def copy(self):
        if self.dd_mat:
            return _make_dd_matrix(dd_CopyMatrix(self.dd_mat))
        else:
            return _make_ddf_matrix(ddf_CopyMatrix(self.ddf_mat))

    def extend(self, rows, linear=False):
        cdef Matrix other
        cdef int success
        # create matrix with given rows
        other = Matrix(rows, linear=linear, number_type=self.number_type)
        # call dd_AppendToMatrix
        if self.dd_mat:
            success = dd_MatrixAppendTo(&self.dd_mat, other.dd_mat)
        else:
            success = ddf_MatrixAppendTo(&self.ddf_mat, other.ddf_mat)
        # check result
        if success != 1:
            raise ValueError(
                "cannot append because column sizes differ")

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
            if self.dd_mat:
                return tuple([_get_mytype(self.dd_mat.matrix[rownum][j])
                              for 0 <= j < self.dd_mat.colsize])
            else:
                return tuple([_get_myfloat(self.ddf_mat.matrix[rownum][j])
                              for 0 <= j < self.ddf_mat.colsize])

    def canonicalize(self):
        cdef dd_rowset impl_linset
        cdef dd_rowset redset
        cdef dd_rowindex newpos
        cdef dd_ErrorType error = dd_NoError
        cdef int m
        cdef dd_boolean success
        if self.rep_type == dd_Unspecified:
            raise ValueError("rep_type unspecified")
        if self.dd_mat:
            m = self.dd_mat.rowsize
            success = dd_MatrixCanonicalize(&self.dd_mat, &impl_linset, &redset, &newpos, &error)
        else:
            m = self.ddf_mat.rowsize
            success = ddf_MatrixCanonicalize(&self.ddf_mat, &impl_linset, &redset, &newpos, <ddf_ErrorType *>(&error))
        result = (_get_set(impl_linset), _get_set(redset))
        set_free(impl_linset)
        set_free(redset)
        libc.stdlib.free(newpos)
        if not success or error != dd_NoError:
            _raise_error(error, "failed to canonicalize matrix")
        return result

cdef class LinProg(NumberTypeable):

    cdef dd_LPPtr dd_lp
    cdef ddf_LPPtr ddf_lp

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
            if self.dd_lp:
                return self.dd_lp.LPS
            else:
                return self.ddf_lp.LPS

    property obj_value:
        def __get__(self):
            if self.dd_lp:
                return _get_mytype(self.dd_lp.optvalue)
            else:
                return _get_myfloat(self.ddf_lp.optvalue)

    property primal_solution:
        def __get__(self):
            cdef int colindex
            if self.dd_lp:
                return tuple([_get_mytype(self.dd_lp.sol[colindex])
                              for 1 <= colindex < self.dd_lp.d])
            else:
                return tuple([_get_myfloat(self.ddf_lp.sol[colindex])
                              for 1 <= colindex < self.ddf_lp.d])

    property dual_solution:
        def __get__(self):
            cdef int colindex
            if self.dd_lp:
                return tuple([_get_mytype(self.dd_lp.dsol[colindex])
                              for 1 <= colindex < self.dd_lp.d])
            else:
                return tuple([_get_myfloat(self.ddf_lp.dsol[colindex])
                              for 1 <= colindex < self.ddf_lp.d])

    def __str__(self):
        """Print the linear program data."""
        cdef libc.stdio.FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        if self.dd_lp:
            dd_WriteLPResult(pfile, self.dd_lp, dd_NoError)
        else:
            ddf_WriteLPResult(pfile, self.ddf_lp, ddf_NoError)
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
        self.ddf_lp = NULL
        # set number type
        self._number_type = mat._number_type
        # read matrix
        if mat.dd_mat:
            self.dd_lp = dd_Matrix2LP(mat.dd_mat, &error)
            if self.dd_lp == NULL or error != dd_NoError:
                if self.dd_lp != NULL:
                    dd_FreeLPData(self.dd_lp)
                _raise_error(error, "failed to load linear program")
        else:
            self.ddf_lp = ddf_Matrix2LP(mat.ddf_mat, <ddf_ErrorType *>(&error))
            if self.ddf_lp == NULL or error != dd_NoError:
                if self.ddf_lp != NULL:
                    ddf_FreeLPData(self.ddf_lp)
                _raise_error(error, "failed to load linear program")
        # debug
        #dd_WriteLP(stdout, self.dd_lp)

    def __dealloc__(self):
        """Deallocate solution memory."""
        if self.dd_lp:
            dd_FreeLPData(self.dd_lp)
        self.dd_lp = NULL
        if self.ddf_lp:
            ddf_FreeLPData(self.ddf_lp)
        self.dd_lp = NULL

    def solve(self, dd_LPSolverType solver=dd_DualSimplex):
        cdef dd_ErrorType error = dd_NoError
        if self.dd_lp:
            dd_LPSolve(self.dd_lp, solver, &error)
        else:
            ddf_LPSolve(self.ddf_lp, <ddf_LPSolverType>solver, <ddf_ErrorType *>(&error))
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

cdef class Polyhedron(NumberTypeable):

    cdef dd_PolyhedraPtr dd_poly
    cdef ddf_PolyhedraPtr ddf_poly

    property rep_type:
        def __get__(self):
            if self.dd_poly:
                return self.dd_poly.representation
            else:
                return self.ddf_poly.representation

        def __set__(self, dd_RepresentationType value):
            if self.dd_poly:
                self.dd_poly.representation = value
            else:
                self.ddf_poly.representation = <ddf_RepresentationType>value

    def __str__(self):
        """Print the polyhedra data."""
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        if self.dd_poly:
            dd_WritePolyFile(pfile, self.dd_poly)
        else:
            ddf_WritePolyFile(pfile, self.ddf_poly)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self, *args, **kwargs):
        # overriding this to prevent base class constructor to be called
        pass

    def __cinit__(self, Matrix mat):
        """Initialize polyhedra from given matrix."""
        cdef dd_ErrorType error = dd_NoError
        # set number type
        self._number_type = mat._number_type
        # initialize pointers
        self.dd_poly = NULL
        self.ddf_poly = NULL
        # read matrix
        if mat.dd_mat:
            self.dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
            if self.dd_poly == NULL or error != dd_NoError:
                # Do not clean up data: see issue #7.
                #if self.dd_poly != NULL:
                #    dd_FreePolyhedra(self.dd_poly)
                _raise_error(error, "failed to load polyhedra")
        else:
            self.ddf_poly = ddf_DDMatrix2Poly(mat.ddf_mat, <ddf_ErrorType *>(&error))
            if self.ddf_poly == NULL or error != dd_NoError:
                # Do not clean up data: see issue #7.
                #if self.ddf_poly != NULL:
                #    ddf_FreePolyhedra(self.ddf_poly)
                _raise_error(error, "failed to load polyhedra")
        # debug
        #dd_WritePolyFile(stdout, self.dd_poly)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.dd_poly:
            dd_FreePolyhedra(self.dd_poly)
        self.dd_poly = NULL
        if self.ddf_poly:
            ddf_FreePolyhedra(self.ddf_poly)
        self.ddf_poly = NULL

    def get_inequalities(self):
        if self.dd_poly:
            return _make_dd_matrix(dd_CopyInequalities(self.dd_poly))
        else:
            return _make_ddf_matrix(ddf_CopyInequalities(self.ddf_poly))

    def get_generators(self):
        if self.dd_poly:
            return _make_dd_matrix(dd_CopyGenerators(self.dd_poly))
        else:
            return _make_ddf_matrix(ddf_CopyGenerators(self.ddf_poly))

# module initialization code comes here
# initialize module constants
dd_set_global_constants()
#ddf_set_global_constants() # called by dd_set_global_constants

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...

