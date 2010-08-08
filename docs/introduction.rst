.. testsetup::

   import cdd

Introduction
============

Essentially, pycddlib consists of three modules:

* :mod:`cdd._fraction`, which wraps the so-called ``GMPRATIONAL``
  build of cddlib, using :class:`~fractions.Fraction` for the Python
  representation of numerical values,

* :mod:`cdd._float`, which wraps the floating point build of cddlib,
  using :class:`float` for the Python representation of numerical
  values, and finally,

* :mod:`cdd`, which provides an interface for both modules at once.

.. module:: cdd

The main module, :mod:`cdd`, implements the following classes:

Numerical Representations
-------------------------

The following is a base class for any class which allows choosing
numerical representation.

.. autoclass:: cdd.NumberTypeable(number_type='float')
.. automethod:: cdd.NumberTypeable.make_number(value)
.. automethod:: cdd.NumberTypeable.number_str(value)
.. automethod:: cdd.NumberTypeable.number_repr(value)
.. automethod:: cdd.NumberTypeable.number_cmp(num1, num2=None)
.. autoattribute:: cdd.NumberTypeable.number_type
.. autoattribute:: cdd.NumberTypeable.NumberType

Classes
-------

Next, the :mod:`cdd` module defines three wrapper classes. Depending
on the value of the *number_type* argument, which is passed on through
the constructor, the wrappers have their *data* attribute set from the
corresponding class from either the :mod:`cdd._float` or
:mod:`cdd._fraction` module.

.. autoclass:: cdd.Matrix(rows, linear=False, number_type='float')

   .. attribute:: data

      A :class:`cdd._fraction.Matrix` or :class:`cdd._float.Matrix`
      instance.

.. autoclass:: cdd.LinProg(mat)

   .. attribute:: data

      A :class:`cdd._fraction.LinProg` or :class:`cdd._float.LinProg`
      instance.

.. autoclass:: cdd.Polyhedron(mat)

   .. attribute:: data

      A :class:`cdd._fraction.Polyhedron` or :class:`cdd._float.Polyhedron`
      instance.

Constants
---------

.. not used elsewhere
   autoclass:: cdd.AdjacencyTestType
.. not used elsewhere
   autoclass:: cdd.CompStatus
.. not used elsewhere
   autoclass:: cdd.Error
.. autoclass:: cdd.LPObjType
.. autoclass:: cdd.LPSolverType
.. autoclass:: cdd.LPStatusType
.. not used elsewhere
   autoclass:: cdd.NumberType
.. autoclass:: cdd.RepType
.. not used elsewhere
   autoclass:: cdd.RowOrderType
