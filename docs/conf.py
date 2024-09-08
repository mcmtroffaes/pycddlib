import importlib
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.doctest",
    "sphinx.ext.coverage",
    "sphinx.ext.imgmath",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
]
source_suffix = ".rst"
master_doc = "index"
project = "pycddlib"
copyright = "2008-2024, Matthias C. M. Troffaes"
release = importlib.metadata.version("pycddlib")
# short X.Y version
version = ".".join(release.split(".")[:2])
exclude_patterns = ["_build"]
intersphinx_mapping = {"python": ("http://docs.python.org/", None)}
