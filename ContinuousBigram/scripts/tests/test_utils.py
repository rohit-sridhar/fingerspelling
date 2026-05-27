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

