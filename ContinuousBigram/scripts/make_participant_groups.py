import copy
import random
import pprint
import argparse

FPL1 = ["FPL1", 175, 128, 117, 155, 122, 207, 33, 223, 121, 137, 150, 54, 251, 203, 141, 245, 157, 166, 246, 143, 40, 253, 47, 20, 219, 158, 213, 63, 111, 240, 53, 136, 216, 27, 239, 89, 196, 51, 107, 56, 73, 81, 22, 113, 26, 0, 241, 184, 227, 109, 188, 6, 38, 221, 181, 195, 9, 95, 31, 13, 112, 242, 135, 2, 254, 161, 15, 93]
FPL2 = ["FPL2", 253, 47, 20, 219, 158, 213, 63, 111, 240, 53, 136, 216, 27, 239, 89, 196, 51, 107, 56, 73, 81, 22, 113, 26, 0, 241, 184, 227, 109, 188, 6, 38, 221, 181, 195, 9, 95, 31, 13, 112, 242, 135, 2, 254, 161, 15, 93]
FPL3 = ["FPL3", 31, 13, 112, 242, 135, 2, 254, 161, 15, 93]

PT_GROUPS = [FPL1, FPL2, FPL3]

# Number of sets to generate per FPL group (above)
M_SETS = 3

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--n", type=int, default=1, help="leave n out")
    parser.add_argument("--seed", type=int, default=4637, help="leave n out")

    return parser.parse_args()

def leave_n_out(n=1):
    groups = {}
    for pt_group in PT_GROUPS:
        val = random.sample(pt_group[1:], n*M_SETS)
        # print(f"Full Val Sample: {val}")
        for i,pt in enumerate(val[::n]):
            i = i*n
            # print(f"Val Subset: {val[i:i+n]}")
            train = copy.deepcopy(pt_group[1:])
            for pt in val[i:i+n]:
                train.remove(pt)
        
            if pt_group[0] not in groups:
                groups[pt_group[0]] = [(train, val[i:i+n])]
            else:
                groups[pt_group[0]].append((train, val[i:i+n]))
        # print()
    # print()
            
    return groups

def print_groups(leave_one_out):
    for group in leave_one_out:
        for pt_set in leave_one_out[group]:
            print(pt_set)
        print()
    print()

if __name__ == "__main__":
    args = parse_args()
    random.seed(args.seed)

    groups = leave_n_out(n=args.n)
    print_groups(groups)
