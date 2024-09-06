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

import numbers
from fractions import Fraction

cdef extern from *:
    """
#ifndef GMPRATIONAL
#error "GMPRATIONAL must be defined"
#endif
#ifdef GMPFLOAT
#error "GMPFLOAT must not be defined"
#endif
    """

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

cdef extern from "cdd.h" nogil:
    ctypedef mpq_t mytype


# get Python Fraction or int from target
cdef _get_mytype(mytype target):
    cdef signed long int num
    cdef unsigned long int den
    cdef char *buf_ptr
    if mpz_fits_slong_p(mpq_numref(target)) and mpz_fits_ulong_p(mpq_denref(target)):
        num = mpz_get_si(mpq_numref(target))
        den = mpz_get_ui(mpq_denref(target))
        if den == 1:
            return num
        else:
            return Fraction(num, den)
    else:
        buf = cpython.bytes.PyBytes_FromStringAndSize(NULL, mpz_sizeinbase(mpq_numref(target), 10) + mpz_sizeinbase(mpq_denref(target), 10) + 3)
        buf_ptr = cpython.bytes.PyBytes_AsString(buf)
        mpq_get_str(buf_ptr, 10, target)
        # trick: bytes(buf_ptr) removes everything after the null
        return Fraction(bytes(buf_ptr).decode('ascii'))

# set target to value
cdef _set_mytype(mytype target, value):
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
