Automatic Installer
~~~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib is to
`install it with pip <https://packaging.python.org/tutorials/installing-packages/>`_::

    pip install pycddlib

On Windows, this will install from a binary wheel
(for Python 3.7 to 3.11; for other versions of Python
you will need to build from source, see below).

On Linux and Mac, this will install from source,
and you will need `GMP <https://gmplib.org/>`_
as well as the Python development headers.
Your
distribution probably has pre-built packages for it. For example, on
Fedora, install it by running::

    dnf install gmp-devel python3-devel

whilst on Ubuntu::

    apt-get install libgmp-dev python3-dev

and on Mac::

    brew install gmp

You may have to specify the include and library folders.
If you use homebrew on Mac, for instance, you may have to write::

  env "CFLAGS=-I$(brew --prefix)/include -L$(brew --prefix)/lib" pip install pycddlib

Building From Source
~~~~~~~~~~~~~~~~~~~~

Full build instructions are in the git repository,
under `build.yml <https://github.com/mcmtroffaes/pycddlib/blob/develop/.github/workflows/build.yml>`_.

For Windows, you must take care to use a compiler and platform toolset
that is compatible with the one that was used
to compile Python. For Python 3.7 to 3.11, you can use
`Visual Studio <https://visualstudio.microsoft.com/>`_ 2022
with platform toolset v143.

Next, you must build MPIR using its provided project file.
For instance, for Python 3.7 to 3.11, this should work::

     Invoke-WebRequest -Uri "https://github.com/wbhart/mpir/archive/refs/heads/mpir-3.0.0.zip" -OutFile "mpir-3.0.0.zip"
     Expand-Archive mpir-3.0.0.zip
     msbuild mpir-3.0.0\mpir-mpir-3.0.0\build.vc14\lib_mpir_gc\lib_mpir_gc.vcxproj /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v143

When building pycddlib,
to tell Python where MPIR is located on your Windows machine, you can use::

    python setup.py build build_ext -I<mpir_include_folder> -L<mpir_lib_folder>
