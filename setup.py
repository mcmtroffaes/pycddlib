from setuptools import setup, Extension

setup(
    ext_modules=[
        Extension(
            name="cdd._cdd",
            sources=["cython/_cdd.pyx"],
            depends=["cython/cddlib.pxi", "cython/mytype.pxi", "cython/setoper.pxi"],
            libraries=["cdd"]
        ),
        Extension(
            name="cdd._cddgmp",
            sources=["cython/_cddgmp.pyx"],
            depends=["cython/cddlib.pxi", "cython/mytype_gmp.pxi", "cython/setoper.pxi"],
            libraries=["cddgmp", "gmp"]
        ),
    ],
)
