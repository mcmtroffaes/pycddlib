Automatic Installer
~~~~~~~~~~~~~~~~~~~

The simplest way to install pycddlib is to
`install it with pip <https://packaging.python.org/en/latest/installing.html>`_::

    pip install pycddlib

On Windows, this will install from a binary wheel
(for Python 2.7 and Python 3.3 and up; for older versions of Python
you will need to build from source, see below).

On Linux, this will install from source,
and you will need `GMP <http://gmplib.org/>`_. Your
distribution probably has a pre-built package for it. For example, on
Fedora, install it by running::

    yum install gmp-devel

Building From Source
~~~~~~~~~~~~~~~~~~~~

Full build instructions are in the git repository,
for Windows under `appveyor.yml <https://github.com/mcmtroffaes/pycddlib/blob/develop/appveyor.yml>`_,
and for Linux under `.travis.yml <https://github.com/mcmtroffaes/pycddlib/blob/develop/.travis.yml>`_.

The Windows build is rather complicated.
First, you must take special care to use the same compiler that was used
to compile Python. For Python 2.6, 2.7, 3.0, 3.1, and 3.2, this is
Microsoft Visual C/C++ 2008 (the `MSVC 2008 express edition
<http://download.microsoft.com/download/A/5/4/A54BADB6-9C3F-478D-8657-93B3FC9FE62D/vcsetup.exe>`_
will do just fine). For Python 3.3, use Microsoft Visual C/C++ 2010
(again, the `MSVC 2010 express edition
<http://download.microsoft.com/download/1/D/9/1D9A6C0E-FC89-43EE-9658-B9F0E3A76983/vc_web.exe>`_
suffices).

Next, MPIR only provides a project file for MSVC 2010 and later.
For versions of Python that require older versions of MSVC,
such as Python 2.7 which requires MSVC 2008,
you can use for instance::

  msbuild mpir-x.x.x/build.vc10/lib_mpir_gc/lib_mpir_gc.vcxproj /p:PlatformToolset=v90

to instruct ``msbuild`` to use MSVC 2008 (i.e. ``v90``)
for compiling and linking.

To tell Python where MPIR is located on your Windows machine,
you can use::

  python setup.py build build_ext -I<mpir_include_folder> -L<mpir_lib_folder>
