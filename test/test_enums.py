from enum import IntEnum

import cdd


def test_rep() -> None:
    assert cdd.Rep.INEQUALITY == 1
    assert cdd.Rep.INEQUALITY.name == "INEQUALITY"
    assert cdd.Rep.INEQUALITY.value == 1
    assert [val for val in cdd.Rep] == [0, 1, 2]
    assert [val.name for val in cdd.Rep] == [
        "UNSPECIFIED",
        "INEQUALITY",
        "GENERATOR",
    ]
    assert [val.value for val in cdd.Rep] == [0, 1, 2]
    assert isinstance(cdd.Rep.INEQUALITY, cdd.Rep)
    assert isinstance(cdd.Rep.INEQUALITY, int)
    assert issubclass(cdd.Rep, IntEnum)
