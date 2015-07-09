import fractions
import nose

from cdd import NumberTypeable

def test_numbertypeable():
    x = NumberTypeable()
    nose.tools.assert_equal(x.number_type, 'float')
    assert(x.NumberType is float)

def test_numbertypeable_float():
    x = NumberTypeable('float')
    nose.tools.assert_equal(x.number_type, 'float')
    assert(x.NumberType is float)

def test_numbertypeable_fraction():
    x = NumberTypeable('fraction')
    nose.tools.assert_equal(x.number_type, 'fraction')
    assert(x.NumberType is fractions.Fraction)

def test_numbertypeable_invalid():
    nose.tools.assert_raises(ValueError, lambda: NumberTypeable('hyperreal'))

def test_makenumber():
    nt_flt = NumberTypeable('float')
    nt_frc = NumberTypeable('fraction')
    numbers = ['4', '2/3', '1.6', '-9/6', 1.12]
    floats = [4., 2.0/3.0, 1.6, -1.5, 1.12]
    fracs = [(4, 1), (2, 3), (8, 5), (-3, 2),
             (1261007895663739, 1125899906842624)]
    for number, flt, frc in zip(numbers, floats, fracs):
        frc = fractions.Fraction(*frc)
        number_flt = nt_flt.make_number(number)
        number_frc = nt_frc.make_number(number)
        nose.tools.assert_almost_equal(flt, number_flt)
        nose.tools.assert_equal(frc, number_frc)
