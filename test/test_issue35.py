import cdd


# this should not segfault
def test_issue35():
    m = cdd.Matrix([[0, 0, 0]], number_type="float")
    m.rep_type = cdd.RepType.INEQUALITY
    m.canonicalize()
