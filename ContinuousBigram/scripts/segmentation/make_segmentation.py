#!/opt/conda/bin/python

import sys
import cv2
import shutil
import argparse

import pandas as pd
import numpy as np

from tqdm import tqdm
from pathlib import Path

ORIGINAL_DATA_LOCATION=Path("/data/deep_learning/ISLR-ML/mputils/out")
METADATA=ORIGINAL_DATA_LOCATION.joinpath("metadata", "supplemental_gen.csv")
LANDMARKS=ORIGINAL_DATA_LOCATION.joinpath("landmarks", "supplemental_gen.parquet")

# PT="f418"
VIDEO_FILES=Path("/data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train")
OUTPUT_MLF_PARENT=Path(f"/data/hmm_modeling/fingerspelling/ContinuousBigram/ext/supplemental_gen_drop-na_lininterp0/dim20/thr0/test/pt")
OUTPUT_VIDEO_PARENT=Path(f"/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts/segmentation/videos")
OUTPUT_DATASET_PARENT=Path(f"/data/hmm_modeling/fingerspelling/ContinuousBigram/scripts/segmentation/datasets")

SEQ_START_FRAMES = {}
SEQ_RECS = {}

FPS = 30
WORD_ID = 0

START_WORD = "sil0"
END_WORD = "sil1"

global args

############################## GENERAL HELPERS ##############################
def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "-pts", "--participants",
        type=str,
        nargs="+",
        required=True,
        help="Participants to make segmentations for",
    )

    parser.add_argument(
        "-vid", "--gen_split_videos",
        action="store_true",
        help="Generates the split videos.",
    )

    parser.add_argument(
        "-srt", "--gen_subtitles",
        action="store_true",
        help="Generates videos with subtitles.",
    )

    parser.add_argument(
        "-dat", "--gen_dataset",
        action="store_true",
        help="Generates the segmented dataset.",
    )

    parser.add_argument(
        "-vfy", "--verify_frame_count",
        action="store_true",
        help="Generate videos with subtitles. Otherwise generates the segmented dataset.",
    )

    return parser.parse_args()

# Reads in the metadata file for ALL the data from
# mputils (where it was generated)
def read_metadata(participant):
    metadata = pd.read_csv(METADATA, index_col="sequence_id")
    pt_metadata = metadata[metadata.participant_id == participant]

    return pt_metadata

def read_landmarks(pt_metadata):
    pt_seq_ids = pt_metadata.index.to_list()
    pt_data = pd.read_parquet(LANDMARKS).loc[pt_seq_ids]

    return pt_data

############################## SEGMENTATION HELPERS ##############################

# Gets the start frame for each sequence, since
# there may be nan values excluded in the MLF 
# frame counts
def get_seq_start_frames(pt_metadata, pt_landmarks):
    def get_start_frame(row):
        seq_id = row.index.to_list()[0]
        first_col_vals = row.x_right_0.fillna(0).to_list()
        if sum(first_col_vals) == 0:
            print("There shouldn't be data points with all NA vals. Skipping.")
            return
            # raise RuntimeError("There shouldn't be data points with all NA vals")

        i = 0
        while first_col_vals[i] == 0:
            i += 1

        SEQ_START_FRAMES[seq_id] = {
            "start_frame": i,
            "num_frames": len(first_col_vals)
        }
        return

    pt_landmarks.groupby("sequence_id").apply(get_start_frame)

# Gets the best recommendation from the MLF file (the first
# recommendation in the file) for each sequence
def get_best_rec(recs, pt_metadata):
    # Invidual recs delimited by "///\n"
    rec_list = recs.split("///\n")
    best_rec = rec_list[0]

    rec_lines = best_rec.split("\n")[:-1]
    rec_path = Path(rec_lines[0][1:-1])
    
    seq_id = int(rec_path.stem)
    SEQ_RECS[seq_id] = []
    for segment in rec_lines[1:]:
        segment_split = segment.split(" ")

        start_frame = int(int(segment_split[0]) / 1000)
        if start_frame > 0:
            start_frame += SEQ_START_FRAMES[seq_id]["start_frame"]
        rec_word = segment_split[2]
        
        SEQ_RECS[seq_id].append((rec_word, start_frame))

    # corr_phrase = pt_metadata.loc[seq_id].phrase
    # pred_phrase = [rec[0] for rec in SEQ_RECS[seq_id][1:-1]]
    # pred_phrase = " ".join(pred_phrase)
    # SEQ_START_FRAMES[seq_id]["pred_correct"] = corr_phrase == pred_phrase

# One iteration of gather_mlf_results.
# Parses mlf file, gets the top rec
# and gathers the frame segmentation
# for the video
def gather_mlf_result(mlf, pt_metadata):
    with open(mlf, "r") as f:
        lines = f.readlines()

    # First join lines. In MLFs, rec lists
    # delimited by ".\n"
    lines = "".join(lines[1:-1])
    recs_by_seq = lines.split(".\n")
    
    for recs in recs_by_seq:
        get_best_rec(recs, pt_metadata)

# Look in output_mlf_path to gather MLF word results
def gather_mlf_results(pt_metadata, participant):
    output_mlf_path = OUTPUT_MLF_PARENT.joinpath(participant)
    word_mlfs = list(output_mlf_path.glob("result.mlf_word.*"))
    for mlf in word_mlfs:
        result = gather_mlf_result(mlf, pt_metadata)

############################## SUBTITLE HELPERS ##############################

# Recormats seconds into the whole second and the 
# milliseconds (called decimal seconds here).
def get_second_components(seconds):
    whole_seconds = "{:02d}".format(int(seconds))
    decimal_seconds = "{:.3f}".format(seconds)[-3:]
    
    return whole_seconds, decimal_seconds

# Uses the saved globals SEQ_START_FRAMES and SEQ_RECS
# to create srt file text. Partitions the video by word
# being signed.
def get_srt_lines(seq):
    segments = SEQ_RECS[seq]
    i = 1

    srt_lines = []
    for k,segment in enumerate(segments):
        start_seconds = segments[k][1] / FPS
        if k == len(segments) - 1:
            end_seconds = SEQ_START_FRAMES[seq]["num_frames"] / FPS
        else:
            end_seconds = segments[k+1][1] / FPS
        word = segments[k][0]
        
        s_seconds, s_milliseconds = get_second_components(start_seconds)
        e_seconds, e_milliseconds = get_second_components(end_seconds)
        srt_txt = f"{i}\n00:00:{s_seconds},{s_milliseconds} --> 00:00:{e_seconds},{e_milliseconds}\n{word}\n\n"
        srt_lines.append(srt_txt)
        i += 1
    
    return srt_lines

# Matches the frame count between the video
# and the mediapipe frames.
def match_frame_count(cap, seq):
    num_frames = 0
    while True:
        status, frame = cap.read()
        if not status:
            break
        num_frames += 1

    if num_frames != SEQ_START_FRAMES[seq]["num_frames"]:
        return False

    return True

# Segments the video file using the subtitles from
# get_srt_file. Saves the video and srt file in
# output file path
def subtitle_video_file(seq, video_file, output_video_path):
    if args.verify_frame_count:
         cap = cv2.VideoCapture(str(video_file))
         if not cap.isOpened():
             print(f"Could not open {video_file}")
         
         if not match_frame_count(cap, seq):
             cap.release()
             return
         cap.release()
    
    srt_lines = get_srt_lines(seq)
    srt_file_name = output_video_path.joinpath(video_file.stem).with_suffix(".srt")
    cp_video_file_name = output_video_path.joinpath(video_file.name)
    
    shutil.copyfile(video_file, cp_video_file_name)
    with open(srt_file_name, "w") as f:
        f.writelines(srt_lines)

############################## GEN SPLIT VIDEO HELPERS ##############################
def split_video_file(seq, video_file, output_video_path):
    cap = cv2.VideoCapture(str(video_file))
    if not cap.isOpened():
        print(f"Could not open {video_file}")
    
    segments = SEQ_RECS[seq]
    print(f"Processing: {video_file}")
    for k,segment in enumerate(segments):
        start_frame = segments[k][1]
        if k == len(segments) - 1:
            end_frame = SEQ_START_FRAMES[seq]["num_frames"]
        else:
            end_frame = segments[k+1][1]
        word = segments[k][0]

        if word == END_WORD:
            break
        elif word == START_WORD:
            while start_frame < end_frame:
                ret, _ = cap.read()
                if not ret:
                    raise ValueError("Couldn't read frame")
                start_frame += 1
        else:
            fourcc = cv2.VideoWriter_fourcc(*"avc1")
            fps = cap.get(cv2.CAP_PROP_FPS)
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            
            word_video_name = "_".join([video_file.stem, word])
            word_video_path = output_video_path.joinpath(word_video_name).with_suffix(".mp4")

            out = cv2.VideoWriter(str(word_video_path), fourcc, fps, (width, height))
            while start_frame < end_frame:
                ret, frame = cap.read()
                if not ret:
                    raise ValueError("Couldn't read frame")
                start_frame += 1
                out.write(frame)
            out.release()
            

############################## GEN DATASET HELPERS ##############################
def gather_data(seq, seq_landmarks, seq_metadata):
    corr_phrase = seq_metadata.phrase.split(" ")
    pred_and_frames = SEQ_RECS[seq][1:-1]
    data = []
    
    global WORD_ID
    for i in range(len(pred_and_frames)):
        if i < len(corr_phrase) and corr_phrase[i] == pred_and_frames[i][0]:
            data.append([WORD_ID, seq_metadata.participant_id, corr_phrase[i]])
            WORD_ID += 1
    return data

def add_to_dataset(seq, pt_metadata, pt_landmarks, dataset):
    seq_landmarks = pt_landmarks.loc[seq]
    seq_metadata = pt_metadata.loc[seq]
    
    data = gather_data(seq, seq_landmarks, seq_metadata)
    dataset.extend(data)

############################## MAIN PROGRAM ##############################
def run_main_pt(participant, dataset):
    pt_metadata = read_metadata(participant)
    pt_landmarks = read_landmarks(pt_metadata)

    get_seq_start_frames(pt_metadata, pt_landmarks)
    mlf_results = gather_mlf_results(pt_metadata, participant)
    
    output_video_path = OUTPUT_VIDEO_PARENT.joinpath(participant)
    output_video_path.mkdir(parents=True, exist_ok=True)
    segmented_seqs = list(SEQ_RECS.keys())

    # for seq in tqdm(segmented_seqs, desc="Sequences"):
    for seq in segmented_seqs:
        video_file = VIDEO_FILES.joinpath(pt_metadata.loc[seq].clipFilename)

        if args.gen_subtitles:
            subtitle_video_file(seq, video_file, output_video_path)
        elif args.gen_split_videos:
            split_video_file(seq, video_file, output_video_path)
        elif args.gen_dataset:
            add_to_dataset(seq, pt_metadata, pt_landmarks, dataset)
        else:
            print("pass. do nothing since nothing was passed.")

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    dataset = []
    # for participant in tqdm(args.participants, desc="Participants"):
    for participant in args.participants:
        run_main_pt(participant, dataset)
        SEQ_RECS.clear()
        SEQ_START_FRAMES.clear()

    if not args.gen_subtitles:
        print(dataset)

