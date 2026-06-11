#!/usr/bin/env python3

from pathlib import Path
import sys
import os
import logging
from types import SimpleNamespace
import pytest

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import grid_search as gs
import utils as ut

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
    # include test_model_path explicitly to avoid AttributeError while checking None
    gs.args = SimpleNamespace(
        test_model_path=None,
        use_phrase=True,
        no_custom_silsp=True,
        cross_word=False,
        no_triletter=True,
        custom_ext="myext",
        full_cov=False,
        debug=False
    )

    name = gs.get_name_ext(tc=5, num_its=10, num_tri_its=2, hmmdef="hmmX", trace_value=3)
    # base (no ip): hmmX_10its_2tri-its_tc5
    assert name.startswith("hmmX_10its_2tri-its_tc5")
    # use_phrase currently not appended in get_name_ext, so skip checking it
    assert "_no-silsp" in name
    assert "_no-triletter" in name
    assert name.endswith(".myext.TR3")


def test_get_hresults_filepaths_with_modelname_replace():
    # Case where model_name already contains an ip token
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_pos10ip_extra", full_cov=False)
    letter, word = gs.get_hresults_prj_filepaths("extdummy", subdirs=str(Path("a") / "b"), ip=20)
    # Should replace pos10ip with pos20ip in the resulting filename

    assert Path(letter).name.startswith("hresults.log_letter")
    model_file = Path(letter).name.split("hresults.log_letter")[-1]

    assert Path(word).name.startswith("hresults.log_word")
    model_file = Path(word).name.split("hresults.log_word")[-1]

    assert "pos20ip" in model_file


def test_get_hresults_filepaths_with_modelname_insert():
    # Case where model_name does NOT contain an ip token -> should insert one
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_extra", full_cov=False)
    letter, word = gs.get_hresults_prj_filepaths("extdummy", subdirs=str(Path("a") / "b"), ip=-5)

    # inserted neg5ip token should appear
    assert Path(letter).name.startswith("hresults.log_letter")
    model_file = Path(letter).name.split("hresults.log_letter")[-1]

    assert Path(word).name.startswith("hresults.log_word")
    model_file = Path(word).name.split("hresults.log_word")[-1]

    assert "neg5ip" in model_file


def test_save_model_copies(tmp_path, monkeypatch):
    # Arrange: use a temporary models root and real make_dir
    monkeypatch.setattr(gs, "MODELS_ROOT", str(tmp_path / "models"))
    monkeypatch.setattr(gs, "MODEL_MACROS_FILE", "newMacros")
    # Restore real make_dir for this test
    monkeypatch.setattr(gs, "make_dir", original_make_dir)

    gs.args = SimpleNamespace(
        test_model_path=None,
        use_phrase=True,
        no_custom_silsp=True,
        cross_word=False,
        no_triletter=True,
        custom_ext="myext",
        full_cov=False,
        debug=False
    )

    subdirs = "test_subdir"
    num_its = 5
    
    # Create the current model file that save_model should copy
    # The training model directory structure is MODELS_ROOT/<subdirs>/<hmmdef>/hmm0.<iter>/
    curr_dir = Path(gs.MODELS_ROOT) / subdirs / "hmmX" / f"hmm0.{num_its-1}"
    curr_dir.mkdir(parents=True)

    src = curr_dir / gs.MODEL_MACROS_FILE
    src.write_text("dummy-model-contents")

    # Act: call save_model with current signature (no 'ip' kw)
    gs.save_model(tc=5, num_its=num_its, num_tri_its=2, hmmdef="hmmX", subdirs=subdirs)

    # Assert: new model path should exist and contain the same contents
    new_model_dir, new_model_path = gs.get_saved_model_path(subdirs, tc=5, num_its=num_its, num_tri_its=2, hmmdef="hmmX")
    assert Path(new_model_path).exists()
    assert Path(new_model_path).read_text() == "dummy-model-contents"




def test_attach_file_handler_writes_file(tmp_path):
    # Remove any existing handlers to keep test isolated
    for h in gs.logger.handlers[:]:
        gs.logger.removeHandler(h)

    log_path = tmp_path / "attach_test.log"

    # Ensure logger will emit INFO messages
    gs.logger.setLevel(logging.INFO)
    # Attach handler
    handler = ut._attach_file_handler(str(log_path), level=logging.INFO, mode='w')
    try:
        gs.logger.info("attach handler test")
        # ensure logs flushed
        handler.flush()
        logging.shutdown()

        assert log_path.exists(), f"Expected log file at {log_path}"
        content = log_path.read_text()
        assert "attach handler test" in content
        assert handler.level == logging.INFO
    finally:
        # Clean up handler
        try:
            gs.logger.removeHandler(handler)
        except Exception:
            pass
        handler.close()


def test_nested_handlers_writes_to_multiple_files(tmp_path):
    # Remove any existing handlers to keep test isolated
    for h in gs.logger.handlers[:]:
        gs.logger.removeHandler(h)

    # Ensure logger will emit DEBUG messages
    gs.logger.setLevel(logging.DEBUG)

    file_info = tmp_path / "info.log"
    file_debug = tmp_path / "debug.log"

    info_handler = ut._attach_file_handler(str(file_info), level=logging.INFO, mode='w')
    debug_handler = ut._attach_file_handler(str(file_debug), level=logging.DEBUG, mode='w')

    try:
        gs.logger.info("info message")
        gs.logger.debug("debug message")

        info_handler.flush()
        debug_handler.flush()
        logging.shutdown()

        assert file_info.exists(), "info log file should exist"
        assert file_debug.exists(), "debug log file should exist"

        info_content = file_info.read_text()
        debug_content = file_debug.read_text()

        # INFO should appear in both
        assert "info message" in info_content
        assert "info message" in debug_content

        # DEBUG only appears in debug handler
        assert "debug message" not in info_content
        assert "debug message" in debug_content

    finally:
        for h in (info_handler, debug_handler):
            try:
                gs.logger.removeHandler(h)
            except Exception:
                pass
            h.close()


def test_add_results_to_csv_writes_timestamp(tmp_path, monkeypatch):
    # Arrange: create fake letter and word results files with expected content
    letter_file = tmp_path / "letter_results.log"
    word_file = tmp_path / "word_results.log"

    letter_file.write_text("HEADER\nWORD: Corr=12.34 Acc=56.78\n")
    word_file.write_text("HEADER\nWORD: Corr=21.0 Acc=31.0\nSENT: Correct=41.0\n")

    # Monkeypatch helpers so add_results_to_csv reads the temp files
    monkeypatch.setattr(gs, "get_hresults_prj_filepaths", lambda name_ext, subdirs, ip: (str(letter_file), str(word_file)))
    monkeypatch.setattr(gs, "swap_prj_to_root", lambda p: p)

    # Provide results_csv path and other expected args attributes
    gs.args = SimpleNamespace(
        results_csv=str(tmp_path / "results.csv"),
        test_model_path=None,
        no_custom_silsp=False,
        cross_word=False,
        full_cov=False,
        no_triletter=False,
        custom_ext=None,
        debug=False
    )

    # Act
    gs.add_results_to_csv(ip=0, tc=1, num_its=1, num_tri_its=1, hmmdef="hmmX", subdirs="sd")

    # Assert: results CSV created and contains date_time header and values
    csv_path = tmp_path / "results.csv"
    assert csv_path.exists()

    lines = csv_path.read_text().splitlines()
    # Header and one result row
    assert lines[0].split("|")[0] == 'date_time'
    assert len(lines) >= 2

    cols = lines[1].split("|")
    # columns: date_time, letter_results_file, letter_corr, letter_acc, word_corr, word_acc, sent_corr
    assert len(cols) >= 7

    import re
    assert re.match(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$', cols[0])
    # Check numeric values were written as strings matching the results
    assert cols[2] == '12.34'
    assert cols[3] == '56.78'
    assert cols[4] == '21.0'
    assert cols[5] == '31.0'
    assert cols[6] == '41.0'
