from pathlib import Path
import sys
from types import SimpleNamespace
import pytest

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import grid_search as gs

# Prevent filesystem side-effects from make_dir
original_make_dir = gs.make_dir

def setup_function():
    gs.make_dir = lambda x: None


def teardown_function():
    gs.make_dir = original_make_dir


def test_get_ip_ext():
    assert gs.get_ip_ext(10) == "pos10ip"
    assert gs.get_ip_ext(-7) == "neg7ip"
    assert gs.get_ip_ext(0) == "0ip"


def test_get_name_ext_various_flags():
    gs.args = SimpleNamespace(
        use_phrase=True,
        no_custom_silsp=True,
        cross_word=False,
        no_triletter=True,
        custom_ext="myext"
    )

    name = gs.get_name_ext(0, tc=5, num_its=10, num_tri_its=2, hmmdef="hmmX", trace_value=3)
    # base (no ip): hmmX_10its_2tri-its_tc5
    assert name.startswith("hmmX_10its_2tri-its_tc5")
    assert "_grliwph" in name
    assert "_no-silsp" in name
    assert "_no-triletter" in name
    assert name.endswith(".myext.TR3")


def test_get_hresults_filepaths_with_modelname_replace():
    # Case where model_name already contains an ip token
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_pos10ip_extra")
    letter, word = gs.get_hresults_filepaths("extdummy", subdirs=Path("a") / "b", ip=20)
    # Should replace pos10ip with pos20ip in the resulting filename

    assert Path(letter).name.startswith("hresults.log_letter")
    model_file = Path(letter).name.split("hresults.log_letter")[-1]

    assert Path(word).name.startswith("hresults.log_word")
    model_file = Path(word).name.split("hresults.log_word")[-1]

    assert "pos20ip" in model_file


def test_get_hresults_filepaths_with_modelname_insert():
    # Case where model_name does NOT contain an ip token -> should insert one
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_extra")
    letter, word = gs.get_hresults_filepaths("extdummy", subdirs=Path("a") / "b", ip=-5)

    # inserted neg5ip token should appear
    assert Path(letter).name.startswith("hresults.log_letter")
    model_file = Path(letter).name.split("hresults.log_letter")[-1]

    assert Path(word).name.startswith("hresults.log_word")
    model_file = Path(word).name.split("hresults.log_word")[-1]

    assert "neg5ip" in model_file
