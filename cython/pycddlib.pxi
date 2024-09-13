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

from typing_extensions import deprecated  # new in Python 3.13

cimport cpython.mem
cimport cpython.unicode
cimport libc.stdio
cimport libc.stdlib

# windows hack for broken libc.stdio.tmpfile

cdef extern from * nogil:
    cdef void _emit_ifdef_msc_ver "#ifdef _MSC_VER //" ()
    cdef void _emit_else "#else //" ()
    cdef void _emit_endif "#endif //" ()

cdef extern from "stdio.h" nogil:
    char *_tempnam(char *dir, char *prefix)

cdef libc.stdio.FILE *libc_stdio_tmpfile() except NULL:
    cdef libc.stdio.FILE *result
    cdef char *name
    _emit_ifdef_msc_ver()
    name = _tempnam(NULL, NULL)
    if name == NULL:
        raise RuntimeError("failed to create temporary file name")
    result = libc.stdio.fopen(name, "wb+TD")
    libc.stdlib.free(name)
    _emit_else()
    result = libc.stdio.tmpfile()
    _emit_endif()
    return result

cdef libc.stdio.FILE *_tmpfile() except NULL:
    cdef libc.stdio.FILE *result
    # libc.stdio.tmpfile() is broken on windows
    result = libc_stdio_tmpfile()
    if result == NULL:
        raise RuntimeError("failed to create temporary file")
    return result

# helper functions

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
        result = cpython.unicode.PyUnicode_DecodeUTF8(
            <char*>buffer, num_bytes, 'strict'
        )
    finally:
        libc.stdio.fclose(pfile)
        cpython.mem.PyMem_RawFree(buffer)
    return result

cdef _get_set(set_type set_):
    # create Python Set from given set_type
    cdef unsigned long elem
    return frozenset(
        elem for elem from 0 <= elem < set_[0] if set_member(elem + 1, set_)
    )

cdef _set_set(set_type set_, pset):
    # set elements of set_type by elements from a Python Container
    cdef unsigned long elem
    for elem from 0 <= elem < set_[0]:
        if elem in pset:
            set_addelem(set_, elem + 1)
        else:
            set_delelem(set_, elem + 1)

cdef _get_dd_setfam(dd_SetFamilyPtr setfam):
    # create Python Sequence[Set] from dd_SetFamilyPtr, and
    # free the pointer; indexing of the sets start at 0, unlike the
    # string output from cddlib, which starts at 1
    cdef long elem
    if setfam == NULL:
        raise ValueError("failed to get set family")
    result = [
        frozenset(
            elem
            for elem from 0 <= elem < setfam.setsize
            if set_member(elem + 1, setfam.set[i])
        )
        for i from 0 <= i < setfam.famsize
    ]
    dd_FreeSetFamily(setfam)
    return result

cdef _raise_error(dd_ErrorType error, msg):
    cdef libc.stdio.FILE *pfile
    pfile = _tmpfile()
    dd_WriteErrorMessages(pfile, error)
    raise RuntimeError(msg + "\n" + _tmpread(pfile).rstrip('\n'))

# extension classes to wrap matrix, linear program, and polyhedron

cdef class Matrix:
    cdef dd_MatrixPtr dd_mat

    property array:
        def __get__(self):
            cdef dd_rowrange i
            cdef dd_colrange j
            return [
                [
                    _get_mytype(self.dd_mat.matrix[i][j])
                    for j in range(self.dd_mat.colsize)
                ]
                for i in range(self.dd_mat.rowsize)
            ]

    property lin_set:
        def __get__(self):
            return _get_set(self.dd_mat.linset)

        def __set__(self, value):
            _set_set(self.dd_mat.linset, value)

    property rep_type:
        def __get__(self):
            return RepType(self.dd_mat.representation)

        def __set__(self, dd_RepresentationType value):
            self.dd_mat.representation = value

    property obj_type:
        def __get__(self):
            return LPObjType(self.dd_mat.objective)

        def __set__(self, dd_LPObjectiveType value):
            self.dd_mat.objective = value

    property obj_func:
        def __get__(self):
            cdef dd_colrange colindex
            return [_get_mytype(self.dd_mat.rowvec[colindex])
                    for colindex in range(self.dd_mat.colsize)]

        def __set__(self, obj_func):
            cdef Py_ssize_t colindex
            if len(obj_func) != self.dd_mat.colsize:
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                _set_mytype(self.dd_mat.rowvec[colindex], value)

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WriteMatrix(pfile, self.dd_mat)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self):
        raise TypeError("This class cannot be instantiated directly.")

    def __dealloc__(self):
        dd_FreeMatrix(self.dd_mat)
        self.dd_mat = NULL

# wrap pointer into Matrix class
# https://cython.readthedocs.io/en/latest/src/userguide/extension_types.html#instantiation-from-existing-c-c-pointers
cdef matrix_from_ptr(dd_MatrixPtr dd_mat):
    if dd_mat == NULL:
        raise MemoryError  # assume malloc failed
    cdef Matrix matrix = Matrix.__new__(Matrix)
    matrix.dd_mat = dd_mat
    return matrix


# create matrix and wrap into Matrix class
# https://cython.readthedocs.io/en/latest/src/userguide/extension_types.html#instantiation-from-existing-c-c-pointers
def matrix_from_array(
    array,
    lin_set=(),
    dd_RepresentationType rep_type=dd_Unspecified,
    dd_LPObjectiveType obj_type=dd_LPnone,
    obj_func=None,
):
    cdef Py_ssize_t numrows, numcols, rowindex, colindex
    cdef dd_MatrixPtr dd_mat
    # determine dimension
    numrows = len(array)
    if numrows > 0:
        numcols = len(array[0])
    else:
        numcols = 0
    # safely cast ranges
    cdef dd_rowrange numrows2 = <dd_rowrange>numrows
    cdef dd_colrange numcols2 = <dd_colrange>numcols
    if numrows2 != numrows or numcols2 != numcols:
        raise ValueError("matrix too large")
    dd_mat = dd_CreateMatrix(numrows2, numcols2)
    if dd_mat == NULL:
        raise MemoryError
    try:
        for rowindex, row in enumerate(array):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                _set_mytype(dd_mat.matrix[rowindex][colindex], value)
        _set_set(dd_mat.linset, lin_set)
        dd_mat.representation = rep_type
        dd_mat.objective = obj_type
        if obj_func is not None:
            if len(obj_func) != dd_mat.colsize:
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                _set_mytype(dd_mat.rowvec[colindex], value)
    except:  # noqa: E722
        dd_FreeMatrix(dd_mat)
        raise
    return matrix_from_ptr(dd_mat)


def matrix_copy(Matrix matrix):
    return matrix_from_ptr(dd_CopyMatrix(matrix.dd_mat))


def matrix_append_to(Matrix matrix1, Matrix matrix2):
    if dd_MatrixAppendTo(&matrix1.dd_mat, matrix2.dd_mat) != 1:
        raise ValueError("cannot append because column sizes differ")


def matrix_canonicalize(Matrix matrix):
    cdef dd_rowset impl_linset
    cdef dd_rowset redset
    cdef dd_rowindex newpos
    cdef dd_ErrorType error = dd_NoError
    cdef dd_boolean success
    if matrix.dd_mat.representation == dd_Unspecified:
        raise ValueError("rep_type unspecified")
    success = dd_MatrixCanonicalize(
        &matrix.dd_mat, &impl_linset, &redset, &newpos, &error
    )
    result = (_get_set(impl_linset), _get_set(redset))
    set_free(impl_linset)
    set_free(redset)
    libc.stdlib.free(newpos)
    if not success or error != dd_NoError:
        _raise_error(error, "failed to canonicalize matrix")
    return result


cdef class LinProg:
    cdef dd_LPPtr dd_lp

    property status:
        def __get__(self):
            return LPStatusType(self.dd_lp.LPS)

    property obj_value:
        def __get__(self):
            return _get_mytype(self.dd_lp.optvalue)

    property primal_solution:
        def __get__(self):
            cdef dd_colrange colindex
            return [_get_mytype(self.dd_lp.sol[colindex])
                    for colindex in range(1, self.dd_lp.d)]

    property dual_solution:
        def __get__(self):
            cdef dd_colrange colindex
            return [_get_mytype(self.dd_lp.dsol[colindex])
                    for colindex in range(1, self.dd_lp.d)]

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        dd_WriteLPResult(pfile, self.dd_lp, dd_NoError)
        return _tmpread(pfile).rstrip('\n')

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

    def __dealloc__(self):
        dd_FreeLPData(self.dd_lp)
        self.dd_lp = NULL

    def solve(self, dd_LPSolverType solver=dd_DualSimplex):
        cdef dd_ErrorType error = dd_NoError
        dd_LPSolve(self.dd_lp, solver, &error)
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

cdef class Polyhedron:

    cdef dd_PolyhedraPtr dd_poly

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.dd_poly)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, Matrix mat):
        cdef dd_ErrorType error = dd_NoError
        # initialize pointers
        self.dd_poly = NULL
        # read matrix
        self.dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
        if self.dd_poly == NULL or error != dd_NoError:
            # do not call dd_FreePolyhedra(self.dd_poly)
            # see issue #7
            _raise_error(error, "failed to load polyhedra")

    def __dealloc__(self):
        if self.dd_poly:
            dd_FreePolyhedra(self.dd_poly)
        self.dd_poly = NULL

    def get_inequalities(self):
        return matrix_from_ptr(dd_CopyInequalities(self.dd_poly))

    def get_generators(self):
        return matrix_from_ptr(dd_CopyGenerators(self.dd_poly))

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
