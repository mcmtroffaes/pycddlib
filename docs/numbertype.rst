.. testsetup::

   import cdd

Numerical Representations
=========================

.. autofunction:: cdd.get_number_type_from_value(value)
.. autofunction:: cdd.get_number_type_from_sequences(*data)
.. autoclass:: cdd.NumberTypeable(number_type='float')
.. automethod:: cdd.NumberTypeable.make_number(value)
.. automethod:: cdd.NumberTypeable.number_str(value)
.. automethod:: cdd.NumberTypeable.number_repr(value)
.. automethod:: cdd.NumberTypeable.number_cmp(num1, num2=None)
.. autoattribute:: cdd.NumberTypeable.number_type
.. autoattribute:: cdd.NumberTypeable.NumberType
