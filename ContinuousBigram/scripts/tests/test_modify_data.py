from pathlib import Path
import sys
from types import SimpleNamespace
import os
import pytest

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import modify_data as md

# Prevent filesystem side-effects from make_dir
original_make_dir = md.make_dir


def setup_function():
    md.make_dir = lambda *a, **k: None

def teardown_function():
    md.make_dir = original_make_dir

def test_check_args_valid_absolute(monkeypatch):
    # Arrange: provide args that satisfy check_data_loc (end with /data and start with ROOT/data)
    # and stub out get_subdirectories to a predictable value
    monkeypatch.setattr(md, "get_subdirectories_joined", lambda x: os.path.join("subA", "subB"))

    md.args = SimpleNamespace(
        method="duplication",
        data_loc=os.path.join(md.ROOT, "data", "subA", "subB", "data"),
        new_data_loc=os.path.join(md.ROOT, "data", "subA", "subC", "data"),
        multiplier=5,
        dupe_all=False,
    )

    # Act
    data_loc, new_data_loc, label_loc, new_label_loc = md._check_args()

    # Assert: returned paths should use the subdirectories returned by the stub
    assert data_loc == os.path.join(md.ROOT, "data", "subA", "subB", "data")
    assert label_loc == os.path.join(md.ROOT, "label", "subA", "subB", "label")
    assert new_data_loc == os.path.join(md.ROOT, "data", "subA", "subB", "data")
    assert new_label_loc == os.path.join(md.ROOT, "label", "subA", "subB", "label")

def test_check_args_invalid_data_loc(monkeypatch):
    # Arrange: args.data_loc missing trailing /data should raise ValueError
    md.args = SimpleNamespace(
        method="duplication",
        data_loc=os.path.join(md.ROOT, "some", "random", "path", "not_data"),
        new_data_loc=os.path.join(md.ROOT, "some2", "random2", "path2", "data"),
        multiplier=5,
        dupe_all=False,
    )

    # Prevent make_dir side-effects if called before the error
    monkeypatch.setattr(md, "get_subdirectories_joined", lambda x: "ignored")
    md.make_dir = lambda *a, **k: None

    # Act / Assert
    with pytest.raises(ValueError):
        md._check_args()

    md.args = SimpleNamespace(
        method="duplication",
        data_loc=os.path.join(md.ROOT, "data", "some", "random", "path", "data"),
        new_data_loc=os.path.join(md.ROOT, "data", "some2", "random2", "path2", "not_data"),
        multiplier=5,
        dupe_all=False,
    )

    # Act / Assert
    with pytest.raises(ValueError):
        md._check_args()

