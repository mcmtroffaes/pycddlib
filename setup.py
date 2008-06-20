"""pycddlib is a Python wrapper for Komei Fukuda's cddlib.

The C-library  cddlib is a C implementation of the Double Description 
Method of Motzkin et al. for generating all vertices (i.e. extreme points)
and extreme rays of a general convex polyhedron in R^d given by a system 
of linear inequalities:

   P = { x=(x1, ..., xd)^T :  b - A  x  >= 0 }

where  A  is a given m x d real matrix, b is a given m-vector 
and 0 is the m-vector of all zeros.

The program can be used for the reverse operation (i.e. convex hull
computation).  This means that  one can move back and forth between 
an inequality representation  and a generator (i.e. vertex and ray) 
representation of a polyhedron with cdd.  Also, cdd can solve a linear
programming problem, i.e. a problem of maximizing and minimizing 
a linear function over P.

See http://www.ifor.math.ethz.ch/~fukuda/cdd_home/cdd.html for more information
about cddlib.

See http://code.google.com/p/stip/ for more information about pycddlib."""

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

classifiers = """\
Development Status :: 4 - Beta
License :: OSI Approved :: GNU General Public License (GPL)
Intended Audience :: Developers
Intended Audience :: End Users/Desktop
Intended Audience :: Science/Research
Topic :: Scientific/Engineering :: Mathematics
Programming Language :: Python
Programming Language :: C
Operating System :: OS Independent"""

from distutils.core import setup
from distutils.extension import Extension
from Pyrex.Distutils import build_ext

import os

doclines = __doc__.split("\n")

cdd_dir = 'cddlib-094f/lib-src'
cdd_sources = [
    'cddcore.c',
    'cddio.c',
    'cddlib.c',
    'cddlp.c',
    'cddmp.c',
    'cddproj.c',
    'setoper.c']

setup(
    name = "pycddlib",
    version = "0.0.0",
    ext_modules= [
        Extension("cddlib",
                  ["cddlib.pyx"] + [os.path.join(cdd_dir, srcfile)
                                    for srcfile in cdd_sources],
                  include_dirs = [cdd_dir])],
    author = "Matthias Troffaes",
    author_email = "matthias.troffaes@gmail.com",
    license = "GPL",
    keywords = "convex, polyhedron, linear programming, double description method",
    platforms = "any",
    description = doclines[0],
    long_description = "\n".join(doclines[2:]),
    url = "http://code.google.com/p/stip/",
    cmdclass = {'build_ext': build_ext})
