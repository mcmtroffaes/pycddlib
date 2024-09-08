Automatic Installer
~~~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib is to
`install it with pip <https://packaging.python.org/tutorials/installing-packages/>`_::

    pip install pycddlib

On Windows, this will install from a binary wheel
(for Python 3.8 to 3.12; for other versions of Python
you will need to build from source, see below).

On Linux and Mac, this will install from source,
and you will need `GMP <https://gmplib.org/>`_,
`cddlib <https://github.com/cddlib/cddlib>`_
as well as the Python development headers.
Your
distribution probably has pre-built packages for it. For example, on
Fedora, install it by running::

    dnf install cddlib-devel gmp-devel python3-devel

whilst on Ubuntu::

    apt-get install libcdd-dev libgmp-dev python3-dev

and on Mac::

    brew install cddlib gmp

You may have to specify the include and library folders.
If you use homebrew on Mac, for instance, you may have to write::

  env "CFLAGS=-I$(brew --prefix)/include -L$(brew --prefix)/lib" pip install pycddlib

Building From Source
~~~~~~~~~~~~~~~~~~~~

Full build instructions are in the git repository,
under `build.yml <https://github.com/mcmtroffaes/pycddlib/blob/develop/.github/workflows/build.yml>`_.

For Windows, first install `vcpkg <https://github.com/microsoft/vcpkg>`_, and run::

    ./vcpkg.exe install cddlib:x64-windows-static-md-release

This will install both cddlib and gmp (as the latter is a dependency).

When building pycddlib,
to tell Python where cddlib and gmp are located on your Windows machine, you can use::

    python setup.py build_ext -I<...\vcpkg\installed\x64-windows-static-md-release\include\> -L<...\vcpkg\installed\x64-windows-static-md-release\lib\>

If you get an error similar to::

    cdd.c(1102): fatal error C1083: Cannot open include file: 'cddlib/setoper.h': No such file or directory

then the include folder that you passed (it should contain all cddlib and gmp ``.h`` files).

If you get an error similar to::

    LINK : fatal error LNK1181: cannot open input file 'cdd.lib'

then check the lib folder that you passed (it should contain the cddlib and gmp ``.lib`` files).

Once this completes successfully, you can then install with::

    python setup.py install

Alternatively, you can also build a wheel and install that::

    python setup.py bdist_wheel
    pip install dist/pycddlib-<...>.whl
