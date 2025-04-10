import math
import random

import pandas as pd
from pyarrow import parquet as pq
from pathlib import Path

# from model import *
from constants import *

import re
import os
import shutil
import argparse

import matplotlib.pyplot as plt
import matplotlib.animation as animation

import numpy as np

# TODO Add proper relative import later
import sys
sys.path.append('../scripts')

from utils import *

fps = 30

# DATA FORMATS
# CARTESIAN_UNPACKED: [x0, x1, x2, ..., x20, y0, y1, ..., y20, z0, z1, ..., z20]
# CARTESIAN_COLLATED: [x0, y0, z0, ..., x20, y20, z20]
# CARTESIAN_TABLE: [[x0, y0, z0], [x1, y1, z1], ..., [x20, y20, z20]]
# POLAR: data converted to angular format
CARTESIAN_UNPACKED = 0
CARTESIAN_COLLATED = 1
CARTESIAN_TABLE = 2
POLAR = 3

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("--pt_id", type=str, default=None, help="Participant ID.")
    parser.add_argument("--parquet_file", type=Path, help="Parquet file with data to visualize.")
    parser.add_argument("--metadata_file", type=Path, help="Path to metadata for parquet file.")
    parser.add_argument("--verbose", action="store_true", help="Print more information.")

    return parser.parse_args()
    
def load_parquet(filename) -> pd.DataFrame:
    print(filename)
    parquet_array = pq.read_table(filename, columns=PARQUET_FEATURE_LIST, memory_map=True).to_pandas()
    return parquet_array

def render(data, filename, wireframe=True):
    x_features = [i for i in range(0, 21)]
    y_features = [i for i in range(21, 42)]
    z_features = [i for i in range(42, 63)]

    last_good_frame = 0
    repeated = data[:]
    
    for i, frame in enumerate(data):
        if not math.isnan(frame[0]):
            repeated[i] = data[i]
            last_good_frame = i
        else:
            repeated[i] = data[last_good_frame]

    repeated = [frame for frame in repeated if not math.isnan(frame[0])]
    
    xs = [frame[x_features] for frame in repeated]
    ys = [frame[y_features] for frame in repeated]
    zs = [frame[z_features] for frame in repeated]

    print(f'{len(xs)=}, {len(ys)=}, {len(zs)=}')

    if len(xs) == 0:
        print(f'{filename} empty data')
        return

    # print(f'{len(xs[0])=}')

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    sct, = ax.plot([], [], [], "o", markersize=2)

    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')

    ax.invert_zaxis()

    lines = list()

    def update(ifrm, xa, ya, za):
        nonlocal lines
        if args.verbose:
            print(f'update({ifrm=})')
        ax.view_init(elev=(20 + ifrm * 0.25), azim=(90 + ifrm * 0.05))
        sct.set_data(xa[ifrm], ya[ifrm])
        sct.set_3d_properties(za[ifrm])

        if wireframe:
            BLACK = 'black'
            RED = 'red'
            BLUE = 'blue'
            YELLOW = 'yellow'
            ORANGE = 'orange'
            GREEN = 'green'

            lines_between = [
                [0, 1, BLACK], [1, 2, RED], [2, 3, RED], [3, 4, RED],
                [1, 5, BLACK], [5, 6, BLUE], [6, 7, BLUE], [7, 8, BLUE],
                [5, 9, BLACK], [9, 10, YELLOW], [10, 11, YELLOW], [11, 12, YELLOW],
                [9, 13, BLACK], [13, 14, ORANGE], [14, 15, ORANGE], [15, 16, ORANGE],
                [13, 17, BLACK], [0, 17, BLACK], [17, 18, GREEN], [18, 19, GREEN], [19, 20, GREEN]
            ]

            for line in lines:
                line.remove()

            lines = list()
            
            for from_pt, to_pt, color in lines_between:
                if np.isnan(xa[ifrm][from_pt]) or np.isnan(xa[ifrm][to_pt]):
                    continue
                
                lines.append(
                    ax.plot(xs=[xa[ifrm][from_pt], xa[ifrm][to_pt]],
                            ys=[ya[ifrm][from_pt], ya[ifrm][to_pt]],
                            zs=[za[ifrm][from_pt], za[ifrm][to_pt]],
                            color=color)[0]
                )

        # print(f'{ifrm=}, {xa[ifrm]=}, {ya[ifrm]=}, {za[ifrm]=}')

    zoom = 0.8
    ax.set_xlim(-zoom / 10, zoom)
    ax.set_ylim(-zoom / 10, zoom)
    ax.set_zlim(-zoom / 10, zoom)
    ani = animation.FuncAnimation(fig, update, len(repeated), fargs=(xs, ys, zs), interval=1000 / fps)

    video_path = get_video_path()
    video_file = video_path.joinpath(f"{filename}.mp4")

    ani.save(video_file, writer='ffmpeg', fps=fps)
    print(f'Made {video_file}')
    plt.close(fig)

def generate_videos():
    pq_data = load_parquet(args.parquet_file)
    metadata = pd.read_csv(args.metadata_file).set_index("sequence_id")
    seq_ids = set(pq_data.index.values.tolist())

    print(f"Sequences Loaded: {len(seq_ids)}")
    if args.pt_id is not None:
        metadata = metadata.astype({"participant_id" : str})
        pt_metadata = metadata.loc[metadata.participant_id == args.pt_id]
        seq_ids = set(pt_metadata.index.values.tolist())
    
    print(f"Sequences Used: {len(seq_ids)}")
    for seq_id in seq_ids:
        row = metadata.loc[seq_id]
        phrase = row.phrase
        
        frames = pq_data[pq_data.index == seq_id]
        frames = frames.iloc[:,1:].to_numpy()
        
        phrase_path = re.sub(r'[:/\\ ]', '_', phrase)
        render(frames[:, PARQUET_RH_FEATURES], f'{phrase_path}_{str(seq_id)}_rh_wire', True)

def get_video_path():
    video_dirname = f"{args.parquet_file.stem}"
    
    if args.pt_id is not None:
        pt_dirname = f"{args.pt_id}"
        video_path = VIDEO_DATA.joinpath(video_dirname, pt_dirname)
    else:
        video_path = VIDEO_DATA.joinpath(video_dirname)

    return Path(video_path)

def make_video_path():
    video_path = get_video_path()
    print(f"Video Path: {video_path}")
    video_path.mkdir(parents=True, exist_ok=True)
    # make_dir(video_path, rmdir=True)

if __name__ == '__main__':
    args = parse_args()
    make_video_path()
    generate_videos()

########################################
################ Old ###################
########################################

# def get_file_ids():
#     pq_files = os.listdir(SUPPLEMENTAL_LANDMARKS)
#     file_ids = []
# 
#     for file in pq_files:
#         file_ids.append(int(os.path.splitext(file)[0]))
# 
#     return file_ids
# 
# def is_right_handed(frames):
#     lh_na = frames.iloc[:,PARQUET_LH_FEATURES].notna().sum()
#     rh_na = frames.iloc[:,PARQUET_RH_FEATURES].notna().sum()
# 
#     if lh_na.loc["x_left_hand_0"].item() <= rh_na.loc["x_right_hand_0"].item():
#         return True
# 
#     return False
# 
# def unify_hands(frames):
#     right_handed = is_right_handed(frames)
#     if not right_handed:
#         frames.iloc[:,PARQUET_LH_FEATURES] = 1 - frames.iloc[:,PARQUET_LH_FEATURES]
#         return frames.iloc[:,PARQUET_LH_FEATURES]
#     else:
#         return frames.iloc[:,PARQUET_RH_FEATURES]

