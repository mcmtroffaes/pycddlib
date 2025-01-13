Version 3.0.2 (13 January 2025)
-------------------------------

* Support not just Fraction and int types as inputs for gmp values,
  but every type with denominator and numerator attributes (such as numpy's
  int32 and int64, and gmpy2's mpq).

* Fix mypy typing issue with enum classes.

* Bump vcpkg hash for Windows wheel.

Version 3.0.1 (22 November 2024)
--------------------------------

* Add Python 3.13 support.

* Bump vcpkg hash for Windows wheel.

Version 3.0.0 (4 October 2024)
------------------------------

This version comes with a lot of improvements, notably:

* support for type checking,

* new functions that more closely reflect upstream cddlib,

* improved build and installation, allowing linkage against arbitrary gmp/cddlib
  versions installed by the system or by the user.

Unfortunately, the interface of the old version did not permit type checking,
due to an unfortunate design decision from the past:
from a typing point of view,
real and rational matrices could be mixed arbitrarily,
and runtime checks had to be put in place to prevent this.

Since type checking is meant to prevent bugs like this long before runtime,
I made the hard decision to break the old API.
As a consequence, the library is now split into two
separate modules: ``cdd`` for real matrices, and ``cdd.gmp`` for rational matrices.
Coincidentally, these two modules reflect the upstream organization of cddlib itself
into ``cdd`` and ``cddgmp``.
Whilst doing this,
new functions have been added
from the upstream cddlib public headers.
This resulted in a faster, cleaner, and less buggy implementation,
which is more closely aligned with upstream cddlib.

Fully detailed changes:

* BACKWARDS INCOMPATIBLE:
  The ``number_type`` arguments are gone.
  The ``cdd`` module now only exposes the floating point interface
  (formerly accessible with ``number_type="float"``).
  The new ``cdd.gmp`` submodule exposes the rational numbers interface
  (formerly accessible with ``number_type="fraction"``).
  This change was necessary to enable fully correct type checking for the library,
  and to allow a version of pycddlib to be installed without needing to compile gmp.

* BACKWARDS INCOMPATIBLE:
  Under the hood, the old version used cython's ``__cinit__`` to initialize
  ``Matrix``, ``LinProg``, and ``Polyhedron`` objects.
  However, exceptions thrown from this function
  risk leaving the object in an invalid state.
  Instead, cython recommends using factory functions.
  So, new factory functions have been introduced to replace the old constructors:
  ``matrix_from_array``, ``linprog_from_matrix``, ``linprog_from_array``,
  and ``polyhedron_from_matrix``.
  As a consequence, errors during construction are now always correctly handled.

* BACKWARDS INCOMPATIBLE:
  For consistency, methods have been refactored into functions
  to more closely reflect the underlying cddlib interface.

    - ``Matrix(...)`` is now ``matrix_from_array(...)``.
      The ``linear`` argument has been replaced with ``lin_set``,
      and all other properties can also be specified from this new factory function.

    - ``Matrix.extend`` is now ``matrix_append_to`` and takes two matrices as argument,
      to match the corresponding cddlib functions.
      It still raises a :exc:`ValueError` if the column sizes differ.

    - ``Matrix.copy`` is now ``matrix_copy``.

    - ``Matrix.canonicalize`` is now ``matrix_canonicalize``,
      and now also returns the sequence of new row indices.

    - ``LinProg(...)`` is now ``linprog_from_matrix(...)``
      or ``linprog_from_array(...)``.
      The ``linprog_from_array`` factory function
      is recommended especially if you have no equality constraints since it saves
      having to allocate a matrix first.
      If you have equality constraints, ``linprog_from_matrix``
      will convert those for you.
      If you use ``linprog_from_array``, you will have to convert these yourself.

    - ``LinProg.solve`` is now ``linprog_solve``.

    - ``Polyhedron(...)`` is now ``polyhedron_from_matrix``.

    - The ``Polyhedron.get_...`` methods are now ``copy_...``. This reflects the
      upstream naming of these functions.

* Enumeration classes now inherit from :class:`enums.IntEnum`.

* Pickle support for ``Matrix`` and ``LinProg`` (see issue #47).
  ``Polyhedron`` does not have pickle support as it has no public interface to
  construct it without running the double description method, which can be very slow.
  As a fallback, you can pickle a matrix
  that you then convert to a polyhedron
  (as noted, this may be be quite slow),
  or simply pickle the outputs that you need for your application
  (i.e. inequalities, generators, adjacencies, incidences, ...).

* Additional functions have been exposed:

    - Fourier and block elimination (see issue #38).

    - Matrix adjacency and weak adjacency using linear programming
      (i.e. without running the double description method).

    - Matrix rank.

    - New functions for redundancy checks and certificates.

    - New functions to canonicalize only linearities, or only inequalities.

* You can now specify the row order type
  when constructing a ``Polyhedron`` from a matrix.
  (This exposes the ``dd_DDMatrix2Poly2`` function.)

* Thanks to the reorganization, there now is a standalone Python package that
  installs just the floating point interface without needing the gmp or cddlib
  libraries installed.
  This is useful on systems where the user cannot easily install
  libraries, such as for instance google colab.
  To install it, use ``pip install pycddlib-standalone``.
  Naturally, you cannot install ``pycddlib`` and ``pycddlib-standalone``
  at the same time.

* Type hints are now included, so the code can fully benefit from type checking.

* The Windows wheels now use vcpkg to compile cddlib and gmp.
  This updates the library from mpir 3.0.0 (dating back from 2017)
  to gmp 6.3.0 (the most recent release at the time of writing).

* The build script no longer compiles cddlib.
  This permits the module to use cddlib and gmp
  as installed by the system (e.g. vcpkg, rpm, ...).
  To build the extension, you may need to point Python to the correct folders.
  Check the installation instructions for more details.

* The ``setup.py`` script has been migrated to ``pyproject.toml``.

* Drop x86 binary wheels on Windows.
  These can still be built but they are no longer distributed in PyPI.

* Drop Python 3.8 support.

Version 2.1.8 (4 September 2024)
--------------------------------

* Support Python 3.12, drop Python 3.7.

* Update cddlib to git hash aff2477 (fixes a segfault).

Version 2.1.7 (11 August 2023)
------------------------------

* Specify minimum required Cython version in setup script
  (see issue #55, reported by sguysc).

* Fix Cython DEF syntax warning.

* Support Python 3.11, drop Python 3.6.

Version 2.1.6 (8 May 2022)
--------------------------

* Bump cddlib to latest git (f83bdbcbefbef960d8fb5afc282ac7c32dcbb482).

* Switch testing from appveyor to github actions.

* Fix release tarballs for recent linux/macos (see issues #49, #53, #54).

Version 2.1.5 (30 November 2021)
--------------------------------

* Add Python 3.10 support.

Version 2.1.4 (4 January 2020)
------------------------------

* Extra release to fix botched tgz upload on pypi.

Version 2.1.3 (4 January 2020)
------------------------------

* Update for cddlib 0.94m.

* Drop Python 3.5 support. Add Python 3.9 support.

Version 2.1.2 (11 August 2020)
------------------------------

* Drop Python 2.7 support.

* Fix string truncation issue (see issue #39).

Version 2.1.1 (16 January 2020)
-------------------------------

* Expose adjacency and incidence (see issues #33, #34, and #36,
  contributed by bobmyhill).

* Add Python 3.8 support.

* Drop Python 3.4 support.

* Use pytest instead of nose for regression tests.

Version 2.1.0 (15 October 2018)
-------------------------------

* updated for cddlib 0.94i

* fix Cython setup requirement (see issue #27)

* add documentation about representation types (see issues #29 and
  #30, contributed by stephane-caron)

* add Python 3.7 support

Version 2.0.0 (13 December 2017)
--------------------------------

* fix creation of rational matrices from numpy array's (see issues #20
  and #21, reported and fixed by Hervé Audren)

* consider all numbers.Rational subtypes as rationals (instead of just
  Fraction)

Version 1.0.6 (24 October 2017)
-------------------------------

* fix segfault when setting rep_type (see issues #16 and #17, reported
  and fixed by Hervé Audren)
* drop Python 3.3 support
* add Python 3.6 support
* updated for MPIR 3.0.0

Version 1.0.5 (24 November 2015)
--------------------------------

* drop Python 3.2 support
* add Python 3.4 and Python 3.5 support
* Matrix.canonicalize now requires rep_type to be specified; you can
  get back the old behaviour by setting rep_type to
  cdd.RepType.INEQUALITY before calling canonicalize (reported by
  Stéphane Caron, fixes issue #4).
* updated for cddlib 0.94h
* windows builds now tested on appveyor
* windows wheels provided for Python 2.7, 3.3, 3.4, and 3.5
* updated for MPIR 2.7.2

Version 1.0.4 (9 July 2012)
---------------------------

* updated for Cython 0.16
* updated for cddlib 0.94g
* updated for MPIR 2.5.1
* various fixes in documentation
* building the documentation no longer requires cdd to be installed
* documentation hosted on readthedocs.org
* development model uses gitflow
* build script uses virtualenv
* workaround for Microsoft tmpfile bug on Vista/Win7 (reported by Lorenzo
  Di Gregorio)

Version 1.0.3 (24 August 2010)
------------------------------

* added Matrix.canonicalize method
* sanitized NumberTypeable class: no more __cinit__ magic: derived
  classes can decide to call __init__ or not
* improved Matrix constructor: number type is derived from the type of
  the elements passed to the constructor, so in general, there is no
  need any more to pass a number_type argument (although this still
  remains supported)
* added get_number_type_from_value and get_number_type_from_sequences
  functions to aid subclasses to determine their number type.

Version 1.0.2 (9 August 2010)
-----------------------------

* new NumberTypeable base class to allow different representations to be
  delegated to construction
* everything is now contained in the cdd module
* code refactored and better organized

Version 1.0.1 (1 August 2010)
-----------------------------

* minor documentation updates
* also support the GMPRATIONAL build of cddlib with Python's fractions.Fraction
* using MPIR so it also builds on Windows
* removed trailing newlines in __str__ methods
* modules are now called cdd (uses float) and cdd.gmp (uses Fraction)

Version 1.0.0 (21 July 2010)
----------------------------

* first release, based on cddlib 0.94f
