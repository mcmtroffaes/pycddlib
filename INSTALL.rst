Automatic Installer
~~~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib, is to `download <http://pypi.python.org/pypi/pycddlib/#downloads>`_ an installer matching your version of Python, and run it.

Building From Source
~~~~~~~~~~~~~~~~~~~~

MPIR
''''

To compile pycddlib, you need `MPIR <http://www.mpir.org/>`_. On Linux, your distributions probably has a pre-built package for it. For example, on Fedora, install it by running::

    yum install mpir-devel

On Windows, download the latest MPIR source tarball (decompress the ``mpir-x.x.x.tar.bz2`` file with `7-Zip <http://www.7-zip.org/>`_), and follow the instructions in :file:`mpir-x.x.x\\build.vc9\\readme.txt`. [#vc9]_ For pycddlib, you only need to build the **lib_mpir_gc** project. Once built, go to the :file:`build.vc9\\lib\\win32\\release` folder, and copy :file:`mpir.h` to::

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\include

and :file:`mpir.lib` and :file:`mpir.pdb` to::

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\lib

pycddlib
''''''''

Once MPIR is installed, `download <http://pypi.python.org/pypi/pycddlib/#downloads>`_ and extract the source ``.zip``. On Windows, start the MSVC command line, and run the setup script from within the extracted folder::

    cd ....\pycddlib-x.x.x
    C:\PythonXX\python.exe setup.py install

On Linux, start a terminal and run::

    cd ..../pycddlib-x.x.x
    python setup.py build
    su -c 'python setup.py install'

Building From Git
~~~~~~~~~~~~~~~~~

To compile the *latest* code, clone the project with `Git <http://git-scm.com>`_ by running::

    git clone --recursive git://github.com/mcmtroffaes/pycddlib

Then simply run the :file:`build.sh` script: this will build the library, install it, generate the documentation, and run all the doctests. Note that, besides `MPIR <http://www.mpir.org/>`_, you also need `Cython <http://www.cython.org/>`_ to compile the source, and `Sphinx <http://sphinx.pocoo.org/>`_ to generate the documentation.

.. rubric:: Footnotes

.. [#vc9]

   When compiling extension modules, it is easiest to use same compiler that was used to compile Python. For Python 2.6, 2.7, 3.0, and 3.1, this is Microsoft Visual C/C++ 2008 (the `express edition <http://download.microsoft.com/download/A/5/4/A54BADB6-9C3F-478D-8657-93B3FC9FE62D/vcsetup.exe>`_ will do just fine).
