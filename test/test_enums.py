from enum import IntFlag
from typing import Union

import pytest

import cdd


# for comparison of cdd.RepType against a classic IntFlag type
class PyRepType(IntFlag):
    UNSPECIFIED = 0
    INEQUALITY = 1
    GENERATOR = 2


@pytest.mark.parametrize("cls", [PyRepType, cdd.RepType])
def test_rep_type(cls: Union[type[PyRepType], type[cdd.RepType]]) -> None:
    assert cls.INEQUALITY == 1
    assert cls.INEQUALITY.name == "INEQUALITY"
    assert cls.INEQUALITY.value == 1
    assert [int(val) for val in cls] == [0, 1, 2]
    assert [val.name for val in cls] == ["UNSPECIFIED", "INEQUALITY", "GENERATOR"]
    assert [val.value for val in cls] == [0, 1, 2]
    assert isinstance(cls.INEQUALITY, cls)
    assert isinstance(cls.INEQUALITY, int)
    assert issubclass(cls, IntFlag)
