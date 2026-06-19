#!/usr/bin/env python3

import traceback
import argparse
import sys
import os
import string
import logging

from utils import *
from pathlib import Path

# WRITTEN = set()
logger = logging.getLogger(__name__)

#################### GENERAL HELPERS ####################
# check if path is valid and if it exists
# TODO: Eventually this should be put in utils or a separate
# args file.
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

def _parse_args():
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
        help="label file location",
    )
    
    parser.add_argument(
        "--dict_loc",
        type=dict_path,
        required=True,
        help="dict location ",
    )
    
    parser.add_argument(
        "--dict_type",
        type=str,
        default="letter",
        choices = [
            "letter", "cross_letter", "word",
            "tri_letter", "tri_word", "tri_word_sksp",
            "cross_word", "tri_letter_whole", "tri_word_whole"
        ],
        help="dict type to generate."
    )
    
    return parser.parse_args()

# set up the logger for training moved to utils.setup_logger
# function removed from this file. See ContinuousBigram/scripts/utils.py for implementation.
def list_word_to_str(word):
    if isinstance(word, list):
        word = "".join(word)

    if not isinstance(word, str):
        raise TypeError(f"{word=} should be of type list or string.")
    
    return word

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
        # if entry not in WRITTEN:
        f.write(entry + "\n")
        #     WRITTEN.add(entry)

def split_list_by_delim(list_to_split, delim):
    split_list = [[]]
    for elem in list_to_split:
        if elem == delim:
            split_list.append([])
        else:
            split_list[-1].append(elem)
    return split_list

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
    word = list_word_to_str(word)
    
    entry_list = [word, word]
    if sksp:
        entry_list.append(SPACE)
    entry = ' '.join(entry_list)
    write_entry_to_file(entry)

# Write the entry for any word with more than 2 letters
def write_full_letter_entry(word):
    _ = process_first_triletter(word, letter=True)
    
    for i in range(1, len(word)-1):
        _ = process_middle_triletter(word, i, letter=True)
    
    _ = process_last_triletter(word, letter=True)

# Main Letter Level Wrapper that picks the correct entry writing function
def add_triletters_to_dict(word):
    if len(word) == 1:
        write_single_entry(word)
    else:
        write_full_letter_entry(word)

# #################### TRILETTER WHOLE LEVEL FUNCTIONS ####################
# # These functions treat words as letters and phrases as words, so the 
# # meaning of "letter" and "word" shifts.
# def add_whole_letter_to_dict(phrase):
#     tokens = phrase.split(SPACE)
#     tokens = [f"{{{token}}}" for token in tokens]
#     
#     if len(tokens) == 1:
#         write_single_entry(tokens)
#     else:
#         write_full_letter_entry(tokens)
# 
# def add_whole_word_to_dict(phrase):
#     tokens = phrase.split(SPACE)
#     tokens = [f"{{{token}}}" for token in tokens]
#     
#     if len(tokens) == 1:
#         write_single_entry(tokens)
#     else:
#         entries = get_full_word_entry(tokens)
#         entries[0] = ''.join(entries[0])
# 
#         entry = ' '.join(entries)
#         write_entry_to_file(entry)
    

#################### UNILETTER LEVEL FUNCTIONS ####################
def write_uniletter_dict(letters):
    # alphabet = string.ascii_lowercase
    with open(args.dict_loc, "w") as f:
        for letter in letters:
            if letter in {ENTER, EXIT, SPACE}:
                continue
            f.write(f"{letter} {letter}\n")

#################### TRILETTER WORD LEVEL FUNCTIONS ####################

# Main Word Level Wrapper that aggregated triletter contexts for word dict
def get_full_word_entry(word):
    word = list_word_to_str(word)
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
def add_triletter_word_to_dict(word, sksp=False):
    if len(word) == 1:
        write_single_entry(word, sksp)
    else:
        # word = word.strip(SPACE)
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
        word = list_word_to_str(word)
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
# word can be a list or a str
def add_uniletter_word_to_dict(word):
    spaced_word = ' '.join(word)
    logger.debug(f"{word=}")
    logger.debug(f"{spaced_word=}")

    word = list_word_to_str(word)

    with open(args.dict_loc, "a") as f:
        f.write(f"{word} {spaced_word}\n")

# Ingests the whole label file into the dict
def ingest_label_file(label_filepath):
    letters, _ = collect_letters_and_tokens(label_filepath)
    # phrase = SPACE.join(tokens)
    
    logger.debug(f"{label_filepath=}")
    logger.debug(f"{letters=}")
    # logger.debug(f"{phrase=}")
    
    if args.dict_type == "letter":
        write_uniletter_dict(letters)
    elif args.dict_type == "cross_letter":
        add_triletters_to_dict(letters)
    # case "tri_letter_whole":
    #     add_whole_letter_to_dict(phrase)
    # case "tri_word_whole":
    #     add_whole_word_to_dict(phrase)
    else:
        tokens = split_list_by_delim(letters, SPACE)
        logger.debug(f"Tokens after Splitting: {tokens}")
        for i,word in enumerate(tokens):
            if args.dict_type == "word":
                add_uniletter_word_to_dict(word)
            elif args.dict_type == "tri_letter":
                add_triletters_to_dict(word)
            elif args.dict_type == "tri_word":
                add_triletter_word_to_dict(word, sksp=False)
            elif args.dict_type == "tri_word_sksp":
                add_triletter_word_to_dict(word, sksp=True)
            elif args.dict_type == "cross_word":
                add_cross_word_to_dict(
                    word,
                    first=(i==0),
                    last=(i==len(tokens)-1),
                )
            else:
                logger.error(f"Unknown dict_type: {args.dict_type}")

def _main():
    setup_logger(
        args.dict_loc.parent / "log.txt",
        logger,
        log_level=logging.DEBUG if args.debug else logging.INFO,
        mode="w"
    )
    logger.info(args)
    initialize_dict()

    label_files = get_label_files(args.label_loc)
    letter_parser = AlphabetParser()
    for label_file in label_files[:5]:
        ingest_label_file(label_file)
    
    cmd = ["sort", "-u", "-o", str(args.dict_loc), str(args.dict_loc)]
    run_subprocess(cmd, logger=logger)

if __name__ == "__main__":
    try:
        args = _parse_args()
        _main()
    except Exception as e:
        logger.error(f"An unexpected exception {e} occurred during training or testing.")
        logger.error(f"{traceback.format_exc()}")
        logging.shutdown()

