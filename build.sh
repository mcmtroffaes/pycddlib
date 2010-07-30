#!/bin/sh
pushd .
(
git clean -xfd &&
python setup.py build &&
python setup.py install --user &&
pushd docs &&
pushd _build/html &&
(([ "`ls -1 | xargs`" ] && (ls -1 | xargs rm -r)) || true) &&
popd &&
make html &&
make latex &&
pushd _build/latex &&
make all-pdf &&
popd &&
make doctest &&
popd  &&
python setup.py sdist --formats=zip
) || popd

