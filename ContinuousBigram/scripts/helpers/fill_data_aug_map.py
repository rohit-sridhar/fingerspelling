import argparse
import json
import os

from utils import *

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--data_aug_map",
        type=str,
        required=True,
        help="Pass the data aug map json file"
    )
    
    parser.add_argument(
        "--data_loc",
        type=str,
        required=True,
        help="Data location with files named by seq id."
    )

    parser.add_argument(
        "--clear_map",
        action="store_true",
        help="Clear the existing data aug map json file"
    )

    return parser.parse_args()

def fill_data_aug_map():
    if args.clear_map:
        data_aug_map = {}
    else:
        with open(args.data_aug_map, "r") as f:
            data_aug_map = json.load(f)
    
    data_files = os.listdir(args.data_loc)
    for data_file in data_files:
        data_aug_map[data_file] = get_data_aug_entry(data_file, "copy", data_file)

    with open(args.data_aug_map, "w") as f:
        json.dump(data_aug_map, f, indent=4)

if __name__ == "__main__":
    args = parse_args()
    print(args)

    fill_data_aug_map()

