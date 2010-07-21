#!/bin/sh
git clean -xfd
python setup.py build
python setup.py install --user
pushd docs
make doctest
make html
make latex
pushd _build/latex
make all-pdf
popd
popd
python setup.py sdist --formats=zip

