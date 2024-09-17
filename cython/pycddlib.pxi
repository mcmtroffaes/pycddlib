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

cdef _get_set(set_type set_):
    # create Python Set from given set_type
    cdef unsigned long elem
    return {
        elem for elem from 0 <= elem < set_[0] if set_member(elem + 1, set_)
    }

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
        {
            elem
            for elem from 0 <= elem < setfam.setsize
            if set_member(elem + 1, setfam.set[i])
        }
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
    """A set of linear inequalities or a set of linear generators."""

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
        r"""Array representing the inequalities or generators.

        An array :math:`[b \quad A]` in the H-representation corresponds to a
        polyhedron described by

        .. math::
           0&\le b_i + A_i x \qquad \forall i\in\{0,\dots,n-1\}\setminus L \\
           0&=   b_i + A_i x \qquad \forall i\in L

        where :math:`L` is :attr:`~cdd.Matrix.lin_set` and :math:`A_i`
        corresponds to the :math:`i`-th row of :math:`A`.

        A array :math:`[t \quad V]` in the V-representation corresponds to a
        polyhedron described by

        .. math::
           \mathrm{conv}\{V_i\colon t_i=1\}
           +\mathrm{nonnegspan}\{V_i\colon t_i=0,i\not\in L\}
           +\mathrm{linspan}\{V_i\colon t_i=0,i\in L\}

        where :math:`L` is :attr:`~cdd.Matrix.lin_set` and :math:`V_i`
        corresponds to the :math:`i`-th row of :math:`V`. Here
        :math:`\mathrm{conv}` is the convex hull operator,
        :math:`\mathrm{nonnegspan}` is the non-negative span operator, and
        :math:`\mathrm{linspan}` is the linear span operator. All entries
        of :math:`t` must be either :math:`0` or :math:`1`.
        """
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


def matrix_canonicalize(mat: Matrix) -> tuple[Set[int], Set[int]]:
    """Transform to canonical representation by recognizing all
    implicit linearities and all redundancies. These are returned
    as a pair of sets of row indices.
    """
    cdef dd_rowset impl_linset = NULL
    cdef dd_rowset redset = NULL
    cdef dd_rowindex newpos = NULL
    cdef dd_ErrorType error = dd_NoError
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
            _raise_error(error, "failed to canonicalize matrix")
        return (_get_set(impl_linset), _get_set(redset))
    finally:
        set_free(impl_linset)
        set_free(redset)
        libc.stdlib.free(newpos)


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
        _raise_error(error, "failed to solve linear program")


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
    mat: Matrix, row_order_type: Optional[RowOrderType] = None
) -> Polyhedron:
    """Run the double description method to convert *mat* into a polyhedron,
    using *row_order_type* if specified.

    .. versionadded:: 3.0.0

        The *row_order_type* parameter.
    """
    if (
        mat.dd_mat.representation != dd_Inequality
        and mat.dd_mat.representation != dd_Generator
    ):
        raise ValueError("rep_type must be INEQUALITY or GENERATOR")
    cdef dd_ErrorType error = dd_NoError
    if row_order_type is None:
        dd_poly = dd_DDMatrix2Poly(mat.dd_mat, &error)
    else:
        dd_poly = dd_DDMatrix2Poly2(mat.dd_mat, row_order_type, &error)
    if error != dd_NoError:
        dd_FreePolyhedra(dd_poly)
        _raise_error(error, "failed to run double description method")
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
        Use :func:`cdd.matrix_canonicalize` on the output to remove redundancies.

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
    """
    return _get_dd_setfam(dd_CopyAdjacency(poly.dd_poly))


def copy_input_adjacency(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the input adjacencies.

    H-representation: For each face, list adjacent faces.
    V-representation: For each vertex, list adjacent vertices.
    """
    return _get_dd_setfam(dd_CopyInputAdjacency(poly.dd_poly))


def copy_incidence(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the incidences.

    H-representation: For each vertex, list adjacent faces.
    V-representation: For each face, list adjacent vertices.
    """
    return _get_dd_setfam(dd_CopyIncidence(poly.dd_poly))


def copy_input_incidence(poly: Polyhedron) -> Sequence[Set[int]]:
    """Get the input incidences.

    H-representation: For each face, list adjacent vertices.
    V-representation: For each vertex, list adjacent faces.
    """
    return _get_dd_setfam(dd_CopyInputIncidence(poly.dd_poly))


def fourier_elimination(mat: Matrix) -> Matrix:
    """Eliminate the last variable from the system of linear inequalities *mat*.

    .. warning::

        This implementation can only handle inequality constraints.
        If your system has equality constraints,
        either convert them into pairs of inequalities first,
        or use :func:`cdd.block_elimination` instead.

    .. note::

        The output is not guaranteed to be minimal,
        that is, it can still contain redundancy.
        Use :func:`cdd.matrix_canonicalize` on the output to remove redundancies.

    .. versionadded:: 3.0.0
    """
    if mat.dd_mat.representation != dd_Inequality:
        raise ValueError("rep_type must be INEQUALITY")
    cdef dd_ErrorType error = dd_NoError
    cdef dd_MatrixPtr dd_mat = dd_FourierElimination(mat.dd_mat, &error)
    if error != dd_NoError:
        dd_FreeMatrix(dd_mat)
        _raise_error(error, "failed fourier elimination")
    return matrix_from_ptr(dd_mat)


def block_elimination(mat: Matrix, col_set: Container[int]) -> Matrix:
    """Eliminate the variables *col_set* from the system of linear inequalities *mat*.
    It does this by using the generators of the dual linear system,
    where the generators are calculated using the double description algorithm.

    .. note::

        The output is not guaranteed to be minimal,
        that is, it can still contain redundancy.
        Use :func:`cdd.matrix_canonicalize` on the output to remove redundancies.

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
        if error != dd_NoError:
            dd_FreeMatrix(dd_mat)
            _raise_error(error, "failed block elimination")
        return matrix_from_ptr(dd_mat)
    finally:
        set_free(dd_colset)


# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...
