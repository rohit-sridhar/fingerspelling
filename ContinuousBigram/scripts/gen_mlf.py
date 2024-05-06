import argparse
import os

from glob import glob
from utils import *

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--ext_loc",
        type=str,
        required=True,
        help="Ext files location."
    )
    
    parser.add_argument(
        "--datafiles_list",
        type=str,
        required=True,
        help="Data files list."
    )
    
    parser.add_argument(
        "--mlf_file",
        type=str,
        required=True,
        help="Location for new mlf file."
    )
    
    parser.add_argument(
        "--mlf_type",
        type=str,
        default="letter",
        choices=["letter","word"],
        help="Type of mlf to create."
    )
    
    parser.add_argument(
        "--sample_period",
        type=int,
        default=1000,
        help="Sample Period (in ms)"
    )
    
    parser.add_argument(
        "--skip_space",
        action="store_true",
        help="Boolean indicating whether to skip spaces (as defined in scripts/utils.py)"
    )
    
    return parser.parse_args()

# Initialize the MLF File
def init_mlf_file():
    with open(args.mlf_file, "w") as f:
        f.write("#!MLF!#\n")

# Get the start/end label timestamps
def get_label_ts(labels, total_duration, num_labels):
    label_ts = []
    start_time = 0
    i = 0

    for label in labels:
        if label.startswith(SPACE) or label.startswith(ENTER) or label.startswith(EXIT):
            i = i + 1
        else:
            i = i + len(label.strip())
        print(i)
        end_time = total_duration * (i / num_labels)
        label_ts.append((str(int(start_time)), str(int(end_time))))
        start_time = end_time
    
    return label_ts

# Remove spaces from label list
def remove_spaces(labels):
    new_labels = []
    for label in labels:
        if label.startswith(SPACE):
            continue
        else:
            new_labels.append(label)
    return new_labels

# Write to mlf file
def write_to_mlf(label_path, labels, label_ts):
    label_lines = [' '.join((times[0], times[1], label)) for label, times in zip(labels, label_ts)]
    with open(args.mlf_file, "a") as f:
        f.write("\"" + label_path + "\"\n")
        f.writelines(label_lines)
        f.write(".\n")

# Get label level info
def get_label_info(data_file):
    label_file = os.path.join(args.ext_loc, os.path.basename(data_file)) + ".lab"
    with open(label_file, "r") as f:
        labels = f.readlines()

    with open(data_file, "r") as f:
        num_lines = len(f.readlines())
    
    num_labels = len(labels)
    if args.mlf_type == "letter" and args.skip_space:
        labels = remove_spaces(labels)
        num_labels = len(labels)
    elif args.mlf_type == "word":
        labels = get_word_labels(labels)
    
    total_duration = args.sample_period * num_lines 
    label_path = os.path.abspath(label_file)
    
    print(label_path)
    label_ts = get_label_ts(labels, total_duration, num_labels)
    print()
    return label_path, labels, label_ts

# Generate the letter level mlf
def gen_mlf():
    with open(args.datafiles_list, "r") as f:
        datafiles = f.readlines()
    
    datafiles = [data_file.strip() for data_file in datafiles]
    for data_file in datafiles:
        label_path, labels, label_ts = get_label_info(data_file)
        write_to_mlf(label_path, labels, label_ts)

# Get the word labels
def get_word_labels(labels):
    word_labels = [labels[0]]
    word = ""
    
    for label in labels[1:]:
        if label.startswith(SPACE) or label.startswith(EXIT):
            word_labels.append(word + "\n")
            if not(label.startswith(SPACE) and args.skip_space):
                word_labels.append(label)
            word = ""
        else:
            word += label.strip()

    return word_labels

if __name__ == "__main__":
    args = parse_args()
    print(args)

    init_mlf_file()
    gen_mlf()

