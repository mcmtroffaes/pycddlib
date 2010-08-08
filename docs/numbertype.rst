.. testsetup::

   import cdd

Numerical Representations
=========================

:class:`~cdd.NumberTypeable` is a base class for any class which
admits different numerical representations. Subclasses of this class
must note that:

* the constructor of the subclass must be called with either

  - a *number_type* keyword argument, or

  - a :class:`~cdd.NumberTypeable` instance as first (non-keyword) argument;

* the :class:`~cdd.NumberTypeable` constructor is always called
  automatically, and looks for the argument as described above---there
  is no need to explicitely call ``NumberTypeable.__init__(self)`` in
  constructors of classes that inherit from
  :class:`~cdd.NumberTypeable`.

.. autoclass:: cdd.NumberTypeable(number_type=None)
.. automethod:: cdd.NumberTypeable.make_number(value)
.. automethod:: cdd.NumberTypeable.number_str(value)
.. automethod:: cdd.NumberTypeable.number_repr(value)
.. automethod:: cdd.NumberTypeable.number_cmp(num1, num2=None)
.. autoattribute:: cdd.NumberTypeable.number_type
.. autoattribute:: cdd.NumberTypeable.NumberType
