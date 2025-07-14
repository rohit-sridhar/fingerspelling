#!/opt/conda/bin/python

import argparse
import json
import sys
import pandas as pd

sys.path.append("/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts")

from pathlib import Path
from utils import *

FILENAME_DELIM = "_"

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "-rd", "--results_dir",
        type=Path,
        required=True,
        help="Path to results dir. It should contain multiple csvs with results. (not hresults files)"
    )

    parser.add_argument(
        "-ds", "--dataset",
        type=str,
        default="supplemental_gen_drop-na",
        choices=["supplemental_gen_drop-na", "supplemental_gen_drop-na_lininterp1", "supplemental_gen_na-thr0.3_drop-na", "supplemental_gen_na-thr0.3_drop-na_lininterp1", "supplemental_gen_na-thr0.5_drop-na", "supplemental_gen_na-thr0.5_drop-na_lininterp1", "supplemental_gen_drop-na_lininterp0", "supplemental_gen_na-thr0.3_drop-na_lininterp0", "supplemental_gen_na-thr0.5_drop-na_lininterp0"],
        help="Prefix to determine participant grouping type"
    )

    parser.add_argument(
        "-pgp", "--pt_grp_prefix",
        type=str,
        default="pt",
        choices=["pt","grp.rnd"],
        help="Prefix to determine participant grouping type"
    )

    return parser.parse_args()

# This function extract the group name from the csv
# filename by splitting it searching the components
# for the grp name prefix passed as an arg.
def get_grp_name_from_file(results_csv):
    csv_filepath_split = results_csv.stem.split(FILENAME_DELIM)
    grp_name = None

    for component in csv_filepath_split:
        if component.startswith(args.pt_grp_prefix):
            grp_name = component

    return grp_name

def get_model_path(results_path):
    model_path_parts = list(results_path.parts)
    model_path_parts[results_path.parts.index(RESULTS_ROOT[:-1])] = MODELS_ROOT[:-1]
    model_path_parts[-1] = results_path.suffix.replace(".log_letter", "newMacros")

    model_path = Path(*model_path_parts)
    return model_path

def get_best_word_acc_by_csv(results_csvs):
    results_dict = {}

    for results_csv in results_csvs:
        df = pd.read_csv(results_csv, delimiter="|")
        df = df.fillna(value=-1.0)
        df = df.loc[df.letter_results_file.str.contains('/' + args.dataset + '/')]
        
        if df.shape[0] == 0:
            continue

        best_row = df.word_acc.argmax()
        results_path = Path(df.iloc[best_row].letter_results_file)
        grp_name = get_grp_name_from_file(results_csv)
        
        model_path = get_model_path(results_path)
        results_dict[grp_name] = {
            "model_path": str(model_path),
            "model_exists": model_path.is_file(),
            "letter_acc": df.iloc[best_row].letter_acc,
            "word_acc": df.iloc[best_row].word_acc,
            "sent_corr": df.iloc[best_row].sent_corr
        }

    return results_dict

def write_json(results_dict):
    json_filename = FILENAME_DELIM.join([args.dataset, args.pt_grp_prefix]) + ".json"
    json_path = args.results_dir.joinpath(json_filename)
    
    with open(json_path, 'w') as f:
        json.dump(results_dict, f, indent=4)

if __name__ == "__main__":
    args = parse_args()
    
    results_csvs = args.results_dir.glob("*.csv")
    results_dict = get_best_word_acc_by_csv(results_csvs)

    write_json(results_dict)

