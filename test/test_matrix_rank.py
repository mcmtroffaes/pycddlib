from collections.abc import Sequence, Set

import pytest

import cdd


@pytest.mark.parametrize(
    "array,basis_rows,basis_cols, rank",
    [
        ([[0]], set(), set(), 0),
        ([[3]], {0}, {0}, 1),
        ([[1, 0], [0, 1]], {0, 1}, {0, 1}, 2),
        ([[1, 0, -1], [0, 1, -1], [2, 2, -4]], {0, 1}, {0, 1}, 2),
        ([[0, 0, 1], [0, 1, 0], [0, 0, 0]], {0, 1}, {1, 2}, 2),
        ([[1, 2, 1], [-2, -3, 1], [3, 5, 0]], {0, 1}, {0, 1}, 2),
        (
            [[1, -2, 0, 4], [1, 5, 1, -8], [3, 1, 1, 0], [3, 8, 2, 12]],
            {0, 1, 3},
            {0, 1, 3},
            3,
        ),
        (
            [
                [0, 3, 0, -15, -4],
                [0, 4, -7, -55, -7],
                [0, 3, 0, -15, 1],
                [0, 1, 0, -5, -1],
                [0, 3, 1, -10, 9],
                [0, -5, -8, -15, 3],
                [0, -2, -4, -10, 1],
            ],
            {0, 1, 2},
            {1, 2, 4},
            3,
        ),
    ],
)
def test_matrix_rank_1(
    array: Sequence[Sequence[float]],
    basis_rows: Set[int],
    basis_cols: Set[int],
    rank: int,
) -> None:
    assert cdd.matrix_rank(cdd.matrix_from_array(array)) == (
        basis_rows,
        basis_cols,
        rank,
    )
