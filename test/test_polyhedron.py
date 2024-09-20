from collections.abc import Sequence, Set
from fractions import Fraction
from typing import Optional

import pytest

import cdd

from . import assert_matrix_almost_equal


def test_polyhedron_type() -> None:
    mat = cdd.matrix_from_array([[1, 1], [1, -1]])
    mat.rep_type = cdd.RepType.INEQUALITY
    poly = cdd.polyhedron_from_matrix(mat)
    assert isinstance(cdd.copy_generators(poly), cdd.Matrix)
    assert isinstance(cdd.copy_inequalities(poly), cdd.Matrix)
    for xss in [
        cdd.copy_adjacency(poly),
        cdd.copy_input_adjacency(poly),
        cdd.copy_incidence(poly),
        cdd.copy_input_incidence(poly),
    ]:
        assert isinstance(xss, Sequence)
        for xs in xss:
            assert isinstance(xs, Set)
            for x in xs:
                assert isinstance(x, int)


def test_sampleh1() -> None:
    array = [[2, -1, -1, 0], [0, 1, 0, 0], [0, 0, 1, 0]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat)
    ext = cdd.copy_generators(poly)
    assert ext.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(
        ext.array, [[1, 0, 0, 0], [1, 2, 0, 0], [1, 0, 2, 0], [0, 0, 0, 1]]
    )
    assert ext.lin_set == {3}  # first row is 0, so fourth row is 3


def test_testcdd2() -> None:
    array = [[7, -3, -0], [7, 0, -3], [1, 1, 0], [1, 0, 1]]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.INEQUALITY)
    assert_matrix_almost_equal(mat.array, array)
    gen = cdd.copy_generators(cdd.polyhedron_from_matrix(mat))
    assert gen.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(
        gen.array,
        [
            (1, Fraction(7, 3), -1),
            (1, -1, -1),
            (1, -1, Fraction(7, 3)),
            (1, Fraction(7, 3), Fraction(7, 3)),
        ],
    )
    # add an equality and an inequality
    cdd.matrix_append_to(mat, cdd.matrix_from_array([[7, 1, -3]], lin_set={0}))
    cdd.matrix_append_to(mat, cdd.matrix_from_array([[7, -3, 1]]))
    assert_matrix_almost_equal(mat.array, array + [[7, 1, -3], [7, -3, 1]])
    assert mat.lin_set == {4}
    gen2 = cdd.copy_generators(cdd.polyhedron_from_matrix(mat))
    assert gen2.rep_type == cdd.RepType.GENERATOR
    assert_matrix_almost_equal(gen2.array, [(1, -1, 2), (1, 0, Fraction(7, 3))])


def test_polyhedron_cube_1() -> None:
    generators = [[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]]
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(generators, rep_type=cdd.RepType.GENERATOR)
    poly = cdd.polyhedron_from_matrix(mat)
    assert_matrix_almost_equal(cdd.copy_generators(poly).array, generators)
    assert_matrix_almost_equal(cdd.copy_inequalities(poly).array, inequalities)


def test_polyhedron_cube_2() -> None:
    generators = [[1, 1, 0], [1, 0, 0], [1, 0, 1], [1, 1, 1]]  # same up to ordering
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(inequalities, rep_type=cdd.RepType.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat)
    assert_matrix_almost_equal(cdd.copy_generators(poly).array, generators)
    assert_matrix_almost_equal(cdd.copy_inequalities(poly).array, inequalities)


@pytest.mark.parametrize(
    "row_order,order",
    [
        (cdd.RowOrderType.MAX_INDEX, [2, 3, 0, 1]),
        (cdd.RowOrderType.MIN_INDEX, [2, 1, 0, 3]),
        (cdd.RowOrderType.MIN_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrderType.MAX_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrderType.MIX_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrderType.LEX_MIN, [0, 1, 2, 3]),
        (cdd.RowOrderType.LEX_MAX, [2, 3, 0, 1]),
    ],
)
def test_polyhedron_row_order(
    row_order: Optional[cdd.RowOrderType], order: Sequence[int]
) -> None:
    generators = [[1, 1, 0], [1, 0, 0], [1, 0, 1], [1, 1, 1]]
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(inequalities, rep_type=cdd.RepType.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat, row_order=row_order)
    assert_matrix_almost_equal(
        cdd.copy_generators(poly).array, [generators[i] for i in order]
    )


def test_polyhedron_nonstandard_v_rep_1() -> None:
    # conv((0.5, 0), (0, 0)) + span_ge((0, 2))
    generators = [[2, 1, 0], [0.5, 0, 0], [0, 0, 2]]
    mat = cdd.matrix_from_array(generators, rep_type=cdd.RepType.GENERATOR)
    poly = cdd.polyhedron_from_matrix(mat)
    mat2 = cdd.copy_output(poly)
    # 0 <= 1 - 2 x1
    # 0 <= x1
    # 0 <= x2
    assert not mat2.lin_set
    assert_matrix_almost_equal(mat2.array, [[1, -2, 0], [0, 1, 0], [0, 0, 1]])
    poly2 = cdd.polyhedron_from_matrix(mat2)
    mat3 = cdd.copy_output(poly2)
    assert not mat3.lin_set
    assert mat3.array == [[1, 0.5, 0], [1, 0, 0], [0, 0, 1]]


def test_polyhedron_nonstandard_v_rep_2() -> None:
    # (1-lambda)*(0.5, 0.5) + lambda*(1.5, 1) s.t. lambda>=0
    # this is a half-line starting at (0.5, 0.5) and intersecting (1.5, 1)
    generators = [[2, 1, 1], [4, 6, 4]]
    mat = cdd.matrix_from_array(generators, rep_type=cdd.RepType.GENERATOR, lin_set={0})
    poly = cdd.polyhedron_from_matrix(mat)
    mat2 = cdd.copy_output(poly)
    # 0 <= -1 + 2 x1
    # 0 = -0.25 - 0.5 x1 + x2
    assert mat2.lin_set == {1}
    assert_matrix_almost_equal(mat2.array, [[-1, 2, 0], [-0.25, -0.5, 1]])
    poly2 = cdd.polyhedron_from_matrix(mat2)
    mat3 = cdd.copy_output(poly2)
    assert not mat3.lin_set
    assert_matrix_almost_equal(mat3.array, [[0, 2, 1], [1, 0.5, 0.5]])
