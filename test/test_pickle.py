from pickle import dumps, loads

import cdd

from . import assert_matrix_almost_equal


def test_pickle_matrix() -> None:
    array = [[1.1, 2.2], [3.3, 4.4], [5.5, 6.6]]
    lin_set = {0, 2}
    obj_func = [-1.1, -2.2]
    data = dumps(
        cdd.matrix_from_array(
            array=array,
            lin_set=lin_set,
            rep=cdd.Rep.GENERATOR,
            obj_func=obj_func,
            obj=cdd.LPObj.MIN,
        )
    )
    mat = loads(data)
    assert isinstance(mat, cdd.Matrix)
    assert_matrix_almost_equal(mat.array, array)
    assert mat.lin_set == lin_set
    assert mat.rep == cdd.Rep.GENERATOR
    assert mat.obj_func == obj_func
    assert mat.obj == cdd.LPObj.MIN


def test_pickle_linprog() -> None:
    array = [[1.1, 2.2], [3.3, 4.4], [5.5, 6.6]]
    data = dumps(
        cdd.linprog_from_array(
            array=array,
            obj=cdd.LPObj.MIN,
        )
    )
    lp = loads(data)
    assert isinstance(lp, cdd.LinProg)
    assert_matrix_almost_equal(lp.array, array)
    assert lp.obj == cdd.LPObj.MIN
