import argparse

from utils import *
from tqdm import tqdm

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--label_loc",
        type=str,
        default=None,
        help="Label file location. If none, gathers phrases from metadata."
    )
    
    parser.add_argument(
        "--phrases_loc",
        type=str,
        default="./grammar/sentences.txt"
    )

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    label_files = get_label_files(args.label_loc)
    sentences = []

    for label_path in tqdm(label_files):
        labels = collect_tokens(label_path)
        sentence = ENTER + ' ' + ' '.join(labels) + ' ' + EXIT + '\n'
        sentences.append(sentence)
    
    with open(args.phrases_loc, 'w') as f:
        f.writelines(sentences)
    

