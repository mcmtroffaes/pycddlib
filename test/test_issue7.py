import pytest

import cdd


# Check that numerical inconsistency is reported properly.
def test_issue7() -> None:
    array = [
        [1.0, -4.0, -40.0, -4.0, 30.0677432, -0.93140119, -20.75373128],
        [1.0, 4.0, -40.0, -4.0, 31.02398625, 5.00096, -18.98561378],
        [1.0, -4.0, -40.0, -4.0, 31.02398625, -1.09504, -20.07358622],
        [1.0, 4.0, -40.0, 4.0, 29.05601375, 1.09504, -18.10561371],
        [1.0, -4.0, 40.0, -4.0, -28.02714601, -1.01021223, 17.92502368],
        [1.0, -4.0, 40.0, -4.0, -27.9039032, -0.93140119, 18.58989128],
        [1.0, -4.0, 40.0, -4.0, -28.86014625, -1.00704, 18.78974629],
        [1.0, 4.0, 40.0, -4.0, -28.86014625, 5.00096, 21.14945378],
        [1.0, -4.0, 40.0, 4.0, -31.21985375, -4.91296, 17.90974622],
        [1.0, 4.0, 40.0, -4.0, -28.86014625, 4.91296, 20.26945371],
    ]
    mat = cdd.matrix_from_array(array, rep_type=cdd.RepType.GENERATOR)
    with pytest.raises(RuntimeError, match="inconsistency"):
        cdd.polyhedron_from_matrix(mat)
