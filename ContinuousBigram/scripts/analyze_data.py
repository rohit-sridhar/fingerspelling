import os
import matplotlib.pyplot as plt
import argparse

from utils import *

LAB_PATH = "./ext/data/"
DATA_PATH = "./data_original/"

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '--analysis_type',
        type=str,
        choices=['frames_per_letter', 'phrases'],
        default='frames_per_letter',
        help="Type of analysis."
    )
    
    parser.add_argument(
        '--label_dir',
        type=str,
        default='./label/label_all',
        help="Types of label files to analyze."
    )
    
    parser.add_argument(
        '--data_dir',
        type=str,
        default='./data/data_all',
        help="Types of data files to analyze."
    )

    return parser.parse_args()

########## FRAMES PER LETTER ANALYSIS ##########
# Get files in a data path (leave out the extensions)
def get_files(data_path):
    files = os.listdir(data_path)
    files = list(set([os.path.splitext(f)[0] for f in files]))
    return files

# Get label count by file
def count_lines(f):
    with open(f, 'r') as handle:
        label_count = len(handle.readlines())
    
    return label_count

# Count frames in data file
def count_frames(f):
    with open(f, 'r') as handle:
        print(handle.readlines())

# Get frames per label (letter) for a given file
def get_file_frames_per_letter(f, frames_per_label, data_path, label_path):
    label_file = os.path.join(label_path, f + ".lab")
    data_file = os.path.join(data_path, f)
    
    num_labels = count_lines(label_file)
    num_frames = count_lines(data_file)

    label_counts.append(num_labels)
    frame_counts.append(num_frames)

    frames_per_label.append(num_frames / num_labels)

# Plot frames per letter for all files in data path/label path
def analyze_frames_per_letter(data_path, label_path):
    files = get_files(data_path)
    
    label_counts = []
    frame_counts = []
    frames_per_label = []

    for f in files:
        get_file_frames_per_letter(f, frames_per_label, data_path, label_path)
    
    plt.hist(frames_per_label)
    plt.savefig('output/frames_per_label.png')
    plt.close()

########## PHRASES ANALYSIS ##########
# Look at all labels and print out the tokens
def analyze_phrases(label_dir):
    label_files = get_label_files(label_dir)
    tokens = set()
    
    for label_file in label_files:
        label_path = os.path.join(label_dir, label_file)
        labels = collect_tokens(label_path, tokens)
        tokens.update(labels)
    print(sorted(list(tokens)))

if __name__ == "__main__":
    args = parse_args()
    print(args)

    if args.analysis_type == "frames_per_letter":
        analyze_frames_per_letter(args.data_dir, args.label_dir)
    elif args.analysis_type == "phrases":
        analyze_phrases(args.label_dir)

