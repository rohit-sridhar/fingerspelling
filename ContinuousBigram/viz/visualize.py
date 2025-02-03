import math

import pandas as pd
from pyarrow import parquet as pq

# from model import *
from constants import *

import re
import os
import shutil
import argparse

import matplotlib.pyplot as plt
import matplotlib.animation as animation

import numpy as np

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
    
    parser.add_argument("--participant_id", type=int, default=2, help="Participant ID.")

    return parser.parse_args()
    
def load_parquet(filename) -> pd.DataFrame:
    print(filename)
    parquet_array = pq.read_table(filename, columns=PARQUET_FEATURE_LIST, memory_map=True).to_pandas()
    # print(f'Number of rows in {filename}: {len(parquet_array.index):,}')
    return parquet_array

def render(data, filename, wireframe=True):
    # x_features = [i for i in range(0, 21)]
    # y_features = [i for i in range(23, 44)]
    # z_features = [i for i in range(46, 67)]

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

    ani.save(f'videos/participant{args.participant_id}/{filename}.mp4', writer='ffmpeg', fps=fps)
    print(f'Made videos/participant{args.participant_id}/{filename}.mp4')

def get_file_ids():
    pq_files = os.listdir(SUPPLEMENTAL_LANDMARKS)
    file_ids = []

    for file in pq_files:
        file_ids.append(int(os.path.splitext(file)[0]))

    return file_ids

def is_right_handed(frames):
    lh_na = frames.iloc[:,PARQUET_LH_FEATURES].notna().sum()
    rh_na = frames.iloc[:,PARQUET_RH_FEATURES].notna().sum()

    if lh_na.loc["x_left_hand_0"].item() <= rh_na.loc["x_right_hand_0"].item():
        return True

    return False

def unify_hands(frames):
    right_handed = is_right_handed(frames)
    if not right_handed:
        frames.iloc[:,PARQUET_LH_FEATURES] = 1 - frames.iloc[:,PARQUET_LH_FEATURES]
        return frames.iloc[:,PARQUET_LH_FEATURES]
    else:
        return frames.iloc[:,PARQUET_RH_FEATURES]

def load_parquets():
    entries = pd.read_csv(SUPPLEMENTAL_METADATA)
    print(entries.shape)
    
    pq_data = load_parquet(f"./data/participant{args.participant_id}.parquet")
    available_seq_ids = set(pq_data.index.values.tolist())
    print(f"Sequences Loaded: {len(available_seq_ids)}")

    SKIP = 0
    NUM_ROWS = 60000
    for i, row in entries.iloc[SKIP:NUM_ROWS+SKIP, :].iterrows():
        file, seq_id, phrase = row[0], row[2], row[4]

        if seq_id not in available_seq_ids:
            continue    
        
        # pq_data = load_parquet(os.path.join('data', file))
        frames = pq_data[pq_data.index == seq_id]
        
        frames = frames.to_numpy()
        # print(frames.shape)
        
        phrase_path = re.sub(r'[:/\\ ]', '_', phrase)
        
        # render(frames[:, PARQUET_RH_FEATURES], f'{phrase_path}_rh')
        render(frames[:, PARQUET_RH_FEATURES], f'{phrase_path}_{str(seq_id)}_rh_wire', True)

if __name__ == '__main__':
    args = parse_args()
    
    if os.path.exists(f"./videos/participant{args.participant_id}"):
        shutil.rmtree(f"./videos/participant{args.participant_id}")
    os.mkdir(f"./videos/participant{args.participant_id}")

    load_parquets()


# def render_frame():
#     file = 'wip2'
#     df = pd.read_csv(f'/Users/sahirshahryar/Desktop/{file}.csv', header=None)
#     frames = df.to_numpy().T.reshape((69,))
#     repeated_frames = np.repeat(frames, 480).reshape((69, 480)).T
#     render(repeated_frames, f'test_{file}')
# 
# 
# def load_csvs_transformed():
#     df = pd.read_csv(f'/Users/sahirshahryar/Desktop/nparr.csv', header=None)
#     frames = df.to_numpy()
#     frame_ct = frames.shape[0]
# 
#     converted = np.zeros((frame_ct, 69))
#     for i, frame in enumerate(frames):
#         if math.isnan(frame[0]):
#             converted[i] = np.array([np.nan] * 69)
# 
#         reverted = hand_abs_coords(frame)
#         reverted = reverted.T.reshape((69,))
#         converted[i] = reverted
# 
#     render(converted, f'test2_rh_wire_reverted')
# 
# 
# def load_csvs():
#     df = pd.read_csv('data/sample/fingertest-out-old.csv', header=None)
#     # df = pd.read_csv('/Users/sahirshahryar/Desktop/nparr.csv')
#     frames = df.to_numpy()
#     frame_ct = frames.shape[0]
# 
#     rh = frames[:, PARQUET_RH_FEATURES].reshape((frame_ct, 23, 3))
#     # print(rh[0])
#     rh = np.transpose(rh, axes=[0, 2, 1])
#     # print(f'{rh.shape=}')
#     rh = rh.reshape((frame_ct, 69))
# 
#     # print(rh[0])
# 
#     # rh = frames[:, PARQUET_RH_FEATURES]
#     # render(rh, f'test_rh_wire', True)
# 
#     there_and_back = np.zeros_like(rh)
#     for i, frame in enumerate(rh):
#         if math.isnan(frame[0]):
#             there_and_back[i] = np.array([np.nan] * 69)
#             continue
# 
#         # copy = frame.copy()
#         # landmarks = copy.reshape((3, 21))
#         # landmarks = landmarks.T
# 
#         # angled = hand_relative_coords(landmarks)
#         reverted = hand_abs_coords(frame)
# 
#         reverted = reverted.T.reshape((69,))
#         there_and_back[i] = reverted
# 
#     # print(rh[0].T.reshape((21, 3)))
#     # print(there_and_back[0])
# 
#     render(there_and_back, f'test2_rh_wire_reverted', True)
# 
# 
# # Defines a new vector basis in 3D space based on the right hand rule, given
# # three coordinates: the origin point, a vector that should point to positive x in the
# # new basis, and a vector in the negative-y-ish direction
# def basis_rh_rule(orig, pos_x, neg_y):
#     j = pos_x - orig
#     j /= np.linalg.norm(j)
# 
#     k = np.cross(pos_x - orig, neg_y - orig)
#     k /= np.linalg.norm(k)
# 
#     i = np.cross(j, k)
#     i /= np.linalg.norm(i)
# 
#     basis = np.array([i, j, k])
#     return basis, np.linalg.inv(basis)
# 
# 
# def hand_relative_coords(landmarks: np.array):
#     print(f'{landmarks=}')
#     palm_triangle = np.array([
#         landmarks[WRIST], landmarks[INDEX_FINGER_MCP], landmarks[PINKY_MCP]
#     ])
# 
#     print(f'{palm_triangle=}')
# 
#     palm_centroid = np.average(palm_triangle, axis=0)
# 
#     # Center all coordinates around the centroid of the palm
#     centered = landmarks - palm_centroid
# 
#     # Copy over positions of the wrist and index/pinky metacarpophalangeal joints.
#     # Don't mind the awkward range syntax here - it's supposed to be for readability,
#     # but unfortunately, python's range syntax creates a half-open interval, meaning
#     # we need to add a +1 to each index to actually get it to include the feature index
#     # we want (for example, for the features indices ranging from WRIST_POS_X to WRIST_POS_Z,
#     # we need WRIST_POS_X:WRIST_POS_Z + 1). This is better than using, for instance, the next
#     # feature label (e.g. what does WRIST_POS_X:WRIST_POS_dX mean on first reading?) or just
#     # magic numbers (e.g., standardized[0:3] provides very little information about what's being
#     # copied, and is subject to creating bugs if the feature indices are updated down the line).
#     standardized = np.zeros((COUNT,))
#     standardized[WRIST_POS_X:WRIST_POS_Z + 1] = centered[WRIST]
#     standardized[INDEX_MCP_X:INDEX_MCP_Z + 1] = centered[INDEX_FINGER_MCP]
#     standardized[PINKY_MCP_X:PINKY_MCP_Z + 1] = centered[PINKY_MCP]
#     standardized[THUMB_CMC_X:THUMB_CMC_Z + 1] = landmarks[THUMB_CMC] - palm_centroid
# 
#     # Assume for the below data that all hand input is right-handed.
#     # Calculate the rotation and scaling of the hand so that the vector
#     # (1, 0, 0) points roughly toward the thumb, (0, 1, 0) points roughly
#     # from the wrist to the index finger,  and (0, 0, 1) points straight
#     # upward when the hand is laid palm-up on a desk.
#     a = centered[WRIST]
#     b = centered[INDEX_FINGER_MCP]
#     c = centered[PINKY_MCP]
#     print(f'{a=}, {b=}, {c=}')
#     basis, basis_inv = basis_rh_rule(a, b, c)
# 
#     # Matrix-multiply all of the centered data points to get their positions in the new coordinate space
#     transformed = np.matmul(basis_inv, centered.T).T
# 
#     def get_rel(f1, f2):
#         rel_pos = transformed[f1] - transformed[f2]
#         return rel_pos / np.linalg.norm(rel_pos)
# 
#     mcp_rel_pos = get_rel(THUMB_MCP, THUMB_CMC)
#     standardized[THUMB_PITCH] = np.arcsin(mcp_rel_pos[2])
#     standardized[THUMB_YAW] = np.arctan2(mcp_rel_pos[1], mcp_rel_pos[0])
# 
#     ip_rel_pos = get_rel(THUMB_IP, THUMB_MCP)
#     standardized[THUMB_PP_PITCH] = np.arcsin(ip_rel_pos[2])
#     standardized[THUMB_PP_YAW] = np.arctan2(ip_rel_pos[1], ip_rel_pos[0])
# 
#     tip_rel_pos = get_rel(THUMB_TIP, THUMB_IP)
#     standardized[THUMB_DP_PITCH] = np.arcsin(tip_rel_pos[2])
#     standardized[THUMB_DP_YAW] = np.arctan2(tip_rel_pos[1], tip_rel_pos[0])
# 
#     # Here we iterate over each of the four remaining fingers, converting each segment's positions in 3D space
#     # to angles of articulation
#     for input_group, output_group in zip(INBOUND_FEATURE_GROUPS, OUTBOUND_FEATURE_GROUPS):
#         # Input feature indices: knuckle, joint, and fingertip positions
#         IN_KNUCKLE, IN_PIP, IN_DIP, IN_TIP = input_group
# 
#         # Output feature indices: proximal phalanx's tilt and yaw, and remaining phalanges' tilt
#         OUT_PITCH, OUT_YAW, OUT_IP_TILT, OUT_DP_TILT = output_group
# 
#         # Calculate the proximal interphalangeal joint's coordinates relative to the knuckle.
#         # We can then calculate its pitch and yaw.
#         pip_rel_pos = transformed[IN_PIP] - transformed[IN_KNUCKLE]
#         pip_rel_pos /= np.linalg.norm(pip_rel_pos)
# 
#         # Calculate the pitch and yaw using arc sine and arc tangent functions, respectively
#         standardized[OUT_PITCH] = np.arcsin(pip_rel_pos[2])
#         standardized[OUT_YAW] = np.arctan2(pip_rel_pos[1], pip_rel_pos[0])
# 
#         # Next, calculate the tilt of the intermediate phalanx relative to .
#         dip_rel_pos = transformed[IN_DIP] - transformed[IN_PIP]
#         dip_rel_pos /= np.linalg.norm(dip_rel_pos)
# 
#         # The line below is copied from David Wolever's StackOverflow answer to the question
#         # "Angles between two n-dimensional vectors in Python": https://stackoverflow.com/a/13849249
#         standardized[OUT_IP_TILT] = np.arccos(np.clip(np.dot(pip_rel_pos, dip_rel_pos), -1, 1))
# 
#         # Next, calculate the tilt of the distal phalanx using the same method as before.
#         tip_rel_pos = transformed[IN_TIP] - transformed[IN_DIP]
#         tip_rel_pos /= np.linalg.norm(tip_rel_pos)
# 
#         standardized[OUT_DP_TILT] = np.arccos(np.clip(np.dot(dip_rel_pos, tip_rel_pos), -1, 1))
# 
#     return standardized
# 
# 
# def lerp(a, b, t):
#     return a + (t * (b - a))
# 
# 
# def polar_to_cart(pitch, yaw):
#     return np.array([
#         np.cos(pitch) * np.cos(yaw),
#         np.cos(pitch) * np.sin(yaw),
#         np.sin(pitch)
#     ])
# 
# 
# def hand_abs_coords(standardized):
#     a = standardized[WRIST_POS_X:WRIST_POS_Z + 1]
#     b = standardized[INDEX_MCP_X:INDEX_MCP_Z + 1]
#     c = standardized[PINKY_MCP_X:PINKY_MCP_Z + 1]
#     d = standardized[THUMB_CMC_X:THUMB_CMC_Z + 1]
# 
#     centered = np.array([a, b, c, d])
#     basis, basis_inv = basis_rh_rule(a, b, c)
# 
#     transformed = np.matmul(basis_inv, centered.T).T
# 
#     # Todo: determine average segment lengths empirically.
#     scale = 0.12
#     segment_lengths = scale * np.array([
#         [1, 0.67, 0.5],  # Thumb
#         [1, 0.67, 0.5],  # Index
#         [1, 0.67, 0.5],  # Middle
#         [1, 0.6, 0.5],   # Ring
#         [0.8, 0.4, 0.4]  # Pinky
#     ])
# 
#     wrist, index, pinky, thumb_cmc = transformed
# 
#     landmarks = np.zeros((23, 3))
#     landmarks[WRIST] = wrist
#     landmarks[INDEX_FINGER_MCP] = index
#     landmarks[PINKY_MCP] = pinky
#     landmarks[THUMB_CMC] = thumb_cmc
# 
#     # middle and ring knuckles - interpolate
#     landmarks[MIDDLE_FINGER_MCP] = lerp(index, pinky, 0.33)
#     landmarks[RING_FINGER_MCP] = lerp(index, pinky, 0.67)
# 
#     length = segment_lengths[0][0]
#     thumb_mcp_disp = length * polar_to_cart(standardized[THUMB_PITCH], standardized[THUMB_YAW])
#     landmarks[THUMB_MCP] = thumb_cmc + thumb_mcp_disp
# 
#     length = segment_lengths[0][1]
#     thumb_ip_disp = length * polar_to_cart(standardized[THUMB_PP_PITCH], standardized[THUMB_PP_YAW])
#     landmarks[THUMB_IP] = landmarks[THUMB_MCP] + thumb_ip_disp
# 
#     length = segment_lengths[0][2]
#     thumb_dp_disp = length * polar_to_cart(standardized[THUMB_DP_PITCH], standardized[THUMB_DP_YAW])
#     landmarks[THUMB_TIP] = landmarks[THUMB_IP] + thumb_dp_disp
# 
#     for finger_idx, input_group, output_group in \
#             zip([1, 2, 3, 4], INBOUND_FEATURE_GROUPS, OUTBOUND_FEATURE_GROUPS):
#         PITCH, YAW, IP_TILT, DP_TILT = output_group
#         BASE, PIP, DIP, TIP = input_group
# 
#         length = segment_lengths[finger_idx][0]
#         pp_disp = length * polar_to_cart(standardized[PITCH], standardized[YAW])
#         landmarks[PIP] = landmarks[BASE] + pp_disp
# 
#         length = segment_lengths[finger_idx][1]
#         mp_disp = length * polar_to_cart(standardized[IP_TILT], standardized[YAW])
#         landmarks[DIP] = landmarks[PIP] + mp_disp
# 
#         length = segment_lengths[finger_idx][2]
#         dp_disp = length * polar_to_cart(standardized[IP_TILT] + standardized[DP_TILT], standardized[YAW])
#         landmarks[TIP] = landmarks[DIP] + dp_disp
# 
#     return np.matmul(basis, landmarks.T).T
# 
# 
# # Augments an example by inserting frames for NaN data (which is why
# # this requires cartesian frame data as input). We can do this in two
# # ways:
# #
# # Interpolation
# # For small gaps in the data, it's acceptable to simply interpolate frame
# # data. This can be done using linear interpolation on the angle values
# # on both ends of the missing data (e.g., if a joint has an angle of 0 radians
# # at the beginning of the gap and 1 radian at the end, we can put in 0.25, 0.5,
# # 0.75, etc. as values for the missing frames). We restrict this to short gaps
# # in the data because interpolating over enormous gaps would simply lead to a
# # large amount of incorrect data which misses out on the complexity of the
# # motions used for fingerspelling. By default, only gaps of 5 frames or fewer
# # are interpolated (hence `interpolate=5`).
# #
# # Extrapolation
# # For larger gaps (exceeding `interpolate`), we can extrapolate additional frames
# # based on the surrounding motion. By default, we restrict this to only 3 frames
# # on each end of the chasm, using a simple physics simulation (based on the momentum
# # of each joint in the  handful of frames before or after the gap). In the future,
# # using a simple ML model trained to predict future frames based on a sequence of input
# # frames may provide more realistic results.
# #
# # For extrapolation, the following properties can be changed:
# # - `extrapolate`: The number of frames to generate on each end of a large chasm of NaN data.
# #   For example if there are 8 NaN frames, this function will generate 3 frames on each end,
# #   leaving a gap of just 2 frames.
# # - `max_sample`: The maximum number of frames to sample the momentum data on when generating
# #   data. It's recommended to keep this value relatively (but not too) small. Small values
# #   (e.g. 1 or 2) may create noisy extrapolations if there are sudden movements, and large
# #   values may end up being essentially meaningless (as the velocity of a joint may average out
# #   to zero if it moves back and forth)
# # - `min_sample`: The minimum number of available frames to sample from. For example, if there
# #   is a sequence of 30 frames and the frames [7, 13] and [16, 22] are NaN, then there aren't
# #   enough frames to create a convincing extrapolation on either end of the 14th and 15th frames,
# #   so the extrapolated result would have its NaN regions reduced to [10, 13] and [16, 19].
# #   By default, the minimum number of required frames for extrapolation to occur is 3 frames.
# # def augment_example(video: HandVideo, interpolate=5, extrapolate=3, max_sample=5, min_sample=3):
# #     # Generate intervals where frame data is null, then we can make decisions for each interval.
# #     nan_segments = list()
# #     nan_start = -1
# #
# #     video.unpack()
# #
# #     for i, frame in enumerate(video):
# #         if math.isnan(frame[0]):
# #             # Frame is empty and no interval has been started: start one now
# #             if nan_start == -1:
# #                 nan_start = i
# #
# #         # Frame had data, so if we had an interval of NaNs, close it and add it to
# #         # the list
# #         elif nan_start != -1:
# #             nan_segments.append((nan_start, i - 1))
# #             nan_start = -1
# #
# #     # Add the current interval if the last frame was empty
# #     if nan_start != -1:
# #         nan_segments.append((nan_start, len(video) - 1))


