import os
import sys
import json
import shutil
import subprocess
import logging
from logging.handlers import MemoryHandler
from pathlib import Path
from glob import glob

logger = logging.getLogger(__name__)
_BUFFER_HANDLER = None

ROOT = "/data/hmm_modeling/fingerspelling/ContinuousBigram"

LOG_ROOT = os.path.join(ROOT, "logs")
OUTPUT_ROOT = os.path.join(ROOT, "output")
RESULTS_ROOT = os.path.join(ROOT, "results")
TEST_RESULTS_ROOT = os.path.join(ROOT, "test_results")
MODELS_ROOT = os.path.join(ROOT, "models")
GRAMMAR_ROOT = os.path.join(ROOT, "grammar")
MLF_ROOT = os.path.join(ROOT, "mlf")
DICT_ROOT = os.path.join(ROOT, "dict")
TOKENS_ROOT = os.path.join(ROOT, "commands")
EXT_ROOT = os.path.join(ROOT, "ext")

# Scripts root is used to make the options file so use abs path.
SCRIPTS_ROOT = os.path.join(ROOT, "scripts")
DATA_ROOT = os.path.join(ROOT, "data")
LABELS_ROOT = os.path.join(ROOT, "label")

#### These are here for import data (to create hard links)
# SUPP_DATA_FILES = "./data/supplemental/dl_cmp/dim20/thr0/all/data"
# SUPP_LABEL_FILES = "./label/supplemental/dl_cmp/dim20/thr0/all/label"
DATA_FILE_DICT_FILE = os.path.join(ROOT, "scripts/util/data_file_dict.json")
SUPP_IDX_MAP_FILE = os.path.join(ROOT, "scripts/util/supplemental_prediction_index_to_character.json")
MAIN_IDX_MAP_FILE = os.path.join(ROOT, "scripts/util/main_prediction_index_to_character.json")

MODEL_MACROS_FILE = "newMacros"
OPTIONS_FILENAME = "options.sh"
GEN_GRAMMAR_SCRIPT = os.path.join(SCRIPTS_ROOT, "gen_grammar.py")
TRAIN_SCRIPT = os.path.join(SCRIPTS_ROOT, "train.sh")
TEST_SCRIPT = os.path.join(SCRIPTS_ROOT, "test.sh")
PREPARE_SCRIPT = os.path.join(SCRIPTS_ROOT, "prepare_files.sh")

GRAMMARFILE_ROOT_VARNAME = "GRAMMARFILE_ROOT"
DICTFILE_ROOT_VARNAME = "DICTFILE_ROOT"
TOKENS_ROOT_VARNAME = "TOKENS_ROOT"
MLF_ROOT_VARNAME = "MLF_ROOT"
OUTPUTFILE_ROOT_VARNAME = "OUTPUTFILE_ROOT"
EXT_DIR_VARNAME = "EXT_DIR"
MODELS_ROOT_VARNAME = "HMM_TEMP_DIR"

IP_VARNAME = "INSERT_PENALTY"
NUM_ITS_VARNAME = "NUM_HMM_DIR"
NUM_TRI_ITS_VARNAME = "TRI_ITERATIONS"
HMMDEF_VARNAME = "HMM_LOCATION"
HMMSIL_VARNAME = "HMM_SIL"
HMMSP_VARNAME = "HMM_SP"
VECTOR_LENGTH_VARNAME = "VECTOR_LENGTH"
LOG_LETTER_VARNAME = "LOG_RESULTS"
LOG_WORD_VARNAME = "LOG_RESULTS_WORD"
NGRAM_WORD_VARNAME = "NGRAM"
GRAMMAR_LETTER_VARNAME = "GRAMMARFILE"
GRAMMAR_WORD_VARNAME = "GRAMMARFILE_WORD"
HEDFILE1_VARNAME = "HEDFILE1"
HEDFILE2_VARNAME = "HEDFILE2"
LEDFILE_UNIQ_VARNAME = "LEDFILE_UNIQ"
CROSS_WORD_VARNAME = "CROSS_WORD"
CUSTOM_SILSP_VARNAME = "CUSTOM_SILSP"
MULTI_PROCESS_VARNAME = "MULTI_PROCESS"
NGRAM_VARNAME = "NGRAM"
TRACE_LEVEL_VARNAME = "TRACE_LEVEL"
TRILETTER_VARNAME = "TRILETTER"
THREADS_VARNAME = "THREADS"
WHOLE_WORD_VARNAME = "WHOLE_WORD"
USE_PHRASE_VARNAME = "WORD_SKSP_PHRASE"

# Next two params are LM utils
BASE_PARAMETER = 1.5
CONSTANT_PARAMETER = 0.01

SUPP_START_IDX = 27
SUPP_END_IDX = 28
SUPP_PAD_IDX = 29

MAIN_START_IDX = 59
MAIN_END_IDX = 60
MAIN_PAD_IDX = 61

BENTEN_THREADS = "96"
EBISU_THREADS = "32"
HOTEI_THREADS = "8"

# the GRAMMAR_FILE_DICTS shoudl be deprecated since grammar_types are no longer in use.
LETTER_GRAMMAR = "grammar_letter"
WORD_GRAMMAR = "grammar_word"

SPACE = '_'
ENTER = 'sil0'
EXIT = 'sil1'

TOKEN_MAP = {
    "0": "{ZERO}",
    "1": "{ONE}",
    "2": "{TWO}",
    "3": "{THREE}",
    "4": "{FOUR}",
    "5": "{FIVE}",
    "6": "{SIX}",
    "7": "{SEVEN}",
    "8": "{EIGHT}",
    "9": "{NINE}",
    "+": "{PLUS}",
    "-": "{MINUS}",
}

MODIFY_DATA_METHODS = [
    "duplication",
    "threshold_duplication",
    "interpolation",
    "fpl_threshold",
    "dim_select",
    "remove_z",
    "normalize",
    "neg_fpl_threshold",
    "match_triletters",
    "import",
    "sample",
    "data_aug_interpolation",
    # "whole_word",
]

DATA_LOC_REQUIRED_METHODS = {
    "duplication",
    "threshold_duplication",
    "interpolation",
    "fpl_threshold",
    "dim_select",
    "remove_z",
    "normalize",
    "neg_fpl_threshold",
    "match_triletters",
    "sample",
    "data_aug_interpolation"
}

NEW_DATA_LOC_REQUIRED_METHODS = {
    "duplication",
    "threshold_duplication",
    "interpolation",
    "fpl_threshold",
    "dim_select",
    "remove_z",
    "normalize",
    "neg_fpl_threshold",
    "match_triletters",
    "sample",
    "import",
    "data_aug_interpolation"
}

##### A note about the sets below. The two sets
# are not a comprehensive list of methods in which
# label loc and new label loc are required. They
# are only a list of methods in which data loc and
# new data loc are not required but labels are.
# label loc and new label loc are built in modify_data.py
# for other methods where they are required.

# LABEL_LOC_REQUIRED_METHODS = {
#     "whole_word"
# }
# 
# NEW_LABEL_LOC_REQUIRED_METHODS = {
#     "whole_word"
# }

########## Utils functions for python scripts ##########
def run_subprocess(cmd, live_print=True, logger=None):
    """Run a subprocess and route its output to the provided logger.

    If live_print is True, stream stdout/stderr lines to logger.info in real time.
    If live_print is False, capture output and log at debug (stdout) or error (stderr).
    Returns the subprocess return code.
    """
    if live_print:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        try:
            for line in proc.stdout:
                logger.info(line.rstrip())
        finally:
            proc.wait()
        return proc.returncode
    else:
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            if result.stdout:
                logger.debug(result.stdout)
        else:
            # include stdout for context when showing errors
            out = (result.stdout or '') + (result.stderr or '')
            logger.error(out)
        return result.returncode

##### SUBDIRECTORY UTILS #####
# swaps an absolute path's prefix ${PRJ} with
# ROOT (defined above). 
def swap_prj_to_root(path_with_prj):
    return os.path.join(ROOT, *path_with_prj.split(os.path.sep)[1:])

# checks if the path is a supplemental_gen dataset
# path
def is_supplemental(path):
    return "supplemental_gen" in path

# checks that the data loc passed is valid (not None,
# starts with DATA_ROOT, and ends with data/)
def valid_data_loc(data_loc):
    return data_loc is not None and \
        data_loc.endswith("/data") and \
        data_loc.startswith(f"{DATA_ROOT}")

# Makes a dir if it doesn't exist. If it does exist, makes dir based
# on arg rmdir
def make_dir(dir_loc, rmdir=False):
    if os.path.exists(dir_loc) and rmdir:
        shutil.rmtree(dir_loc)
        os.makedirs(dir_loc)
        print(f"Deleted {dir_loc} and recreated it since it exists and rmdir is True.")
    elif not(os.path.exists(dir_loc)):
        os.makedirs(dir_loc)
        print(f"Created {dir_loc}")
    else:
        print(f"Did not create {dir_loc} since it exists and rmdir is False.")

# The functions below get the subdirectories for a given data directory.
# It expects an absolute path as input.
def get_subdirectories_split(filepath):
    return filepath[len(ROOT)+1:].split("/")[1:-1]

# Get the subdirectories of the data file (leave out root and filename)
# Expects input filepath to start at root. The folder directly beneath root
# and the leaf folder should have the same name.
def get_subdirectories_joined(filepath):
    if not filepath.startswith(ROOT):
        raise ValueError("filepath arg must start with ROOT")

    subdir_list = get_subdirectories_split(filepath)
    subdirs = os.path.join(*(subdir_list))
    return subdirs

def get_test_data_file(subdirs):
    return os.path.join(OUTPUT_ROOT, subdirs, "testing-extfiles0")

##### OPTIONS FILE UTILS #####
# Get the options file
def get_options_file(subdirs):
    return os.path.join(SCRIPTS_ROOT, subdirs, "options.sh")

##### LABELS UTILS #####

# Get label files in label dir
def get_label_files(label_dir):
    file_pattern = os.path.join(label_dir, "*.lab")
    files = glob(file_pattern)
    return files

# Get tokens from a given label file. Does not
# include the SPACE or SIL character.
def collect_tokens(label_path):
    with open(label_path, 'r') as f:
        labels = f.readlines()
    
    labels = [l.strip() for l in labels]
    labels = ''.join(labels[1:-1]).split(SPACE)
    return labels

def get_triletters(tokens):
    triletters = []
    for token in tokens:
        if len(token) == 1:
            return [token]

        for i,letter in enumerate(token):
            if i == 0:
                triletter = '+'.join([token[0], token[1]])
            elif i == len(token) - 1:
                triletter = '-'.join([token[-2], token[-1]])
            else:
                triletter = token[i-1] + '-' + token[i] + '+' + token[i+1]
            triletters.append(triletter)
    
    return triletters

##### Load JSON Char Maps #####
def load_json_file(filename):
    with open(filename, "r") as f:
        json_data = json.load(f)
    return json_data

# TODO replace function below and use above.
# def get_char_idx_map(supplemental=True):
#     with open(map_file, "r") as f:
#         char_idx_map = json.load(f)
# 
#     return char_idx_map

##### DATA AUGMENTATION UTILS #####
def get_data_aug_entry(start_seq, augmentation, end_seq):
    return " ".join([start_seq, "(" + augmentation + ")", end_seq])

def get_next_seq_id(data_aug_map):
    seq_ids = list(data_aug_map.keys())
    seq_ids = [int(seq_id) for seq_id in seq_ids]
    
    next_seq_id = 0
    if min(seq_ids) > 0:
        next_seq_id = min(seq_ids) - 1
    else:
        while next_seq_id < len(seq_ids) - 1 and seq_ids[next_seq_id] + 1 == seq_ids[next_seq_id + 1]:
            next_seq_id = seq_ids[next_seq_id + 1]
        
        if next_seq_id == len(seq_ids) - 1:
            next_seq_id = max(seq_ids) + 1
        else:
            next_seq_id = seq_ids[next_seq_id] + 1
    
    return str(next_seq_id)

##### Logging utils #####
def init_buffering_logger(capacity=10000, flush_level=logging.ERROR):
    """Attach a MemoryHandler to the root logger to buffer logs until file handlers are configured.
    initialize the root logger piping to /dev/null. Pass a file handler or stream handler to 
    setup_logger with a module level logger to log. Anything stored in _BUFFER_HANDLER will be 
    emptied during the first call to setup_logger from any module that imports this one.
    _BUFFER_HANDLER stays None after that for the duration of the script.

    capacity: max number of records to buffer
    flush_level: level at which buffer will flush to target
    """
    logging.basicConfig(
        filename=os.devnull,
        level=logging.DEBUG,
    )
    global _BUFFER_HANDLER
    root = logging.getLogger()
    if _BUFFER_HANDLER is not None and _BUFFER_HANDLER in root.handlers:
        return _BUFFER_HANDLER

    mem = MemoryHandler(capacity=capacity, flushLevel=flush_level, target=None)
    mem.setLevel(logging.DEBUG)
    root.addHandler(mem)
    _BUFFER_HANDLER = mem


# Initialize buffering at import so early log calls are not lost
init_buffering_logger()

def _attach_file_handler(log_path, module_logger, level=logging.DEBUG, mode='w'):
    """Attach a FileHandler to the given logger (or module logger) that writes to log_path.

    Returns the handler so callers can remove/close it when done.
    """
    fh = logging.FileHandler(log_path, mode=mode)
    formatter = logging.Formatter("%(asctime)s - %(funcName)s - %(filename)s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d | %H:%M:%S")
    fh.setFormatter(formatter)
    fh.setLevel(level)
    module_logger.addHandler(fh)
    return fh


# set up the logger for any script
def setup_logger(log_file, module_logger, log_level=logging.INFO):
    """Configure logging to a file and flush any buffered logs.

    log_file must be a valid file path. logger should be a module logger.
    log_level should be an int logging level. Buffered logs (from init_buffering_logger)
    will be flushed to an existing FileHandler on the module logger if present;
    otherwise they will be flushed to the new root FileHandler created here.
    """
    log_file = Path(log_file)
    log_file.parent.mkdir(parents=True, exist_ok=True)

    # Reuse attach helper to create and attach a FileHandler to the root logger
    fh = _attach_file_handler(log_file, module_logger, level=log_level)

    # If a buffer handler exists, pick a suitable target and flush into it.
    global _BUFFER_HANDLER
    if _BUFFER_HANDLER is not None:
        try:
            # Prefer an existing FileHandler attached to the module logger so buffered
            # records go to per-context files (e.g., grid_handler). Fall back to root fh.

            target = fh
            # target = None
            # for h in logger.handlers:
            #     if isinstance(h, logging.FileHandler):
            #         target = h
            #         break

            # if target is None:
            #     target = fh

            _BUFFER_HANDLER.setTarget(target)
            _BUFFER_HANDLER.flush()

            root = logging.getLogger()
            root.removeHandler(_BUFFER_HANDLER)
        except Exception:
            pass

    try:
        _BUFFER_HANDLER.close()
    except Exception:
        pass

    _BUFFER_HANDLER = None
    return fh

