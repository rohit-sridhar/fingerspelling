# This code currently uses both pathlib and os.path.
# This should be fixed later.

import cv2
import sys
import mediapipe as mp
from mediapipe.framework.formats.landmark_pb2 import NormalizedLandmark, NormalizedLandmarkList
import time
import argparse
import os
import glob
import random
import pandas as pd
from tqdm import tqdm
from multiprocessing import Pool
import json
from pathlib import Path

global args

def parse_args():
    """ This is executed when run from the command line """
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("--pt", type=str, default=None, help="participant filtering. optional.")
    parser.add_argument("-n", "--sample_size", type=int, default=100, help="sample size.")
    parser.add_argument("-s", "--video_src", type=Path, required=True, help="directory with videos.")
    parser.add_argument("-p", "--parquet_file", type=Path, required=True, help="parquet file for processing.")
    parser.add_argument("-d", "--dest", type=Path, required=True, help="destination for overlay videos.")
    
    args = parser.parse_args()
    return args

# with open(mediapipe_filepath) as f:
#     json_data = json.load(f)
#     frame_data = json_data[str(num_frames)]
#     pose_landmarks = NormalizedLandmarkList(
#       landmark = [NormalizedLandmark(x=frame_data["pose"][str(x)][0], y=frame_data["pose"][str(x)][1], z=frame_data["pose"][str(x)][2]) for x in range(33)]
#     )
#     left_hand_json = frame_data["landmarks"]["0"]
#     if left_hand_json == {}:
#         left_hand_landmarks = None
#     else:
#         left_hand_landmarks = NormalizedLandmarkList(
#           landmark = [NormalizedLandmark(x=left_hand_json[str(x)][0], y=left_hand_json[str(x)][1], z=left_hand_json[str(x)][2]) for x in range(21)]
#         )
#     right_hand_json = frame_data["landmarks"]["1"]
#     if right_hand_json == {}:
#         right_hand_landmarks = None
#     else:

def format_hand_landmarks(frame_i, landmarks):
    frame_lm = landmarks.loc[landmarks.frame == frame_i].drop('frame', axis=1)
    if frame_lm.isna().all(axis=1).item():
        return None
    else:
        frame_data = frame_lm.iloc[0].to_list()
        right_hand_landmarks = NormalizedLandmarkList(
          landmark = [NormalizedLandmark(x=frame_data[x], y=frame_data[x+21], z=frame_data[x+21*2]) for x in range(21)]
        )
        return right_hand_landmarks

def draw_mediapipe_landmarks(video_details):
    # mediapipe_filepath = video_details['mediapipe_filepath']
    video_filepath = video_details['video_filepath']
    new_video_filepath = video_details['new_video_filepath']
    # show_overlay = video_details.get('show_overlay', False)
    hand_landmarks = video_details['hand_landmarks']

    print(f"Original Video Filepath: {video_filepath}")
    print(f"New Video Filepath: {new_video_filepath}")
    
    mp_drawing = mp.solutions.drawing_utils
    mp_holistic = mp.solutions.holistic
    
    # For video input:
    cap = cv2.VideoCapture(video_filepath)
    result = cv2.VideoWriter(filename=new_video_filepath,
                           fourcc=cv2.VideoWriter.fourcc(*"mp4v"),
                           fps=cap.get(cv2.CAP_PROP_FPS), frameSize=(int(cap.get(3)), int(cap.get(4))))
    print(result.get(cv2.CAP_PROP_FPS))
    start = time.time()
    num_frames = 0
    pose_null = 0

    while cap.isOpened():
        success, image = cap.read()
        if not success:
            print("Ignoring empty camera frame.")
            # If loading a video, use 'break' instead of 'continue'.
            break
        
        # Flip the image horizontally for a later selfie-view display, and convert
        # the BGR image to RGB.
        # image = cv2.cvtColor(cv2.flip(image, 1), cv2.COLOR_BGR2RGB)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        right_hand_landmarks = format_hand_landmarks(
            num_frames,
            hand_landmarks
        )

        mp_drawing.draw_landmarks(
            image, right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
        # mp_drawing.draw_landmarks(
        #     image, left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
        # mp_drawing.draw_landmarks(
        #     image, pose_landmarks, mp_holistic.POSE_CONNECTIONS)
        # if pose_landmarks is None:
        #     pose_null += 1
        
        #define the screen resulation
        screen_res = 1280, 720
        scale_width = screen_res[0] / image.shape[1]
        scale_height = screen_res[1] / image.shape[0]
        scale = min(scale_width, scale_height)
        #resized window width and height
        window_width = int(image.shape[1] * scale)
        window_height = int(image.shape[0] * scale)
        #cv2.WINDOW_NORMAL makes the output window resizealbe
        window_width = int(cap.get(3))
        window_height = int(cap.get(4))
        image = cv2.flip(image, 1)
        result.write(image)
        # if show_overlay:
        #     cv2.imshow('Overlay', image)
        if cv2.waitKey(5) & 0xFF == 27:
            break
        num_frames += 1
    
    end = time.time() - start
    print("Number of times pose is none = " + str(pose_null))
    print("Time taken = " + str(end))
    print("Total frames = " + str(num_frames))
    print("Frames processed per second = " + str(num_frames/end))
    # holistic.close()
    cap.release()
    result.release()
    
    return new_video_filepath

def get_parquet():
    metadata_file = Path(str(args.parquet_file).replace("landmarks", "metadata").replace(".parquet",".csv"))

    pq_data = pd.read_parquet(args.parquet_file)
    metadata = pd.read_csv(metadata_file)

    return pq_data, metadata

def get_pt_files(src_files):
    processed_src_files = []
    for filename in src_files:
        basename = os.path.basename(filename)
        pt = basename.split('_')[0]
        
        if pt == args.pt:
            processed_src_files.append(filename)

    processed_src_files = random.sample(processed_src_files, min(args.sample_size, len(processed_src_files)))
    return processed_src_files

if __name__ == "__main__":
    args = parse_args()
    random.seed(100)

    pq_data, metadata = get_parquet()
    available_videos = set(metadata.clipFilename.to_list())
    
    src_files = sorted(glob.glob(os.path.join(args.video_src, "*.mp4")))
    src_files = [src_file for src_file in src_files if os.path.basename(src_file) in available_videos]
    if args.pt is None:
        processed_src_files = random.sample(src_files, min(args.sample_size, len(src_files)))
    else:
        processed_src_files = get_pt_files(src_files)
    # print(f"Files for processing {processed_src_files}")
    
    # dest_files = []
    # for file in tqdm(processed_src_files):
    #     dest_files.append(os.path.join(args.dest, file.split('/')[-1]))
    
    mapped = []
    seen_phrases = set() 
    
    for src_f in processed_src_files:
        filename = os.path.basename(src_f)
        metadata_row = metadata.loc[metadata['clipFilename'] == filename]
        hand_landmarks = pq_data.loc[metadata_row.sequence_id]
        phrase = metadata_row['phrase'].item().replace(' ','_') 
        seq_id = str(metadata_row['sequence_id'].item())

        pt = filename.split('_')[0]
        new_vidname = '_'.join([pt, seq_id, phrase + '.mp4'])
        dest_f = os.path.join(args.dest, new_vidname)
        mapped.append({
            'video_filepath': str(src_f),
            'new_video_filepath': str(dest_f),
            'hand_landmarks': hand_landmarks
        })
    
    Path(args.dest).mkdir(parents=True, exist_ok=True)
    
    pool = Pool(1)
    results = pool.map(draw_mediapipe_landmarks, mapped)
    print(results)
    
