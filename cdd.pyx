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

import fractions

# generated files with type specific cddlib header declarations
include "cddlib.pxi"
include "cddlib_f.pxi"

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

DEF FLOAT = 1
DEF FRACTION = 2

cdef inline _invalid(int number_type):
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
                _invalid(self._number_type)

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
                return fractions.Fraction
            else:
                _invalid(self._number_type)

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
                return fractions.Fraction.from_float(value)
            else:
                return fractions.Fraction(value)
        else:
            _invalid(self._number_type)

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
            if not isinstance(value, fractions.Fraction):
                raise TypeError(
                    'expected fractions.Fraction but got {0}'
                    .format(value.__class__.__name__))
            return str(value)
        else:
            _invalid(self._number_type)

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
            if not isinstance(value, fractions.Fraction):
                raise TypeError(
                    'expected fractions.Fraction but got {0}'
                    .format(value.__class__.__name__))
            if value.denominator == 1:
                # integer: "x"
                return str(value.numerator)
            # anything else: "'x/y'"
            return repr(str(value))
        else:
            _invalid(self._number_type)

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

cdef class Matrix(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef readonly object data

    def __init__(self, rows, linear=False, number_type='float'):
        NumberTypeable.__init__(self, number_type)
        if self._number_type == FLOAT:
            self.data = _float.Matrix(rows, linear)
        elif self._number_type == FRACTION:
            self.data = _fraction.Matrix(rows, linear)
        else:
            _invalid(self._number_type)

cdef class LinProg(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef readonly object data

    def __init__(self, Matrix mat):
        NumberTypeable.__init__(self, mat.number_type)
        if self._number_type == FLOAT:
            self.data = _float.LinProg(mat.data)
        elif self._number_type == FRACTION:
            self.data = _fraction.LinProg(mat.data)
        else:
            _invalid(self._number_type)

cdef class Polyhedron(NumberTypeable):
    """Bases: :class:`cdd.NumberTypeable`"""

    cdef readonly object data

    def __init__(self, Matrix mat):
        NumberTypeable.__init__(self, mat.number_type)
        if self._number_type == FLOAT:
            self.data = _float.Polyhedron(mat.data)
        elif self._number_type == FRACTION:
            self.data = _fraction.Polyhedron(mat.data)
        else:
            _invalid(self._number_type)
