from pathlib import Path
import sys
import os

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import utils as ut

def test_get_subdirectories_absolute():
    # absolute path with multiple subdirectories
    filepath1 = os.path.join("", ut.ROOT, "data", "a", "b", "c", "data")
    filepath2 = os.path.join("", ut.ROOT, "label", "a", "b", "c", "label")
    filepath3 = os.path.join("", ut.ROOT, "mlf", "a", "b", "c", "mlf")

    # os.path.join with leading empty string produces a leading slash on POSIX
    # but utils.get_subdirectories_split expects a string starting with '/'
    # ensure string startswith '/'
    if not filepath1.startswith('/'):
        filepath1 = '/' + filepath1
    if not filepath2.startswith('/'):
        filepath2 = '/' + filepath2
    if not filepath3.startswith('/'):
        filepath3 = '/' + filepath3

    subdirs1 = ut.get_subdirectories_joined(filepath1)
    subdirs2 = ut.get_subdirectories_joined(filepath2)
    subdirs3 = ut.get_subdirectories_joined(filepath3)

    assert subdirs1 == os.path.join('a', 'b', 'c')
    assert subdirs2 == os.path.join('a', 'b', 'c')
    assert subdirs3 == os.path.join('a', 'b', 'c')


def test_setup_logger_creates_file_and_sets_info(tmp_path):
    import logging

    # Clear any existing handlers so logging.basicConfig will configure a file handler
    for h in logging.root.handlers[:]:
        logging.root.removeHandler(h)

    # Call the moved setup_logger (utils is imported as ut at module level)
    import logging
    ut.setup_logger(log_dir=tmp_path, log_level=logging.INFO)

    # Emit a log record to ensure the file is created
    logger = logging.getLogger("test_setup_logger")
    logger.info("setup logger test info")

    # Ensure records are flushed to disk
    logging.shutdown()

    log_file = tmp_path / "log.txt"
    assert log_file.exists(), f"Expected log file at {log_file}"

    content = log_file.read_text()
    assert "setup logger test info" in content
    # Root level should be INFO when debug=False
    assert logging.getLogger().level == logging.INFO


def test_setup_logger_debug_sets_debug_level(tmp_path):
    import logging

    for h in logging.root.handlers[:]:
        logging.root.removeHandler(h)

    ut.setup_logger(log_dir=tmp_path, log_level=logging.DEBUG)
    logger = logging.getLogger("test_setup_logger_debug")
    logger.debug("debug message")
    logging.shutdown()

    log_file = tmp_path / "log.txt"
    assert log_file.exists()
    content = log_file.read_text()
    assert "debug message" in content
    assert logging.getLogger().level == logging.DEBUG


def test_setup_logger_arg_validation(tmp_path):
    import pytest, logging
    for h in logging.root.handlers[:]:
        logging.root.removeHandler(h)

    # stdout=False requires a log_dir
    with pytest.raises(ValueError):
        ut.setup_logger(None, stdout=False)

    # stdout=True requires log_dir to be None
    with pytest.raises(ValueError):
        ut.setup_logger(tmp_path, stdout=True)


def test_setup_logger_stdout_attaches_stream_handler(tmp_path):
    import logging
    for h in logging.root.handlers[:]:
        logging.root.removeHandler(h)

    # Should not raise
    ut.setup_logger(None, stdout=True)
    # check that the last handler is a StreamHandler pointing to stdout
    handlers = logging.getLogger().handlers
    assert handlers, "Expected at least one handler"
    from logging import StreamHandler
    stream_handlers = [h for h in handlers if isinstance(h, StreamHandler)]
    assert stream_handlers, "Expected a StreamHandler when stdout=True"
    # check stream is sys.stdout
    assert stream_handlers[-1].stream is sys.stdout
