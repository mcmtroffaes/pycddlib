"""Setup script for pycddlib."""

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
from Cython.Distutils import build_ext

import os

# get version from pyx file
for line in open('pycddlib.pyx'):
    if line.startswith("__version__"):
       version = line[line.find('"')+1:line.rfind('"')]
       break
else:
    raise RuntimeError("failed to extract version from pycddlib.pyx")

# get documentation from README file
doclines = open('README').read().split('\n')

cdd_dir = 'cddlib/lib-src'
cdd_sources = [
    'cddcore.c',
    'cddio.c',
    'cddlib.c',
    'cddlp.c',
    'cddmp.c',
    'cddproj.c',
    'setoper.c']
cdd_headers = [
    'cdd.h',
    'cddmp.h',
    'cddtypes.h',
    'setoper.h']

setup(
    name = "pycddlib",
    version = version,
    ext_modules= [
        Extension("pycddlib",
                  ["pycddlib.pyx"] + [os.path.join(cdd_dir, srcfile)
                                      for srcfile in cdd_sources],
                  include_dirs = [cdd_dir],
                  depends=[os.path.join(cdd_dir, hdrfile)
                           for hdrfile in cdd_headers])],
    author = "Matthias Troffaes",
    author_email = "matthias.troffaes@gmail.com",
    license = "GPL",
    keywords = "convex, polyhedron, linear programming, double description method",
    platforms = "any",
    description = doclines[0],
    long_description = "\n".join(doclines[2:]),
    url = "http://mcmtroffaes.github.com/pycddlib/",
    cmdclass = {'build_ext': build_ext})
