import os
import sys
import json
import shutil
import subprocess

from glob import glob

ROOT = "/data/hmm_modeling/fingerspelling/ContinuousBigram/"

# These are concatenated with ${PRJ} in options so
# leave them relative here. Use ROOT above to make an
# absolute path as needed.
LOG_ROOT = "logs/"
OUTPUT_ROOT = "output/"
RESULTS_ROOT = "results/"
MODELS_ROOT = "models/"
GRAMMAR_ROOT = "grammar/"
MLF_ROOT = "mlf/"
DICT_ROOT = "dict/"
TOKENS_ROOT = "commands/"
EXT_ROOT = "ext/"

# Scripts root is used to make the options file so use abs path.
SCRIPTS_ROOT = os.path.join(ROOT, "scripts")

#### These are here for import data (to create hard links)
# SUPP_DATA_FILES = "./data/supplemental/dl_cmp/dim20/thr0/all/data/"
# SUPP_LABEL_FILES = "./label/supplemental/dl_cmp/dim20/thr0/all/label/"
DATA_FILE_DICT_FILE = os.path.join(ROOT, "scripts/util/data_file_dict.json")
SUPP_CHAR_MAP_FILE = os.path.join(ROOT, "scripts/util/supplemental_character_to_prediction_index.json")
MAIN_CHAR_MAP_FILE = os.path.join(ROOT, "scripts/util/main_character_to_prediction_index.json")

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
def is_supplemental(path):
    return "supplemental_gen" in path

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
# 
# def get_idx_char_map(supplemental=True):
#     map_file = SUPP_CHAR_MAP_FILE if supplemental else MAIN_CHAR_MAP_FILE
#     char_idx_map = load_json_file(map_file)
#     idx_char_map = {char_idx_map[key]:key for key in char_idx_map}
#     return idx_char_map

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

