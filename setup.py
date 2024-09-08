"""Setup script for pycddlib."""

# pycddlib is a Python wrapper for Komei Fukuda's cddlib
# Copyright (c) 2008-2024, Matthias Troffaes
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
Intended Audience :: Science/Research
Topic :: Scientific/Engineering :: Mathematics
Programming Language :: C
Programming Language :: Cython
Programming Language :: Python
Programming Language :: Python :: 3
Operating System :: OS Independent"""

from setuptools import setup
from setuptools.extension import Extension

# get documentation from README.rst file
doclines = open("README.rst").read().split("\n")


setup(
    name="pycddlib",
    version="3.0.0a0",
    ext_modules=[
        Extension(
            name="cdd",
            sources=["cdd.pyx"],
            undef_macros=["GMPRATIONAL"],
            libraries=['cdd'],
        ),
        Extension(
            name="cddgmp",
            sources=["cddgmp.pyx"],
            define_macros=[("GMPRATIONAL", None)],
            libraries=['cddgmp', 'gmp'],
        ),
    ],
    author="Matthias C. M. Troffaes",
    author_email="matthias.troffaes@gmail.com",
    license="GPL",
    keywords="convex, polyhedron, linear programming, double description method",
    platforms="any",
    description=doclines[0],
    long_description="\n".join(doclines[2:]),
    long_description_content_type="text/x-rst",
    url="http://pypi.python.org/pypi/pycddlib",
    classifiers=classifiers.split("\n"),
    setup_requires=[
        # setuptools 18.0 properly handles Cython extensions.
        "setuptools>=18.0",
        "Cython>=3.0.0",
    ],
    python_requires=">=3.8",
)
