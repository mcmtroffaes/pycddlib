Automatic Installer
~~~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib, is to `download <http://pypi.python.org/pypi/pycddlib/#downloads>`_ an installer matching your version of Python, and run it.

Building From Source
~~~~~~~~~~~~~~~~~~~~

MPIR/GMP
''''''''

To compile pycddlib on Windows, you need `MPIR <http://www.mpir.org/>`_. Download the latest MPIR source tarball (decompress the ``mpir-x.x.x.tar.bz2`` file with `7-Zip <http://www.7-zip.org/>`_), and run :file:`configure.bat` and :file:`make.bat` from the :file:`mpir-x.x.x\\win` folder. [#vc9]_ Once built, go to the :file:`mpir-x.x.x` folder, and copy :file:`mpir.h` and :file:`mpirxx.h` to::

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\include

and :file:`mpir.lib` and :file:`mpirxx.lib` to either (for a 32-bit build)::

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\lib

or (for a 64-bit build)::

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\lib\amd64

On Linux, you need `GMP <http://gmplib.org/>`_ (although you can also use MPIR if you desire so, by tweaking the ``setup.py`` file). Your distribution probably has a pre-built package for it. For example, on Fedora, install it by running::

    yum install gmp-devel

pycddlib
''''''''

Once MPIR/GMP is installed, `download <http://pypi.python.org/pypi/pycddlib/#downloads>`_ and extract the source ``.zip``. On Windows, start the MSVC command line, and run the setup script from within the extracted folder::

    cd ..\pycddlib-x.x.x
    C:\PythonXX\python.exe setup.py install

On Linux, start a terminal and run::

    cd ../pycddlib-x.x.x
    python setup.py build
    su -c 'python setup.py install'

Building From Git
~~~~~~~~~~~~~~~~~

To compile the *latest* code, clone the project with `Git <http://git-scm.com>`_ by running::

    git clone --recursive git://github.com/mcmtroffaes/pycddlib

Then simply run the :file:`build.sh` script: this will build the library, install it, generate the documentation, and run all the doctests. Note that, besides `MPIR <http://www.mpir.org/>`_, you also need `Cython <http://www.cython.org/>`_ to compile the source, and `Sphinx <http://sphinx.pocoo.org/>`_ to generate the documentation.

.. rubric:: Footnotes

.. [#vc9]

   When compiling extension modules, use same compiler that was used to compile Python. For Python 2.6, 2.7, 3.0, 3.1, and 3.2, this is Microsoft Visual C/C++ 2008 (the `MSVC 2008 express edition <http://download.microsoft.com/download/A/5/4/A54BADB6-9C3F-478D-8657-93B3FC9FE62D/vcsetup.exe>`_ will do just fine). For Python 3.3, use Microsoft Visual C/C++ 2010 (again, the `MSVC 2010 express edition <http://download.microsoft.com/download/1/D/9/1D9A6C0E-FC89-43EE-9658-B9F0E3A76983/vc_web.exe>`_ suffices).
