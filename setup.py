from setuptools import setup, Extension

setup(
    ext_modules=[
        Extension(
            name="cdd._cdd",
            sources=["src/cdd/_cdd.pyx"],
            depends=["src/cdd/cddlib.pxi", "src/cdd/mytype.pxi", "src/cdd/setoper.pxi"],
            libraries=["cdd"]
        ),
        Extension(
            name="cdd._cddgmp",
            sources=["src/cdd/_cddgmp.pyx"],
            depends=["src/cdd/cddlib.pxi", "src/cdd/mytype_gmp.pxi", "src/cdd/setoper.pxi"],
            libraries=["cddgmp", "gmp"]
        ),
    ],
)
