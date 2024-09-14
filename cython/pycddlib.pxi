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
            cdef _Shape shape = _Shape(self.dd_mat.rowsize, self.dd_mat.colsize)
            return _get_array_from_matrix(self.dd_mat.matrix, shape)

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

    def __reduce__(self):
        return (
            matrix_from_array,
            (self.array, self.lin_set, self.rep_type, self.obj_type, self.obj_func),
        )


# wrap pointer into Matrix class
# https://cython.readthedocs.io/en/latest/src/userguide/extension_types.html#instantiation-from-existing-c-c-pointers
cdef matrix_from_ptr(dd_MatrixPtr dd_mat):
    if dd_mat == NULL:
        raise MemoryError  # assume malloc failed
    cdef Matrix mat = Matrix.__new__(Matrix)
    mat.dd_mat = dd_mat
    return mat


cdef struct _Shape:
    dd_rowrange numrows
    dd_colrange numcols

cdef _array_shape(array):
    cdef Py_ssize_t numrows, numcols
    numrows = len(array)
    if numrows > 0:
        numcols = len(array[0])
    else:
        numcols = 0
    cdef _Shape shape = _Shape(<dd_rowrange>numrows, <dd_colrange>numcols)
    if shape.numrows != numrows or shape.numcols != numcols:
        raise ValueError("array too large")
    return shape

cdef _set_matrix_from_array(mytype **pp, _Shape shape, array):
    for rowindex, row in enumerate(array):
        if len(row) != shape.numcols:
            raise ValueError("rows have different lengths")
        for colindex, value in enumerate(row):
            _set_mytype(pp[rowindex][colindex], value)


cdef _get_array_from_matrix(mytype **pp, _Shape shape):
    cdef dd_rowrange i
    cdef dd_colrange j
    return [
        [_get_mytype(pp[i][j]) for j in range(shape.numcols)]
        for i in range(shape.numrows)
    ]


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
    cdef _Shape shape = _array_shape(array)
    dd_mat = dd_CreateMatrix(shape.numrows, shape.numcols)
    if dd_mat == NULL:
        raise MemoryError
    try:
        _set_matrix_from_array(dd_mat.matrix, shape, array)
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


def matrix_canonicalize(Matrix mat):
    cdef dd_rowset impl_linset
    cdef dd_rowset redset
    cdef dd_rowindex newpos
    cdef dd_ErrorType error = dd_NoError
    cdef dd_boolean success
    if mat.dd_mat.representation == dd_Unspecified:
        raise ValueError("rep_type unspecified")
    success = dd_MatrixCanonicalize(
        &mat.dd_mat, &impl_linset, &redset, &newpos, &error
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

    property array:
        def __get__(self):
            cdef _Shape shape = _Shape(self.dd_lp.m, self.dd_lp.d)
            return _get_array_from_matrix(self.dd_lp.A, shape)

    property obj_type:
        def __get__(self):
            return LPObjType(self.dd_lp.objective)

        def __set__(self, dd_LPObjectiveType value):
            self.dd_lp.objective = value

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
            return [
                (
                    self.dd_lp.nbindex[colindex + 1] - 1,
                    _get_mytype(self.dd_lp.dsol[colindex])
                )
                for colindex in range(1, self.dd_lp.d)
                if self.dd_lp.nbindex[colindex + 1] > 0
            ]

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        dd_WriteLPResult(pfile, self.dd_lp, dd_NoError)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self):
        raise TypeError("This class cannot be instantiated directly.")

    def __dealloc__(self):
        dd_FreeLPData(self.dd_lp)
        self.dd_lp = NULL

    def __reduce__(self):
        return linprog_from_array, (self.array, self.obj_type)


cdef linprog_from_ptr(dd_LPPtr dd_lp):
    if dd_lp == NULL:
        raise MemoryError  # assume malloc failed
    cdef LinProg lp = LinProg.__new__(LinProg)
    lp.dd_lp = dd_lp
    return lp


def linprog_from_matrix(Matrix mat) -> LinProg:
    # cddlib does not check if obj_type is valid
    if mat.obj_type != dd_LPmax and mat.obj_type != dd_LPmin:
        raise ValueError("obj_type must be MIN or MAX")
    # cddlib assumes H-representation
    if mat.rep_type != dd_Inequality:
        raise ValueError("rep_type must be INEQUALITY")
    cdef dd_ErrorType error = dd_NoError
    # note: dd_Matrix2LP never reports error... so ignore
    cdef dd_LPPtr dd_lp = dd_Matrix2LP(mat.dd_mat, &error)
    if dd_lp == NULL:
        raise MemoryError
    return linprog_from_ptr(dd_lp)


def linprog_from_array(array, dd_LPObjectiveType obj_type):
    if obj_type != dd_LPmax and obj_type != dd_LPmin:
        raise ValueError("obj_type must be MIN or MAX")
    cdef _Shape shape = _array_shape(array)
    cdef dd_LPPtr dd_lp = dd_CreateLPData(
        obj_type, NUMBER_TYPE, shape.numrows, shape.numcols
    )
    if dd_lp == NULL:
        raise MemoryError
    try:
        _set_matrix_from_array(dd_lp.A, shape, array)
    except:  # noqa: E722
        dd_FreeLPData(dd_lp)
        raise
    return linprog_from_ptr(dd_lp)


def linprog_solve(LinProg lp, dd_LPSolverType solver=dd_DualSimplex):
    cdef dd_ErrorType error = dd_NoError
    dd_LPSolve(lp.dd_lp, solver, &error)
    if error != dd_NoError:
        _raise_error(error, "failed to solve linear program")


cdef class Polyhedron:
    cdef dd_PolyhedraPtr dd_poly

    property rep_type:
        def __get__(self):
            return RepType(self.dd_poly.representation)

    def __str__(self):
        cdef libc.stdio.FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.dd_poly)
        return _tmpread(pfile).rstrip('\n')

    def __init__(self):
        raise TypeError("This class cannot be instantiated directly.")

    def __dealloc__(self):
        dd_FreePolyhedra(self.dd_poly)
        self.dd_poly = NULL

cdef polyhedron_from_ptr(dd_PolyhedraPtr dd_poly):
    if dd_poly == NULL:
        raise MemoryError  # assume malloc failed
    cdef Polyhedron poly = Polyhedron.__new__(Polyhedron)
    poly.dd_poly = dd_poly
    return poly


def polyhedron_from_matrix(Matrix mat):
    if mat.rep_type != dd_Inequality and mat.rep_type != dd_Generator:
        raise ValueError("rep_type must be INEQUALITY or GENERATOR")
    cdef dd_ErrorType error = dd_NoError
    dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
    if dd_poly == NULL:
        raise MemoryError
    if error != dd_NoError:
        dd_FreePolyhedra(dd_poly)
        _raise_error(error, "failed to load polyhedra")
    return polyhedron_from_ptr(dd_poly)


def copy_input(Polyhedron poly):
    return matrix_from_ptr(dd_CopyInput(poly.dd_poly))


def copy_output(Polyhedron poly):
    return matrix_from_ptr(dd_CopyOutput(poly.dd_poly))


def copy_inequalities(Polyhedron poly):
    return matrix_from_ptr(dd_CopyInequalities(poly.dd_poly))


def copy_generators(Polyhedron poly):
    return matrix_from_ptr(dd_CopyGenerators(poly.dd_poly))


def copy_adjacency(Polyhedron poly):
    return _get_dd_setfam(dd_CopyAdjacency(poly.dd_poly))


def copy_input_adjacency(Polyhedron poly):
    return _get_dd_setfam(dd_CopyInputAdjacency(poly.dd_poly))


def copy_incidence(Polyhedron poly):
    return _get_dd_setfam(dd_CopyIncidence(poly.dd_poly))


def copy_input_incidence(Polyhedron poly):
    return _get_dd_setfam(dd_CopyInputIncidence(poly.dd_poly))


# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...
