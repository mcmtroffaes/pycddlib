from collections.abc import Sequence, Set
from fractions import Fraction
from typing import Optional

import pytest

import cdd

from . import assert_matrix_almost_equal


def test_polyhedron_type() -> None:
    mat = cdd.matrix_from_array([[1, 1], [1, -1]])
    mat.rep = cdd.Rep.INEQUALITY
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
    mat = cdd.matrix_from_array(array, rep=cdd.Rep.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat)
    ext = cdd.copy_generators(poly)
    assert ext.rep == cdd.Rep.GENERATOR
    assert_matrix_almost_equal(
        ext.array, [[1, 0, 0, 0], [1, 2, 0, 0], [1, 0, 2, 0], [0, 0, 0, 1]]
    )
    assert ext.lin_set == {3}  # first row is 0, so fourth row is 3


def test_testcdd2() -> None:
    array = [[7, -3, -0], [7, 0, -3], [1, 1, 0], [1, 0, 1]]
    mat = cdd.matrix_from_array(array, rep=cdd.Rep.INEQUALITY)
    assert_matrix_almost_equal(mat.array, array)
    gen = cdd.copy_generators(cdd.polyhedron_from_matrix(mat))
    assert gen.rep == cdd.Rep.GENERATOR
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
    assert gen2.rep == cdd.Rep.GENERATOR
    assert_matrix_almost_equal(gen2.array, [(1, -1, 2), (1, 0, Fraction(7, 3))])


def test_polyhedron_cube_1() -> None:
    generators = [[1, 0, 1], [1, 1, 0], [1, 1, 1], [1, 0, 0]]
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(generators, rep=cdd.Rep.GENERATOR)
    poly = cdd.polyhedron_from_matrix(mat)
    assert_matrix_almost_equal(cdd.copy_generators(poly).array, generators)
    assert_matrix_almost_equal(cdd.copy_inequalities(poly).array, inequalities)


def test_polyhedron_cube_2() -> None:
    generators = [[1, 1, 0], [1, 0, 0], [1, 0, 1], [1, 1, 1]]  # same up to ordering
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(inequalities, rep=cdd.Rep.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat)
    assert_matrix_almost_equal(cdd.copy_generators(poly).array, generators)
    assert_matrix_almost_equal(cdd.copy_inequalities(poly).array, inequalities)


@pytest.mark.parametrize(
    "row_order,order",
    [
        (cdd.RowOrder.MAX_INDEX, [2, 3, 0, 1]),
        (cdd.RowOrder.MIN_INDEX, [2, 1, 0, 3]),
        (cdd.RowOrder.MIN_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrder.MAX_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrder.MIX_CUTOFF, [1, 0, 2, 3]),
        (cdd.RowOrder.LEX_MIN, [0, 1, 2, 3]),
        (cdd.RowOrder.LEX_MAX, [2, 3, 0, 1]),
    ],
)
def test_polyhedron_row_order(
    row_order: Optional[cdd.RowOrder], order: Sequence[int]
) -> None:
    generators = [[1, 1, 0], [1, 0, 0], [1, 0, 1], [1, 1, 1]]
    inequalities = [[0, 0, 1], [0, 1, 0], [1, 0, -1], [1, -1, 0]]
    mat = cdd.matrix_from_array(inequalities, rep=cdd.Rep.INEQUALITY)
    poly = cdd.polyhedron_from_matrix(mat, row_order=row_order)
    print(cdd.copy_generators(poly).array)
    assert_matrix_almost_equal(
        cdd.copy_generators(poly).array, [generators[i] for i in order]
    )
