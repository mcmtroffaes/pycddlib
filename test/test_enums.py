from enum import IntFlag

import cdd


def test_rep_type() -> None:
    assert cdd.RepType.INEQUALITY == 1
    assert cdd.RepType.INEQUALITY.name == "INEQUALITY"
    assert cdd.RepType.INEQUALITY.value == 1
    assert [val for val in cdd.RepType] == [0, 1, 2]
    assert [val.name for val in cdd.RepType] == [
        "UNSPECIFIED",
        "INEQUALITY",
        "GENERATOR",
    ]
    assert [val.value for val in cdd.RepType] == [0, 1, 2]
    assert isinstance(cdd.RepType.INEQUALITY, cdd.RepType)
    assert isinstance(cdd.RepType.INEQUALITY, int)
    assert issubclass(cdd.RepType, IntFlag)
