#!/bin/bash
pushd .
(
git clean -xfd &&
python3 setup.py build &&
python3 setup.py install --user &&
pushd docs &&
make clean &&
make html &&
make latexpdf &&
make doctest &&
popd  &&
python3 setup.py sdist --formats=zip
) || popd

