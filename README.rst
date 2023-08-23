pycddlib is a Python wrapper for Komei Fukuda's cddlib.

`cddlib <https://people.inf.ethz.ch/fukudak/cdd_home/>`_ is
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

* Download: https://pypi.org/project/pycddlib/#files

* Documentation: https://pycddlib.readthedocs.io/en/latest/

* Development: https://github.com/mcmtroffaes/pycddlib/ |ci|

.. |ci| image:: https://github.com/mcmtroffaes/pycddlib/actions/workflows/build.yml/badge.svg
       :target: https://github.com/mcmtroffaes/pycddlib/actions/workflows/build.yml
       :alt: ci
