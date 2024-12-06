import argparse
import re

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("--log_file", type=str, default=None, required=True, help="Analyze logs.")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    print(args)

    with open(args.log_file, "r") as f:
        lines = f.readlines()
    
    skip_nums = set()
    frame_nums = []
    lines = [ln.strip() for ln in lines]

    for ln in lines:
        if re.match("[0-9]+ speech frames accumulated", ln):
            num_frames = re.search("[0-9]+", ln)
            frame_nums.append(int(num_frames.group(0)))
        if re.match("Example [0-9]+ skipped$", ln):
            skip_num = re.search("[0-9]+", ln)
            match = skip_num.group(0)
            # if int(match) > 50000:
            #     print(ln)
            #     print(int(match))
            #     print()
            skip_nums.add(int(match))

    print(f"Skipped: {len(skip_nums)}, Accumulated: {sum(frame_nums)}")

