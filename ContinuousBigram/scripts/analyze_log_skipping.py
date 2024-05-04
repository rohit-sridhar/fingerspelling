import re
import argparse

global args

CHARS = ''

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--log_file",
        type=str,
        default="logs/dim20/thr0/grliwi/output.log_neg13ip_3state-pca20-gmm4_20its_5tri-its_silsp",
        help="Location for log file to be analyzed."
    )

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    print(args)

    with open(args.log_file, "r") as f:
        lines = f.readlines()
    
    curr_char = ''
    for ln in lines:
        if re.match(""
        if re.fullmatch("Example [0-9]+ skipped\n", ln):
            print(ln)

