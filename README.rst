pycddlib is a Python wrapper for Komei Fukuda's cddlib.

`cddlib <http://www.inf.ethz.ch/personal/fukudak/cdd_home/>`_ is
an implementation of the Double Description Method of Motzkin et
al. for generating all vertices (i.e. extreme points) and extreme rays
of a general convex polyhedron given by a system of linear
inequalities.

The program also supports the reverse operation (i.e. convex hull
computation). This means that one can move back and forth between an
inequality representation and a generator (i.e. vertex and ray)
representation of a polyhedron with cdd.  Also, it can solve a linear
programming problem, i.e. a problem of maximizing and minimizing a
linear function over a polyhedron.

* Download: http://pypi.python.org/pypi/pycddlib/#downloads

* Documentation: http://pycddlib.readthedocs.org/

* Development: http://github.com/mcmtroffaes/pycddlib/ |imagetravis| |appveyor|

.. |imagetravis| image:: https://travis-ci.org/mcmtroffaes/pycddlib.png?branch=develop
       :target: https://travis-ci.org/mcmtroffaes/pycddlib
       :alt: travis-ci

.. |appveyor| image:: https://ci.appveyor.com/api/projects/status/i6j85w5ni7pq6pt9/branch/develop?svg=true
       :target: https://ci.appveyor.com/project/mcmtroffaes/pycddlib
       :alt: appveyor
