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

cimport python_unicode
cimport python_bytes

IF GMP:
    from fractions import Fraction

# get object as file
cdef extern from "Python.h":
    FILE *PyFile_AsFile(object)

# utility functions

cdef FILE *_tmpfile() except NULL:
     cdef FILE *result
     result = tmpfile()
     if result == NULL:
         raise RuntimeError("failed to create temporary file")
     return result

cdef _tmpread(FILE *pfile):
    cdef char result[1024]
    cdef size_t num_bytes
    # read the file
    fseek(pfile, 0, SEEK_SET)
    num_bytes = fread(result, 1, 1024, pfile)
    # close the file
    fclose(pfile)
    # return result
    return python_unicode.PyUnicode_DecodeUTF8(result, num_bytes, 'strict')

cdef _raise_error(dd_ErrorType error, msg):
    """Convert error into string and raise it."""
    cdef FILE *pfile
    pfile = _tmpfile()
    dd_WriteErrorMessages(pfile, error)
    raise RuntimeError(msg + "\n" + _tmpread(pfile).rstrip('\n'))

cdef _make_matrix(dd_MatrixPtr matptr):
    """Create matrix from given pointer."""
    # we must "cdef Matrix mat" because otherwise pyrex will not
    # recognize mat.thisptr as a C pointer
    cdef Matrix mat
    if matptr == NULL:
        raise ValueError("failed to make matrix")
    mat = Matrix([[0]])
    dd_FreeMatrix(mat.thisptr)
    mat.thisptr = matptr
    return mat

cdef _get_set(set_type set_):
    """Create Python frozenset from given set_type."""
    cdef long elem
    return frozenset([elem - 1
                      for elem from 1 <= elem <= set_[0]
                      if set_member(elem, set_)])

cdef _set_set(set_type set_, pset):
    """Set elements of set_type by elements from Python set."""
    cdef long elem
    for elem from 1 <= elem <= set_[0]:
        if elem - 1 in pset:
            set_addelem(set_, elem)
        else:
            set_delelem(set_, elem)

IF GMP:

    cdef _get_mytype(mytype target):
        """Get :class:`~fractions.Fraction` or :class:`int` from target."""
        cdef signed long int num
        cdef unsigned long int den
        cdef char *buf_ptr
        if mpz_fits_slong_p(mpq_numref(target)) and mpz_fits_ulong_p(mpq_denref(target)):
            num = mpz_get_si(mpq_numref(target))
            den = mpz_get_ui(mpq_denref(target))
            if den == 1:
                # calling int() makes that we don't return a long unless needed
                return int(num)
            else:
                return Fraction(num, den)
        else:
            buf = python_bytes.PyBytes_FromStringAndSize(NULL, mpz_sizeinbase(mpq_numref(target), 10) + mpz_sizeinbase(mpq_denref(target), 10) + 3)
            buf_ptr = python_bytes.PyBytes_AsString(buf)
            mpq_get_str(buf_ptr, 10, target)
            # trick: bytes(buf_ptr) removes everything after the null
            return Fraction(bytes(buf_ptr).decode('ascii'))

    cdef _set_mytype(mytype target, value):
        """Set target to given value (:class:`str`, :class:`int`,
        :class:`long`, :class:`float`, or :class:`~fractions.Fraction`). A
        :class:`str` is automatically converted to a
        :class:`~fractions.Fraction` using its constructor.
        """
        # convert string to fraction
        if isinstance(value, str):
            value = Fraction(value)
        # set target to value
        if isinstance(value, float):
            dd_set_d(target, value)
        elif isinstance(value, (Fraction, int, long)):
            try:
                dd_set_si2(target, value.numerator, value.denominator)
            except OverflowError:
                # in case of overflow, set it using mpq_set_str
                buf = str(value).encode('ascii')
                if mpq_set_str(target, buf, 10) == -1:
                    raise ValueError('could not convert %s to mpq_t' % value)

ELSE:

    cdef _get_mytype(mytype target):
        return target[0]

    cdef _set_mytype(mytype target, value):
        if isinstance(value, str) and '/' in value:
            num, den = value.split('/')
            target[0] = float(num) / float(den)
        else:
            target[0] = float(value)

# actual cddlib wrappers

# matrix class
cdef class Matrix:
    """A class for working with sets of linear constraints and extreme
    points.

    :param rows: The rows of the matrix. Each element can be an :class:`int`, :class:`float`, :class:`~fractions.Fraction`, or :class:`str`. The values are automatically converted to a fraction if you use :mod:`cddgmp`, or a float if you use :mod:`cdd`.
    :type rows: :class:`list` of :class:`list`\ s.
    :param linear: Whether to add the rows to the :attr:`lin_set` or not.
    :type linear: :class:`bool`

    .. warning::

       Beware when using floats:

       >>> print(Matrix([[1.12]])[0][0])
       1261007895663739/1125899906842624

       If the float represents a fraction, it is better to pass it as a
       string, so it gets automatically converted to its exact fraction
       representation:

       >>> print(Matrix([['1.12']])[0][0])
       28/25

       Of course, this is only relevant for :mod:`cddgmp`; it is not a
       concern when using :mod:`cdd`, in which case both ``1.12`` and
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
        """Representation (see :class:`RepType`)."""
        def __get__(self):
            return self.thisptr.representation
        def __set__(self, dd_RepresentationType value):
            self.thisptr.representation = value

    property obj_type:
        """Linear programming objective: maximize or minimize (see
        :class:`LPObjType`).
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

    def __delitem__(self, dd_rowrange rownum):
        """Remove a row. Raises ValueError on failure."""
        cdef int success
        # remove the row
        success = dd_MatrixRowRemove(&self.thisptr, rownum)
        # check the result
        if success != 1:
            raise ValueError(
                "cannot remove row %i" % rownum)

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
        """The type of solver to use (see :class:`LPSolverType`)."""
        def __get__(self):
            return self.thisptr.solver

    property obj_type:
        """Whether we are minimizing or maximizing (see
        :class:`LPObjType`).
        """
        def __get__(self):
            return self.thisptr.objective
        def __set__(self, dd_LPObjectiveType value):
            self.thisptr.objective = value

    property status:
        """The status of the linear program (see
        :class:`LPStatusType`).
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

        :param solver: The method of solution (see :class:`LPSolverType`).
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
        """Representation (see :class:`RepType`)."""
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

# module initialization code comes here
# initialize module constants
dd_set_global_constants()

# should call dd_free_global_constants() when module is destroyed
# how does python do that?? let's not bother for now...


