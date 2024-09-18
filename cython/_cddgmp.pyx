# cython: language_level=3

"""Python wrapper for Komei Fukuda's cddlib."""

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

from fractions import Fraction
from typing import Union

from cdd import LPObjType, LPSolverType, LPStatusType, RepType

NumberType = Fraction
SupportsNumberType = Union[Fraction, int]

cdef extern from * nogil:
    "#define GMPRATIONAL"

include "setoper.pxi"
include "mytype_gmp.pxi"
include "cdd.pxi"

cdef dd_NumberType NUMBER_TYPE = dd_Rational

include "pycddlib.pxi"
