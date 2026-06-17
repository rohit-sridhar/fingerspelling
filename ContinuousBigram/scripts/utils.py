#!/usr/bin/env python3

import os
import sys
import json
import shutil
import subprocess
import threading
import logging
import signal
from logging.handlers import MemoryHandler
from pathlib import Path
from glob import glob

# Logger globals
logger = logging.getLogger(__name__)
root_logger = logging.getLogger()
_BUFFER_HANDLER = None

# process ending signals to catch
KILL_SIGNALS = [
    signal.SIGTERM,
    signal.SIGINT,
    signal.SIGQUIT,
    signal.SIGHUP,
]

# Important root dirs
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
INSTR_ROOT = os.path.join(ROOT, "instr")
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
N_STATES_VARNAME = "N_STATES"
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
FILE_UNIQ_STR_VARNAME = "FILE_UNIQ_STR"
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

# {" ":0,"!":1,"#":2,"$":3,"%":4,"&":5,"'":6,"(":7,")":8,"*":9,"+":10,",":11,"-":12,".":13,"\/":14,"0":15,"1":16,"2":17,"3":18,"4":19,"5":20,"6":21,"7":22,"8":23,"9":24,":":25,";":26,"=":27,"?":28,"@":29,"[":30,"_":31,"a":32,"b":33,"c":34,"d":35,"e":36,"f":37,"g":38,"h":39,"i":40,"j":41,"k":42,"l":43,"m":44,"n":45,"o":46,"p":47,"q":48,"r":49,"s":50,"t":51,"u":52,"v":53,"w":54,"x":55,"y":56,"z":57,"~":58,"<":59,">": 60,"P": 61}
# SPECIAL_TOKEN_MAP = {
#     "!": "{EXCL}",
#     "#": "{HASH}",
#     "$": "{DOLLAR}",
#     "%": "{PCT}",
#     "&": "{AMPSND}",
#     "'": "{SQUOTE}",
#     "(": "{LPAREN}",
#     ")": "{RPAREN}",
#     "*": "{AST}",
#     "+": "{PLUS}",
#     ",": "{COMMA}",
#     "-": "{HYPHEN}",
#     ".": "{DOT}",
#     "\/" "{FSLASH}",
#     "0": "{ZERO}",
#     "1": "{ONE}",
#     "2": "{TWO}",
#     "3": "{THREE}",
#     "4": "{FOUR}",
#     "5": "{FIVE}",
#     "6": "{SIX}",
#     "7": "{SEVEN}",
#     "8": "{EIGHT}",
#     "9": "{NINE}",
#     ":": "{COLON}",
#     ";": "{SEMICOLON}",
#     "=": "{EQUAL}",
#     "?": "{QMARK}",
#     "@": "{AT}",
#     "[": "{LBRACKET}",
#     "_": "{UNDERSCORE}",
#     -
# }

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

########################################################################
# Subprocess utilities
########################################################################

def run_subprocess(cmd, logger=None):
    """Run a subprocess and route its output to the provided logger.

    If live_print is True, stream stdout/stderr lines to logger.info in real time.
    If live_print is False, capture output and log at debug (stdout) or error (stderr).
    Returns the subprocess return code.
    """
    with subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
    ) as proc:
        # Create separate threads to read stdout and stderr simultaneously
        stdout_thread = threading.Thread(target=log_stream, args=(proc.stdout, logger.info))
        stderr_thread = threading.Thread(target=log_stream, args=(proc.stderr, logger.error))

        stdout_thread.start()
        stderr_thread.start()

        # Wait for threads to finish reading all output
        stdout_thread.join()
        stderr_thread.join()

    return_code = proc.returncode
    output_msg = f"Process {' '.join(cmd)} exited with {return_code=}"
    if proc.returncode == 0:
        logger.info(output_msg)
    else:
        logger.error(output_msg)


def log_stream(stream, log_level_function):
    """Reads a stream line-by-line and sends it to a specific logging function."""
    with stream:
        for line in stream:
            log_level_function(line.rstrip("\r\n"))

########################################################################
# Path and subdirectory utilities
########################################################################

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
    logger.debug(f"{subdirs=}")
    return subdirs

def get_test_data_file(subdirs):
    return os.path.join(OUTPUT_ROOT, subdirs, "testing-extfiles0")

########################################################################
# Directory utilities
########################################################################

# Makes a dir if it doesn't exist. If it does exist, makes dir based
# on arg rmdir
def make_dir(dir_loc, rmdir=False):
    if os.path.exists(dir_loc) and rmdir:
        shutil.rmtree(dir_loc)
        os.makedirs(dir_loc)
        logger.info(f"Deleted {dir_loc} and recreated it since it exists and rmdir is True.")
    elif not(os.path.exists(dir_loc)):
        os.makedirs(dir_loc)
        logger.info(f"Created {dir_loc}")
    else:
        logger.info(f"Did not create {dir_loc} since it exists and rmdir is False.")

########################################################################
# Options file utilities
########################################################################

# Get the options file
def get_options_file(subdirs):
    return os.path.join(SCRIPTS_ROOT, subdirs, "options.sh")

########################################################################
# Labels utilities
########################################################################

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

########################################################################
# JSON utilities
########################################################################

def load_json_file(filename):
    with open(filename, "r") as f:
        json_data = json.load(f)
    return json_data

########################################################################
# Data augmentation utilities
########################################################################

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

########################################################################
# Logging utilities
########################################################################

def get_log_file(subdirs, name_ext, mode):
    """Return a log file path. Ensures the log directory exists.

    mode must be one of: "train", "test", "grid_search", "prepare_data". Raises ValueError otherwise.
    """
    if mode not in ("train", "test", "grid_search", "prepare_data", "modify_data"):
        raise ValueError("mode must be one of 'train', 'test', 'grid_search', 'modify_data' or 'prepare_data'")

    log_dir = os.path.join(LOG_ROOT, subdirs)
    make_dir(log_dir)

    return os.path.join(log_dir, f"{mode}.log_" + name_ext)


def set_buffer_handler_level(new_level=logging.INFO):
    if _BUFFER_HANDLER is not None and _BUFFER_HANDLER in root_logger.handlers:
        _BUFFER_HANDLER.setLevel(new_level)


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
    if _BUFFER_HANDLER is not None and _BUFFER_HANDLER in root_logger.handlers:
        return

    mem = MemoryHandler(capacity=capacity, flushLevel=flush_level, target=None)
    mem.setLevel(logging.DEBUG)
    root_logger.addHandler(mem)
    _BUFFER_HANDLER = mem


# Initialize buffering at import so early log calls are not lost
init_buffering_logger()


def _attach_file_handler(log_file, level=logging.DEBUG, mode="a"):
    """Attach a FileHandler to the given logger (or module logger) that writes to log_file.

    Returns the handler so callers can remove/close it when done.
    """
    fh = logging.FileHandler(log_file, mode=mode)
    formatter = logging.Formatter("%(asctime)s - %(funcName)s - %(filename)s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d | %H:%M:%S")
    fh.setFormatter(formatter)
    fh.setLevel(level)

    root_logger.addHandler(fh)
    return fh


def flush_buffer(fh):
    global _BUFFER_HANDLER
    if _BUFFER_HANDLER is not None:
        try:
            target = fh

            _BUFFER_HANDLER.setTarget(target)
            _BUFFER_HANDLER.flush()

            root_logger.removeHandler(_BUFFER_HANDLER)
        except Exception:
            pass

        try:
            _BUFFER_HANDLER.close()
        except Exception:
            pass

        _BUFFER_HANDLER = None


# set up the logger for any script
# def setup_logger(log_file, module_logger, flush=False, log_level=logging.INFO):
def setup_logger(log_file, flush=False, log_level=logging.INFO, mode="w"):
    """Configure logging to a file and flush any buffered logs.

    log_file must be a valid file path. logger should be a module logger.
    log_level should be an int logging level. Buffered logs (from init_buffering_logger)
    will be flushed to an existing FileHandler on the module logger if present;
    otherwise they will be flushed to the new root FileHandler created here.

    """
    log_file = Path(log_file)
    log_file.parent.mkdir(parents=True, exist_ok=True)

    # Reuse attach helper to create and attach a FileHandler to the root logger
    # fh = _attach_file_handler(log_file, module_logger, level=log_level)
    fh = _attach_file_handler(log_file, level=log_level, mode=mode)

    # If a buffer handler exists flush it into fh.
    if flush:
        flush_buffer(fh)

    return fh
