.. testsetup::

   import cdd

.. currentmodule:: cdd

Numerical Representations
=========================

.. function:: get_number_type_from_value(value)

    Determine number type from a value.

    :return: ``'fraction'`` if the value is
        :class:`~numbers.Rational` or :class:`str`, otherwise
        ``'float'``.
    :rtype: :class:`str`

.. function:: get_number_type_from_sequences(*data)

    Determine number type from sequences.

    :return: ``'fraction'`` if all elements are
        :class:`~numbers.Rational` or :class:`str`, otherwise
        ``'float'``.
    :rtype: :class:`str`

.. class:: NumberTypeable(number_type='float')

    Base class for any class which admits different numerical
    representations.

    :param number_type: The number type (``'float'`` or ``'fraction'``).
    :type number_type: :class:`str`

.. method:: NumberTypeable.make_number(value)

        Convert value into a number.

        :param value: The value to convert.
        :type value: :class:`int`, :class:`float`, or :class:`str`
        :returns: The converted value.
        :rtype: :attr:`~cdd.NumberTypeable.NumberType`

        >>> nt = cdd.NumberTypeable('float')
        >>> print(repr(nt.make_number('2/3'))) # doctest: +ELLIPSIS
        0.666666666...
        >>> nt = cdd.NumberTypeable('fraction')
        >>> print(repr(nt.make_number('2/3'))) # doctest: +ELLIPSIS
        Fraction(2, 3)

.. method:: NumberTypeable.number_str(value)

        Convert value into a string.

        :param value: The value.
        :type value: :attr:`~cdd.NumberTypeable.NumberType`
        :returns: A string for the value.
        :rtype: :class:`str`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_str(x)) # doctest: +ELLIPSIS
        4.0
        0.666666666...
        1.6
        -1.5
        1.12
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_str(x))
        4
        2/3
        8/5
        -3/2
        1261007895663739/1125899906842624

.. method:: NumberTypeable.number_repr(value)

        Return representation string for value.

        :param value: The value.
        :type value: :attr:`~cdd.NumberTypeable.NumberType`
        :returns: A string for the value.
        :rtype: :class:`str`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_repr(x))
        4.0
        0.666666666...
        1.6...
        -1.5
        1.12...
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(nt.number_repr(x))
        4
        '2/3'
        '8/5'
        '-3/2'
        '1261007895663739/1125899906842624'

.. method:: NumberTypeable.number_cmp(num1, num2=None)

        Compare values. Type checking may not be performed, for
        speed. If *num2* is not specified, then *num1* is compared
        against zero.

        :param num1: First value.
        :type num1: :attr:`~cdd.NumberTypeable.NumberType`
        :param num2: Second value.
        :type num2: :attr:`~cdd.NumberTypeable.NumberType`

        >>> a = cdd.NumberTypeable('float')
        >>> a.number_cmp(0.0, 5.0)
        -1
        >>> a.number_cmp(5.0, 0.0)
        1
        >>> a.number_cmp(5.0, 5.0)
        0
        >>> a.number_cmp(1e-30)
        0
        >>> a = cdd.NumberTypeable('fraction')
        >>> a.number_cmp(0, 1)
        -1
        >>> a.number_cmp(1, 0)
        1
        >>> a.number_cmp(0, 0)
        0
        >>> a.number_cmp(a.make_number(1e-30))
        1

.. attribute:: NumberTypeable.number_type

        The number type as string (``'float'`` or ``'fraction'``).

.. attribute:: NumberTypeable.NumberType

        The number type as class
        (:class:`float` or :class:`~fractions.Fraction`).
