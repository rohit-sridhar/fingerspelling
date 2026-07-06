#!/usr/bin/env python3

import argparse
import logging
import json
import sys
import pandas as pd

sys.path.append("/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts")

from pathlib import Path
from utils import *

FILENAME_DELIM = "_"
logger = logging.getLogger(__name__)

global args

def _parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "-rd", "--results_dir",
        type=Path,
        required=True,
        help="Path to results dir. It should contain multiple csvs with results. (not hresults files)",
    )

    parser.add_argument(
        "-ds", "--dataset",
        type=str,
        default="supplemental_gen_drop-na_lininterp0",
        choices=["supplemental_gen_drop-na_lininterp0", "supplemental_gen_na-thr0.3_drop-na_lininterp0", "supplemental_gen_drop-na_lininterp1", "supplemental_gen_na-thr0.3_drop-na_lininterp1"],
        help="Dataset to get best model",
    )

    parser.add_argument(
        "-pgp", "--pt_grp_prefix",
        type=str,
        default="pt",
        choices=["pt","grp.rnd"],
        help="Prefix to determine participant grouping type to get best model over",
    )
    parser.add_argument(
        "-dbg", "--debug",
        action="store_true",
        help="Run in debug mode (verbose)",
    )

    return parser.parse_args()

# This function extract the group name from the csv
# filename by splitting it searching the components
# for the grp name prefix passed as an arg.
def get_grp_name_from_file(results_csv):
    csv_filepath_split = results_csv.stem.split(FILENAME_DELIM)
    logger.debug(f"Results CSV split: {csv_filepath_split=}")
    grp_name = None

    for component in csv_filepath_split:
        if component.startswith(args.pt_grp_prefix):
            grp_name = component

    logger.debug(f"Extracted Group Name from results file: {grp_name=}")
    return grp_name

def get_model_path(results_path):
    logger.debug(f"{results_path=}")
    results_relative = results_path.relative_to(RESULTS_ROOT)

    model_file = results_path.name.replace("hresults.log_letter", "newMacros")
    model_path = MODELS_ROOT / results_relative.parent / model_file
    # model_path_parts = list(results_path.parts)
    # model_path_parts[results_path.parts.index(RESULTS_ROOT[:-1])] = MODELS_ROOT[:-1]
    # model_path_parts[-1] = results_path.suffix.replace(".log_letter", "newMacros")

    logger.debug(f"{model_path=}")
    return model_path

def get_best_word_acc_by_csv(results_csvs):
    results_dict = {}

    for results_csv in results_csvs:
        logger.info(f"Processing {results_csv}")
        df = pd.read_csv(results_csv, delimiter="|")
        logger.debug(f"After loading dataset: {df.shape=}")
        
        df = df.fillna(value=-1.0)
        df = df.loc[df.letter_results_file.str.contains('/' + args.dataset + '/')]
        logger.debug(f"After dataset filtering: {df.shape=}")
        
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
    logger.info(f"Dumping best model to JSON {json_filename}")
    json_path = args.results_dir / json_filename
    
    with open(json_path, 'w') as f:
        json.dump(results_dict, f, indent=4)

if __name__ == "__main__":
    args = _parse_args()
    log_file = args.results_dir / "log.txt"
    setup_logger(
        log_file,
        log_level=logging.DEBUG if args.debug else logging.INFO,
        mode="a",
    )
    logger.info(args)
    
    results_csvs = args.results_dir.glob("*.csv")
    results_dict = get_best_word_acc_by_csv(results_csvs)
    
    write_json(results_dict)
    
