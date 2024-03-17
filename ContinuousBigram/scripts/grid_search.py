import argparse
import re
import os

OUTPUT_ROOT = "logs/"
RESULTS_ROOT = "results/"

OPTIONS_FILE = "./scripts/options.sh"
TRAIN_FILE = "./scripts/train.sh"
PREPARE_FILE = "./scripts/prepare_files.sh"

TOT_PREPARE = "./scripts/cv/test_on_train.sh"
EXT_FILE_LIST = "all-extfiles"
TRAIN_LIST = "./trainsets/training-extfiles"
TEST_LIST = "./testsets/testing-extfiles"
GEN_TOT_NAME = "./scripts/gen_train_test_name.sh"

IP_VARNAME = "INSERT_PENALTY"
LOG_LETTER_VARNAME = "LOG_RESULTS"
LOG_WORD_VARNAME = "LOG_RESULTS_WORD"

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--ip_values",
        type=float,
        nargs='+',
        default=[0],
        help="All the Insertion Penalty vals to test. Higher penalizes deletions. Lower penalizes insertions. 0 is the center."
    )
     
    parser.add_argument(
        "--data_files",
        type=str,
        nargs='+',
        default=['./data/silentspeller/data'],
        help="All the different datasets to test. (must end with /data)"
    )
     
    parser.add_argument(
        "--label_files",
        type=str,
        nargs='+',
        default=['./label/silentspeller/label'],
        help="All the different datasets to test. (must end with /label)"
    )

    return parser.parse_args()

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
def get_name_ext(ip):
    if ip > 0:
        name_ext = f"pos{abs(int(ip))}ip"
    elif ip < 0:
        name_ext = f"neg{abs(int(ip))}ip"
    else:
        name_ext = "0ip"
    return name_ext

# Ge the results filepath
def get_hresults_filepaths(name_ext, subdirs):
    letter_results_file = '_'.join(["hresults.log_letter", name_ext])
    word_results_file = '_'.join(["hresults.log_word", name_ext])
    
    results_dir = os.path.join(RESULTS_ROOT, subdirs)
    _make_dir(results_dir)
    letter_results = os.path.join("${PRJ}", results_dir, letter_results_file)
    word_results = os.path.join("${PRJ}", results_dir, word_results_file)
    
    return (letter_results, word_results)

# Get the subdirectories of the data file (leave out root and filename)
def get_subdirectories(data_file):
    if data_file.startswith('.'):
        return os.path.join(*(data_file.split('/')[2:-1]))
    else:
        return os.path.join(*(data_file.split('/')[1:-1]))

# Helper to edit the options file with new hyperparam (for 1 param)
def edit_options_file(re_search, re_repl):
    with open(OPTIONS_FILE, 'r') as f:
        lines = f.readlines()
     
    for i in range(len(lines)):
        lines[i] = re.sub(re_search, re_repl, lines[i])
    
    with open(OPTIONS_FILE, 'w') as f:
        f.writelines(lines)
    
# Edit options file with all new hyperparams (calls helper above)
def edit_options(ip, subdirs):
    ip_search = IP_VARNAME + "\s*=\s*-?[0-9]+(\.[0-9]+)*"
    ip_repl = IP_VARNAME + f"={ip}"
    
    name_ext = get_name_ext(ip)
    letter_results, word_results = get_hresults_filepaths(name_ext, subdirs)

    letter_search = LOG_LETTER_VARNAME + "\s*=\s*\$\{PRJ\}\/.*hresults\.log_letter.*"
    letter_repl = LOG_LETTER_VARNAME + f"={letter_results}"
    
    word_search = LOG_WORD_VARNAME + "\s*=\s*\$\{PRJ\}\/.*hresults\.log_word.*"
    word_repl = LOG_WORD_VARNAME + f"={word_results}"
    
    edit_options_file(ip_search, ip_repl)
    edit_options_file(letter_search, letter_repl)
    edit_options_file(word_search, word_repl)

    os.system(' '.join(["grep", IP_VARNAME, OPTIONS_FILE]))
    os.system(' '.join(["grep", LOG_LETTER_VARNAME, OPTIONS_FILE]))
    os.system(' '.join(["grep", LOG_WORD_VARNAME, OPTIONS_FILE]))
 
# Runs the train model script
def train_model(ip, subdirs):
    name_ext = get_name_ext(ip)
    
    output_dir = os.path.join(OUTPUT_ROOT, subdirs)
    _make_dir(output_dir)
    output_file = os.path.join(output_dir, "output.log_" + name_ext)
    train_command = ' '.join([TRAIN_FILE, OPTIONS_FILE, "\&>", output_file])
    
    print(train_command)
    os.system(train_command)

def prepare_data(data_file, label_file):
    prepare_command = ' '.join([PREPARE_FILE, OPTIONS_FILE, data_file, label_file])
    cv_split_command = ' '.join([TOT_PREPARE, EXT_FILE_LIST, TRAIN_LIST, TEST_LIST, GEN_TOT_NAME, OPTIONS_FILE])
    
    print(prepare_command)
    print(cv_split_command)

    os.system(prepare_command)
    os.system(cv_split_command)

if __name__ == "__main__":
    args = parse_args()
    check_args()
    print(args)
    
    for i in range(len(args.data_files)):
        # TODO Write prepare files function
        data_file = args.data_files[i]
        label_file = args.label_files[i]
        
        # prepare_data(data_file, label_file)
        subdirs = get_subdirectories(data_file)

        for ip in args.ip_values:
            edit_options(ip, subdirs)
            train_model(ip, subdirs)
            print()

