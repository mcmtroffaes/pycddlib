The :mod:`cdd.gmp` module
=========================

.. module:: cdd.gmp

This module works just the same way like :mod:`cdd`.
The only difference is that all numbers are represented by :class:`~fractions.Fraction`
instead of :class:`float`, and all arithmetic is exact.

.. warning::

   Passing a :class:`float` will result in a :exc:`TypeError`:

   >>> cdd.gmp.matrix_from_array([[1.12]])
   Traceback (most recent call last):
       ...
   TypeError: value 1.12 is not Rational

   If the float represents a fraction, you must pass it as a fraction explicitly:

   >>> print(cdd.gmp.matrix_from_array([[Fraction(112, 100)]]).array)
   [[Fraction(28, 25)]]

   If you really must use a float as a fraction,
   pass it explicitly to the :class:`~fractions.Fraction` constructor:

   >>> print(cdd.gmp.matrix_from_array([[Fraction(1.12)]]).array)
   [[Fraction(1261007895663739, 1125899906842624)]]

   As you can see from the output above, for typical use cases,
   you will not want to do this.
