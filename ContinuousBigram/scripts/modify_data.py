import argparse
import os
import sys
import shutil
import random

import numpy as np
import pandas as pd

from tqdm import tqdm
from math import ceil
from utils import *

global args

############### GENERAL HELPER FUNCTIONS ###############

# This helper resticts which args are required through
# args passed to another argname
def required_by_set(argname, list_to_search):
    try:
        method_idx = sys.argv.index(argname) + 1
    except ValueError:
        method_idx = 0  # If --help is passed, this prevents an error
    return sys.argv[method_idx] in list_to_search

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--import_data_loc",
        type=str,
        required=required_by_set("--method", {"import"}),
        help="Use with the import method only. Defines original location for imported data."
    )

    parser.add_argument(
        "--data_loc",
        type=str,
        required=required_by_set("--method", DATA_LOC_REQUIRED_METHODS),
        help="Original data location (for all methods except word_level and import). " + \
                "Must end with /data (for naming convention), " + \
                "unless method is import. Used for label loc."
    )
    
    parser.add_argument(
        "--new_data_loc",
        type=str,
        required=required_by_set("--method", NEW_DATA_LOC_REQUIRED_METHODS),
        help="Location to store new data (for all methods except word_level). " + \
                "Must end with /data (for naming convention). " + \
                "Subdirs passed here are used for new label loc."
    )
    
    parser.add_argument(
        "--label_loc",
        type=str,
        required=required_by_set("--method", LABEL_LOC_REQUIRED_METHODS),
        help="Location for label files (only for word_level methods). " + \
                "Must end with /label (for naming convention)."
    )
    
    parser.add_argument(
        "--new_label_loc",
        type=str,
        required=required_by_set("--method", NEW_LABEL_LOC_REQUIRED_METHODS),
        help="Location to store new labels (only for word_level methods). " + \
                "Must end with /label (for naming convention)."
    )
    
    parser.add_argument(
        "--commands_file",
        type=str,
        default="commands/commands_tri_internal",
        required=required_by_set("--method", {"match_triletters"}),
        help="File with triletter labels (only for match_triletters method)."
    )

    parser.add_argument(
        "--char_map_file",
        type=str,
        default="/data/parquet/asl-fingerspelling/supplemental_character_to_prediction_index.json",
        required=required_by_set("--method", {"import"}),
        help="Maps characters to indices and vice versa (only for import method)."
    )

    parser.add_argument(
        "--method",
        type=str,
        choices=MODIFY_DATA_METHODS,
        required=True,
        help="Method for modifying data."
    )

    parser.add_argument(
        "--multiplier",
        type=int,
        default=5,
        required=required_by_set("--method", {"duplication"}),
        help="Multiplier to add new frames (only for duplication method)."
    )

    parser.add_argument(
        "--num_interpolations",
        type=int,
        default=3,
        required=required_by_set("--method", {"interpolation"}),
        help="Number of interpolations (only for interpolation)."
    )

    parser.add_argument(
        "--fpl_threshold",
        type=int,
        default=4,
        required=required_by_set("--method", {"fpl_threshold", "threshold_duplication"}),
        help="Minimum number of frames per label (only for fpl_threshold, threshold_duplication method)."
    )

    parser.add_argument(
        "--dupe_all",
        action="store_true",
        required=required_by_set("--method", {"duplication"}),
        help="Duplicate all of the frames, as opposed to only those within the threshold (only for duplication method)."
    )

    parser.add_argument(
        "--interp_all",
        action="store_true",
        required=required_by_set("--method", {"interpolation"}),
        help="Interpolate all of the frames, as opposed to only those within the threshold (only for interpolation method)."
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=7268,
        required=required_by_set("--method", {"sample"}),
        help="Seed for randomization (only for sample method)."
    )

    parser.add_argument(
        "--sample_ratio",
        type=float,
        default=None,
        required=required_by_set("--method", {"sample"}),
        help="Seed for randomization (only for sample method)."
    )
    
    parser.add_argument(
        "--dims_kept",
        type=int,
        nargs = '+',
        default = [0,3,4,7,8,11,12,15,16,19],
        required=required_by_set("--method", {"dim_select"}),
        help="Dimensions to keep (int between 0 to 19; only for dim_select). Subtract MP by 1 (due to wrist centering)."
    )
    
    return parser.parse_args()

# Make dir and overwrite if path exists already
def _make_dir(dir_loc):
    if os.path.exists(dir_loc):
        shutil.rmtree(dir_loc)
    os.makedirs(dir_loc)

# Remove trailing slash from a path
def _rm_trailing_slash(path):
    if path is not None and path.endswith('/'):
        return path[:-1]
    else:
        return path

# Get data/label paths and new data/label paths
def get_data_label_paths(subdirs):
    return os.path.join('data', subdirs, 'data')

# Checks args and makes modifications.
def _check_args():
    data_loc, label_loc, new_data_loc, new_label_loc = None, None, None, None

    if args.method in DATA_LOC_REQUIRED_METHODS:
        data_loc = _rm_trailing_slash(args.data_loc)
        if data_loc is None or not(data_loc.endswith('/data')):
            raise ValueError("Must pass a data path that ends with /data.")
        
        subdirs = get_subdirectories(data_loc)
        label_loc = os.path.join('label', subdirs, 'label')

    if args.method in LABEL_LOC_REQUIRED_METHODS:
        label_loc = _rm_trailing_slash(args.label_loc)
        if label_loc is None or not(label_loc.endswith('/label')):
            raise ValueError("Must pass a label path ends with /label.")
        
        subdirs = get_subdirectories(label_loc)
        data_loc = os.path.join('label', subdirs, 'label')
        
    if args.method in NEW_DATA_LOC_REQUIRED_METHODS:
        new_data_loc = _rm_trailing_slash(args.new_data_loc)
        if new_data_loc is None or not(new_data_loc.endswith('/data')):
            raise ValueError("Must pass a new data path that ends with /data.")
        
        new_subdirs = get_subdirectories(new_data_loc)
        new_label_loc = os.path.join('label', new_subdirs, 'label')

    if args.method in NEW_LABEL_LOC_REQUIRED_METHODS:
        new_label_loc = _rm_trailing_slash(args.new_label_loc)
        if new_label_loc is None or not(new_label_loc.endswith('/label')):
            raise ValueError("Must pass new label location for [neg]_fpl_threshold/match_triletters/import/sample methods. It must end with /label.")
        
        new_subdirs = get_subdirectories(new_label_loc)
        new_data_loc = os.path.join('label', new_subdirs, 'label')
    
    _make_dir(new_label_loc)
    _make_dir(new_data_loc)
    
    if args.method == "match_triletters" and args.commands_file is None:
        raise ValueError("Must pass triletter commands file for match triletters.")
    
    if args.method == "sample":
        if args.sample_ratio is None:
            raise ValueError("Must pass in a sample ratio when using the sample method.")
        if args.sample_ratio < 0 or args.sample_ratio > 1:
            raise ValueError("Sample Ratio must be between 0 and 1 (exclusive).")
    
    return data_loc, new_data_loc, label_loc, new_label_loc


############### DATA DUPLICATION FUNCTIONS ###############

def duplicate_frames(datafile, label_file, new_datafile, new_label_file, multiplier, dupe_all):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as f:
        labels = f.readlines()
    
    new_frames = []
    
    if dupe_all or len(frames) / len(labels) < multiplier:
        for frame in frames:
            new_frames.extend([frame] * multiplier)
    else:
        new_frames = frames

    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(new_frames)
    os.link(label_file, new_label_file)

def threshold_duplicate_frames(datafile, label_file, new_datafile, new_label_file, fpl_threshold):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    if len(frames) == 0:
        return

    with open(label_file, 'r') as f:
        labels = f.readlines()
    
    new_frames = []
    if len(frames) / len(labels) < fpl_threshold:
        total_frames = len(labels) * fpl_threshold
        multiplier = ceil(total_frames / len(frames))

        for frame in frames:
            new_frames.extend([frame] * multiplier)
    else:
        new_frames = frames
    
    print(f"Old: {len(frames)} New: {len(new_frames)} labels: {len(labels)}")
    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(new_frames)
    os.link(label_file, new_label_file)
    

############### INTERPOLATION FUNCTIONS ###############

def to_numpy(frame):
    frame = frame.split("  ")
    frame = np.array([float(landmark) for landmark in frame])

    return frame

def _interpolate(frames):
    new_frames = []
    for i,_ in enumerate(frames[:-1]):
        frames_i = to_numpy(frames[i])
        frames_i_next = to_numpy(frames[i+1])
        
        frames_interp = ((frames_i + frames_i_next) / 2).tolist()
        frames_interp = "  ".join([str(round(landmark, 6)) for landmark in frames_interp])

        new_frames.append(frames[i])
        new_frames.append(frames_interp + "\n")
    
    new_frames.append(frames[-1])
    return new_frames

def interpolate_frames(datafile, label_file, new_datafile, new_label_file, num_interpolations, interp_all):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as f:
        labels = f.readlines()
    
    for _ in range(num_interpolations):
        if interp_all or len(frames) / len(labels) < 2 ** num_interpolations:
            frames = _interpolate(frames)
    
    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(frames)
    os.link(label_file, new_label_file)

############### FPL THRESHOLD FUNCTIONS ###############

def fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, threshold):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as lab:
        labels = lab.readlines()

    if len(frames) / len(labels) >= threshold:
        os.link(datafile, new_datafile)
        os.link(label_file, new_label_file)

############### NEG FPL THRESHOLD FUNCTIONS ###############

def neg_fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, threshold):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as lab:
        labels = lab.readlines()

    if len(frames) / len(labels) < threshold:
        os.link(datafile, new_datafile)
        os.link(label_file, new_label_file)

############### DIM SELECT FUNCTIONS ###############

def _select_from_frame(frame, dims):
    frame = frame.strip().split('  ')
    new_frame = []
    
    for dim in dims:
        i = dim*3
        new_frame.extend([frame[i], frame[i+1], frame[i+2]])
    
    new_frame[-1] += '\n'
    new_frame = '  '.join(new_frame)
    return new_frame

def dim_select(datafile, new_datafile, dims):
    with open(datafile, 'r') as f:
        frames = f.readlines()
    
    new_frames = []
    for frame in frames:
        new_frame = _select_from_frame(frame, dims)
        new_frames.append(new_frame)

    with open(new_datafile, 'w') as f:
        f.writelines(new_frames)
    os.link(label_file, new_label_file)

############### REMOVE Z FUNCTIONS ###############
# Does not check to see if Z coordinates already removed
def _remove_z_from_frame(frame):
    frame = frame.strip().split('  ')
    new_frame = []
    
    for i in range(0, len(frame), 3):
        new_frame.extend([frame[i], frame[i+1]])

    new_frame[-1] += '\n'
    new_frame = '  '.join(new_frame)
    return new_frame

def remove_z(datafile, new_datafile):
    with open(datafile, 'r') as f:
        frames = f.readlines()

    new_frames = []
    for frame in frames:
        new_frame = _remove_z_from_frame(frame)
        new_frames.append(new_frame)

    with open(new_datafile, 'w') as f:
        f.writelines(new_frames)
    os.link(label_file, new_label_file)

############### MATCH TRILETTER FUNCTIONS ###############
def read_triletters_from_commands():
    with open(args.commands_file, "r") as f:
        triletters = f.readlines()
    
    triletters = set([triletter.strip() for triletter in triletters])
    
    return triletters

def match_triletters(datafile, label_file, commands_triletters):
    tokens = collect_tokens(label_file)
    
    label_triletters = get_triletters(tokens)
    label_triletters = set(label_triletters)

    return label_triletters.issubset(commands_triletters)

############### IMPORT DATA FUNCTIONS ###############
def get_landmarks(df, seq_id):
    landmarks = np.array(df.loc[seq_id].all_landmarks) * 100
    landmarks = landmarks[1:,:] - landmarks[:-1,:]
    landmarks = landmarks.tolist()
    
    landmarks = [[str(round(coord, 6)) for coord in landmark] for landmark in landmarks]
    landmarks = ["  ".join(landmark) + "\n" for landmark in landmarks]
    
    return landmarks

def get_labels(df, seq_id, idx_char_map, supplemental=True):
    idx_labels = np.array(df.loc[seq_id].phrase).tolist()
    phrase = []

    for idx in idx_labels:
        if (idx == 27 and supplemental) or (idx == 59):
            phrase.append(ENTER + "\n")
        elif (idx == 28 and supplemental) or (idx == 60):
            phrase.append(EXIT + "\n")
        elif idx == 0:
            phrase.append(SPACE + "\n")
        elif (idx == 30 and supplemental) or (idx == 61):
            print("OH NO!")
        else:
            phrase.append(idx_char_map[idx] + "\n")
    
    return phrase

def import_data(new_data_loc, new_label_loc):
    df = pd.read_pickle(args.import_data_loc)
    dl_seq_ids = df.index.to_list()
    
    if os.path.basename(args.char_map_file).startswith("supplemental"):
        data_path = SUPP_DATA_FILES
        label_path = SUPP_LABEL_FILES
        supplemental = True
    else:
        data_path = ALL_DATA_PATH
        label_path = ALL_LABEL_PATH
        supplemental = False
    
    idx_char_map = get_idx_char_map(args.char_map_file)

    for seq_id in tqdm(dl_seq_ids):
        new_datafile = os.path.join(new_data_loc, str(seq_id))
        new_label_file = os.path.join(new_label_loc, str(seq_id) + ".lab")
        
        datafile = os.path.join(data_path, str(seq_id))
        label_file = os.path.join(label_path, str(seq_id) + ".lab")

        if os.path.exists(datafile) and os.path.exists(label_file):
            os.link(datafile, new_datafile)
            os.link(label_file, new_label_file)
        else:
            landmarks = get_landmarks(df, seq_id)
            phrase = get_labels(df, seq_id, idx_char_map, supplemental)
            
            with open(new_datafile, 'w') as f:
                f.writelines(landmarks)
            
            with open(new_label_file, 'w') as f:
                f.writelines(phrase)

############### SAMPLE DATA FUNCTIONS ###############
def sample_data(datafile, label_file, new_datafile, new_label_file, sample_ratio):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as lab:
        labels = lab.readlines()

    if random.random() < sample_ratio:
        os.link(datafile, new_datafile)
        os.link(label_file, new_label_file)
    
############### WORD LEVEL FUNCTIONS ###############
def word_level(label_file, new_label_file):
    with open(label_file, 'r') as lab:
        label = lab.readlines()
    
    new_phrase = [label[0]]
    
    for i,char in enumerate(label[1:-1], 1):
        char2 = char.strip()
        next_char = label[i+1]

        if ord('a') <= ord(char2) <= ord('z') and next_char not in (SPACE+'\n', EXIT+'\n'):
            new_phrase.append(char2)
        else:
            new_phrase.append(char)
    
    new_phrase.append(label[-1])
    new_phrase = ''.join(new_phrase)

    with open(new_label_file, 'w') as f:
        f.write(new_phrase)
    
def get_file_seq_ids(data_loc):
    if args.method in LABEL_LOC_REQUIRED_METHODS:
        files = os.listdir(label_loc)
    else:
        files = os.listdir(data_loc)
    return files

if __name__ == "__main__":
    args = parse_args()
    print(args)

    data_loc, new_data_loc, label_loc, new_label_loc = _check_args()
    random.seed(args.seed)

    if args.method == "import":
        import_data(new_data_loc, new_label_loc)
        sys.exit()

    if args.method == "match_triletters":
        commands_triletters = read_triletters_from_commands()
    
    files = get_file_seq_ids(data_loc)
    for f in tqdm(files):
        datafile = os.path.join(data_loc, f)
        new_datafile = os.path.join(new_data_loc, f)
        
        label_file = os.path.join(label_loc, f + '.lab')
        new_label_file = os.path.join(new_label_loc, f + '.lab')

        if args.method == "duplication":
            duplicate_frames(datafile, label_file, new_datafile, new_label_file, args.multiplier, args.dupe_all)
        if args.method == "threshold_duplication":
            threshold_duplicate_frames(datafile, label_file, new_datafile, new_label_file, args.fpl_threshold)
        elif args.method == "interpolation":
            interpolate_frames(datafile, label_file, new_datafile, new_label_file, args.num_interpolations, args.interp_all)
        elif args.method == "fpl_threshold":
            fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, args.fpl_threshold)
        elif args.method == "neg_fpl_threshold":
            neg_fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, args.fpl_threshold)
        elif args.method == "dim_select":
            dim_select(datafile, label_file, new_datafile, new_label_file, args.dims_kept)
        elif args.method == "remove_z":
            remove_z(datafile, label_file, new_datafile, new_label_file)
        elif args.method == "match_triletters":
            if match_triletters(datafile, label_file, commands_triletters):
                os.link(datafile, new_datafile)
                os.link(label_file, new_label_file)
        elif args.method == "sample":
            sample_data(datafile, label_file, new_datafile, new_label_file, args.sample_ratio)
        elif args.method == "word_level":
            word_level(label_file, new_label_file)

