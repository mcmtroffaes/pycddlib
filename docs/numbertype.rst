.. testsetup::

   import cdd

Numerical Representations
=========================

The following is a base class for any class which allows choosing
numerical representation.

.. autoclass:: cdd.NumberTypeable(number_type='float')
.. automethod:: cdd.NumberTypeable.make_number(value)
.. automethod:: cdd.NumberTypeable.number_str(value)
.. automethod:: cdd.NumberTypeable.number_repr(value)
.. automethod:: cdd.NumberTypeable.number_cmp(num1, num2=None)
.. autoattribute:: cdd.NumberTypeable.number_type
.. autoattribute:: cdd.NumberTypeable.NumberType
