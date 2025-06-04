import argparse
import re
import os
import pickle

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        '--results_file',
        type=str,
        default='./results/supplemental/dl_cmp/dim20/thr1/train/interpall1/pt2/hresults.log_letter_grliwi_neg10ip_6state-pca20-gmm4_20its_5tri-its_tc50',
        help="Results file to analyze"
    )

    parser.add_argument(
        '--data_loc',
        type=str,
        default='./data/supplemental/dl_cmp/dim20/thr1/train/interpall1/pt2/data',
        help="Original Data Location"
    )

    parser.add_argument(
        '--output_file',
        type=str,
        default='./output/pt2_seq_ids.pkl',
        help="File to output Sequence IDs to"
    )

    return parser.parse_args()

def get_incorrect_sequence_ids():
    with open(args.results_file, "r") as f:
        lines = f.readlines()
        
    extract_lines = []
    for line in lines:
        if line.startswith("Aligned transcription: "):
            extract_lines.append(line.strip())
    
    sequence_ids = set()
    for line in extract_lines:
        search = re.search("[0-9]+\.lab", line)
        seq_id = os.path.splitext(search.group(0))[0]
        sequence_ids.add(int(seq_id))
    
    return sequence_ids

def get_all_sequence_ids():
    sequence_ids = os.listdir(args.data_loc)
    sequence_ids = set([int(seq_id) for seq_id in sequence_ids])
    return sequence_ids

if __name__ == "__main__":
    args = parse_args()
    print(args)

    incorrect_sequence_ids = get_incorrect_sequence_ids()
    all_sequence_ids = get_all_sequence_ids()
    correct_sequence_ids = all_sequence_ids - incorrect_sequence_ids

    print(f"{len(incorrect_sequence_ids)}")
    print(f"{len(all_sequence_ids)}")
    
    with open(args.output_file, "wb") as f:
        pickle.dump((all_sequence_ids, correct_sequence_ids, incorrect_sequence_ids), f)

