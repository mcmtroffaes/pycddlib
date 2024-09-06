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

from fractions import Fraction

cdef extern from "cdd.h" nogil:
    ctypedef double myfloat[1]

cdef _get_mytype(myfloat target):
    return target[0]

cdef _set_mytype(myfloat target, value):
    if isinstance(value, str):
        target[0] = Fraction(value)
    else:
        target[0] = float(value)
