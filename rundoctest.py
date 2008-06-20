# run all doctests in the Python cddlib module

import doctest, unittest
import pycddlib

suite = unittest.TestSuite()
for mod in [ pycddlib ]:
    try:
        suite.addTest(doctest.DocTestSuite(mod))
    except ValueError: # no tests
        pass
runner = unittest.TextTestRunner(verbosity=10)
runner.run(suite)

