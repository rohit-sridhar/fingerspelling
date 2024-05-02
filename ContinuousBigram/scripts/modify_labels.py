import os
import argparse

from tqdm import tqdm

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--old_label_loc",
        type=str,
        default="./label/silentspeller.bk/label",
        help="Location for label files to be edited"
    )
    
    parser.add_argument(
        "--new_label_loc",
        type=str,
        default=None,
        help="Location to store new labels (pass None for in place editing)"
    )
    
    parser.add_argument(
        "--old_label",
        type=str,
        default="sil",
        help="Old label (should be the entire line of label file)"
    )
    
    parser.add_argument(
        "--new_label",
        type=str,
        default=None,
        help="New label"
    )

    parser.add_argument(
        "--edit_type",
        type=str,
        default=None,
        choices=["replace", "remove", "repl_body", "repl_head", "repl_tail"],
        help="Replace one label with another. Remove removes the label. repl_body replaces every label except the head/tail. repl_head/repl_tail replace the head/tail respectively."
    )

    return parser.parse_args()

def check_args():
    if args.new_label_loc is None:
        args.new_label_loc = args.old_label_loc

    if not os.path.exists(args.new_label_loc):
        os.makedirs(args.new_label_loc)
    
    args.old_label = add_newline(args.old_label)
    if args.new_label is not None:
        args.new_label = add_newline(args.new_label)
    elif args.edit_type != "remove":
        raise ValueError("New Label must not be None if edit_type is replace, repl_body or repl_head/repl_tail.")

# Add newline to label if there isn't one already
def add_newline(label):
    if not(label.endswith("\n")):
        label += "\n"
    return label

# Write new label file to path
def write_new_labfile(labels, labfile):
    new_labpath = os.path.join(args.new_label_loc, labfile)
    with open(new_labpath, "w") as f:
        f.writelines(labels)

# Edit label file based on edit type
def edit_labfile(label_path):
    with open(label_path, 'r') as lab:
        labels = lab.readlines()
    
    labels[-1] = add_newline(labels[-1])

    new_labels = []
    if args.edit_type == "repl_head":
        new_labels.append(args.new_label)
        labels = labels[1:]
    elif args.edit_type == "repl_tail":
        tail = args.new_label
        labels = labels[:-1]
    elif args.edit_type == "repl_body":
        new_labels.append(labels[0])
        tail = labels[-1]
        labels = labels[1:-1]
    
    for i in range(len(labels)):
        if labels[i] == args.old_label:
            if args.edit_type == "replace" or args.edit_type == "repl_body":
                new_labels.append(args.new_label)
            elif args.edit_type == "remove":
                continue
            else:
                new_labels.append(labels[i])
        else:
            new_labels.append(labels[i])
    
    if args.edit_type == "repl_body" or args.edit_type == "repl_tail":
        new_labels.append(tail)
    
    return new_labels

if __name__ == "__main__":
    args = parse_args()
    print(args)
    check_args()
    
    filelist = os.listdir(args.old_label_loc)
    filelist.sort()
    
    for labfile in tqdm(filelist):
        label_path = os.path.join(args.old_label_loc, labfile)
        new_labels = edit_labfile(label_path)
        write_new_labfile(new_labels, labfile)
    
