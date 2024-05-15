import argparse
import os
import shutil
import numpy as np
from tqdm import tqdm

############### GENERAL HELPER FUNCTIONS ###############

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "--data_loc",
        type=str,
        required=True,
        help="Original data location (for all methods). Must end with /data (for naming convention)."
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
        help="Location for label files (only for fpl_threshold). Must end with /label (for naming convention)."
    )
    
    parser.add_argument(
        "--new_label_loc",
        type=str,
        default=None,
        help="Location to store new labels (only for fpl_threshold). Must end with /label (for naming convention)."
    )

    parser.add_argument(
        "--method",
        type=str,
        choices=["duplication", "interpolation", "fpl_threshold", "dim_select", "remove_z", "copy", "normalize", "neg_fpl_threshold"],
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
        help="Minimum number of frames per label (only for fpl_threshold method)."
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
def _check_args(args):
    args.data_loc = _rm_trailing_slash(args.data_loc)
    args.new_data_loc = _rm_trailing_slash(args.new_data_loc)
    args.label_loc = _rm_trailing_slash(args.label_loc)
    args.new_label_loc = _rm_trailing_slash(args.new_label_loc)
    
    data_path_list = [args.data_loc, args.new_data_loc]
    label_path_list = [args.label_loc, args.new_label_loc]
    
    for path in data_path_list:
        if not(path.endswith('/data')):
            raise ValueError("Must pass a data path ends with /data.")
    
    for path in label_path_list:
        if path is not None and not(path.endswith('/label')):
            raise ValueError("Must pass a label path ends with /label.")

    _make_dir(args.new_data_loc)
    if args.method.endswith("fpl_threshold"):
        if args.new_label_loc is None:
            raise ValueError("Must pass new label location for [neg]_fpl_threshold method.")
        _make_dir(args.new_label_loc)

############### DATA DUPLICATION FUNCTIONS ###############

def duplicate_frames(datafile, new_datafile, multiplier):
    with open(datafile, 'r') as df:
        frames = df.readlines()
        
    new_frames = []
    for frame in frames:
        new_frames.extend([frame] * multiplier)
    
    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(new_frames)

############### INTERPOLATION FUNCTIONS ###############

def _interpolate(frames):
    new_frames = []
    for i,_ in enumerate(frames[:-1]):
        frames_i = np.array(frames[i])
        frames_i_next = np.array(frames[i+1])
        frames_interp = ((frames_i + frames_i_next) / 2).tolist()

        new_frames.append(frames[i])
        new_frames.append(frames_interp)
        new_frames.append(frames[i+1])

    return new_frames

def interpolate_frames(datafile, new_datafile, num_interpolations):
    with open(datafile, 'r') as df:
        new_frames = df.readlines()
    
    for _ in range(num_interpolations):
        new_frames = _interpolate(new_frames)
    
    with open(new_datafile, 'w') as new_datafile:
        new_datafile.writelines(new_frames)

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

def copy(datafile, new_datafile):
    os.link(datafile, new_datafile)

if __name__ == "__main__":
    args = parse_args()
    print(args)
    _check_args(args)

    files = os.listdir(args.data_loc)
    
    for f in tqdm(files):
        datafile = os.path.join(args.data_loc, f)
        new_datafile = os.path.join(args.new_data_loc, f)
        
        if args.method == "duplication":
            duplicate_frames(datafile, new_datafile, args.multiplier)
        elif args.method == "interpolation":
            interpolate_frames(datafile, new_datafile, args.num_interpolations)
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
        elif args.method == "copy":
            copy(datafile, new_datafile)

