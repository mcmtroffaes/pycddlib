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

# actual cddlib wrappers

# matrix class
cdef class Matrix:
    """A class for working with sets of linear constraints and extreme
    points.

    :param rows: The rows of the matrix. Each element can be an
        :class:`int`, :class:`float`, :class:`~fractions.Fraction`, or
        :class:`str`. The values are automatically converted to a
        fraction if you use :mod:`cdd._fraction`, and to a float if
        you use :mod:`cdd._float`.
    :type rows: :class:`list` of :class:`list`\ s.
    :param linear: Whether to add the rows to the :attr:`lin_set` or not.
    :type linear: :class:`bool`

    .. warning::

       With the fraction number type, beware when using floats:

       >>> print(cdd._fraction.Matrix([[1.12]])[0][0])
       1261007895663739/1125899906842624

       If the float represents a fraction, it is better to pass it as a
       string, so it gets automatically converted to its exact fraction
       representation:

       >>> print(cdd._fraction.Matrix([['1.12']])[0][0])
       28/25

       Of course, this is only relevant for :mod:`cdd._fraction`; it is not a
       concern when using :mod:`cdd._float`, in which case both ``1.12`` and
       ``'1.12'`` will yield the same result, namely the
       :class:`float` ``1.12``.
    """

    # pointer containing the matrix data
    #cdef dd_MatrixPtr thisptr ### defined in pxd

    property row_size:
        """Number of rows."""
        def __get__(self):
            return self.thisptr.rowsize

    def __len__(self):
        """Number of rows."""
        return self.thisptr.rowsize

    property col_size:
        """Number of columns."""
        def __get__(self):
            return self.thisptr.colsize

    property lin_set:
        """A :class:`frozenset` containing the rows of linearity
        (generators of linearity space for V-representation, and
        equations for H-representation).
        """
        def __get__(self):
            return _get_set(self.thisptr.linset)
        def __set__(self, value):
            _set_set(self.thisptr.linset, value)

    property rep_type:
        """Representation (see :class:`cdd.RepType`)."""
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    property obj_type:
        """Linear programming objective: maximize or minimize (see
        :class:`cdd.LPObjType`).
        """
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

    property obj_func:
        """A :class:`tuple` containing the linear programming objective
        function.
        """
        def __get__(self):
            # return an immutable tuple to prohibit item assignment
            cdef int colindex
            return tuple([_get_mytype(self.thisptr.rowvec[colindex])
                          for 0 <= colindex < self.thisptr.colsize])
        def __set__(self, obj_func):
            cdef int colindex
            if len(obj_func) != self.thisptr.colsize:
                raise ValueError(
                    "objective function does not match matrix column size")
            for colindex, value in enumerate(obj_func):
                _set_mytype(self.thisptr.rowvec[colindex], value)

    def __str__(self):
        """Print the matrix data."""
        cdef FILE *pfile
        pfile = _tmpfile()
        dd_WriteMatrix(pfile, self.thisptr)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, rows, linear=False):
        """Load matrix data from the rows (which is a list of lists)."""
        cdef int numrows, numcols, rowindex, colindex
        # reset pointer
        self.thisptr = NULL
        # determine dimension
        numrows = len(rows)
        if numrows > 0:
            numcols = len(rows[0])
        else:
            numcols = 0
        # create new matrix
        self.thisptr = dd_CreateMatrix(numrows, numcols)
        # load data
        for rowindex, row in enumerate(rows):
            if len(row) != numcols:
                raise ValueError("rows have different lengths")
            for colindex, value in enumerate(row):
                _set_mytype(self.thisptr.matrix[rowindex][colindex], value)
        if linear:
            # set all constraints as linear
            set_compl(self.thisptr.linset, self.thisptr.linset)
        # debug
        #dd_WriteMatrix(stdout, self.thisptr)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.thisptr != NULL:
            dd_FreeMatrix(self.thisptr)
        self.thisptr = NULL

    def copy(self):
        """Make a copy of the matrix and return that copy."""
        return _make_matrix(dd_CopyMatrix(self.thisptr))

    def extend(self, rows, linear=False):
        """Append rows to self (this corresponds to the dd_MatrixAppendTo
        function in cdd; to emulate the effect of dd_MatrixAppend, first call
        copy and then call extend on the copy).

        The column size must be equal in the two input matrices. It
        raises a ValueError if the input rows are not appropriate.

        :param rows: The rows to append.
        :type rows: :class:`list` of :class:`list`\ s
        :param linear: Whether to add the rows to the :attr:`lin_set` or not.
        :type linear: :class:`bool`
        """
        cdef Matrix other
        cdef int success
        # create matrix with given rows
        other = Matrix(rows, linear=linear)
        # call dd_AppendToMatrix
        success = dd_MatrixAppendTo(&self.thisptr, other.thisptr)
        # check result
        if success != 1:
            raise ValueError(
                "cannot append because column sizes differ")

    def __getitem__(self, key):
        """Return a row, or a slice of rows, of the matrix.

        :param key: The row number, or slice of row numbers, to get.
        :type key: :class:`int` or :class:`slice`
        :rtype: :class:`tuple` of :class:`~fractions.Fraction`, or :class:`tuple` of :class:`tuple` of :class:`~fractions.Fraction`
        """
        cdef dd_rowrange rownum
        cdef dd_rowrange j
        # check if we are slicing
        if isinstance(key, slice):
            indices = key.indices(len(self))
            # XXX once generators are supported in cython, this should
            # return (self.__getitem__(i) for i in xrange(*indices))
            return tuple([self.__getitem__(i) for i in xrange(*indices)])
        else:
            rownum = key
            if rownum < 0 or rownum >= self.thisptr.rowsize:
                raise IndexError("row index out of range")
            # return an immutable tuple to prohibit item assignment
            return tuple([_get_mytype(self.thisptr.matrix[rownum][j])
                          for 0 <= j < self.thisptr.colsize])

cdef class LinProg:
    """A class for solving linear programs.

    :param mat: The matrix to load the linear program from.
    :type mat: :class:`Matrix`
    """
    # pointer to linear program
    #cdef dd_LPPtr thisptr ### defined in pxd

    property solver:
        """The type of solver to use (see :class:`cdd.LPSolverType`)."""
        def __get__(self):
            return self.thisptr.solver

    property obj_type:
        """Whether we are minimizing or maximizing (see
        :class:`cdd.LPObjType`).
        """
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

    property status:
        """The status of the linear program (see
        :class:`cdd.LPStatusType`).
        """
        def __get__(self):
            return self.thisptr.LPS

    property obj_value:
        """The optimal value of the objective function."""
        def __get__(self):
            return _get_mytype(self.thisptr.optvalue)

    property primal_solution:
        """A :class:`tuple` containing the primal solution."""
        def __get__(self):
            cdef int colindex
            return tuple([_get_mytype(self.thisptr.sol[colindex])
                          for 1 <= colindex < self.thisptr.d])

    property dual_solution:
        """A :class:`tuple` containing the dual solution."""
        def __get__(self):
            cdef int colindex
            return tuple([_get_mytype(self.thisptr.dsol[colindex])
                          for 1 <= colindex < self.thisptr.d])

    def __str__(self):
        """Print the linear program data."""
        cdef FILE *pfile
        # open file for writing the data
        pfile = _tmpfile()
        # note: if lp has an error, then exception is raised
        # so pass dd_NoError
        dd_WriteLPResult(pfile, self.thisptr, dd_NoError)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, Matrix mat):
        """Initialize linear program solution from solved linear program in
        the given matrix.
        """
        cdef dd_ErrorType error
        error = dd_NoError
        self.thisptr = NULL
        # read matrix
        self.thisptr = dd_Matrix2LP(mat.thisptr, &error)
        if self.thisptr == NULL or error != dd_NoError:
            if self.thisptr != NULL:
                dd_FreeLPData(self.thisptr)
            _raise_error(error, "failed to load linear program")
        # debug
        #dd_WriteLP(stdout, self.thisptr)

    def __dealloc__(self):
        """Deallocate solution memory."""
        if self.thisptr != NULL:
            dd_FreeLPData(self.thisptr)
        self.thisptr = NULL

    def solve(self, dd_LPSolverType solver=dd_DualSimplex):
        """Solve linear program.

        :param solver: The method of solution (see :class:`cdd.LPSolverType`).
        :type solver: :class:`int`
        """
        cdef dd_ErrorType error
        error = dd_NoError
        dd_LPSolve(self.thisptr, solver, &error)
        if error != dd_NoError:
            _raise_error(error, "failed to solve linear program")

cdef class Polyhedron:
    """A class for converting between representations of a polyhedron.

    :param mat: The matrix to load the polyhedron from.
    :type mat: :class:`Matrix`
    """

    # pointer to polyhedra
    #cdef dd_PolyhedraPtr thisptr ### defined in pxd

    property rep_type:
        """Representation (see :class:`cdd.RepType`)."""
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    def __str__(self):
        """Print the polyhedra data."""
        cdef FILE *pfile
        pfile = _tmpfile()
        dd_WritePolyFile(pfile, self.thisptr)
        return _tmpread(pfile).rstrip('\n')

    def __cinit__(self, Matrix mat):
        """Initialize polyhedra from given matrix."""
        cdef dd_ErrorType error
        error = dd_NoError
        self.thisptr = NULL
        # read matrix
        self.thisptr = dd_DDMatrix2Poly(mat.thisptr, &error)
        if self.thisptr == NULL or error != dd_NoError:
            if self.thisptr != NULL:
                dd_FreePolyhedra(self.thisptr)
            _raise_error(error, "failed to load polyhedra")
        # debug
        #dd_WritePolyFile(stdout, self.thisptr)

    def __dealloc__(self):
        """Deallocate matrix."""
        if self.thisptr != NULL:
            dd_FreePolyhedra(self.thisptr)
        self.thisptr = NULL

    def get_inequalities(self):
        """Get all inequalities.

        :returns: H-representation.
        :rtype: :class:`Matrix`
        """
        return _make_matrix(dd_CopyInequalities(self.thisptr))

    def get_generators(self):
        """Get all generators.

        :returns: V-representation.
        :rtype: :class:`Matrix`
        """
        return _make_matrix(dd_CopyGenerators(self.thisptr))
