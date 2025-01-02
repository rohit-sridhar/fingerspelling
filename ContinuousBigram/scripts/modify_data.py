import argparse
import os
import shutil
import random

import numpy as np
import pandas as pd

from tqdm import tqdm
from math import ceil
from utils import *

global args

############### GENERAL HELPER FUNCTIONS ###############

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "--data_loc",
        type=str,
        required=True,
        help="Original data location (for all methods). Must end with /data (for naming convention), unless method is import."
    )
    
    parser.add_argument(
        "--new_data_loc",
        type=str,
        required=True,
        help="Location to store new data (for all methods). Must end with /data (for naming convention)."
    )
    
    parser.add_argument(
        "--label_loc",
        type=str,
        default="./label/label",
        help="Location for label files (only for fpl_threshold, interpolation, threshold_duplication, duplication methods). Must end with /label (for naming convention)."
    )
    
    parser.add_argument(
        "--new_label_loc",
        type=str,
        default=None,
        help="Location to store new labels (only for fpl_threshold, import). Must end with /label (for naming convention)."
    )
    
    parser.add_argument(
        "--commands_file",
        type=str,
        default="commands/commands_tri_internal",
        help="File with triletter labels (only for match_triletters method)."
    )

    parser.add_argument(
        "--char_map_file",
        type=str,
        default="/data/parquet/asl-fingerspelling/supplemental_character_to_prediction_index.json",
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
        help="Multiplier to add new frames (only for duplication method)."
    )

    parser.add_argument(
        "--num_interpolations",
        type=int,
        default=3,
        help="Number of interpolations (only for interpolation)."
    )

    parser.add_argument(
        "--fpl_threshold",
        type=int,
        default=4,
        help="Minimum number of frames per label (only for fpl_threshold, threshold_duplication method)."
    )

    parser.add_argument(
        "--dupe_all",
        action="store_true",
        help="Duplicate all of the frames, as opposed to only those within the threshold (only for duplication method)."
    )

    parser.add_argument(
        "--interp_all",
        action="store_true",
        help="Interpolate all of the frames, as opposed to only those within the threshold (only for interpolation method)."
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=7268,
        help="Seed for randomization (only for sample method)."
    )

    parser.add_argument(
        "--sample_ratio",
        type=float,
        default=None,
        help="Seed for randomization (only for sample method)."
    )
    
    parser.add_argument(
        "--dims_kept",
        type=int,
        nargs = '+',
        default = [0,3,4,7,8,11,12,15,16,19],
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

# Checks args and makes modifications.
def _check_args():
    args.data_loc = _rm_trailing_slash(args.data_loc)
    args.new_data_loc = _rm_trailing_slash(args.new_data_loc)
    args.label_loc = _rm_trailing_slash(args.label_loc)
    args.new_label_loc = _rm_trailing_slash(args.new_label_loc)
    
    data_path_list = [args.data_loc, args.new_data_loc]
    label_path_list = [args.label_loc, args.new_label_loc]
    
    if args.method != "import":
        for path in data_path_list:
            if not(path.endswith('/data')):
                raise ValueError("Must pass a data path ends with /data.")
    
    for path in label_path_list:
        if path is not None and not(path.endswith('/label')):
            raise ValueError("Must pass a label path ends with /label.")

    if args.method == "match_triletters" and args.commands_file is None:
        raise ValueError("Must pass triletter commands file for match triletters.")

    _make_dir(args.new_data_loc)
    if args.method in ("match_triletters", "import", "sample", "fpl_threshold", "neg_fpl_threshold"):
        if args.new_label_loc is None:
            raise ValueError("Must pass new label location for [neg]_fpl_threshold/match_triletters/import/sample methods.")
        _make_dir(args.new_label_loc)
    
    if args.method == "sample":
        if args.sample_ratio is None:
            raise ValueError("Must pass in a sample ratio when using the sample method.")
        if args.sample_ratio < 0 or args.sample_ratio > 1:
            raise ValueError("Sample Ratio must be between 0 and 1 (inclusive).")


############### DATA DUPLICATION FUNCTIONS ###############

def duplicate_frames(datafile, label_file, new_datafile, multiplier, dupe_all):
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

def threshold_duplicate_frames(datafile, label_file, new_datafile, fpl_threshold):
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

def interpolate_frames(datafile, label_file, new_datafile, num_interpolations, interp_all):
    with open(datafile, 'r') as df:
        frames = df.readlines()
    
    with open(label_file, 'r') as f:
        labels = f.readlines()
    
    for _ in range(num_interpolations):
        if interp_all or len(frames) / len(labels) < 2 ** num_interpolations:
            frames = _interpolate(frames)
    
    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(frames)

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

############### MATCH TRILETTER FUNCTIONS ###############
def copy(datafile, new_datafile):
    os.link(datafile, new_datafile)

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

def import_data():
    df = pd.read_pickle(args.data_loc)
    print(df)
    dl_seq_ids = df.index.to_list()
    
    if os.path.basename(args.char_map_file).startswith("supplemental"):
        supplemental = True
    else:
        supplemental = False
    
    print(f"Supplemental: {supplemental}")
    idx_char_map = get_idx_char_map(args.char_map_file)

    for seq_id in tqdm(dl_seq_ids):
        new_datafile = os.path.join(args.new_data_loc, str(seq_id))
        new_labelfile = os.path.join(args.new_label_loc, str(seq_id) + ".lab")
        
        landmarks = get_landmarks(df, seq_id)
        phrase = get_labels(df, seq_id, idx_char_map, supplemental)
        
        with open(new_datafile, 'w') as f:
            f.writelines(landmarks)
        
        with open(new_labelfile, 'w') as f:
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
    

if __name__ == "__main__":
    args = parse_args()
    print(args)
    _check_args()
    random.seed(args.seed)

    if args.method == "import":
        import_data()
        exit(0)

    if args.method == "match_triletters":
        commands_triletters = read_triletters_from_commands()
     
    files = os.listdir(args.data_loc)
    for f in tqdm(files):
        datafile = os.path.join(args.data_loc, f)
        new_datafile = os.path.join(args.new_data_loc, f)
        
        if args.method == "duplication":
            label_file = os.path.join(args.label_loc, f + '.lab')
            duplicate_frames(datafile, label_file, new_datafile, args.multiplier, args.dupe_all)
        if args.method == "threshold_duplication":
            label_file = os.path.join(args.label_loc, f + '.lab')
            threshold_duplicate_frames(datafile, label_file, new_datafile, args.fpl_threshold)
        elif args.method == "interpolation":
            label_file = os.path.join(args.label_loc, f + '.lab')
            interpolate_frames(datafile, label_file, new_datafile, args.num_interpolations, args.interp_all)
        elif args.method == "fpl_threshold":
            label_file = os.path.join(args.label_loc, f + '.lab')
            new_label_file = os.path.join(args.new_label_loc, f + '.lab')
            fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, args.fpl_threshold)
        elif args.method == "neg_fpl_threshold":
            label_file = os.path.join(args.label_loc, f + '.lab')
            new_label_file = os.path.join(args.new_label_loc, f + '.lab')
            neg_fpl_threshold_files(datafile, label_file, new_datafile, new_label_file, args.fpl_threshold)
        elif args.method == "dim_select":
            dim_select(datafile, new_datafile, args.dims_kept)
        elif args.method == "remove_z":
            remove_z(datafile, new_datafile)
        elif args.method == "match_triletters":
            label_file = os.path.join(args.label_loc, f + '.lab')
            new_label_file = os.path.join(args.new_label_loc, f + '.lab')
            if match_triletters(datafile, label_file, commands_triletters):
                copy(datafile, new_datafile)
                copy(label_file, new_label_file)
        elif args.method == "sample":
            label_file = os.path.join(args.label_loc, f + '.lab')
            new_label_file = os.path.join(args.new_label_loc, f + '.lab')
            sample_data(datafile, label_file, new_datafile, new_label_file, args.sample_ratio)

