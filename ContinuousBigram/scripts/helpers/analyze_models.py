#!/usr/bin/env python3

import argparse
import logging
import json
import sys
import pandas as pd
import matplotlib.pyplot as plt

sys.path.append("/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts")

from itertools import takewhile
from tqdm import tqdm
from pathlib import Path
from utils import *

FILENAME_DELIM = "_"
logger = logging.getLogger(__name__)

global args

# maps analysis type to its required args
REQUIRED_ARGS = {
    "best_model": {"-gp"},
    "plot_scores": {},
}
HMMDEF_POS = 1
TRAIN_TYPE_POS = 5

def is_required(arg):
    for i,arg_passed in enumerate(sys.argv):
        if arg_passed in ["-at", "--analysis_type"]:
            if i+1 < len(sys.argv):
                return arg in REQUIRED_ARGS[sys.argv[i+1]]

def _parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "-rd", "--results_dir",
        type=Path,
        required=True,
        help="Path to results dir. It should contain multiple csvs with results. (not hresults files)",
    )

    parser.add_argument(
        "-at", "--analysis_type",
        type=str,
        required=True,
        choices=["best_model", "plot_scores"],
        help="type of model analysis to perform."
    )

    parser.add_argument(
        "-ds", "--dataset",
        type=str,
        default="supplemental_gen_drop-na_lininterp0",
        choices=["supplemental_gen_drop-na_lininterp0", "supplemental_gen_na-thr0.3_drop-na_lininterp0", "supplemental_gen_drop-na_lininterp1", "supplemental_gen_na-thr0.3_drop-na_lininterp1"],
        help="Dataset to get best model",
    )

    parser.add_argument(
        "-gp", "--grp_prefixes",
        type=str,
        nargs="+",
        choices=["pt","grp.rnd", "sd"],
        default=[],
        required=is_required("-gp"),
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
def get_grp_names_from_file(results_csv):
    csv_filepath_split = results_csv.stem.split(FILENAME_DELIM)
    logger.debug(f"Results CSV split: {csv_filepath_split=}")
    grp_names = []

    if not args.grp_prefixes:
        grp_names = ["null"]
    else:
        for grp_prefix in args.grp_prefixes:
            for component in csv_filepath_split:
                if component.startswith(grp_prefix):
                    grp_names.append(component)

    logger.debug(f"Extracted Group Name from results file: {grp_names=}")
    return grp_names

# gets model path from results path
def get_model_path(results_path):
    logger.debug(f"{results_path=}")
    results_relative = results_path.relative_to(RESULTS_ROOT)

    model_file = results_path.name.replace("hresults.log_letter", "newMacros")
    model_path = MODELS_ROOT / results_relative.parent / model_file

    logger.debug(f"{model_path=}")
    return model_path

# gathers results form csv files and adds some columns (grp_by, model_path, etc)
def gather_results(results_csvs):
    def add_model_path(row):
        logger.debug(row)
        results_path = Path(row["letter_results_file"])
        model_path = get_model_path(results_path)
        return str(model_path), model_path.is_file()
    
    def add_grp_names(row, grp_names=[]):
        return "_".join(grp_names)
    
    df_cols = ["grp_by","model_path","model_exists","letter_acc","word_acc","sent_corr"]
    df_chunks = []
    logger.debug(df_cols)
    
    for results_csv in tqdm(results_csvs):
        logger.info(f"Processing {results_csv}")
        df = pd.read_csv(results_csv, delimiter="|")
        logger.debug(f"After loading results csv: {df.shape=}")
        
        df["letter_results_file"] = df["letter_results_file"].astype("str")
        logger.debug(f"dataframe dtypes: {df.dtypes}")
        df = df.fillna(value=-1.0)
        df = df.loc[df.letter_results_file.str.contains('/' + args.dataset + '/')]
        
        if df.shape[0] == 0:
            continue
        
        df[["model_path", "model_exists"]] = df.apply(add_model_path, axis=1, result_type="expand")
        
        grp_names = get_grp_names_from_file(results_csv)
        df["grp_by"] = df.apply(
            add_grp_names,
            grp_names=grp_names,
            axis=1,
            result_type="expand"
        )
        df_chunks.append(df.copy())
    df = pd.concat(df_chunks, axis=0)
    df = df[df_cols].reset_index(drop=True)
    logger.debug(f"After all preprocessing: {df}")
    return df

# gets best rows for letter acc by grp_by column (defined 
# by grp_prefixes arg)
def get_best_rows(df):
    max_indices = df.groupby("grp_by")["letter_acc"].idxmax()
    logger.debug(max_indices)

    df = df.loc[max_indices]
    df = df.set_index("grp_by", drop=True)
    logger.debug(f"After max over groups (final df): {df}")

    return df

# writes json from the dataframe that has been restricted to max rows
def write_json(df):
    json_filename = FILENAME_DELIM.join([args.dataset] + args.grp_prefixes) + ".json"
    logger.info(f"Dumping best model to JSON {json_filename}")
    json_path = args.results_dir / json_filename
    
    with open(json_path, 'w') as f:
        json.dump(df.to_dict(orient='index'), f, indent=4)

# adds analysis cols to df. should be called by df.apply
def add_analysis_cols(row):
    hyperparams = str(Path(row.model_path).name).split("_")
    logger.debug(hyperparams)

    hmmdef = hyperparams[HMMDEF_POS]
    n_states = "".join(takewhile(str.isdigit, hmmdef))
    
    train_type = "default"
    if TRAIN_TYPE_POS < len(hyperparams):
        train_type = hyperparams[TRAIN_TYPE_POS]

    return n_states, train_type

def plot_col_by_cat(column, category):
    df.boxplot(column=column, by=category)
    plt.title(f"{column} by {category} Boxplot")
    plt.suptitle("")
    plt.ylabel("scores")

    fig_loc = args.results_dir / f"{column}_by_{category}_box.png"
    plt.savefig(fig_loc)
    plt.clf()

def analyze_scores(df):
    if (df["grp_by"] != "null").any():
        df_groups = df.groupby("grp_by")
        model_exists_by_group = df_groups["model_exists"].any()
        logger.info("Model Exists Count:")
        logger.info(model_exists_by_group.value_counts())
    
    plot_col_by_cat("letter_acc", "n_states")
    plot_col_by_cat("word_acc", "n_states")
    plot_col_by_cat("sent_corr", "n_states")

    plot_col_by_cat("letter_acc", "train_type")
    plot_col_by_cat("word_acc", "train_type")
    plot_col_by_cat("sent_corr", "train_type")
    
    plt.close()

if __name__ == "__main__":
    args = _parse_args()
    log_file = args.results_dir / "log.txt"
    setup_logger(
        log_file,
        log_level=logging.DEBUG if args.debug else logging.INFO,
        mode="a",
    )
    logger.info(args)
    
    results_csvs = list(args.results_dir.glob("*.csv"))
    df = gather_results(results_csvs)
    if args.analysis_type == "best_model":
        df = get_best_rows(df)
        write_json(df)
    elif args.analysis_type == "plot_scores":
        # df = df.drop("grp_by", axis=1)
        df[["n_states", "train_type"]] = df.apply(
            add_analysis_cols,
            axis=1,
            result_type="expand",
        )
        logger.debug(df)
        analyze_scores(df)

