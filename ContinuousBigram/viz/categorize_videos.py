import pickle
import argparse
import os
import shutil

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "--seq_id_pkl",
        type=str,
        default="./pt2_seq_ids.pkl",
        help="Pickle file with Seq ID breakdown."
    )
    
    parser.add_argument(
        "--vid_dir",
        type=str,
        default="./videos/participant93/",
        help="Directory with original videos."
    )
    
    parser.add_argument(
        "--cat_vid_dir",
        type=str,
        default="./categorized_videos/participant93",
        help="Directory with categorized videos."
    )

    return parser.parse_args()

def categorize_video(vid_name, correct_seq_ids, incorrect_seq_ids):
    print(vid_name)
    vid_loc = os.path.join(args.vid_dir, vid_name)
    seq_id = int(vid_name.split('_')[-3])
    
    if seq_id in correct_seq_ids:
        new_vid_loc = os.path.join(correct_vid_dir, vid_name)
    elif seq_id in incorrect_seq_ids:
        new_vid_loc = os.path.join(incorrect_vid_dir, vid_name)
    else:  # This happens because the training data was filtered in some way (usually will be the case)
        new_vid_loc = os.path.join(remaining_vid_dir, vid_name)

    os.link(vid_loc, new_vid_loc)

def clean_dir(directory):
    if os.path.exists(directory):
        shutil.rmtree(directory)
    os.makedirs(directory)

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    correct_vid_dir = os.path.join(args.cat_vid_dir, "correct_videos")
    incorrect_vid_dir = os.path.join(args.cat_vid_dir, "incorrect_videos")
    remaining_vid_dir = os.path.join(args.cat_vid_dir, "remaining_videos")

    clean_dir(correct_vid_dir)
    clean_dir(incorrect_vid_dir)
    clean_dir(remaining_vid_dir)

    with open(args.seq_id_pkl, "rb") as f:
        seq_id_split = pickle.load(f)
    
    correct_seq_ids = seq_id_split[1]
    incorrect_seq_ids = seq_id_split[2]

    vid_list = os.listdir(args.vid_dir)
    
    for vid_name in vid_list:
        categorize_video(vid_name, correct_seq_ids, incorrect_seq_ids)

