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

cimport libc.stdio

# also need time_t
cdef extern from "time.h" nogil:
    ctypedef long time_t

cdef extern from "cddlib/setoper.h" nogil:
    ctypedef unsigned long *set_type
    cdef unsigned long set_blocks(long len)
    cdef void set_initialize(set_type *setp, long len)
    cdef void set_free(set_type set)
    cdef void set_emptyset(set_type set)
    cdef void set_copy(set_type setcopy, set_type set)
    cdef void set_addelem(set_type set, long elem)
    cdef void set_delelem(set_type set, long elem)
    cdef void set_int(set_type set, set_type set1, set_type set2)
    cdef void set_uni(set_type set, set_type set1, set_type set2)
    cdef void set_diff(set_type set, set_type set1, set_type set2)
    cdef void set_compl(set_type set, set_type set1)
    cdef int set_subset(set_type set1, set_type set2)
    cdef int set_member(long elem, set_type set)
    cdef long set_card(set_type set)
    cdef long set_groundsize(set_type set)
    cdef void set_write(set_type set)
    cdef void set_fwrite(libc.stdio.FILE *f, set_type set)
    cdef void set_fwrite_compl(libc.stdio.FILE *f, set_type set)
    cdef void set_binwrite(set_type set)
    cdef void set_fbinwrite(libc.stdio.FILE *f, set_type set)
