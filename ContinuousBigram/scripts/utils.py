import os

from glob import glob

OUTPUT_ROOT = "logs/"
RESULTS_ROOT = "results/"

OPTIONS_FILE = "./scripts/options.sh"
TRAIN_FILE = "./scripts/train.sh"
PREPARE_FILE = "./scripts/prepare_files.sh"
HEDFILE2 = "./instr/mktri2.hed"

TOT_PREPARE = "./scripts/cv/test_on_train.sh"
EXT_FILE_LIST = "all-extfiles"
TRAIN_LIST = "./trainsets/training-extfiles"
TEST_LIST = "./testsets/testing-extfiles"
GEN_TOT_NAME = "./scripts/gen_train_test_name.sh"

IP_VARNAME = "INSERT_PENALTY"
NUM_ITS_VARNAME = "NUM_HMM_DIR"
NUM_TRI_ITS_VARNAME = "TRI_ITERATIONS"
HMMDEF_VARNAME = "HMM_LOCATION"
LOG_LETTER_VARNAME = "LOG_RESULTS"
LOG_WORD_VARNAME = "LOG_RESULTS_WORD"
GRAMMAR_LETTER_VARNAME = "GRAMMARFILE"
GRAMMAR_WORD_VARNAME = "GRAMMARFILE_WORD"
HEDFILE1_VARNAME = "HEDFILE1"
CUSTOM_SILSP_VARNAME = "CUSTOM_SILSP"
MULTI_PROCESS_VARNAME = "MULTI_PROCESS"
USE_BGL_VARNAME = "BIGRAM_LETTER"
USE_BGW_VARNAME = "BIGRAM_WORD"
TRACE_LEVEL_VARNAME = "TRACE_LEVEL"

LETTER_GRAMMAR_FILE_DICT = {
    "grliwins": "${PRJ}/grammar/grammar_letter_isolated_ns",
    "grliwinw": "${PRJ}/grammar/grammar_letter_isolated_new",
    "grliwi": "${PRJ}/grammar/grammar_letter_isolated",
    "grliw2g": "${PRJ}/grammar/grammar_letter_isolated",
    "grliw3g": "${PRJ}/grammar/grammar_letter_isolated",
    "grliw4g": "${PRJ}/grammar/grammar_letter_isolated",
    "grliw5g": "${PRJ}/grammar/grammar_letter_isolated",
    "grliwph": "${PRJ}/grammar/grammar_letter_isolated",
    "grl2gwi": "${PRJ}/grammar/grammar_letter_2gram",
    "grl2gw2g": "${PRJ}/grammar/grammar_letter_2gram",
    "grl2gw3g": "${PRJ}/grammar/grammar_letter_2gram",
    "grl2gw4g": "${PRJ}/grammar/grammar_letter_2gram",
    "grl2gw5g": "${PRJ}/grammar/grammar_letter_2gram",
    "grl2gwph": "${PRJ}/grammar/grammar_letter_2gram",
    "grl3gwi": "${PRJ}/grammar/grammar_letter_3gram",
    "grl3gw2g": "${PRJ}/grammar/grammar_letter_3gram",
    "grl3gw3g": "${PRJ}/grammar/grammar_letter_3gram",
    "grl3gw5g": "${PRJ}/grammar/grammar_letter_3gram",
    "grl3gwph": "${PRJ}/grammar/grammar_letter_3gram",
    "grl4gw4g": "${PRJ}/grammar/grammar_letter_4gram",
    "grl5gw5g": "${PRJ}/grammar/grammar_letter_5gram",
    "grlwdwi": "${PRJ}/grammar/grammar_letter_word",
    "grlwdwph": "${PRJ}/grammar/grammar_letter_word",
}

WORD_GRAMMAR_FILE_DICT = {
    "grliwins": "${PRJ}/grammar/grammar_word_isolated_ns",
    "grliwinw": "${PRJ}/grammar/grammar_word_isolated",
    "grliwi": "${PRJ}/grammar/grammar_word_isolated",
    "grliw2g": "${PRJ}/grammar/grammar_word_2gram",
    "grliw3g": "${PRJ}/grammar/grammar_word_3gram",
    "grliw4g": "${PRJ}/grammar/grammar_word_4gram",
    "grliw5g": "${PRJ}/grammar/grammar_word_5gram",
    "grliwph": "${PRJ}/grammar/grammar_word_phrase",
    "grl2gwi": "${PRJ}/grammar/grammar_word_isolated",
    "grl2gw2g": "${PRJ}/grammar/grammar_word_2gram",
    "grl2gw3g": "${PRJ}/grammar/grammar_word_3gram",
    "grl2gw4g": "${PRJ}/grammar/grammar_word_4gram",
    "grl2gw5g": "${PRJ}/grammar/grammar_word_5gram",
    "grl2gwph": "${PRJ}/grammar/grammar_word_phrase",
    "grl3gwi": "${PRJ}/grammar/grammar_word_isolated",
    "grl3gw2g": "${PRJ}/grammar/grammar_word_2gram",
    "grl3gw3g": "${PRJ}/grammar/grammar_word_3gram",
    "grl3gw5g": "${PRJ}/grammar/grammar_word_5gram",
    "grl3gwph": "${PRJ}/grammar/grammar_word_phrase",
    "grl4gw4g": "${PRJ}/grammar/grammar_word_4gram",
    "grl5gw5g": "${PRJ}/grammar/grammar_word_5gram",
    "grlwdwi": "${PRJ}/grammar/grammar_word_isolated",
    "grlwdwph": "${PRJ}/grammar/grammar_word_phrase",
}

SPACE = '_'
ENTER = 'sil0'
EXIT = 'sil1'

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

