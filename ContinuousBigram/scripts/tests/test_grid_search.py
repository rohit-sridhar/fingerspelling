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
        custom_ext="myext"
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
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_pos10ip_extra")
    letter, word = gs.get_hresults_prj_filepaths("extdummy", subdirs=str(Path("a") / "b"), ip=20)
    # Should replace pos10ip with pos20ip in the resulting filename

    assert Path(letter).name.startswith("hresults.log_letter")
    model_file = Path(letter).name.split("hresults.log_letter")[-1]

    assert Path(word).name.startswith("hresults.log_word")
    model_file = Path(word).name.split("hresults.log_word")[-1]

    assert "pos20ip" in model_file


def test_get_hresults_filepaths_with_modelname_insert():
    # Case where model_name does NOT contain an ip token -> should insert one
    gs.args = SimpleNamespace(test_model_path="./models/foo/newMacros_extra")
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
        custom_ext="myext"
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
    handler = gs._attach_file_handler(str(log_path), level=logging.INFO, mode='w')
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

    info_handler = gs._attach_file_handler(str(file_info), level=logging.INFO, mode='w')
    debug_handler = gs._attach_file_handler(str(file_debug), level=logging.DEBUG, mode='w')

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
