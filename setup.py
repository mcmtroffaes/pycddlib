from setuptools import setup, Extension

setup(
    ext_modules=[
        Extension(
            name="cdd.__init__",
            sources=["cython/_cdd.pyx"],
            depends=["cython/cddlib.pxi", "cython/mytype.pxi", "cython/setoper.pxi"],
            libraries=["cdd"]
        ),
        Extension(
            name="cdd.gmp",
            sources=["cython/_cddgmp.pyx"],
            depends=["cython/cddlib.pxi", "cython/mytype_gmp.pxi", "cython/setoper.pxi"],
            libraries=["cddgmp", "gmp"]
        ),
    ],
)
