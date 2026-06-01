#!/usr/bin/env python

import argparse
import sys
import os
import string
import logging

from utils import *
from pathlib import Path

WRITTEN = set()
global args

logger = logging.getLogger(__name__)

#################### GENERAL HELPERS ####################
# check if path is valid and if it exists
def label_path(pth):
    try:
        pth = Path(pth)
    except ValueError:
        raise argparse.ArgumentTypeError(f"{pth} not a valid path.")
    
    if not pth.is_dir():
        raise argparse.ArgumentTypeError(f"{pth} must be a directory.")
    
    pth = pth.resolve()
    if not str(pth)[len(ROOT)+1:].startswith("label") or not str(pth)[len(ROOT)+1:].endswith("label"):
        raise ValueError("The directory directly under ROOT and the leaf must be named \"label\".")
    
    return pth

# check if path is valid and if it exists
def dict_path(pth):
    try:
        pth = Path(pth)
    except ValueError:
        raise argparse.ArgumentTypeError(f"{pth} not a valid path.")
    
    pth = pth.resolve()
    if not str(pth)[len(ROOT)+1:].startswith("dict") and not str(pth.parent)[len(ROOT)+1:].endswith("dict"):
        raise ValueError("The directory directly under ROOT and the leaf must be named \"dict\".")

    return pth

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "--debug", "-dbg",
        action="store_true",
        help="run in debug mode",
    )
    parser.add_argument(
        "--label_loc",
        type=label_path,
        required=True,
        help="Label file location",
    )
    
    parser.add_argument(
        "--dict_loc",
        type=dict_path,
        required=True,
        help="New dict name",
    )
    
    parser.add_argument(
        "--dict_type",
        type=str,
        default="letter",
        choices = ['letter', 'word', 'tri_letter', 'tri_letter_whole', 'tri_word', 'tri_word_whole', 'tri_word_sksp', 'cross_letter', 'cross_word'],
        help="New dict file"
    )
    
    return parser.parse_args()

# set up the logger for training moved to utils.setup_logger
# function removed from this file. See ContinuousBigram/scripts/utils.py for implementation.

# Initialize the tri letter dictionary with sil/enter/exit vars
def initialize_dict():
    with open(args.dict_loc, 'w') as f:
        if args.dict_type.startswith("cross_") or \
                args.dict_type.endswith("_sksp") or \
                args.dict_type.endswith("_whole"):
            f.writelines([f'{ENTER} {ENTER}\n', f'{EXIT} {EXIT}\n'])
        else:
            f.writelines([f'{ENTER} {ENTER}\n', f'{EXIT} {EXIT}\n', f'{SPACE} {SPACE}\n'])

# Write a single dictionary entry to file (triletter only)
def write_entry_to_file(entry):
    with open(args.dict_loc, "a") as f:
        if entry not in WRITTEN:
            f.write(entry + "\n")
            WRITTEN.add(entry)

#################### TRILETTER LEVEL FUNCTIONS ####################

# Process the first entry for any word
def process_first_triletter(word, letter=True):
    logger.debug(f"{word=}")
    try:
        val = '+'.join([word[0],word[1]])
    except:
        raise ValueError(word)
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
def write_single_entry(word, sksp=False):
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

#################### TRILETTER WHOLE LEVEL FUNCTIONS ####################
def add_whole_letter_to_dict(phrase):
    tokens = phrase.split(SPACE)
    tokens = [f"{{{token}}}" for token in tokens]
    
    if len(tokens) == 1:
        write_single_entry(tokens)
    else:
        write_full_letter_entry(tokens)

def add_whole_word_to_dict(phrase):
    tokens = phrase.split(SPACE)
    tokens = [f"{{{token}}}" for token in tokens]
    
    if len(tokens) == 1:
        write_single_entry(tokens)
    else:
        entries = get_full_word_entry(tokens)
        entries[0] = ''.join(entries[0])

        entry = ' '.join(entries)
        write_entry_to_file(entry)
    

#################### UNILETTER LEVEL FUNCTIONS ####################
def write_uniletter_dict():
    alphabet = string.ascii_lowercase
    with open(args.dict_loc, 'a') as f:
        for letter in alphabet:
            f.write(f"{letter} {letter}\n")

#################### TRILETTER WORD LEVEL FUNCTIONS ####################

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
def add_word_to_dict(word, sksp=False):
    if len(word) == 1:
        write_single_entry(word, sksp)
    else:
        word = word.strip(SPACE)
        entries = get_full_word_entry(word)

        ### NOTE about the if statement below.
        # Counterintuitive but is the way it should be.
        # when skipping space, they don't go away. They
        # are appended to the end of the word. When not
        # skipping spaces mlf word doesn't model them and
        # leaves them at the letter level.
        if sksp:
            entries.append(SPACE)

        entry = ' '.join(entries)
        write_entry_to_file(entry)

def add_cross_word_to_dict(word, first=False, last=False):
    if first and last:
        logger.info(f"phrase consists of just {word}")

    if len(word) == 1:
        entries = [word, word]
    else:
        entries = get_full_word_entry(word)

    if not first:
        entries[1] = f"{SPACE}-{entries[1]}"
    if not last:
        entries[-1] = f"{entries[-1]}+{SPACE}"

    logger.debug(f"{entries=}")
    entry = ' '.join(entries)
    write_entry_to_file(entry)

#################### UNILETTER WORD LEVEL FUNCTIONS ####################
def add_uniletter_word_to_dict(word):
    spaced_word = ' '.join(word)
    with open(args.dict_loc, "a") as f:
        f.write(f"{word} {spaced_word}\n")

# Ingests the whole label file into the dict
def ingest_label_file(label_filepath):
    tokens = collect_tokens(label_filepath)
    logger.debug(f"{label_filepath=}")
    phrase = SPACE.join(tokens)
    if args.dict_type == "cross_letter":
        logger.debug(f"{phrase=}")
        add_letter_to_dict(phrase)
    elif args.dict_type == "tri_letter_whole":
        add_whole_letter_to_dict(phrase)
    elif args.dict_type == "tri_word_whole":
        add_whole_word_to_dict(phrase)
    else:
        for i,word in enumerate(tokens):
            if args.dict_type == "word":
                add_uniletter_word_to_dict(word)
            elif args.dict_type == "tri_letter":
                add_letter_to_dict(word)
            elif args.dict_type == "tri_word":
                add_word_to_dict(word, sksp=False)
            elif args.dict_type == "tri_word_sksp":
                add_word_to_dict(word, sksp=True)
            # Note we don't use the sksp arg with dict_type cross_word
            elif args.dict_type == "cross_word":
                add_cross_word_to_dict(
                    word,
                    first=(i==0),
                    last=(i==len(tokens)-1),
                )

if __name__ == "__main__":
    args = parse_args()
    setup_logger(log_dir=args.dict_loc.parent, log_level=logging.DEBUG if args.debug else logging.INFO, stdout=False)
    logger.info(args)
    
    initialize_dict()
    if args.dict_type == "letter":
        write_uniletter_dict()
    else:
        label_files = get_label_files(args.label_loc)
        for label_file in label_files:
            ingest_label_file(label_file)

