#!/opt/conda/bin/python

import cv2
import shutil

import pandas as pd
import numpy as np

from tqdm import tqdm
from pathlib import Path

ORIGINAL_DATA_LOCATION=Path("/data/deep_learning/ISLR-ML/mputils/out")
METADATA=ORIGINAL_DATA_LOCATION.joinpath("metadata", "supplemental_gen.csv")
LANDMARKS=ORIGINAL_DATA_LOCATION.joinpath("landmarks", "supplemental_gen.parquet")

# b718 1d72 f066 7f32 3a6e
PT="3a6e"
VIDEO_FILES=Path("/data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train")
OUTPUT_MLF_PATH=Path(f"/data/hmm_modeling/fingerspelling/ContinuousBigram/ext/supplemental_gen_drop-na_lininterp0/dim20/thr0/test/pt/{PT}")
OUTPUT_FILE_PATH=Path(f"/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts/segmentation/videos/{PT}")

SEQ_START_FRAMES = {}
SEQ_RECS = {}

FPS = 30

############################## GENERAL HELPERS ##############################

# Reads in the metadata file for ALL the data from
# mputils (where it was generated)
def read_metadata():
    metadata = pd.read_csv(METADATA, index_col="sequence_id")
    metadata = metadata[metadata.participant_id == PT]

    return metadata

############################## SEGMENTATION HELPERS ##############################

# Gets the start frame for each sequence, since
# there may be nan values excluded in the MLF 
# frame counts
def get_seq_start_frames(metadata):
    def get_start_frame(row):
        seq_id = row.index.to_list()[0]
        first_col_vals = row.x_right_0.fillna(0).to_list()
        if sum(first_col_vals) == 0:
            SEQ_START_FRAMES[seq_id] = None
            return

        i = 0
        while first_col_vals[i] == 0:
            i += 1

        SEQ_START_FRAMES[seq_id] = (i, len(first_col_vals))
        return

    pt_seq_ids = metadata.index.to_list()
    pt_data = pd.read_parquet(LANDMARKS).loc[pt_seq_ids]
    pt_data.groupby("sequence_id").apply(get_start_frame)

def get_best_rec(recs):
    # Invidual recs delimited by "///\n"
    rec_list = recs.split("///\n")
    best_rec = rec_list[0]

    rec_lines = best_rec.split("\n")[:-1]
    rec_path = Path(rec_lines[0][1:-1])
    
    seq_id = int(rec_path.stem)
    SEQ_RECS[seq_id] = []
    for segment in rec_lines[1:]:
        segment_split = segment.split(" ")

        start_ms = int(int(segment_split[0]) / 1000)
        if start_ms > 0:
            start_ms += SEQ_START_FRAMES[seq_id][0]
        rec_word = segment_split[2]
        
        SEQ_RECS[seq_id].append((rec_word, start_ms))

# One iteration of gather_mlf_results
# Parses mlf file, gets the top rec
# and gathers the frame segmentation
# for the video
def gather_mlf_result(mlf):
    with open(mlf, "r") as f:
        lines = f.readlines()

    # First join lines. In MLFs, rec lists
    # delimited by ".\n"
    lines = "".join(lines[1:-1])
    recs_by_seq = lines.split(".\n")
    
    for recs in recs_by_seq:
        get_best_rec(recs)

# Look in OUTPUT_MLF_PATH to gather MLF word results
def gather_mlf_results():
    word_mlfs = list(OUTPUT_MLF_PATH.glob("result.mlf_word.*"))
    for mlf in word_mlfs[:5]:
        result = gather_mlf_result(mlf)

##### Video functions

def get_second_components(seconds):
    whole_seconds = "{:02d}".format(int(seconds))
    decimal_seconds = "{:.3f}".format(seconds)[-3:]
    
    return whole_seconds, decimal_seconds

def get_srt_lines(seq):
    segments = SEQ_RECS[seq]
    i = 1

    srt_lines = []
    for k,segment in enumerate(segments):
        start_seconds = segments[k][1] / FPS
        if k == len(segments) - 1:
            end_seconds = SEQ_START_FRAMES[seq][1] / FPS
        else:
            end_seconds = segments[k+1][1] / FPS
        word = segments[k][0]
        
        s_seconds, s_milliseconds = get_second_components(start_seconds)
        e_seconds, e_milliseconds = get_second_components(end_seconds)
        srt_txt = f"{i}\n00:00:{s_seconds},{s_milliseconds} --> 00:00:{e_seconds},{e_milliseconds}\n{word}\n\n"
        srt_lines.append(srt_txt)
        i += 1
    
    return srt_lines

def match_frame_count(cap):
    num_frames = 0
    while True:
        status, frame = cap.read()
        if not status:
            break
        num_frames += 1

    if num_frames != SEQ_START_FRAMES[seq][1]:
        print(f"Video Frames: {num_frames}")
        print(f"MP Frames: {SEQ_START_FRAMES[seq][1]}")
        return False

    return True

def segment_video_file(seq, video_file):
    cap = cv2.VideoCapture(str(video_file))
    if not cap.isOpened():
        print(f"Could not open {video_file}")
    
    if not match_frame_count(cap):
        return
    
    srt_lines = get_srt_lines(seq)
    srt_file_name = OUTPUT_FILE_PATH.joinpath(video_file.stem).with_suffix(".srt")
    cp_video_file_name = OUTPUT_FILE_PATH.joinpath(video_file.name)

    shutil.copyfile(video_file, cp_video_file_name)
    with open(srt_file_name, "w") as f:
        f.writelines(srt_lines)

############################## MAIN PROGRAM ##############################

if __name__ == "__main__":
    metadata = read_metadata()
    get_seq_start_frames(metadata)
    mlf_results = gather_mlf_results()
    
    OUTPUT_FILE_PATH.mkdir(parents=True, exist_ok=True)
    segmented_seqs = list(SEQ_RECS.keys())
    for seq in tqdm(segmented_seqs):
        video_file = VIDEO_FILES.joinpath(metadata.loc[seq].clipFilename)
        segment_video_file(seq, video_file)

