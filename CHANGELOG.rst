Version 3.0.0 (in development)
------------------------------

* BACKWARDS INCOMPATIBLE:
  The ``number_type`` arguments are gone.
  The ``cdd`` module now only exposes the floating point interface
  (formerly accessible with ``number_type="float"``).
  The new ``cdd.gmp`` module exposes the rational numbers interface
  (formerly accessible with ``number_type="fraction"``).
  This change enables more straightforward type checking for the library,
  and also better reflects how the upstream C libraries are organized.
  It also enables easier switching between the two interfaces,
  by simply changing ``import cdd`` to ``import cdd.gmp as cdd``.

* BACKWARDS INCOMPATIBLE:
  The ``Polyhedron`` class no longer exposes the ``rep_type`` attribute.
  Internally, it was simply copied from the underlying matrix,
  and changing its made no difference, so it seemed sensible to remove it
  from the interface.

* BACKWARDS INCOMPATIBLE:
  The ``LinProg`` class no longer exposes the ``solver`` attribute,
  since this was internally only set as part of the ``solve`` method anyway.

* Type hints are now included, so code can fully benefit from type checkers
  such as mypy.

* Thanks to the reorganization, there now is a standalone Python package that
  installs just the floating point interface without needing the gmp or cddlib
  libraries installed.
  This is useful for installation on systems where the user cannot easily install
  libraries, such as for instance on google colab.
  To install it, use ``pip install pycddlib-standalone``.
  Naturally, you cannot install ``pycddlib`` and ``pycddlib-standalone``
  at the same time.

* Use vcpkg to compile cddlib and gmp.
  This updates the library from mpir 3.0.0 (dating back from 2017)
  to gmp 6.3.0 (the most recent release at the time of writing).

* Simplify build script to no longer compile cddlib.
  This allows the module to make use cddlib and gmp
  as installed by the system (e.g. vcpkg, rpm, ...).
  To build the extension, you may need to point Python to the correct folders.
  Check the installation instructions for more details.

* The ``setup.py`` script has been migrated to ``pyproject.toml``.
  As a result, setuptools 74.1 or greater is now required for building pycddlib.

* Drop x86 binary wheels on Windows.
  These can still be built but they are no longer distributed in PyPI.

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
