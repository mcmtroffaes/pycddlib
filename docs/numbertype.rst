.. testsetup::

   import cdd

.. currentmodule:: cdd

Numerical Representations
=========================

.. function:: get_number_type_from_value(value)

    Determine number type from a value.

    :return: ``'fraction'`` if the value is
        :class:`~fractions.Fraction` or :class:`str`, otherwise
        ``'float'``.
    :rtype: :class:`str`

.. function:: get_number_type_from_sequences(*data)

    Determine number type from sequences.

    :return: ``'fraction'`` if all elements are
        :class:`~fractions.Fraction` or :class:`str`, otherwise
        ``'float'``.
    :rtype: :class:`str`

.. class:: NumberTypeable(number_type='float')

    Base class for any class which admits different numerical
    representations.

    :param number_type: The number type (``'float'`` or ``'fraction'``).
    :type number_type: :class:`str`

    >>> x = cdd.NumberTypeable()
    >>> x.number_type
    'float'
    >>> x = cdd.NumberTypeable('float')
    >>> x.number_type
    'float'
    >>> y = cdd.NumberTypeable('fraction') # doctest: +ELLIPSIS
    >>> y.number_type
    'fraction'
    >>> # hyperreals are not supported :-)
    >>> cdd.NumberTypeable('hyperreal') # doctest: +ELLIPSIS
    Traceback (most recent call last):
        ...
    ValueError: ...

.. method:: NumberTypeable.make_number(value)

        Convert value into a number.

        :param value: The value to convert.
        :type value: :class:`int`, :class:`float`, or :class:`str`
        :returns: The converted value.
        :rtype: :attr:`~cdd.NumberTypeable.NumberType`

        >>> numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
        >>> nt = cdd.NumberTypeable('float')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(repr(x))
        4.0
        0.6666666666666666
        1.6
        -1.5
        1.12
        >>> nt = cdd.NumberTypeable('fraction')
        >>> for number in numbers:
        ...     x = nt.make_number(number)
        ...     print(repr(x))
        Fraction(4, 1)
        Fraction(2, 3)
        Fraction(8, 5)
        Fraction(-3, 2)
        Fraction(1261007895663739, 1125899906842624)

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
        ...     print(nt.number_str(x))
        4.0
        0.666666666667
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
        0.6666666666666666
        1.6
        -1.5
        1.12
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

        The number type as string.

        >>> cdd.NumberTypeable().number_type
        'float'
        >>> cdd.NumberTypeable('float').number_type
        'float'
        >>> cdd.NumberTypeable('fraction').number_type
        'fraction'

.. attribute:: NumberTypeable.NumberType

        The number type as class.

        >>> cdd.NumberTypeable().NumberType
        <class 'float'>
        >>> cdd.NumberTypeable('float').NumberType
        <class 'float'>
        >>> cdd.NumberTypeable('fraction').NumberType
        <class 'fractions.Fraction'>
