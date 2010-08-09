pycddlib is a Python wrapper for Komei Fukuda's cddlib.

`cddlib <http://www.ifor.math.ethz.ch/~fukuda/cdd_home/cdd.html>`_ is
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
