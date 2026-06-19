#!/usr/bin/env python3

from pathlib import Path
import logging
import sys
import os

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import utils as ut
logger = logging.getLogger("__main__")

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
    from pathlib import Path

    # Clear any existing handlers so logging.basicConfig will configure a file handler
    for h in logging.root.handlers:
        logging.root.removeHandler(h)

    # Call the moved setup_logger (utils is imported as ut at module level)
    log_file = Path(tmp_path / "log.txt")
    fh = ut.setup_logger(str(log_file), flush=True, log_level=logging.INFO)
    logger.setLevel(logging.INFO)

    # Emit a log record to ensure the file is created
    # logger = logging.getLogger("test_setup_logger")
    # logger.addHandler(fh)
    logger.info("setup logger test info")

    # Ensure records are flushed to disk
    fh.flush()
    logging.shutdown()

    assert log_file.exists(), f"Expected log file at {log_file}"

    content = log_file.read_text()
    assert "setup logger test info" in content
    # Ensure the handler level matches requested level
    assert fh.level == logging.INFO


def test_setup_logger_debug_sets_debug_level(tmp_path):
    for h in logging.root.handlers:
        logging.root.removeHandler(h)

    log_file_path = str(tmp_path / "log.txt")
    fh = ut.setup_logger(log_file_path, flush=True, log_level=logging.DEBUG)
    logger.setLevel(logging.DEBUG)
    # logger = logging.getLogger("test_setup_logger_debug")
    # logger.addHandler(fh)
    logger.debug("debug message")

    fh.flush()
    logging.shutdown()

    log_file = tmp_path / "log.txt"
    assert log_file.exists()
    content = log_file.read_text()
    assert "debug message" in content
    assert fh.level == logging.DEBUG


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


def test_alphabet_parser_empty_init():
    # AlphabetParser initialized with no charset should have an empty trie
    ap = ut.AlphabetParser()
    assert isinstance(ap.trie, dict)
    assert ap.trie == {}


def test_alphabet_parser_add_tokens_and_structure():
    # Add single- and multi-character tokens and verify trie structure
    ap = ut.AlphabetParser(['a', 'ab', 'abc', 'b'])

    # Root should contain 'a' and 'b'
    assert 'a' in ap.trie
    assert 'b' in ap.trie

    # 'a' should have child 'b' (for 'ab') and that child should have 'c' (for 'abc')
    assert 'b' in ap.trie['a']
    assert 'c' in ap.trie['a']['b']

    # 'b' at root (single-char token) should exist and be a dict (possibly empty)
    assert isinstance(ap.trie['b'], dict)


def test_alphabet_parser_ignores_empty_string():
    # Empty string should not create entries in the trie
    ap = ut.AlphabetParser(['x'])
    # use the correct method name to add a set of letters
    ap.add_letterset({''})
    # empty string should not be added as a key at the root
    assert '' not in ap.trie
    # existing entries remain intact
    assert 'x' in ap.trie


def test_parse_string_simple_letters():
    # single-character alphabet should split into each character
    ap = ut.AlphabetParser(['a', 'b', 'c'])
    result = ap.parse_string('abc')
    assert result == ['a', 'b', 'c']


def test_parse_string_with_multichar_tokens():
    # multi-character tokens should be parsed greedily according to trie
    ap = ut.AlphabetParser(['a', 'ab', 'abc', 'x'])
    result = ap.parse_string('abcx')
    # implementation consumes the longest matching path in the trie, so 'abc' + 'x'
    assert result == ['abc', 'x']


def test_parse_string_raises_on_unknown_character():
    ap = ut.AlphabetParser(['a', 'b'])
    try:
        ap.parse_string('ac')
        raised = False
    except ValueError:
        raised = True
    assert raised, "Expected ValueError when parsing string with characters outside the alphabet"
