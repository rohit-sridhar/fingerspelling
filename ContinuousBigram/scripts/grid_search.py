import argparse
import re
import os
import csv
import sys
import subprocess
import shutil

from itertools import product
from utils import *
from glob import glob

###### TO ADD A NEW HYPERPARAM #######
### Below, we describe the workflow for adding new hyperparams
# Add an arg to parse_args
# If a non-boolean arg, need to add the arg to the iterator and pass it to
## edit_options, train_model, get_name_ext
# Modify edit_options to search for and modify the option in the relevant files
# Modify edit_options to print out the modification
# Modify get_name_ext to print out the appropriate extension

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--data_files",
        type=str,
        nargs='+',
        default=['./data/supplemental/dl_cmp/dim20/thr1/train/interpall1/pt2/data/'],
        help="All the different datasets to test. (must end with /data) " + \
                "The label path is created from this path."
    )
    
    parser.add_argument(
        "--results_csv",
        type=str,
        default=None,
        help="Results CSV to append results to. If the file does not exist, it is created. \
                If it does exist, results are appended. If nothing is passed the results \
                won't be saved."
    )

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
        help="Number of standard training iterations."
    )
    
    parser.add_argument(
        "--num_tri_its",
        type=int,
        nargs='+',
        default=[5],
        help="Number of tri letter iterations."
    )
    
    parser.add_argument(
        "--trace_values",
        type=int,
        nargs='+',
        default=[1],
        help="Trace Values. If not passed, uses 1 by default."
    )
    
    parser.add_argument(
        "--hmmdefs",
        type=str,
        nargs='+',
        default=['6state-pca20-gmm2'],
        help="HMM Def files to test on."
    )

    parser.add_argument(
        "--ngrams",
        type=int,
        nargs='+',
        default=[1],
        help="Ngrams to use with HLM modeling tools. If Ngram=0, doesn't use HLM tools. CURRENTLY NOT IN USE."
    )
    
    parser.add_argument(
        "--no_custom_silsp",
        action='store_true',
        help="If true, won't use custom sil/sp models. custom sil/sp is used by default."
    )

    parser.add_argument(
        "--full_cov",
        action='store_true',
        help="If true, uses hmmdefs with full covariance for sil/sp models."
    )
    
    parser.add_argument(
        "--no_multi_process",
        action='store_true',
        help="If true, won't use multiprocessing."
    )

    parser.add_argument(
        "--no_triletter",
        action='store_true',
        help="If true, won't use triletter modeling."
    )
    
    parser.add_argument(
        "--prepare_data",
        action='store_true',
        help="If true, will prepare data before training. Warning: not thread safe."
    )
    
    parser.add_argument(
        "--prepare_data_only",
        action='store_true',
        help="If true, will prepare data before training."
    )
    
    parser.add_argument(
        "--test_model",
        action='store_true',
        help="If true, will run testing. If a model is not passed as an arg, will build a model name from other args (as in train time)"
    )
    
    parser.add_argument(
        "--whole_word",
        action='store_true',
        help="If true will model on the whole word level (words treated like letters, phrases like words)."
    )

    parser.add_argument(
        "--use_phrase",
        action='store_true',
        help="If true uses phrase level grammar in the word grammar."
    )
    
    parser.add_argument(
        "--test_model_path",
        type=str,
        default=None,
        help="Model path for testing."
    )
    
    parser.add_argument(
        "--cross_word",
        action="store_true",
        help="True if using cross word triphones."
    )
    
    parser.add_argument(
        "--clear_hresults",
        action="store_true",
        help="If true, clear the hresults files (otherwise results will be appended, if the files exist)."
    )
    
    parser.add_argument(
        "--print_mode",
        action="store_true",
        help="If true, only prints. Does not train or test. Data will still be prepared and dirs/files will be created."
    )
    
    parser.add_argument(
        "--custom_ext",
        type=str,
        default=None,
        help="Custom label the results/log file."
    )

    return parser.parse_args()

# Makes the dir for the options file
def _make_options_file(subdirs):
    options_dir = os.path.join(SCRIPTS_ROOT, subdirs)
    print("##### Setting Up Options File #####")
    make_dir(options_dir)
    print("#####\n")

    new_options_file = os.path.join(options_dir, OPTIONS_FILENAME)
    original_options_file = os.path.join(SCRIPTS_ROOT, OPTIONS_FILENAME)
    copy_options_file = shutil.copy2(original_options_file, new_options_file)
    
# Check args
def check_args():
    for i in range(len(args.data_files)):
        if args.data_files[i].endswith('/'):
            args.data_files[i] = args.data_files[i][:-1]
        
        if not(args.data_files[i].endswith('data')):
            raise ValueError("Data files must end with /data (last subdir).")

    if args.test_model_path is not None:
        if args.test_model_path.startswith("."):
            args.test_model_path = os.path.join(*args.test_model_path.split(os.path.sep)[1:])
        
        if not(args.test_model_path.startswith(MODELS_ROOT)):
            raise ValueError("Please pass a path where the first dir is (./)?model")

# get the ip ext (for results file naming)
def get_ip_ext(ip):
    ip_int = abs(int(ip))
    if ip > 0:
        return f"pos{ip_int}ip"
    elif ip < 0:
        return f"neg{ip_int}ip"
    else:
        return f"{ip_int}ip" 

# Get the name extension for the results/output file
def get_name_ext(tc, num_its, num_tri_its, hmmdef, trace_value=None):
    name_ext = ""

    # Do not include insertion-penalty (ip) in the name extension anymore
    name_ext += "_".join([f"{hmmdef}", f"{num_its}its", f"{num_tri_its}tri-its", f"tc{tc}"])

    print(args)
    if args.use_phrase:
        name_ext += "_grliwph"

    if args.no_custom_silsp:
        name_ext += "_no-silsp"
    
    if args.cross_word:
        name_ext += "_cross"
    
    if args.no_triletter:
        name_ext += "_no-triletter"

    if args.custom_ext is not None:
        name_ext += f".{args.custom_ext}"

    if trace_value is not None:
        name_ext += f".TR{trace_value}"
    
    return name_ext

# Get the results filepath
def get_hresults_filepaths(name_ext, subdirs, ip):
    results_dir = os.path.join(RESULTS_ROOT, subdirs)
    print("##### Creating Results Dirs #####")
    make_dir(results_dir)
    
    if args.test_model_path is None:
        letter_results_file = '_'.join(["hresults.log_letter", name_ext])
        word_results_file = '_'.join(["hresults.log_word", name_ext])
    else:
        model_dir, model_name = os.path.split(args.test_model_path)
        model_results_dir = '_'.join(model_dir.split(os.path.sep)[1:])
        
        results_dir = os.path.join(results_dir, model_results_dir)
        make_dir(results_dir)
        
        # Ensure model_name contains the correct insertion-penalty token if present; be robust to different name formats
        model_name_split = model_name.split("_")
        ip_token = get_ip_ext(ip)
        ip_idx = None
        for i, t in enumerate(model_name_split):
            if re.match(r'^(pos|neg)?\d+ip$', t):
                ip_idx = i
                break
        
        if ip_idx is not None:
            model_name_split[ip_idx] = ip_token
        else:
            # insert after first component to preserve legacy structure where applicable
            if len(model_name_split) >= 1:
                model_name_split.insert(1, ip_token)
            else:
                model_name_split.append(ip_token)
        model_name = "_".join(model_name_split)

        letter_results_file = '.'.join(["hresults", "log_letter", model_name])
        word_results_file = '.'.join(["hresults", "log_word", model_name])
        
    letter_results = os.path.join("${PRJ}", results_dir, letter_results_file)
    word_results = os.path.join("${PRJ}", results_dir, word_results_file)
    print("#####\n")

    return (letter_results, word_results)

# get ledfile name (uniq for each hyperparam/data setting)
def get_ledfile_info(subdirs):
    subdir_arr = subdirs.split(os.path.sep)
    new_subdirs = '_'.join(subdir_arr)
    return new_subdirs

def get_vector_dim(subdirs):
    vector_dim_str = subdirs.split(os.path.sep)[1]
    vector_dim = int(re.search(r"[0-9]+", vector_dim_str).group())
    return vector_dim

# Returns appropriate values for all bool args. Does not
# do this for triletter (handled separately)
def get_bool_arg_info():
    custom_silsp = "yes" if not(args.no_custom_silsp) else "no"
    multi_process = "yes" if not(args.no_multi_process) else "no"
    hedfile1 = "${PRJ}/instr/mktri1_silsp.hed" if not(args.no_custom_silsp) else "${PRJ}/instr/mktri1_orig.hed"
    cross_word = "yes" if args.cross_word else "no"
    whole_word = "yes" if args.whole_word else "no"
    use_phrase = "yes" if args.use_phrase else "no"

    return custom_silsp, multi_process, hedfile1, cross_word, whole_word, use_phrase

def get_machine_info():
    return os.cpu_count()

# Helper to edit the options file with new hyperparam (for 1 param)
def edit_file(re_search, re_repl, file_to_edit):
    with open(file_to_edit, 'r') as f:
        lines = f.readlines()
     
    for i in range(len(lines)):
        lines[i] = re.sub(re_search, re_repl, lines[i])
    
    with open(file_to_edit, 'w') as f:
        f.writelines(lines)
    
# The function below makes changes for triletter modeling. commands_word and
# mlf location word stay the same (between single/tri) so those are not modified.
def make_triletter_changes(subdirs):
    triletter_search = TRILETTER_VARNAME + r"\s*=\s*(yes|no)"
    dictfile_search = r"^DICTFILE\s*=\s*\$\{DICTFILE_ROOT\}\/dict_(tri|letter)2letter"
    dictfile_word_search = r"^DICTFILE_WORD\s*=\s*\$\{DICTFILE_ROOT\}\/dict_(tri|letter)2word"
    tokens_search = r"^TOKENS\s*=\s*\$\{TOKENS_ROOT\}\/commands_(tri_internal|letter)"
    mlf_location_search = r"^MLF_LOCATION\s*=\s*\$\{MLF_ROOT\}\/labels.mlf_(tri_internal|letter)"
    
    if args.no_triletter:
        triletter_repl = TRILETTER_VARNAME + "=no"
        dictfile_repl = "DICTFILE=${DICTFILE_ROOT}/dict_letter2letter"
        dictfile_word_repl = "DICTFILE_WORD=${DICTFILE_ROOT}/dict_letter2word"
        tokens_repl = "TOKENS=${TOKENS_ROOT}/commands_letter"
        mlf_location_repl = "MLF_LOCATION=${MLF_ROOT}/labels.mlf_letter"
    else:
        triletter_repl = TRILETTER_VARNAME + "=yes"
        dictfile_repl = "DICTFILE=${DICTFILE_ROOT}/dict_tri2letter"
        dictfile_word_repl = "DICTFILE_WORD=${DICTFILE_ROOT}/dict_tri2word"
        tokens_repl = "TOKENS=${TOKENS_ROOT}/commands_tri_internal"
        mlf_location_repl = "MLF_LOCATION=${MLF_ROOT}/labels.mlf_tri_internal"
    
    options_file = get_options_file(subdirs)

    edit_file(triletter_search, triletter_repl, options_file)
    edit_file(dictfile_search, dictfile_repl, options_file)
    edit_file(dictfile_word_search, dictfile_word_repl, options_file)
    edit_file(tokens_search, tokens_repl, options_file)
    edit_file(mlf_location_search, mlf_location_repl, options_file)
 
    print("##### Setting Triletter HTK Files #####")
    run_subprocess(["grep", "^"+TRILETTER_VARNAME+r"\s*=\s*", options_file])
    run_subprocess(["grep", r"^DICTFILE\s*=\s*", options_file])
    run_subprocess(["grep", r"^DICTFILE_WORD\s*=\s*", options_file])
    run_subprocess(["grep", r"^TOKENS\s*=\s*", options_file])
    run_subprocess(["grep", r"^MLF_LOCATION\s*=\s*", options_file])
    print("#####\n")
    

# Edit options file with all new hyperparams (calls helper above)
def edit_options(ip, tc, num_its, num_tri_its, hmmdef, subdirs, ngram, trace_value=None):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef) # We leave trace_value out in this call.
    letter_results, word_results = get_hresults_filepaths(name_ext, subdirs, ip)

    custom_silsp, multi_process, hedfile1, cross_word, whole_word, use_phrase = get_bool_arg_info()
    hedfile2 = f"${{PRJ}}/instr/mktri2_tc.{hmmdef}.hed"
    num_threads = get_machine_info()

    ip_search = IP_VARNAME + r"\s*=\s*-?[0-9]+(\.[0-9]+)*"
    ip_repl = IP_VARNAME + f"={ip}"

    tc_search = "^TC [0-9]+"
    tc_repl = f"TC {tc}"

    num_its_search = NUM_ITS_VARNAME + r"\s*=\s*[0-9]+"
    num_its_repl = NUM_ITS_VARNAME + f"={num_its}"

    num_tri_its_search = NUM_TRI_ITS_VARNAME + r"\s*=\s*[0-9]+"
    num_tri_its_repl = NUM_TRI_ITS_VARNAME + f"={num_tri_its}"

    hmmdef_search = HMMDEF_VARNAME + r"\s*=\s*\$HMM_TOPOLOGY_DIR\/.+"
    hmmdef_repl = HMMDEF_VARNAME + f"=$HMM_TOPOLOGY_DIR/{hmmdef}"

    models_dir = os.path.join(MODELS_ROOT, subdirs, hmmdef)
    models_root_search = MODELS_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/models.*"
    models_root_repl = MODELS_ROOT_VARNAME + os.path.join("=${PRJ}", models_dir)
    
    hedfile1_search = HEDFILE1_VARNAME + r"\s*=\s*\$\{PRJ\}\/instr\/mktri1_.*\.hed"
    hedfile1_repl = HEDFILE1_VARNAME + f"={hedfile1}"
    
    hedfile2_search = HEDFILE2_VARNAME + r"\s*=\s*\$\{PRJ\}\/instr\/mktri2_.*\.hed"
    hedfile2_repl = HEDFILE2_VARNAME + f"={hedfile2}"
    
    custom_silsp_search = CUSTOM_SILSP_VARNAME + r"\s*=\s*(yes|no)"
    custom_silsp_repl = CUSTOM_SILSP_VARNAME + f"={custom_silsp}"
    
    multi_process_search = MULTI_PROCESS_VARNAME + r"\s*=\s*(yes|no)"
    multi_process_repl = MULTI_PROCESS_VARNAME + f"={multi_process}"
    
    cross_word_search = CROSS_WORD_VARNAME + r"\s*=\s*(yes|no)"
    cross_word_repl = CROSS_WORD_VARNAME + f"={cross_word}"
    
    ngram_word_search = NGRAM_WORD_VARNAME + r"\s*=\s*[0-9]"
    ngram_word_repl = NGRAM_WORD_VARNAME + f"={ngram}"
    
    whole_word_search = WHOLE_WORD_VARNAME + r"\s*=\s*(yes|no)"
    whole_word_repl = WHOLE_WORD_VARNAME + f"={whole_word}"

    use_phrase_search = USE_PHRASE_VARNAME + r"\s*=\s*(yes|no)"
    use_phrase_repl = USE_PHRASE_VARNAME + f"={use_phrase}"

    cross_word_hedfile1_search = r"^CL commands\/commands_tri_(internal|cross)$"
    cross_word_hedfile1_repl = "CL commands/commands_tri_cross" if args.cross_word else "CL commands/commands_tri_internal"
    hedfile1_local_file = hedfile1.replace("${PRJ}", ".")

    letter_results_search = LOG_LETTER_VARNAME + r"\s*=\s*\$\{PRJ\}\/.*hresults\.log_letter.*"
    letter_results_repl = LOG_LETTER_VARNAME + f"={letter_results}"
    
    word_results_search = LOG_WORD_VARNAME + r"\s*=\s*\$\{PRJ\}\/.*hresults\.log_word.*"
    word_results_repl = LOG_WORD_VARNAME + f"={word_results}"

    trace_level_search = TRACE_LEVEL_VARNAME + r"\s*=\s*[0-9]+"
    trace_level_repl = TRACE_LEVEL_VARNAME + f"={trace_value}"

    threads_search = THREADS_VARNAME + r"\s*=\s*[0-9]+"
    threads_repl = THREADS_VARNAME + f"={num_threads}"
    
    options_file = get_options_file(subdirs)

    ## The commented out edit_file calls below are because they are
    ## currently unnecessary and interfere with multiprocessing on PACE
    edit_file(ip_search, ip_repl, options_file)
    edit_file(num_its_search, num_its_repl, options_file)
    edit_file(num_tri_its_search, num_tri_its_repl, options_file)
    edit_file(hmmdef_search, hmmdef_repl, options_file)
    edit_file(models_root_search, models_root_repl, options_file)
    edit_file(letter_results_search, letter_results_repl, options_file)
    edit_file(word_results_search, word_results_repl, options_file)
    edit_file(hedfile1_search, hedfile1_repl, options_file)
    edit_file(hedfile2_search, hedfile2_repl, options_file)
    edit_file(custom_silsp_search, custom_silsp_repl, options_file)
    edit_file(multi_process_search, multi_process_repl, options_file)
    edit_file(cross_word_search, cross_word_repl, options_file)
    edit_file(ngram_word_search, ngram_word_repl, options_file)
    edit_file(trace_level_search, trace_level_repl, options_file)
    edit_file(threads_search, threads_repl, options_file)
    edit_file(whole_word_search, whole_word_repl, options_file)
    edit_file(use_phrase_search, use_phrase_repl, options_file)
    
    # make models dir here
    make_dir(models_dir)
    
    print("##### Hyperparameters #####")
    run_subprocess(["grep", "^" + IP_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + NUM_ITS_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + NUM_TRI_ITS_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + HMMDEF_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + MODELS_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + LOG_LETTER_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + LOG_WORD_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + HEDFILE1_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + HEDFILE2_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + CUSTOM_SILSP_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + MULTI_PROCESS_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + CROSS_WORD_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + NGRAM_WORD_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + TRACE_LEVEL_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + THREADS_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + WHOLE_WORD_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + USE_PHRASE_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["head", "-n", "1", f"{hedfile1_local_file}"])
    print("#####\n")

def edit_htk_root_file_options(subdirs):
    options_file = get_options_file(subdirs)
    led_file_info = get_ledfile_info(subdirs)
    vector_dim = get_vector_dim(subdirs)
    
    # Handle triletter changes separately
    make_triletter_changes(subdirs)

    # grammarfile_root_search = GRAMMARFILE_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/grammar.*"
    # grammarfile_root_repl = GRAMMARFILE_ROOT_VARNAME + os.path.join("=${PRJ}", GRAMMAR_ROOT, subdirs)

    # dictfile_root_search = DICTFILE_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/dict.*"
    # dictfile_root_repl = DICTFILE_ROOT_VARNAME + os.path.join("=${PRJ}", DICT_ROOT, subdirs)
    # 
    # tokens_root_search = TOKENS_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/commands.*"
    # tokens_root_repl = TOKENS_ROOT_VARNAME + os.path.join("=${PRJ}", TOKENS_ROOT, subdirs)
    
    mlf_root_search = MLF_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/mlf.*"
    mlf_root_repl = MLF_ROOT_VARNAME + os.path.join("=${PRJ}", MLF_ROOT, subdirs)

    outputfile_root_search = OUTPUTFILE_ROOT_VARNAME + r"\s*=\s*\$\{PRJ\}\/output.*"
    outputfile_root_repl = OUTPUTFILE_ROOT_VARNAME + os.path.join("=${PRJ}", OUTPUT_ROOT, subdirs)

    ext_dir_search = EXT_DIR_VARNAME + r"\s*=\s*\$\{PRJ\}\/ext.*"
    ext_dir_repl = EXT_DIR_VARNAME + os.path.join("=${PRJ}", EXT_ROOT, subdirs)
    
    ledfile_uniq_search = LEDFILE_UNIQ_VARNAME + r"\s*=\s*.+"
    ledfile_uniq_repl = LEDFILE_UNIQ_VARNAME + f"={led_file_info}"

    hmmsil_search = HMMSIL_VARNAME + r"\s*=\s*\$HMM_TOPOLOGY_DIR\/3state-pca.+"
    hmmsil_repl = HMMSIL_VARNAME + f"=$HMM_TOPOLOGY_DIR/3state-pca{vector_dim}-sil-skip-loop"
    hmmsil_repl = hmmsil_repl + "-fullcov" if args.full_cov else hmmsil_repl

    hmmsp_search = HMMSP_VARNAME + r"\s*=\s*\$HMM_TOPOLOGY_DIR\/1state-pca.+"
    hmmsp_repl = HMMSP_VARNAME + f"=$HMM_TOPOLOGY_DIR/1state-pca{vector_dim}-sp"
    hmmsp_repl = hmmsp_repl + "-fullcov" if args.full_cov else hmmsp_repl

    vector_length_search = VECTOR_LENGTH_VARNAME + r"\s*=\s*[0-9]+"
    vector_length_repl = VECTOR_LENGTH_VARNAME + f"={vector_dim}"

    # edit_file(grammarfile_root_search, grammarfile_root_repl, options_file)
    # edit_file(dictfile_root_search, dictfile_root_repl, options_file)
    # edit_file(tokens_root_search, tokens_root_repl, options_file)
    edit_file(mlf_root_search, mlf_root_repl, options_file)
    edit_file(outputfile_root_search, outputfile_root_repl, options_file)
    edit_file(ext_dir_search, ext_dir_repl, options_file)
    edit_file(ledfile_uniq_search, ledfile_uniq_repl, options_file)
    edit_file(hmmsil_search, hmmsil_repl, options_file)
    edit_file(hmmsp_search, hmmsp_repl, options_file)
    edit_file(vector_length_search, vector_length_repl, options_file)

    print("##### Set root files #####")
    run_subprocess(["grep", "^" + GRAMMARFILE_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + DICTFILE_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + TOKENS_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + MLF_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + OUTPUTFILE_ROOT_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + EXT_DIR_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + LEDFILE_UNIQ_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + HMMSIL_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + HMMSP_VARNAME + r"\s*=\s*", options_file])
    run_subprocess(["grep", "^" + VECTOR_LENGTH_VARNAME + r"\s*=\s*", options_file])
    print("#####\n")
    
    grammar_dir = os.path.join(GRAMMAR_ROOT, subdirs)
    dict_dir = os.path.join(DICT_ROOT, subdirs)
    tokens_dir = os.path.join(TOKENS_ROOT, subdirs)
    mlf_dir = os.path.join(MLF_ROOT, subdirs)
    outputfile_dir = os.path.join(OUTPUT_ROOT, subdirs)
    ext_dir = os.path.join(EXT_ROOT, subdirs)
    
    print("##### Create HTK File Directories #####")
    make_dir(grammar_dir)
    make_dir(dict_dir)
    make_dir(tokens_dir)
    make_dir(mlf_dir)
    make_dir(outputfile_dir)
    make_dir(ext_dir)
    print("#####\n")

def test_model(ip, tc, num_its, num_tri_its, hmmdef, subdirs, trace_value):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef, trace_value=trace_value)
    
    log_dir = os.path.join(LOG_ROOT, subdirs)
    print("##### Creating Testing Log Dir #####")
    make_dir(log_dir)
    print("#####\n")

    log_file = os.path.join(log_dir, "output.log_" + name_ext + ".test_model")
    
    if args.test_model_path is None:
        _, new_model_path = get_model_path(subdirs, ip, tc, num_its, num_tri_its, hmmdef)
    else:
        new_model_path = args.test_model_path
    print(f"Model Dir: {new_model_path}")

    options_file = get_options_file(subdirs)
    test_data_file = get_test_data_file(subdirs)
    test_args = [TEST_SCRIPT, options_file, test_data_file, new_model_path]  # Last arg is for phrase grammar
    print("Test Command: " + ' '.join(test_args))
    print(f"Log file: {log_file}\n")

    if args.print_mode:
        run_subprocess(test_args)
    else:
        with open(log_file, "w") as f:
            subprocess.run(test_args, stdout=f, stderr=subprocess.STDOUT)

# Runs the train model script
def train_model(ip, tc, num_its, num_tri_its, hmmdef, subdirs, trace_value):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef, trace_value=trace_value)
    
    log_dir = os.path.join(LOG_ROOT, subdirs)
    print("##### Creating Training Log Dir #####")
    make_dir(log_dir)
    print("#####\n")
    
    log_file = os.path.join(log_dir, "output.log_" + name_ext)
    
    options_file = get_options_file(subdirs)
    train_args = [TRAIN_SCRIPT, options_file]
    
    print("Train Command: " + ' '.join(train_args))
    print(f"Output file: {log_file}\n")
    
    if args.print_mode:
        run_subprocess(train_args)
    else:
        with open(log_file, "w") as f:
            subprocess.run(train_args, stdout=f, stderr=subprocess.STDOUT)

def get_results(results_file, letter_results=True):
    with open(results_file, "r") as f:
        results_lines = f.readlines()
    
    results = None 
    corr_match = None
    acc_match = None
    sent_match = None
    for line in results_lines:
        if line.startswith("WORD: "):
            corr_match = re.search(r"Corr=-?[0-9]+\.[0-9]+", line).group(0)
            acc_match = re.search(r"Acc=-?[0-9]+\.[0-9]+", line).group(0)
        if line.startswith("SENT: "):
            sent_match = re.search(r"Correct=-?[0-9]+\.[0-9]+", line).group(0)
    
    if corr_match is not None and acc_match is not None:
        if letter_results:
            results = [corr_match.split('=')[1], acc_match.split('=')[1]]
        elif sent_match is not None:
            results = [corr_match.split('=')[1], acc_match.split('=')[1], sent_match.split('=')[1]]
        else:
            print("No sentence results found. Check results file for error.")
    else:
        print("No word/letter results found. Check results file for error.")
    return results

def add_results_to_csv(ip, tc, num_its, num_tri_its, hmmdef, subdirs):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef)
    letter_results_file, word_results_file = get_hresults_filepaths(name_ext, subdirs, ip)
    
    letter_results_file = os.path.join('.', *letter_results_file.split("/")[1:])
    word_results_file = os.path.join('.', *word_results_file.split("/")[1:])
    
    letter_results = get_results(letter_results_file, letter_results=True)
    word_results = get_results(word_results_file, letter_results=False)
    
    results = [letter_results_file]
    if letter_results is not None:
        results += letter_results
    else:
        results += ["NA", "NA"]
    
    if word_results is not None:
        results += word_results
    else:
        results += ["NA","NA","NA"]

    if os.path.exists(args.results_csv):
        with open(args.results_csv, 'a', newline='') as f:
            csvwriter = csv.writer(
                f, delimiter='|',
                quotechar='\\', quoting=csv.QUOTE_MINIMAL
            )
            csvwriter.writerow(results)
    else:
        with open(args.results_csv, 'w') as f:
            csvwriter = csv.writer(
                f, delimiter='|',
                quotechar='\\', quoting=csv.QUOTE_MINIMAL
            )
            csvwriter.writerow(['letter_results_file','letter_corr', 'letter_acc', 'word_corr', 'word_acc', 'sent_corr'])
            csvwriter.writerow(results)

def get_model_path(subdirs, ip, tc, num_its, num_tri_its, hmmdef):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef)  # Pass none for first arg because the model doesn't vary by grammar

    new_model_dir = os.path.join(MODELS_ROOT, subdirs)
    new_model_file = '_'.join([MODEL_MACROS_FILE, name_ext])
    new_model_path = os.path.join(new_model_dir, new_model_file)

    return new_model_dir, new_model_path

def save_model(ip, tc, num_its, num_tri_its, hmmdef, subdirs):
    curr_model_path = os.path.join(MODELS_ROOT, subdirs, f"hmm0.{num_its-1}", MODEL_MACROS_FILE)
    
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef)  # Pass none for first arg because the model doesn't vary by grammar
    new_model_dir, new_model_path = get_model_path(subdirs, ip, tc, num_its, num_tri_its, hmmdef)
    make_dir(new_model_dir)
    
    print(f"Current Model Dir: {curr_model_path}")
    print(f"New Model Dir: {new_model_path}")
    
    if os.path.exists(curr_model_path):
        shutil.copy(curr_model_path, new_model_path)
    else:
        print("Model wasn't created or is missing. Check the log file")

# Prepare data using scripts/prepare_files.sh. Not in use currently.
def prepare_data(data_file, label_file, subdirs):
    options_file = get_options_file(subdirs)
    prepare_command = [PREPARE_SCRIPT, options_file, data_file, label_file]
    
    print("##### Run prepare data #####")
    print(f"Prepare Data: {' '.join(prepare_command)}")
    print("#####\n")

    run_subprocess(prepare_command)

# TODO Standardize the output file naming and name ext (with trace ext)
# Note that grammar_type_arg is different from grammar_type.
# In this case grammar_type is hardcoded as grliwi, but it should be
# hardcoded everywhere
def gen_grammar(subdirs, label_file, grammar_type_arg='word'):
    if grammar_type_arg.startswith("letter"):
        grammar_file = "_".join([LETTER_GRAMMAR, "isolated"])
        if grammar_type_arg.endswith("_whole_word"):
            grammar_file = "_".join([grammar_file, "whole"])
    else:
        grammar_file = WORD_GRAMMAR
        if grammar_type_arg.endswith("_phrase_sksp"):
            grammar_file = "_".join([grammar_file, "phrase", "sksp"])
        elif grammar_type_arg.endswith("_sksp"):
            grammar_file = "_".join([grammar_file, "isolated", "sksp"])
        elif grammar_type_arg.endswith("_whole_word"):
            grammar_file = "_".join([grammar_file, "isolated", "whole"])
        else:
            grammar_file = "_".join([grammar_file, "isolated"])

    grammar_filepath = os.path.join(GRAMMAR_ROOT, subdirs, grammar_file)

    gen_grammar_args = ['python', GEN_GRAMMAR_SCRIPT]
    gen_grammar_args += ["--label_loc", label_file]
    gen_grammar_args += ["--grammar_file", grammar_filepath]

    print("Gen Grammar Command: " + ' '.join(gen_grammar_args))
    run_subprocess(gen_grammar_args)

# def clear_results_files(ip, tc, num_its, num_tri_its, hmmdef, subdirs, grammar_type):
def clear_results_files(ip, tc, num_its, num_tri_its, hmmdef, subdirs):
    name_ext = get_name_ext(tc, num_its, num_tri_its, hmmdef)
    letter_results_file, word_results_file = get_hresults_filepaths(name_ext, subdirs, ip)
    
    letter_results_file = os.path.join(*letter_results_file.split(os.path.sep)[1:])
    word_results_file = os.path.join(*word_results_file.split(os.path.sep)[1:])

    print("##### Clearing Results Files #####")
    with open(letter_results_file, 'w') as f:
        print(f"Cleared letter results")

    with open(word_results_file, 'w') as f:
        print(f"Cleared word results")
    print("#####\n")

if __name__ == "__main__":
    args = parse_args()
    check_args()
    
    print("##### Args #####")
    print(args)
    print("#####\n")
    
    arg_iter = product(
        args.ip_values,
        args.hmmdefs,
        args.tc,
        args.num_its,
        args.num_tri_its,
        args.trace_values,
        args.ngrams
    )
    
    for data_file in args.data_files:
        # TODO Write prepare files function
        subdirs = get_subdirectories(data_file)
        label_file = os.path.join('label', subdirs, 'label')
        
        _make_options_file(subdirs)
        edit_htk_root_file_options(subdirs)

        if args.prepare_data or args.prepare_data_only:
            prepare_data(data_file, label_file, subdirs)

            # Exit here after prepare_files and gen_grammar finish
            if args.prepare_data_only:
                exit(0)

        for arg_tup in arg_iter:
            ip = arg_tup[0]
            hmmdef = arg_tup[1]
            tc = arg_tup[2]
            num_its = arg_tup[3]
            num_tri_its = arg_tup[4]
            trace_value = arg_tup[5]
            ngram = arg_tup[6]
            
            edit_options(
                ip,
                tc,
                num_its,
                num_tri_its,
                hmmdef,
                subdirs,
                ngram,
                trace_value=trace_value,
            )
 
            if args.clear_hresults:
                clear_results_files(
                    ip,
                    tc,
                    num_its,
                    num_tri_its,
                    hmmdef,
                    subdirs,
                )

            if args.test_model:
                test_model(
                    ip,
                    tc,
                    num_its,
                    num_tri_its,
                    hmmdef,
                    subdirs,
                    trace_value
                )
            else:
                train_model(
                    ip,
                    tc,
                    num_its,
                    num_tri_its,
                    hmmdef,
                    subdirs,
                    trace_value
                )
            
                save_model(
                    ip,
                    tc,
                    num_its,
                    num_tri_its,
                    hmmdef,
                    subdirs,
                )

            if args.results_csv is not None:
                add_results_to_csv(
                    ip,
                    tc,
                    num_its,
                    num_tri_its,
                    hmmdef,
                    subdirs,
                )
            
            print()

