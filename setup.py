from setuptools import Extension, setup

setup(
    ext_modules=[
        Extension(
            name="cdd.__init__",
            sources=["cython/_cdd.pyx"],
            depends=[
                "cython/cdd.pxi",
                "cython/mytype.pxi",
                "cython/pycddlib.pxi",
                "cython/pyenums.pxi",
                "cython/setoper.pxi",
            ],
            libraries=["cdd"],
        ),
        Extension(
            name="cdd.gmp",
            sources=["cython/_cddgmp.pyx"],
            depends=[
                "cython/cdd.pxi",
                "cython/mytype_gmp.pxi",
                "cython/pycddlib.pxi",
                "cython/setoper.pxi",
            ],
            libraries=["cddgmp", "gmp"],
        ),
    ],
)
