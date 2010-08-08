"""Python wrapper for Komei Fukuda's cddlib."""


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

cimport python_bytes
cimport python_unicode

from fractions import Fraction

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

# also need time_t
cdef extern from "time.h":
    ctypedef long time_t

# gmp integer functions
cdef extern from "mpir.h" nogil:
    ctypedef struct mpz_t:
        pass
    signed long int mpz_get_si(mpz_t op)
    unsigned long int mpz_get_ui(mpz_t op)
    int mpz_fits_slong_p(mpz_t op)
    int mpz_fits_ulong_p(mpz_t op)
    size_t mpz_sizeinbase(mpz_t op, int base)

# gmp rational functions
cdef extern from "mpir.h" nogil:
    ctypedef struct mpq_t:
        pass
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
    cdef void set_fwrite(FILE *f,set_type set)
    cdef void set_fwrite_compl(FILE *f,set_type set)
    cdef void set_binwrite(set_type set)
    cdef void set_fbinwrite(FILE *f,set_type set)

cdef extern from "cdd.h" nogil:
    ctypedef mpq_t mytype

cdef extern from "cdd_f.h" nogil:
    ctypedef double myfloat[1]

include "cddlib.pxi"

include "cddlib_f.pxi"

# helper functions

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
    cdef FILE *pfile
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
        buf = python_bytes.PyBytes_FromStringAndSize(NULL, mpz_sizeinbase(mpq_numref(target), 10) + mpz_sizeinbase(mpq_denref(target), 10) + 3)
        buf_ptr = python_bytes.PyBytes_AsString(buf)
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
    if isinstance(value, float):
        dd_set_d(target, value)
    elif isinstance(value, (Fraction, int, long)):
        try:
            dd_set_si2(target, value.numerator, value.denominator)
        except OverflowError:
            # in case of overflow, set it using mpq_set_str
            buf = str(value).encode('ascii')
            if mpq_set_str(target, buf, 10) == -1:
                raise ValueError('could not convert %s to mpq_t' % value)

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

cdef inline _invalid_number_type(int number_type):
    raise RuntimeError("invalid number type %i" % number_type)

cdef class NumberTypeable:
    """Base class for classes that can have different representations
    of numbers.

    :param number_type: The number type (``'float'`` or ``'fraction'``).
    :type number_type: :class:`str`

    >>> cdd.NumberTypeable('float') # doctest: +ELLIPSIS
    <cdd._core.NumberTypeable object at ...>
    >>> cdd.NumberTypeable('fraction') # doctest: +ELLIPSIS
    <cdd._core.NumberTypeable object at ...>
    >>> # hyperreals are not supported :-)
    >>> cdd.NumberTypeable('hyperreal') # doctest: +ELLIPSIS
    Traceback (most recent call last):
        ...
    ValueError: ...
    """

    cdef int _number_type

    def __init__(self, number_type='float'):
        if number_type == 'float':
            self._number_type = FLOAT
        elif number_type == 'fraction':
            self._number_type = FRACTION
        else:
            raise ValueError("specify 'float' or 'fraction'")

    property number_type:
        """The number type as string.

        >>> cdd.NumberTypeable('float').number_type
        'float'
        >>> cdd.NumberTypeable('fraction').number_type
        'fraction'
        """
        def __get__(self):
            if self._number_type == FLOAT:
                return 'float'
            elif self._number_type == FRACTION:
                return 'fraction'
            else:
                _invalid_number_type(self._number_type)

    property NumberType:
        """The number type as class.

        >>> cdd.NumberTypeable('float').NumberType
        <type 'float'>
        >>> cdd.NumberTypeable('fraction').NumberType
        <class 'fractions.Fraction'>
        """
        def __get__(self):
            if self._number_type == FLOAT:
                return float
            elif self._number_type == FRACTION:
                return Fraction
            else:
                _invalid_number_type(self._number_type)

    def make_number(self, value):
        """Convert value into a number.

        :param value: The value to convert.
        :type value: :class:`int`, :class:`float`, or :class:`str`
        :returns: The converted value.
        :rtype: :attr:`~cdd.NumberTypeable.NumberType`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(repr(x))
        4.0
        0.66666666666666663
        1.6000000000000001
        -1.5
        1.1200000000000001
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(repr(x))
        Fraction(4, 1)
        Fraction(2, 3)
        Fraction(8, 5)
        Fraction(-3, 2)
        Fraction(1261007895663739, 1125899906842624)
        """
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
        """Convert value into a string.

        :param value: The value.
        :type value: :attr:`~cdd.NumberTypeable.NumberType`
        :returns: A string for the value.
        :rtype: :class:`str`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_str(x))
        4.0
        0.666666666667
        1.6
        -1.5
        1.12
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_str(x))
        4
        2/3
        8/5
        -3/2
        1261007895663739/1125899906842624
        """
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
        """Return representation string for value.

        :param value: The value.
        :type value: :attr:`~cdd.NumberTypeable.NumberType`
        :returns: A string for the value.
        :rtype: :class:`str`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_repr(x))
        4.0
        0.66666666666666663
        1.6000000000000001
        -1.5
        1.1200000000000001
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_repr(x))
        4
        '2/3'
        '8/5'
        '-3/2'
        '1261007895663739/1125899906842624'
        """
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
        """Compare values. Type checking may not be performed, for
        speed. If *num2* is not specified, then *num1* is compared
        against zero.

        :param num1: First value.
        :type num1: :attr:`~cdd.NumberTypeable.NumberType`
        :param num2: Second value.
        :type num2: :attr:`~cdd.NumberTypeable.NumberType`

        >>> a = cdd.NumberTypeable('float')
        >>> a.number_cmp(0.0, 5.0)
        -1
        >>> a.number_cmp(5.0, 0.0)
        1
        >>> a.number_cmp(5.0, 5.0)
        0
        >>> a.number_cmp(1e-30)
        0
        >>> a = cdd.NumberTypeable('fraction')
        >>> a.number_cmp(0, 1)
        -1
        >>> a.number_cmp(1, 0)
        1
        >>> a.number_cmp(0, 0)
        0
        >>> a.number_cmp(a.make_number(1e-30))
        1
        """
        cdef double f1, f2, fdiff
        if self._number_type == FLOAT:
            if num2 is not None:
                # converting to double first, so substraction is faster
                f1 = num1
                f2 = num2
                fdiff = num1 - num2
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
    """Adjacency test type.

    .. attribute::
       COMBINATORIAL
       ALGEBRAIC
    """
    COMBINATORIAL = dd_Combinatorial
    ALGEBRAIC     = dd_Algebraic

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

cdef class LPSolverType:
    """Type of solver for a linear program.

    .. attribute::
       CRISS_CROSS
       DUAL_SIMPLEX
    """
    CRISS_CROSS  = dd_CrissCross
    DUAL_SIMPLEX = dd_DualSimplex

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

# extension classes to wrap matrix, linear program, and polyhedron

cdef class Matrix(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef dd_MatrixPtr dd_mat
    cdef ddf_MatrixPtr ddf_mat

cdef class LinProg(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef dd_LPPtr dd_lp
    cdef ddf_LPPtr ddf_lp

cdef class Polyhedron(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef dd_PolyhedraPtr dd_poly
    cdef ddf_PolyhedraPtr ddf_poly
