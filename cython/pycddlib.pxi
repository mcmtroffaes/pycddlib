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

from collections.abc import Container, Sequence, Set
from contextlib import contextmanager
from enum import IntEnum
from typing import Optional

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

cdef _get_arow(dd_colrange size, dd_Arow row):
    # create Python Sequence from given dd_Arow, starting at index 1
    return [_get_mytype(row[i]) for i in range(1, size)]

cdef _get_set(set_type set_):
    # create Python Set from given set_type
    cdef unsigned long elem
    return {
        elem for elem in range(set_[0]) if set_member(elem + 1, set_)
    }

cdef _set_set(set_type set_, elems):
    # set elements of set_type by elements from a Python Container
    cdef unsigned long elem
    for elem in range(set_[0]):
        if elem in elems:
            set_addelem(set_, elem + 1)
        else:
            set_delelem(set_, elem + 1)

cdef setfam_from_ptr(dd_SetFamilyPtr dd_setfam):
    # create Python Sequence[Set] from dd_SetFamilyPtr, and
    # free the pointer; indexing of the sets start at 0, unlike the
    # string output from cddlib, which starts at 1
    cdef dd_bigrange elem
    cdef dd_bigrange i
    if dd_setfam == NULL:
        raise MemoryError
    result = [
        {
            elem
            for elem in range(dd_setfam.setsize)
            if set_member(elem + 1, dd_setfam.set[i])
        }
        for i in range(dd_setfam.famsize)
    ]
    dd_FreeSetFamily(dd_setfam)
    return result

cdef setfam_from_ptr_with_error(dd_SetFamilyPtr dd_setfam, dd_ErrorType error):
    if error != dd_NoError:
        dd_FreeSetFamily(dd_setfam)
        _raise_error(error)
    return setfam_from_ptr(dd_setfam)


cdef _raise_error(dd_ErrorType error):
    cdef libc.stdio.FILE *pfile
    pfile = _tmpfile()
    dd_WriteErrorMessages(pfile, error)
    raise RuntimeError(_tmpread(pfile).rstrip('\n'))

# extension classes to wrap matrix, linear program, and polyhedron

cdef class Matrix:
    r"""A set of inequalities/equalities (H-representation)
    or a set of non-linear/linear generators (V-representation)
    described by an array :math:`[b \quad A]` and a row index set :math:`L`.

    For this class,
    :attr:`~cdd.Matrix.rep_type` determines the representation type,
    :attr:`~cdd.Matrix.array` determines the array :math:`[b \quad A]`, and
    :attr:`~cdd.Matrix.lin_set` determines the row index set :math:`L`.

    The H-representation corresponds to a polyhedron :math:`P` formed by
    all points :math:`x` satisfying

    .. math::
        0&\le b_i + A_i x \qquad \forall i\notin L \\
        0&=   b_i + A_i x \qquad \forall i\in L \\

    where :math:`A_i` denotes the :math:`i`-th row of :math:`A`.

    To understand the V-representation,
    first we need the concept of a *halfspace*.
    For any real number :math:`z_0` and column vector :math:`z`,
    we define a halfspace as follows:

    .. math::
        H_{z_0,z}^{\ge}=\{x\colon z_0+x^T z\ge 0\}

    Note that :math:`z` is allowed to be the zero vector,
    in which case the halfspace is either the complete space (if :math:`z_0\ge 0`)
    or the empty space (if :math:`z_0<0`).

    The V-representation corresponds to the polyhedron
    formed by the intersection of all
    halfspaces :math:`H_{z_0,z}^{\ge}` satisfying

    .. math::
        0&\le b_i z_0 + A_i z \qquad \forall i\notin L \\
        0&=   b_i z_0 + A_i z \qquad \forall i\in L

    A halfspace that satisfies these constraints is called *feasible*.
    The set of feasible halfspaces forms a convex cone, denoted :math:`Z`,
    in the :math:`(z_0,z)`-space.
    This cone has a dual:

    .. math::
        Z^*=\{(x_0,x)\colon x_0z_0+x^Tz\ge 0\, \forall z\in Z\}

    In other words, the polyhedron described by the V-representation
    is the intersection of
    the dual cone :math:`Z^*` and
    the hyperplane determined by :math:`x_0=1`:

    .. math::
        P=Z^*\cap\{(x_0,x)\colon x_0=1\}

    To make this easier to visualize,
    by convention,
    each equation is divided by :math:`b_i` if :math:`b_i\neq 0`, i.e.

    .. math::
        [t_i \quad V_i]=
        \begin{cases}
        [0 \quad A_i]\text{ if }b_i=0 \\
        [1 \quad A_i/b_i]\text{ if }b_i\neq 0
        \end{cases}

    This then leads to an array :math:`[t \quad V]`,
    representing the same polyhedron :math:`P`
    as :math:`[b \quad A]`:
    indeed, :math:`H_{z_0,z}^{\ge}` is feasible if and only if

    .. math::
        0\le t_i z_0 + V_i z \qquad &\forall i\notin L \\
        0=   t_i z_0 + V_i z \qquad &\forall i\in L

    For any point of the form :math:`x=\sum_i \lambda_i V_i^T`,
    with :math:`\sum_i \lambda_i t_i=1`
    and :math:`\lambda_i\ge 0` for all :math:`i\notin L`,
    we have that
    :math:`x` belongs to the polyhedron, because in that case

    .. math::
       z_0+x^T z
       &= z_0 + \sum_i \lambda_i V_i z \\
       &=\sum_i \lambda_i (t_i z_0 + V_i z)
       &\ge 0

    It can be shown that this describes the entire polyhedron, i.e.
    the polyhedron in the V-representation is the set of points

    .. math::

        P=\left\{
        \sum_i \lambda_i V_i\colon
        \sum_{i} \lambda_i t_i=1
        \text{ and }
        \forall i\notin L\colon\lambda_i\ge 0
        \right\}

    For this reason, the :math:`V_i` are called the *generators*
    of the polyhedron.
    By the Minkowski-Weyl theorem,
    without loss of generality,
    it can be assumed that
    :math:`i\notin L` whenever :math:`t_i=1`. In that case,

    .. math::
           P=
           \mathrm{conv}\{V_i\colon t_i=1\}
           +\mathrm{span}_{\ge}\{V_i\colon t_i=0,i\not\in L\}
           +\mathrm{span}\{V_i\colon t_i=0,i\in L\}

    where
    :math:`\mathrm{conv}` is the convex hull operator,
    :math:`\mathrm{span}_{\ge}` is the linear span operator
    with non-negative coefficients, and
    :math:`\mathrm{span}` is the linear span operator
    with free coefficients.

    The library will always output V-representations
    in this form, i.e. so that all components of the first column are zero or one,
    and so that :math:`L` does not contain rows whose first component is one.
    """

    cdef dd_MatrixPtr dd_mat
    # hack for annotation of properties
    __annotations__ = dict(
        array=Sequence[Sequence[NumberType]],
        lin_set=Set[int],
        rep_type=RepType,
        obj_type=LPObjType,
        obj_func=Sequence[NumberType],
    )

    @property
    def array(self):
        """Array representing the inequalities or generators."""
        cdef _Shape shape = _Shape(self.dd_mat.rowsize, self.dd_mat.colsize)
        return _get_array_from_matrix(self.dd_mat.matrix, shape)

    @property
    def lin_set(self):
        """A set containing the rows of linearity.
        These are linear generators for the V-representation, and
        equalities for the H-representation.
        """
        return _get_set(self.dd_mat.linset)

    @lin_set.setter
    def lin_set(self, value):
        _set_set(self.dd_mat.linset, value)

    @property
    def rep_type(self):
        """Representation:
        inequalities (H-representation), generators (V-representation), or unspecified.
        """
        return RepType(self.dd_mat.representation)

    @rep_type.setter
    def rep_type(self, dd_RepresentationType value):
        self.dd_mat.representation = value

    @property
    def obj_type(self):
        """Linear programming objective: maximize, minimize, or none."""
        return LPObjType(self.dd_mat.objective)

    @obj_type.setter
    def obj_type(self, dd_LPObjectiveType value):
        self.dd_mat.objective = value

    @property
    def obj_func(self):
        """Linear programming objective function."""
        cdef dd_colrange colindex
        return [_get_mytype(self.dd_mat.rowvec[colindex])
                for colindex in range(self.dd_mat.colsize)]

    @obj_func.setter
    def obj_func(self, obj_func):
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


cdef matrix_from_ptr_with_error(dd_MatrixPtr dd_mat, dd_ErrorType error):
    if error != dd_NoError:
        dd_FreeMatrix(dd_mat)
        _raise_error(error)
    return matrix_from_ptr(dd_mat)


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
    array: Sequence[Sequence[SupportsNumberType]],
    lin_set: Container[int] = (),
    rep_type: RepType = RepType.UNSPECIFIED,
    obj_type: LPObjType = LPObjType.NONE,
    obj_func: Optional[Sequence[SupportsNumberType]] = None,
) -> Matrix:
    """Construct a matrix with the given attributes.

    See :attr:`cdd.Matrix.array` for an explanation of how *array* must be laid out.
    This function also accepts 2-dimensional numpy arrays.
    """
    cdef Py_ssize_t numrows, numcols, rowindex, colindex
    cdef dd_MatrixPtr dd_mat
    cdef _Shape shape = _array_shape(array)
    dd_mat = dd_CreateMatrix(shape.numrows, shape.numcols)
    if dd_mat == NULL:
        raise MemoryError
    try:
        _set_matrix_from_array(dd_mat.matrix, shape, array)
        _set_set(dd_mat.linset, lin_set)
        dd_mat.representation = rep_type.value
        dd_mat.objective = obj_type.value
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


def matrix_copy(mat: Matrix) -> Matrix:
    """Return a copy of *mat*."""
    return matrix_from_ptr(dd_CopyMatrix(mat.dd_mat))


def matrix_append_to(mat1: Matrix, mat2: Matrix) -> None:
    """Append *mat2* to *mat1*.

    A :exc:`ValueError` is raised if the column sizes are unequal.
    """
    if dd_MatrixAppendTo(&mat1.dd_mat, mat2.dd_mat) != 1:
        raise ValueError("cannot append because column sizes differ")

cdef int _ROW_CHECK_TYPE_REDUNDANT = 0
cdef int _ROW_CHECK_TYPE_STRONGLY_REDUNDANT = 1
cdef int _ROW_CHECK_TYPE_IMPLICIT_LINEARITY = 2

# () -> Optional[Sequence[NumberType]]
cdef _certificate(dd_MatrixPtr dd_mat, int row, int row_check_type):
    """Returns a certificate to prove that *row_check_type* is not satisfied,
    otherwise returns ``None``.
    """
    if (
        dd_mat.representation != dd_Inequality
        and dd_mat.representation != dd_Generator
    ):
        raise ValueError("rep_type must be INEQUALITY or GENERATOR")
    if set_member(row + 1, dd_mat.linset):
        raise ValueError("row must not be in lin_set")
    if not (0 <= row < dd_mat.rowsize):
        raise IndexError("row out of range")
    cdef dd_ErrorType error = dd_NoError
    cdef dd_colrange certificate_size = dd_mat.colsize + (
        1 if dd_mat.representation == dd_Generator else 0
    )
    cdef dd_Arow certificate = NULL
    cdef dd_boolean is_red = 0
    cdef dd_rowrange crow = row
    dd_InitializeArow(certificate_size, &certificate)
    try:
        if row_check_type == _ROW_CHECK_TYPE_REDUNDANT:
            is_red = dd_Redundant(dd_mat, crow + 1, certificate, &error)
        elif row_check_type == _ROW_CHECK_TYPE_STRONGLY_REDUNDANT:
            is_red = dd_SRedundant(dd_mat, crow + 1, certificate, &error)
        elif row_check_type == _ROW_CHECK_TYPE_IMPLICIT_LINEARITY:
            is_red = dd_ImplicitLinearity(dd_mat, crow + 1, certificate, &error)
        if certificate == NULL or error != dd_NoError:
            _raise_error(error)
        return _get_arow(certificate_size, certificate) if not is_red else None
    finally:
        dd_FreeArow(certificate_size, certificate)

def redundant(mat: Matrix, row: int) -> Optional[Sequence[NumberType]]:
    r"""A certificate in case *row* is
    not redundant
    for *mat*, otherwise ``None``.

    A row is redundant in the H- or V-representation
    if its removal does not affect the polyhedron.

    For the H-representation, the
    "no redundancy"
    certificate :math:`x` is
    a solution that satisfies all constraints but violates *row*, i.e.

    .. math::
       0&>   b_j+A_j x \\
       0&\le b_i+A_i x \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i+A_i x \qquad\forall i\in L,\,i\neq j

    For the V-representation, the
    "no redundancy"
    certificate :math:`(z_0,z)` is
    a halfspace :math:`H_{z_0,z}^{\ge}`
    that contains all generators but does not contain *row*, i.e.

    .. math::
       0&>   b_j z_0 + A_j z \\
       0&\le b_i z_0 + A_i z \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i z_0 + A_i z \qquad\forall i\in L,\,i\neq j

    .. warning::
        Linearity rows are not checked
        i.e. *row* should not be in the :attr:`~cdd.Matrix.lin_set`.

    .. versionadded:: 3.0.0
    """
    return _certificate(mat.dd_mat, row, _ROW_CHECK_TYPE_REDUNDANT)

def s_redundant(mat: Matrix, row: int) -> Optional[Sequence[NumberType]]:
    r"""A certificate in case *row* is
    not strongly redundant
    for *mat*, otherwise ``None``.

    A row is strongly redundant in the H-representation if every point in
    the polyhedron satisfies it with strict inequality.
    A row is strongly redundant in the V-representation if it is in
    the relative interior of the polyhedron.

    For the H-representation, the
    "no strong redundancy"
    certificate :math:`x` is
    a feasible solution satisfying the constraint *row* with equality, i.e.

    .. math::
       0&=   b_j+A_j x \\
       0&\le b_i+A_i x \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i+A_i x \qquad\forall i\in L,\,i\neq j

    For the V-representation, the
    "no strong redundancy"
    certificate :math:`(z_0,z)` is
    a feasible halfspace :math:`H_{z_0,z}^{\ge}`
    that contains the generator *row* on its edge, i.e.

    .. math::
       0&=   b_j z_0 + A_j z \\
       0&\le b_i z_0 + A_i z \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i z_0 + A_i z \qquad\forall i\in L,\,i\neq j

    .. warning::
        Linearity rows are not checked
        i.e. *row* should not be in the :attr:`~cdd.Matrix.lin_set`.

    .. versionadded:: 3.0.0
    """
    return _certificate(mat.dd_mat, row, _ROW_CHECK_TYPE_STRONGLY_REDUNDANT)

def implicit_linearity(mat: Matrix, row: int) -> Optional[Sequence[NumberType]]:
    r"""A certificate in case *row* is
    not implicitly linear
    for *mat*, otherwise ``None``.

    A row is implicitly linear in the H- or V-representation
    if adding it to the linearity set :attr:`~cdd.Matrix.lin_set`
    does not affect the polyhedron.

    For the H-representation, the
    "no implicit linearity"
    certificate :math:`x` is
    a feasible solution satisfying inequality *row* with strict inequality, i.e.

    .. math::
       0&<   b_j+A_j x \\
       0&\le b_i+A_i x \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i+A_i x \qquad\forall i\in L,\,i\neq j

    For the V-representation, the
    "no implicit linearity"
    certificate :math:`(z_0,z)` is
    a feasible halfspace :math:`H_{z_0,z}^{\ge}`
    that strictly contains the generator *row*, i.e.

    .. math::
       0&<   b_j z_0 + A_j z \\
       0&\le b_i z_0 + A_i z \qquad\forall i\notin L,\,i\neq j \\
       0&=   b_i z_0 + A_i z \qquad\forall i\in L,\,i\neq j

    .. warning::
        Linearity rows are not checked
        i.e. *row* should not be in the :attr:`~cdd.Matrix.lin_set`.

    .. versionadded:: 3.0.0
    """
    return _certificate(mat.dd_mat, row, _ROW_CHECK_TYPE_IMPLICIT_LINEARITY)

# () -> Set[int]
cdef _certificate_rows(dd_MatrixPtr dd_mat, int row_check_type):
    """Returns all non-linearity rows that have no certificate,
    in the sense of *row_check_type*, for *mat*.
    """
    cdef dd_ErrorType error = dd_NoError
    cdef dd_rowset row_set = NULL
    try:
        if row_check_type == _ROW_CHECK_TYPE_REDUNDANT:
            row_set = dd_RedundantRows(dd_mat, &error)
        elif row_check_type == _ROW_CHECK_TYPE_STRONGLY_REDUNDANT:
            row_set = dd_SRedundantRows(dd_mat, &error)
        elif row_check_type == _ROW_CHECK_TYPE_IMPLICIT_LINEARITY:
            row_set = dd_ImplicitLinearityRows(dd_mat, &error)
        if row_set == NULL or error != dd_NoError:
            _raise_error(error)
        return _get_set(row_set)
    finally:
        set_free(row_set)

def redundant_rows(mat: Matrix) -> Set[int]:
    """Returns all non-linearity rows that are
    redundant
    for *mat*.

    .. versionadded:: 3.0.0
    """
    return _certificate_rows(mat.dd_mat, _ROW_CHECK_TYPE_REDUNDANT)

def s_redundant_rows(mat: Matrix) -> Set[int]:
    """Returns all non-linearity rows that are
    strongly redundant
    for *mat*.

    .. versionadded:: 3.0.0
    """
    return _certificate_rows(mat.dd_mat, _ROW_CHECK_TYPE_STRONGLY_REDUNDANT)

def implicit_linearity_rows(mat: Matrix) -> Set[int]:
    """Returns all non-linearity rows that are
    implicitly linear
    for *mat*.

    .. versionadded:: 3.0.0
    """
    return _certificate_rows(mat.dd_mat, _ROW_CHECK_TYPE_IMPLICIT_LINEARITY)

def matrix_canonicalize(
    mat: Matrix
) -> tuple[Set[int], Set[int], Sequence[Optional[int]]]:
    """Transform to canonical representation by recognizing all
    implicit linearities and all redundancies. These are returned
    as a pair of sets of row indices, along with a sequence of new row positions
    (``None`` for removed rows).

    This function has the same effect as calling
    :func:`~cdd.matrix_canonicalize_linearity` followed by
    :func:`~cdd.matrix_redundancy_remove`.

    .. versionadded:: 1.0.3

    .. versionchanged:: 3.0.0
        Also return new row positions.
    """
    cdef dd_rowset impl_linset = NULL
    cdef dd_rowset redset = NULL
    cdef dd_rowindex newpos = NULL
    cdef dd_ErrorType error = dd_NoError
    cdef dd_rowrange original_rowsize = mat.dd_mat.rowsize
    cdef dd_boolean success
    if mat.dd_mat.representation == dd_Unspecified:
        raise ValueError("rep_type unspecified")
    success = dd_MatrixCanonicalize(
        &mat.dd_mat, &impl_linset, &redset, &newpos, &error
    )
    try:
        if (
            not success
            or error != dd_NoError
            or impl_linset == NULL
            or redset == NULL
            or newpos == NULL
        ):
            _raise_error(error)
        return (
            _get_set(impl_linset),
            _get_set(redset),
            [
                pos - 1 if (pos := newpos[i + 1]) > 0 else None
                for i in range(original_rowsize)
            ],
        )
    finally:
        set_free(impl_linset)
        set_free(redset)
        libc.stdlib.free(newpos)

cdef int _CANONICALIZE_REDUNDANCY = 0
cdef int _CANONICALIZE_LINEARITY = 1

# () -> tuple[Set[int], Sequence[Optional[int]]]
cdef _matrix_canonicalize_something(dd_MatrixPtr *dd_mat, int something):
    cdef dd_rowset rowset = NULL
    cdef dd_rowindex newpos = NULL
    cdef dd_ErrorType error = dd_NoError
    cdef dd_rowrange original_rowsize = dd_mat[0].rowsize
    cdef dd_boolean success
    if dd_mat[0].representation == dd_Unspecified:
        raise ValueError("rep_type unspecified")
    if something == _CANONICALIZE_LINEARITY:
        success = dd_MatrixCanonicalizeLinearity(
            dd_mat, &rowset, &newpos, &error
        )
    elif something == _CANONICALIZE_REDUNDANCY:
        success = dd_MatrixRedundancyRemove(
            dd_mat, &rowset, &newpos, &error
        )
    try:
        if (
            not success
            or error != dd_NoError
            or rowset == NULL
            or newpos == NULL
        ):
            _raise_error(error)
        return (
            _get_set(rowset),
            [
                pos - 1 if (pos := newpos[i + 1]) > 0 else None
                for i in range(original_rowsize)
            ],
        )
    finally:
        set_free(rowset)
        libc.stdlib.free(newpos)

def matrix_canonicalize_linearity(
    mat: Matrix
) -> tuple[Set[int], Sequence[Optional[int]]]:
    """Add all implicit linearities to the :attr:`~cdd.Matrix.lin_set`,
    and then remove all redundant linearities
    (e.g. everything in :attr:`~cdd.Matrix.lin_set`),
    by finding a basis for the linearity rows.

    Returns implicit linearities as a sets of row indices,
    along with a sequence of new row positions (``None`` for removed rows).

    .. versionadded:: 3.0.0
    """
    return _matrix_canonicalize_something(&mat.dd_mat, _CANONICALIZE_LINEARITY)

def matrix_redundancy_remove(
    mat: Matrix
) -> tuple[Set[int], Sequence[Optional[int]]]:
    """Remove all redundant non-linearity rows
    (e.g. everything outside of :attr:`~cdd.Matrix.lin_set`).

    Returns redundant rows as a set of row indices,
    along with a sequence of new row positions (``None`` for removed rows).

    .. versionadded:: 3.0.0
    """
    return _matrix_canonicalize_something(&mat.dd_mat, _CANONICALIZE_REDUNDANCY)

def matrix_adjacency(mat: Matrix) -> Sequence[Set[int]]:
    """Generate the input adjacency of the polyhedron represented by *mat*.

    H-representation: For each face, list adjacent faces.
    V-representation: For each vertex, list adjacent vertices.

    .. note::
        The implementation uses linear programming,
        instead of the double description method,
        so this function should work for large scale problems.

    .. seealso::
        The :func:`~cdd.copy_input_adjacency` function performs a similar operation,
        using the double description method.

    .. warning::
        This function assumes that the matrix has no redundancies.
        Call :func:`~cdd.matrix_canonicalize` first if need be.

    .. versionadded:: 3.0.0
    """
    cdef dd_ErrorType error = dd_NoError
    cdef dd_SetFamilyPtr dd_setfam = dd_Matrix2Adjacency(mat.dd_mat, &error)
    return setfam_from_ptr_with_error(dd_setfam, error)

def matrix_weak_adjacency(mat: Matrix) -> Sequence[Set[int]]:
    """Generate the weak input adjacency of the polyhedron represented by *mat*.

    H-representation: For each face, list adjacent faces.
    V-representation: For each vertex, list adjacent vertices.

    .. note::
        The implementation uses linear programming,
        instead of the double description method,
        so this function should work for large scale problems.

    .. seealso::
        The :func:`~cdd.copy_input_adjacency` function performs a similar operation,
        using the double description method.

    .. warning::
        This function assumes that the matrix has no redundancies.
        Call :func:`~cdd.matrix_canonicalize` first if need be.

    .. versionadded:: 3.0.0
    """
    cdef dd_ErrorType error = dd_NoError
    cdef dd_SetFamilyPtr dd_setfam = dd_Matrix2WeakAdjacency(mat.dd_mat, &error)
    return setfam_from_ptr_with_error(dd_setfam, error)


def matrix_rank(
    mat: Matrix, ignored_rows: Container[int] = (), ignored_cols: Container[int] = ()
) -> tuple[Set[int], Set[int], int]:
    """Return a row basis, a column basis, and rank, of *mat*,
    whilst ignoring *ignored_rows* and *ignored_cols*.

    .. versionadded:: 3.0.0
    """
    cdef set_type dd_ignored_rows = NULL
    cdef set_type dd_ignored_cols = NULL
    cdef set_type rowbasis = NULL
    cdef set_type colbasis = NULL
    cdef long rank = 0
    set_initialize(&dd_ignored_rows, mat.dd_mat.rowsize)
    try:
        if ignored_rows:
            _set_set(dd_ignored_rows, ignored_rows)
        set_initialize(&dd_ignored_cols, mat.dd_mat.colsize)
        try:
            if ignored_cols:
                _set_set(dd_ignored_cols, ignored_cols)
            rank = dd_MatrixRank(
                mat.dd_mat, dd_ignored_rows, dd_ignored_cols, &rowbasis, &colbasis
            )
            try:
                result = (_get_set(rowbasis), _get_set(colbasis), rank)
            finally:
                set_free(rowbasis)
                set_free(colbasis)
        finally:
            set_free(dd_ignored_cols)
    finally:
        set_free(dd_ignored_rows)
    return result


cdef class LinProg:
    """A linear program: a set of inequalities and an objective function to optimize."""
    cdef dd_LPPtr dd_lp
    __annotations__ = dict(
        array=Sequence[Sequence[NumberType]],
        dual_solution=Sequence[tuple[int, NumberType]],
        obj_type=LPObjType,
        obj_value=NumberType,
        primal_solution=Sequence[NumberType],
        solver=LPSolverType,
        status=LPStatusType,
    )

    @property
    def array(self):
        r"""The array representing the linear program. More specifically,
        the constraints :math:`0\le b+Ax`
        and objective function :math:`\gamma + c^T x`
        are stored as an array as follows:

        .. math::
            \begin{array}{cc} b & A \\ \gamma & c \end{array}

        i.e. the constraints are stored as a H-representation (with inequalities only),
        and the objective function is stored in the final row.
        Only inequality constraints are represented.
        Equality constraints can be represented by two opposing inequalities.
        """
        cdef _Shape shape = _Shape(self.dd_lp.m, self.dd_lp.d)
        return _get_array_from_matrix(self.dd_lp.A, shape)

    @property
    def obj_type(self):
        """Whether we are minimizing or maximizing."""
        return LPObjType(self.dd_lp.objective)

    @obj_type.setter
    def obj_type(self, dd_LPObjectiveType value):
        self.dd_lp.objective = value

    @property
    def solver(self):
        """The solver used when last solving the linear program."""
        return LPSolverType(self.dd_lp.solver)

    @property
    def status(self):
        """The status of the linear program, after solving."""
        return LPStatusType(self.dd_lp.LPS)

    @property
    def obj_value(self):
        """The optimal value of the objective function, after solving."""
        return _get_mytype(self.dd_lp.optvalue)

    @property
    def primal_solution(self):
        """The optimal value of the primal variables, after solving."""
        cdef dd_colrange colindex
        return [_get_mytype(self.dd_lp.sol[colindex])
                for colindex in range(1, self.dd_lp.d)]

    @property
    def dual_solution(self):
        """The optimal value of the dual variables, after solving.
        Only the non-basic components are given (the basic components are zero).
        They are returned as index-value pairs.
        """
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


def linprog_from_matrix(mat: Matrix) -> LinProg:
    """Convert *mat* into a linear program.
    Note that *mat* must have the H-representation,
    and its objective type must be set,
    otherwise a :exc:`ValueError` is raised.
    """
    # cddlib does not check if obj_type is valid
    if mat.dd_mat.objective != dd_LPmax and mat.dd_mat.objective != dd_LPmin:
        raise ValueError("obj_type must be MIN or MAX")
    # cddlib assumes H-representation
    if mat.dd_mat.representation != dd_Inequality:
        raise ValueError("rep_type must be INEQUALITY")
    cdef dd_ErrorType error = dd_NoError
    # note: dd_Matrix2LP never reports error... so ignore
    return linprog_from_ptr(dd_Matrix2LP(mat.dd_mat, &error))


def linprog_from_array(
    array: Sequence[Sequence[SupportsNumberType]], obj_type: LPObjType
) -> LinProg:
    """Construct a linear program from *array*.

    See :attr:`cdd.LinProg.array` for an explanation of how *array* must be laid out.
    This function also accepts 2-dimensional numpy arrays.

    .. versionadded:: 3.0.0
    """
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


def linprog_solve(
    lp: LinProg, solver: LPSolverType = LPSolverType.DUAL_SIMPLEX
) -> None:
    """Solve the linear program *lp* using *solver*."""
    cdef dd_ErrorType error = dd_NoError
    dd_LPSolve(lp.dd_lp, solver, &error)
    if error != dd_NoError:
        _raise_error(error)


cdef class Polyhedron:
    """Representation of a polyhedron."""
    cdef dd_PolyhedraPtr dd_poly
    __annotations__ = dict(
        rep_type=RepType,
    )

    @property
    def rep_type(self):
        """Representation type of the input."""
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


def polyhedron_from_matrix(
    mat: Matrix, row_order: Optional[RowOrderType] = None
) -> Polyhedron:
    """Run the double description method to convert *mat* into a polyhedron,
    using *row_order* if specified.

    .. versionadded:: 3.0.0

        The *row_order* parameter.
    """
    if (
        mat.dd_mat.representation != dd_Inequality
        and mat.dd_mat.representation != dd_Generator
    ):
        raise ValueError("rep_type must be INEQUALITY or GENERATOR")
    cdef dd_ErrorType error = dd_NoError
    if row_order is None:
        dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
    else:
        dd_poly = dd_DDMatrix2Poly2(mat.dd_mat, row_order, &error)
    if error != dd_NoError:
        dd_FreePolyhedra(dd_poly)
        _raise_error(error)
    return polyhedron_from_ptr(dd_poly)


def copy_input(poly: Polyhedron) -> Matrix:
    """Returns the original matrix that the polyhedron was constructed from.

    .. versionadded:: 3.0.0
    """
    return matrix_from_ptr(dd_CopyInput(poly.dd_poly))


def copy_output(poly: Polyhedron) -> Matrix:
    """Returns the dual representation of the original matrix.
    If the original was a H-representation, this will return its V-representation,
    and vice versa.

    .. note::

        The output is not guaranteed to be minimal,
        that is, it can still contain redundancy.
        Use :func:`~cdd.matrix_canonicalize` on the output to remove redundancies.

    .. versionadded:: 3.0.0
    """
    return matrix_from_ptr(dd_CopyOutput(poly.dd_poly))


def copy_inequalities(poly: Polyhedron) -> Matrix:
    """Copy a H-representation of the inequalities."""
    return matrix_from_ptr(dd_CopyInequalities(poly.dd_poly))


def copy_generators(poly: Polyhedron) -> Matrix:
    """Copy a V-representation of all the generators."""
    return matrix_from_ptr(dd_CopyGenerators(poly.dd_poly))


def copy_adjacency(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the adjacencies.

    H-representation: For each vertex, list adjacent vertices.
    V-representation: For each face, list adjacent faces.

    .. versionadded:: 2.1.1
    """
    return setfam_from_ptr(dd_CopyAdjacency(poly.dd_poly))


def copy_input_adjacency(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the input adjacencies.

    H-representation: For each face, list adjacent faces.
    V-representation: For each vertex, list adjacent vertices.

    .. seealso::
        The :func:`~cdd.matrix_adjacency` and
        :func:`~cdd.matrix_weak_adjacency`
        functions perform a similar operation,
        using linear programming.

    .. versionadded:: 2.1.1
    """
    return setfam_from_ptr(dd_CopyInputAdjacency(poly.dd_poly))


def copy_incidence(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the incidences.

    H-representation: For each vertex, list adjacent faces.
    V-representation: For each face, list adjacent vertices.

    .. versionadded:: 2.1.1
    """
    return setfam_from_ptr(dd_CopyIncidence(poly.dd_poly))


def copy_input_incidence(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the input incidences.

    H-representation: For each face, list adjacent vertices.
    V-representation: For each vertex, list adjacent faces.

    .. versionadded:: 2.1.1
    """
    return setfam_from_ptr(dd_CopyInputIncidence(poly.dd_poly))


def fourier_elimination(mat: Matrix) -> Matrix:
    """Eliminate the last variable from the system of linear inequalities *mat*.

    .. warning::

        This implementation can only handle inequality constraints.
        If your system has equality constraints,
        either convert them into pairs of inequalities first,
        or use :func:`~cdd.block_elimination` instead.

    .. note::

        The output is not guaranteed to be minimal,
        that is, it can still contain redundancy.
        Use :func:`~cdd.matrix_canonicalize` on the output to remove redundancies.

    .. versionadded:: 3.0.0
    """
    if mat.dd_mat.representation != dd_Inequality:
        raise ValueError("rep_type must be INEQUALITY")
    cdef dd_ErrorType error = dd_NoError
    cdef dd_MatrixPtr dd_mat = dd_FourierElimination(mat.dd_mat, &error)
    return matrix_from_ptr_with_error(dd_mat, error)


def block_elimination(mat: Matrix, col_set: Container[int]) -> Matrix:
    """Eliminate the variables *col_set* from the system of linear inequalities *mat*.
    It does this by using the generators of the dual linear system,
    where the generators are calculated using the double description algorithm.

    .. note::

        The output is not guaranteed to be minimal,
        that is, it can still contain redundancy.
        Use :func:`~cdd.matrix_canonicalize` on the output to remove redundancies.

    .. versionadded:: 3.0.0
    """
    if mat.dd_mat.representation != dd_Inequality:
        raise ValueError("rep_type must be INEQUALITY")
    cdef set_type dd_colset = NULL
    cdef dd_MatrixPtr dd_mat = NULL
    cdef dd_ErrorType error = dd_NoError
    set_initialize(&dd_colset, mat.dd_mat.colsize)
    try:
        _set_set(dd_colset, col_set)
        dd_mat = dd_BlockElimination(mat.dd_mat, dd_colset, &error)
        return matrix_from_ptr_with_error(dd_mat, error)
    finally:
        set_free(dd_colset)


# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...
