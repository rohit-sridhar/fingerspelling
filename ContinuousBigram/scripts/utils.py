import os
import json

from glob import glob

LOG_ROOT = "logs/"
OUTPUT_ROOT = "output/"
RESULTS_ROOT = "results/"
MODELS_ROOT = "models/"
GRAMMAR_ROOT = "grammar/"

SUPP_DATA_FILES = "./data/supplemental/dl_cmp/dim20/thr0/all/data/"
SUPP_LABEL_FILES = "./label/supplemental/dl_cmp/thr0/all/label/"
MAIN_DATA_FILES = "./data/main/dl_cmp/dim20/thr0/all/data/"
MAIN_LABEL_FILES = "./label/main/dl_cmp/thr0/all/label/"

MODEL_MACROS_FILE = "newMacros"
GEN_GRAMMAR_FILE = "./scripts/gen_grammar.py"
OPTIONS_FILE = "./scripts/options.sh"
TRAIN_FILE = "./scripts/train.sh"
TEST_FILE = "./scripts/test.sh"
PREPARE_FILE = "./scripts/prepare_files.sh"
HEDFILE2 = "./instr/mktri2_tc.hed"

TOT_PREPARE = "./scripts/cv/test_on_train.sh"
EXT_FILE_LIST = "all-extfiles"
TRAIN_LIST = "./trainsets/training-extfiles"
TEST_LIST = "./testsets/testing-extfiles"
GEN_TOT_NAME = "./scripts/gen_train_test_name.sh"

GRAMMARFILE_ROOT_VARNAME = "GRAMMARFILE_ROOT"
DICTFILE_ROOT_VARNAME = "DICTFILE_ROOT"
TOKENS_ROOT_VARNAME = "TOKENS_ROOT"
MLF_ROOT_VARNAME = "MLF_ROOT"

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
CROSS_WORD_VARNAME = "CROSS_WORD"
CUSTOM_SILSP_VARNAME = "CUSTOM_SILSP"
MULTI_PROCESS_VARNAME = "MULTI_PROCESS"
NGRAM_VARNAME = "NGRAM"
TRACE_LEVEL_VARNAME = "TRACE_LEVEL"
TRILETTER_VARNAME = "TRILETTER"
THREADS_VARNAME = "THREADS"

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
LETTER_GRAMMAR_FILE_DICT = {
    "grliwins": "${GRAMMARFILE_ROOT}/grammar_letter_isolated_ns",
    "grliwinw": "${GRAMMARFILE_ROOT}/grammar_letter_isolated_new",
    "grliwi": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grliw2g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grliw3g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grliw4g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grliw5g": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grliwph": "${GRAMMARFILE_ROOT}/grammar_letter_isolated",
    "grl2gwi": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl2gw2g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl2gw3g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl2gw4g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl2gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl2gwph": "${GRAMMARFILE_ROOT}/grammar_letter_2gram",
    "grl3gwi": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
    "grl3gw2g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
    "grl3gw3g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
    "grl3gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
    "grl3gwph": "${GRAMMARFILE_ROOT}/grammar_letter_3gram",
    "grl4gw4g": "${GRAMMARFILE_ROOT}/grammar_letter_4gram",
    "grl5gw5g": "${GRAMMARFILE_ROOT}/grammar_letter_5gram",
    "grlwdwi": "${GRAMMARFILE_ROOT}/grammar_letter_word",
    "grlwdwph": "${GRAMMARFILE_ROOT}/grammar_letter_word",
}

WORD_GRAMMAR_FILE_DICT = {
    "grliwins": "${GRAMMARFILE_ROOT}/grammar_word_isolated_ns",
    "grliwinw": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
    "grliwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
    "grliw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
    "grliw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
    "grliw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
    "grliw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
    "grliwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
    "grl2gwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
    "grl2gw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
    "grl2gw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
    "grl2gw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
    "grl2gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
    "grl2gwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
    "grl3gwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
    "grl3gw2g": "${GRAMMARFILE_ROOT}/grammar_word_2gram",
    "grl3gw3g": "${GRAMMARFILE_ROOT}/grammar_word_3gram",
    "grl3gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
    "grl3gwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
    "grl4gw4g": "${GRAMMARFILE_ROOT}/grammar_word_4gram",
    "grl5gw5g": "${GRAMMARFILE_ROOT}/grammar_word_5gram",
    "grlwdwi": "${GRAMMARFILE_ROOT}/grammar_word_isolated",
    "grlwdwph": "${GRAMMARFILE_ROOT}/grammar_word_phrase",
}

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
]

########## Utils functions for python scripts ##########

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

