#!/bin/sh
pushd .
(
git clean -xfd &&
python2 setup.py build &&
python2 setup.py install --user &&
git clean -xfd &&
python3 setup.py build &&
python3 setup.py install --user &&
pushd docs &&
pushd _build/html &&
(([ "`ls -1 | xargs`" ] && (ls -1 | xargs rm -r)) || true) &&
popd &&
make html &&
make latexpdf &&
make doctest &&
popd  &&
python3 setup.py sdist --formats=zip
) || popd

