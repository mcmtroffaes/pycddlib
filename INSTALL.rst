From Binary Wheel
~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib is to
`install it with pip <https://packaging.python.org/en/latest/tutorials/installing-packages/>`_::

    pip install pycddlib

On Windows, for currently supported versions of Python,
this will install from a binary wheel.
For other versions of Python or other operating systems
you will need to build from the source distribution,
or directly from the source repository.

From Source
~~~~~~~~~~~

Installing cddlib and GMP
*************************

First, you will need cddlib, GMP,
as well as the Python development headers.
If you have Linux or Mac, then your
distribution probably has pre-built packages for it. For example, on
Fedora, install it by running::

    dnf install cddlib-devel gmp-devel python3-devel

whilst on Ubuntu::

    apt-get install libcdd-dev libgmp-dev python3-dev

and on Mac::

    brew install cddlib gmp

If your distribution does not have pre-built packages,
you may be able to use `vcpkg <https://github.com/microsoft/vcpkg>`_.
For instance, on Windows::

    ./vcpkg.exe install cddlib:x64-windows-static-md-release

whilst on Linux::

    ./vcpkg install cddlib:x64-linux

This will install both cddlib and gmp (as the latter is a dependency).

Invoking Pip
************

You may have to specify the include and library folders.
If you use homebrew on Mac, for instance, you may have to write::

  env "CFLAGS=-I$(brew --prefix)/include -L$(brew --prefix)/lib" pip install pycddlib

This should not be needed on Linux, but if you do,
you can also use the above command,
substituting the appropriate folders for ``-I`` and ``-L``.

Unfortunately, there appears to be no reliable way to pass the include and lib folders
to pip on Windows.
In this case, you need to build from the repository,
as documented below.

Invoking Build
**************

Alternatively,
pycddlib can be compiled from the source repository
into a wheel using `build <https://pypi.org/project/build/>`_.
This wheel can then be installed using pip.
As with the pip method, ensure you have cddlib and gmp installed first.

To tell the build script where cddlib and gmp are located,
for instance assuming you have installed them via ``vcpkg`` on Windows
using the ``x64-windows-static-md-release`` triplet,
you can use::

    python -m build -w -C="--global-option=build_ext" -C="--global-option=-I<...\vcpkg\installed\x64-windows-static-md-release\include\>" -C="--global-option=-L<...\vcpkg\installed\x64-windows-static-md-release\lib\>"

You can adjust the ``-I`` and ``-L`` arguments as needed.
If you get an error similar to::

    cdd.c(1102): fatal error C1083: Cannot open include file: 'cddlib/setoper.h': No such file or directory

then check the include folder that you passed (it should contain all cddlib and gmp ``.h`` files).

If you get an error similar to::

    LINK : fatal error LNK1181: cannot open input file 'cdd.lib'

then check the lib folder that you passed (it should contain the cddlib and gmp ``.lib`` files).

Once this completes successfully, you can then install the wheel with::

    pip install dist/pycddlib-<...>.whl

Invoking Setup
**************

If you do not wish to use ``python -m build``,
you can also call ``setup.py`` directly to create the wheel, as follows::

    python setup.py build_ext -I<...\vcpkg\installed\x64-windows-static-md-release\include\> -L<...\vcpkg\installed\x64-windows-static-md-release\lib\>
    python setup.py bdist_wheel

However, note that
`running setup.py directly is deprecated <https://blog.ganssle.io/articles/2021/10/setup-py-deprecated.html>`_.

Build Scripts
~~~~~~~~~~~~~

Build scripts for Windows, Linux, and Mac,
can be found in the git repository,
under `build.yml <https://github.com/mcmtroffaes/pycddlib/blob/develop/.github/workflows/build.yml>`_.
