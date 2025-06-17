import os
import sys
import json
import shutil
import subprocess

from glob import glob

LOG_ROOT = "logs/"
OUTPUT_ROOT = "output/"
RESULTS_ROOT = "results/"
MODELS_ROOT = "models/"
GRAMMAR_ROOT = "grammar/"
MLF_ROOT = "mlf/"
DICT_ROOT = "dict/"
TOKENS_ROOT = "commands/"
EXT_ROOT = "ext/"
SCRIPTS_ROOT = "/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts/"

#### These are here for import data (to create hard links)
# SUPP_DATA_FILES = "./data/supplemental/dl_cmp/dim20/thr0/all/data/"
# SUPP_LABEL_FILES = "./label/supplemental/dl_cmp/dim20/thr0/all/label/"
DATA_FILE_DICT = {
    "supplemental_gen": {
        "data_path": "./data/supplemental_gen/dim20/thr0/all/data/",
        "label_path": "./label/supplemental_gen/dim20/thr0/all/label/",
        "supplemental": True,
    },
    "supplemental_gen_na-thr0.3": {
        "data_path": "./data/supplemental_gen/dim20/thr0/all/data/",
        "label_path": "./label/supplemental_gen/dim20/thr0/all/label/",
        "supplemental": True,
    },
    "supplemental_gen_drop-na": {
        "data_path": "./data/supplemental_gen/dim20/thr0/all/data/",
        "label_path": "./label/supplemental_gen/dim20/thr0/all/label/",
        "supplemental": True,
    },
    "supplemental_gen_na-thr0.3_drop-na": {
        "data_path": "./data/supplemental_gen/dim20/thr0/all/data/",
        "label_path": "./label/supplemental_gen/dim20/thr0/all/label/",
        "supplemental": True,
    },
}
# SUPP_GEN_DATA_FILES = 
# SUPP_GEN_LABEL_FILES = 
# MAIN_DATA_FILES = "./data/main/dim20/thr0/all/data/"
# MAIN_LABEL_FILES = "./label/main/dim20/thr0/all/label/"

MODEL_MACROS_FILE = "newMacros"
OPTIONS_FILENAME = "options.sh"
GEN_GRAMMAR_FILE = os.path.join(SCRIPTS_ROOT, "gen_grammar.py")
TRAIN_FILE = os.path.join(SCRIPTS_ROOT, "train.sh")
TEST_FILE = os.path.join(SCRIPTS_ROOT, "test.sh")
PREPARE_FILE = os.path.join(SCRIPTS_ROOT, "prepare_files.sh")

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
LETTER_GRAMMAR = "grammar_letter_isolated"
# LETTER_GRAMMAR_FILE_DICT = {
#     "grliwins": "${GRAMMARFILE_ROOT}/grammar_letter_isolated_ns",
#     "grliwinw": "${GRAMMARFILE_ROOT}/grammar_letter_isolated_new",
#     "grliwi": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grliw2g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grliw3g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grliw4g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grliw5g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grliwph": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
#     "grl2gwi": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl2gw2g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl2gw3g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl2gw4g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl2gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl2gwph": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
#     "grl3gwi": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
#     "grl3gw2g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
#     "grl3gw3g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
#     "grl3gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
#     "grl3gwph": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
#     "grl4gw4g": "${GRAMMARFILE_ROOT}/grammar_letter_4gram",
#     "grl5gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_5gram",
#     "grlwdwi": "${GRAMMARFILE_ROOT}/grammar_letter_word",
#     "grlwdwph": "${GRAMMARFILE_ROOT}/grammar_letter_word",
# }

WORD_GRAMMAR = "grammar_word_isolated"
# WORD_GRAMMAR_FILE_DICT = {
#     "grliwins": "${GRAMMARFILE_ROOT}/grammar_word_isolated_ns",
#     "grliwinw": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
#     "grliwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
#     "grliw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
#     "grliw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
#     "grliw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
#     "grliw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
#     "grliwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
#     "grl2gwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
#     "grl2gw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
#     "grl2gw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
#     "grl2gw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
#     "grl2gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
#     "grl2gwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
#     "grl3gwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
#     "grl3gw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
#     "grl3gw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
#     "grl3gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
#     "grl3gwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
#     "grl4gw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
#     "grl5gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
#     "grlwdwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
#     "grlwdwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
# }

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
def run_subprocess(cmd, live_print=True):
    if live_print:
        subprocess.run(cmd, stdout=sys.stdout)
    else:
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout)
        else:
            print(result.stderr)

##### SUBDIRECTORY UTILS #####

# Makes a dir if it doesn't exist. If it does exist, makes dir based
# on arg rmdir
def make_dir(dir_loc, rmdir=False):
    if os.path.exists(dir_loc) and rmdir:
        shutil.rmtree(dir_loc)
        os.makedirs(dir_loc)
        print(f"Deleted {dir_loc} and recreated it")
    elif not(os.path.exists(dir_loc)):
        os.makedirs(dir_loc)
        print(f"Created {dir_loc}")
    else:
        print(f"Did not create {dir_loc} since rmdir is {rmdir}")

# The functions below get the subdirectories for 
### TODO _get_subdirs and get_subdirectories make a lot of 
### assumptions about the path passed in. Fix this in check_args
## for now. Later, move to PathLib
def _get_subdirs(filepath):
    if filepath.startswith('.'):
        # return os.path.join(*(data_file.split('/')[2:-1]))
        return filepath.split('/')[2:-1]
    else:
        return filepath.split('/')[1:-1]

# Get the subdirectories of the data file (leave out root and filename)
def get_subdirectories(filepath):
    subdir_list = _get_subdirs(filepath)
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
def get_char_idx_map(map_file):
    with open(map_file, "r") as f:
        char_idx_map = json.load(f)

    return char_idx_map

def get_idx_char_map(map_file):
    char_idx_map = get_char_idx_map(map_file)
    idx_char_map = {char_idx_map[key]:key for key in char_idx_map}
    return idx_char_map

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

