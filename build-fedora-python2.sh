#!/bin/bash
pushd .
(
git clean -xfd &&
python2 setup.py build &&
python2 setup.py install --user &&
pushd docs &&
make clean &&
make html &&
make latexpdf &&
make doctest &&
popd  &&
python2 setup.py sdist --formats=zip
) || popd
