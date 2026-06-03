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
    for h in logging.root.handlers:
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

    for h in logging.root.handlers:
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


def test_buffer_handler_attached(tmp_path):
    import logging
    from logging.handlers import MemoryHandler

    # Remove any handlers, then re-initialize buffering
    for h in logging.root.handlers:
        logging.root.removeHandler(h)

    ut.init_buffering_logger()

    # Check that the module-level buffer exists and is attached
    assert getattr(ut, '_BUFFER_HANDLER', None) is not None
    assert isinstance(ut._BUFFER_HANDLER, MemoryHandler)
    assert ut._BUFFER_HANDLER in logging.getLogger().handlers
