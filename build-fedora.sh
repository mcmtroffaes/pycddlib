#!/bin/bash
#
# usage:
#
#   ./build-fedora.sh <interpreter> <virtualenv-relative-path>
#
# for example:
#
#   ./build-fedora.sh python3 ../env
#

# set up environment

if [ -z "$1" ]
then
    VIRTUALENV=virtualenv
else
    VIRTUALENV="virtualenv -p $1"
fi
if [ -z "$2" ]
then
   ENVPATH=../env
else
   ENVPATH=$2
fi
PYTHON=$ENVPATH/bin/python
PIP=$ENVPATH/bin/pip
SPHINXBUILD=$ENVPATH/bin/sphinx-build

# build package and create documentation

git clean -xfd &&
$VIRTUALENV $ENVPATH &&
$PIP install Cython &&
$PIP install Sphinx &&
$PYTHON setup.py build &&
$PYTHON setup.py install &&
pushd docs &&
make SPHINXBUILD=../$SPHINXBUILD clean &&
make SPHINXBUILD=../$SPHINXBUILD html &&
make SPHINXBUILD=../$SPHINXBUILD latexpdf &&
make SPHINXBUILD=../$SPHINXBUILD doctest &&
popd &&
$PYTHON setup.py sdist --formats=zip

