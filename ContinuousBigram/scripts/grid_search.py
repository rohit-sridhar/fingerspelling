import argparse
import re
import os
import subprocess

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
USE_BGL_VARNAME = "BIGRAM_LETTER"
USE_BGW_VARNAME = "BIGRAM_WORD"

GRAMMAR_PATH_IDX = 2

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


global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--ip_values",
        type=float,
        nargs='+',
        default=[-10],
        help="All the Insertion Penalty vals to test. Higher penalizes deletions. Lower penalizes insertions. 0 is the center."
    )
    
    parser.add_argument(
        "--tc",
        type=int,
        nargs='+',
        default=[50],
        help="HHEd cluster f value for TC command in instr/mktri2.hed."
    )
    
    parser.add_argument(
        "--num_its",
        type=int,
        nargs='+',
        default=[20],
        help="All the Insertion Penalty vals to test. Higher penalizes deletions. Lower penalizes insertions. 0 is the center."
    )
    
    parser.add_argument(
        "--num_tri_its",
        type=int,
        nargs='+',
        default=[5],
        help="All the Insertion Penalty vals to test. Higher penalizes deletions. Lower penalizes insertions. 0 is the center."
    )
    
    parser.add_argument(
        "--hmmdefs",
        type=str,
        nargs='+',
        default=['6state-pca20-gmm4'],
        help="HMM Def files to test on."
    )
    
    parser.add_argument(
        "--data_files",
        type=str,
        nargs='+',
        default=['./data/dim20/thr8/grliwi/data'],
        help="All the different datasets to test. (must end with /data)"
    )

    parser.add_argument(
        "--label_files",
        type=str,
        nargs='+',
        default=['./label/thr8/label'],
        help="All the different datasets to test. (must end with /label)"
    )
    
    parser.add_argument(
        "--no_custom_silsp",
        action='store_true',
        help="If true, won't use custom sil/sp models. custom sil/sp is used by default."
    )
    
    parser.add_argument(
        "--use_bg_letter",
        action='store_true',
        help="If true, will use letter level bigram with HBuild."
    )
    
    parser.add_argument(
        "--use_bg_word",
        action='store_true',
        help="If true, will use word level bigram with HBuild."
    )
    
    parser.add_argument(
        "--test",
        action='store_true',
        help="If true, appends .TST to all output files."
    )

    return parser.parse_args()

# Makes a dir if it doesn't already exist
def _make_dir(dir_loc):
    if not(os.path.exists(dir_loc)):
        os.makedirs(dir_loc)

# Check args
def check_args():
    if len(args.data_files) != len(args.label_files):
        raise ValueError("Data File and Label file length should match.")

    for i in range(len(args.data_files)):
        if args.data_files[i].endswith('/'):
            args.data_files[i] = args.data_files[i][:-1]
        
        if not(args.data_files[i].endswith('data')):
            raise ValueError("Data files must end with /data (last subdir).")

        if args.label_files[i].endswith('/'):
            args.label_files[i] = args.label_files[i][:-1]

        if not(args.label_files[i].endswith('label')):
            raise ValueError("Label files must end with /label (last subdir).")
    
# Get the name extension for the results/output file
def get_name_ext(ip, tc, num_its, num_tri_its, hmmdef):
    ip_int = abs(int(ip))
    if ip > 0:
        name_ext = f"pos{ip_int}ip_{hmmdef}_{num_its}its_{num_tri_its}tri-its_tc{tc}"
    elif ip < 0:
        name_ext = f"neg{ip_int}ip_{hmmdef}_{num_its}its_{num_tri_its}tri-its_tc{tc}"
    else:
        name_ext = f"{ip_int}ip_{hmmdef}_{num_its}its_{num_tri_its}tri-its_tc{tc}"
    
    if not(args.no_custom_silsp):
        name_ext += "_silsp"
    
    if args.use_bg_letter:
        name_ext += "_bgl"
    
    if args.use_bg_word:
        name_ext += "_bgw"
    
    if args.test:
        name_ext += ".TST"

    return name_ext

# Get the results filepath
def get_hresults_filepaths(name_ext, subdirs):
    letter_results_file = '_'.join(["hresults.log_letter", name_ext])
    word_results_file = '_'.join(["hresults.log_word", name_ext])
    
    results_dir = os.path.join(RESULTS_ROOT, subdirs)
    _make_dir(results_dir)
    letter_results = os.path.join("${PRJ}", results_dir, letter_results_file)
    word_results = os.path.join("${PRJ}", results_dir, word_results_file)
    
    return (letter_results, word_results)

# Get grammar filepath based on grammar type
def get_grammar_filepaths(grammar_type):
    letter_grammar = LETTER_GRAMMAR_FILE_DICT[grammar_type]
    word_grammar = WORD_GRAMMAR_FILE_DICT[grammar_type]
    return letter_grammar, word_grammar

def get_bool_arg_info():
    custom_silsp = "yes" if not(args.no_custom_silsp) else "no"
    hedfile1 = "${PRJ}/instr/mktri1_silsp.hed" if not(args.no_custom_silsp) else "${PRJ}/instr/mktri1_orig.hed"
    use_bgl = "yes" if args.use_bg_letter else "no"
    use_bgw = "yes" if args.use_bg_word else "no"

    return custom_silsp, hedfile1, use_bgl, use_bgw

def get_subdirs(filepath):
    if filepath.startswith('.'):
        # return os.path.join(*(data_file.split('/')[2:-1]))
        return filepath.split('/')[2:-1]
    else:
        return filepath.split('/')[1:-1]


# Get the subdirectories of the data file (leave out root and filename)
def get_subdirectories(data_file, label_file):
    data_subdirs = get_subdirs(data_file)
    # label_subdirs = get_subdirs(label_file)
    
    # for subdir in data_subdirs:
    #     if subdir in label_subdirs:
    #         label_subdirs.remove(subdir)

    # subdirs = os.path.join(*(data_subdirs + label_subdirs))
    subdirs = os.path.join(*(data_subdirs))
    return subdirs

# Helper to edit the options file with new hyperparam (for 1 param)
def edit_file(re_search, re_repl, file_to_edit):
    with open(file_to_edit, 'r') as f:
        lines = f.readlines()
     
    for i in range(len(lines)):
        lines[i] = re.sub(re_search, re_repl, lines[i])
    
    with open(file_to_edit, 'w') as f:
        f.writelines(lines)
    
# Edit options file with all new hyperparams (calls helper above)
def edit_options(ip, tc, num_its, num_tri_its, hmmdef, grammar_type, subdirs):
    name_ext = get_name_ext(ip, tc, num_its, num_tri_its, hmmdef)
    letter_results, word_results = get_hresults_filepaths(name_ext, subdirs)
    letter_grammar, word_grammar = get_grammar_filepaths(grammar_type)
    custom_silsp, hedfile1, use_bgl, use_bgw = get_bool_arg_info()
    
    ip_search = IP_VARNAME + "\s*=\s*-?[0-9]+(\.[0-9]+)*"
    ip_repl = IP_VARNAME + f"={ip}"

    tc_search = "^TC [0-9]+"
    tc_repl = f"TC {tc}"
    
    num_its_search = NUM_ITS_VARNAME + "\s*=\s*[0-9]+"
    num_its_repl = NUM_ITS_VARNAME + f"={num_its}"
    
    num_tri_its_search = NUM_TRI_ITS_VARNAME + "\s*=\s*[0-9]+"
    num_tri_its_repl = NUM_TRI_ITS_VARNAME + f"={num_tri_its}"

    hmmdef_search = HMMDEF_VARNAME + "\s*=\s*\$HMM_TOPOLOGY_DIR\/.+"
    hmmdef_repl = HMMDEF_VARNAME + f"=$HMM_TOPOLOGY_DIR/{hmmdef}"
    
    hedfile1_search = HEDFILE1_VARNAME + "\s*=\s*\$\{PRJ\}\/mktri1.*\.hed"
    hedfile1_repl = HEDFILE1_VARNAME + f"={hedfile1}"
    
    custom_silsp_search = CUSTOM_SILSP_VARNAME + "\s*=\s*(yes|no)"
    custom_silsp_repl = CUSTOM_SILSP_VARNAME + f"={custom_silsp}"
    
    use_bgl_search = USE_BGL_VARNAME + "\s*=\s*(yes|no)"
    use_bgl_repl = USE_BGL_VARNAME + f"={use_bgl}"
    
    use_bgw_search = USE_BGW_VARNAME + "\s*=\s*(yes|no)"
    use_bgw_repl = USE_BGW_VARNAME + f"={use_bgw}"

    letter_results_search = LOG_LETTER_VARNAME + "\s*=\s*\$\{PRJ\}\/.*hresults\.log_letter.*"
    letter_results_repl = LOG_LETTER_VARNAME + f"={letter_results}"
    
    word_results_search = LOG_WORD_VARNAME + "\s*=\s*\$\{PRJ\}\/.*hresults\.log_word.*"
    word_results_repl = LOG_WORD_VARNAME + f"={word_results}"

    letter_grammar_search = GRAMMAR_LETTER_VARNAME + "\s*=\s*\$\{PRJ\}\/.*grammar_.*"
    letter_grammar_repl = GRAMMAR_LETTER_VARNAME + f"={letter_grammar}"

    word_grammar_search = GRAMMAR_WORD_VARNAME + "\s*=\s*\$\{PRJ\}\/.*grammar_.*"
    word_grammar_repl = GRAMMAR_WORD_VARNAME + f"={word_grammar}"

    edit_file(ip_search, ip_repl, OPTIONS_FILE)
    edit_file(tc_search, tc_repl, HEDFILE2)
    edit_file(num_its_search, num_its_repl, OPTIONS_FILE)
    edit_file(num_tri_its_search, num_tri_its_repl, OPTIONS_FILE)
    edit_file(hmmdef_search, hmmdef_repl, OPTIONS_FILE)
    edit_file(letter_results_search, letter_results_repl, OPTIONS_FILE)
    edit_file(word_results_search, word_results_repl, OPTIONS_FILE)
    edit_file(letter_grammar_search, letter_grammar_repl, OPTIONS_FILE)
    edit_file(word_grammar_search, word_grammar_repl, OPTIONS_FILE)
    edit_file(hedfile1_search, hedfile1_repl, OPTIONS_FILE)
    edit_file(custom_silsp_search, custom_silsp_repl, OPTIONS_FILE)
    edit_file(use_bgl_search, use_bgl_repl, OPTIONS_FILE)
    edit_file(use_bgw_search, use_bgw_repl, OPTIONS_FILE)
    
    subprocess.run(["grep", IP_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", NUM_ITS_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", NUM_TRI_ITS_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", HMMDEF_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", LOG_LETTER_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", LOG_WORD_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", GRAMMAR_LETTER_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", GRAMMAR_WORD_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", HEDFILE1_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", CUSTOM_SILSP_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", USE_BGL_VARNAME, OPTIONS_FILE])
    subprocess.run(["grep", USE_BGW_VARNAME, OPTIONS_FILE])

# Runs the train model script
def train_model(ip, num_its, num_tri_its, subdirs):
    name_ext = get_name_ext(ip, tc, num_its, num_tri_its, hmmdef)
    
    output_dir = os.path.join(OUTPUT_ROOT, subdirs)
    _make_dir(output_dir)
    output_file = os.path.join(output_dir, "output.log_" + name_ext)
    
    train_args = [TRAIN_FILE, OPTIONS_FILE]
    print("Train Command: " + ' '.join(train_args))
    print(f"Output file: {output_file}")
    
    with open(output_file, "w") as f:
        subprocess.run(train_args, stdout=f, stderr=subprocess.STDOUT)

############### NOT IN USE CURRENTLY ###############
# Prepare data using scripts/prepare_data.sh. Not in use currently.
# def prepare_data(data_file, label_file):
#     prepare_command = ' '.join([PREPARE_FILE, OPTIONS_FILE, data_file, label_file])
#     cv_split_command = ' '.join([TOT_PREPARE, EXT_FILE_LIST, TRAIN_LIST, TEST_LIST, GEN_TOT_NAME, OPTIONS_FILE])
#     
#     print(prepare_command)
#     print(cv_split_command)
# 
#     os.system(prepare_command)
#     os.system(cv_split_command)

if __name__ == "__main__":
    args = parse_args()
    check_args()
    print(args)
    
    for i in range(len(args.data_files)):
        # TODO Write prepare files function
        data_file = args.data_files[i]
        label_file = args.label_files[i]
        
        # prepare_data(data_file, label_file)
        subdirs = get_subdirectories(data_file, label_file)
        grammar_type = subdirs.split(os.sep)[GRAMMAR_PATH_IDX]

        for ip in args.ip_values:
            for hmmdef in args.hmmdefs:
                for tc in args.tc:
                    for num_its in args.num_its:
                        for num_tri_its in args.num_tri_its:
                            edit_options(ip, tc, num_its, num_tri_its, hmmdef, grammar_type, subdirs)
                            train_model(ip, num_its, num_tri_its, subdirs)
                            print()

