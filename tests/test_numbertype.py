import nose

from cdd import NumberTypeable

def test_numbertypeable():
    x = NumberTypeable()
    nose.tools.assert_equal(x.number_type, 'float')

def test_numbertypeable_float():
    x = NumberTypeable('float')
    nose.tools.assert_equal(x.number_type, 'float')

def test_numbertypeable_fraction():
    x = NumberTypeable('fraction')
    nose.tools.assert_equal(x.number_type, 'fraction')

def test_numbertypeable_invalid():
    nose.tools.assert_raises(ValueError, lambda: NumberTypeable('hyperreal'))
