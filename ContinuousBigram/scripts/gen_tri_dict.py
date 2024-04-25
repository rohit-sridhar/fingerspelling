import argparse
import os

from utils import *

WRITTEN = set()
global args

#################### GENERAL HELPERS ####################

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "--label_loc",
        type=str,
        default="./label/thr8/label/",
        help="Label file location"
    )
    
    parser.add_argument(
        "--dict_loc",
        type=str,
        default="./dict/dict_tri2letter",
        help="New dict name"
    )
    
    parser.add_argument(
        "--dict_type",
        type=str,
        default="letter",
        choices = ['letter', 'word'],
        help="New dict file"
    )
    
    return parser.parse_args()

# Initialize the tri letter dictionary with sil/enter/exit vars
def initialize_dict():
    with open(args.dict_loc, 'w') as f:
        f.writelines([f'{ENTER} {ENTER}\n', f'{EXIT} {EXIT}\n', f'{SPACE} {SPACE}\n'])

# Write a single dictionary entry to file (triletter only)
def write_entry_to_file(entry):
    with open(args.dict_loc, "a") as f:
        if entry not in WRITTEN:
            f.write(entry + "\n")
            WRITTEN.add(entry)

#################### LETTER LEVEL FUNCTIONS ####################

# Process the first entry for any word
def process_first_triletter(word, letter=True):
    val = '+'.join([word[0],word[1]])
    entry = ' '.join([word[0], val])
    
    if letter:
        write_entry_to_file(entry)
    return val

# Process the last entry for any word
def process_last_triletter(word, letter=True):
    val = '-'.join([word[-2],word[-1]])
    entry = ' '.join([word[-1], val])
    
    if letter:
        write_entry_to_file(entry)
    return val

# Process the middle entry for any word (centered at i)
def process_middle_triletter(word, i, letter=True):
    val = '-'.join([word[i-1], word[i]])
    val = '+'.join([val, word[i+1]])
    entry = ' '.join([word[i], val])
    
    if letter:
        write_entry_to_file(entry)
    return val

# Write a single letter entry
def write_single_entry(word):
    entry = ' '.join([word, word])
    write_entry_to_file(entry)

# Write the entry for any word with more than 2 letters
def write_full_letter_entry(word):
    _ = process_first_triletter(word, letter=True)
    
    for i in range(1, len(word)-1):
        _ = process_middle_triletter(word, i, letter=True)
    
    _ = process_last_triletter(word, letter=True)

# Main Letter Level Wrapper that picks the correct entry writing function
def add_letter_to_dict(word):
    if len(word) == 1:
        write_single_entry(word)
    else:
        write_full_letter_entry(word)


#################### WORD LEVEL FUNCTIONS ####################

# Main Word Level Wrapper that aggregated triletter contexts for word dict
def get_full_word_entry(word):
    entries = [word]
    first_triletter = process_first_triletter(word, letter=False)
    entries.append(first_triletter)
    
    for i in range(1, len(word)-1):
        next_triletter = process_middle_triletter(word, i, letter=False)
        entries.append(next_triletter)

    last_triletter = process_last_triletter(word, letter=False)
    entries.append(last_triletter)
    return entries

# Adds all triletters for a given word to the dict
def add_word_to_dict(word):
    if len(word) == 1:
        write_single_entry(word)
    else:
        entries = get_full_word_entry(word)
        entry = ' '.join(entries)
        write_entry_to_file(entry)

# Ingests the whole label file into the dict
def ingest_label_file(label_filepath):
    tokens = collect_tokens(label_filepath)
    for word in tokens:
        if args.dict_type == "letter":
            add_letter_to_dict(word)
        elif args.dict_type == "word":
            add_word_to_dict(word)

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    label_files = get_label_files(args.label_loc)
    initialize_dict()
    
    for label_file in label_files:
        ingest_label_file(label_file)

