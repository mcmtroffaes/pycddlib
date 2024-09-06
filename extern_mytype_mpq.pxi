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
