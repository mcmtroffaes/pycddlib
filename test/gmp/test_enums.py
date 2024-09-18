from enum import IntEnum

import pytest

import cdd
import cdd.gmp


@pytest.mark.parametrize(
    "name", ["RepType", "LPObjType", "LPStatusType", "LPSolverType"]
)
def test_gmp_rep_type(name: str) -> None:
    assert issubclass(getattr(cdd, name), IntEnum)
    assert getattr(cdd, name) is getattr(cdd.gmp, name)
