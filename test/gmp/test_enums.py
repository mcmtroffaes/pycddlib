from enum import IntEnum

import pytest

import cdd
import cdd.gmp


@pytest.mark.parametrize(
    "name", ["Rep", "LPObj", "LPStatus", "LPSolver"]
)
def test_gmp_rep(name: str) -> None:
    assert issubclass(getattr(cdd, name), IntEnum)
    assert getattr(cdd, name) is getattr(cdd.gmp, name)
