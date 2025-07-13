import argparse
import os
import sys
import json

from pathlib import Path
from utils import *

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    # TODO Make remaining args using Path instead of str
    parser.add_argument(
        "--metadata_file",
        type=Path,
        help="metadata file name"
    )

    parser.add_argument(
        "--label_loc",
        type=str,
        default="./label/thr8/label",
        help="label file location"
    )
    
    parser.add_argument(
        "--grammar_file",
        type=str,
        required=True,
        help="grammar file name"
    )

    return parser.parse_args()

def validate_grammar_file():
    return args.grammar_file.endswith('grammar_letter_isolated') or \
            args.grammar_file.endswith('grammar_letter_isolated_whole') or \
            args.grammar_file.endswith('grammar_word_isolated') or \
            args.grammar_file.endswith('grammar_word_isolated_sksp') or \
            args.grammar_file.endswith('grammar_word_isolated_whole') or \
            args.grammar_file.endswith('grammar_word_phrase_sksp')

def check_args(args):
    if not(validate_grammar_file()):
        raise ValueError("Must pass a grammar path that ends with appropriate filename")
    
########## WORD LEVEL GRAMMAR HELPERS ##########
# Get a sorted list of all tokens in the label directory. Does not include
# SPACE or ENTER/EXIT
def get_tokens():
    tokens = set()
    files = get_label_files(args.label_loc)
    
    for label_file in files:
        phrase_tokens = collect_tokens(label_file)
        for token in phrase_tokens:
            tokens.add(token)
    
    return sorted(list(tokens))

# Gets phrases from the label files
# def get_phrases(n_gram):
def get_phrases(whole=True):
    phrases = set()
    files = get_label_files(args.label_loc)

    for label_file in files:
        phrase = collect_tokens(label_file)
        if whole:
            phrase = [f"{{{token}}}" for token in phrase]
            phrases.add("".join(phrase))
        else:
            phrase = [f"{token}" for token in phrase]
            phrases.add(" ".join(phrase))
    
    return list(phrases)


########## LETTER LEVEL GRAMMAR HELPERS ##########
# Get a sorted list of all tokens in the label directory
# def get_letters(n_gram):
def get_letters():
    tokens = get_tokens()  # Get tokens to get letters from them
    letters = set([SPACE])
    
    for token in tokens:
        for i in range(len(token)):
            letters.add(token[i])

    return sorted(list(letters))

# Gets phrases from the label files
def get_words():
    tokens = get_tokens()  # Pass n gram 1 to just get tokens
    words = set()

    for token in tokens:
        word = ' '.join([*token])
        words.add(word)
    
    return list(words)

########## WORD LEVEL GRAMMAR WRITERS ##########
# Grammar for 1 gram
def write_word_grammar(tokens):
    token_options = ' | '.join(tokens)
    
    line_1 = f"$word = {token_options};\n"
    
    if args.grammar_file.endswith("grammar_word_isolated"):
        line_2 = f"({ENTER} {{ $word {SPACE} }} $word {EXIT})\n"
    elif args.grammar_file.endswith("grammar_word_isolated_sksp"):
        line_2 = f"({ENTER} {{ $word }} $word {EXIT})\n"
    elif args.grammar_file.endswith("grammar_word_isolated_whole"):
        line_2 = f"({ENTER} {{ $word }} $word {EXIT})\n"
    
    with open(args.grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

# Force the phrase (none gram)
def write_word_grammar_phrase(phrases):
    phrase_options = ' | '.join(phrases)

    line_1 = f"$phrase = {phrase_options};\n"
    line_2 = f"({ENTER} $phrase {EXIT})\n"

    with open(args.grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

########## LETTER LEVEL GRAMMAR WRITERS ##########
def write_letter_grammar(letters):
    letter_options = ' | '.join(letters)

    line_1 = f"$char = {letter_options};\n"
    line_2 = f"({ENTER} < $char > {EXIT})\n"
    
    with open(args.grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

if __name__ == "__main__":
    args = parse_args()
    check_args(args)
    print(args)
    
    if "letter" not in args.grammar_file:
        if args.grammar_file.endswith("_whole"):
            tokens = get_phrases(whole=True)
            write_word_grammar_phrase(tokens)
        elif args.grammar_file.endswith("_phrase_sksp"):
            tokens = get_phrases(whole=False)
            write_word_grammar_phrase(tokens)
        else:
            tokens = get_tokens()
            write_word_grammar(tokens)
    else:
        if args.grammar_file.endswith("_whole"):
            letters = get_tokens()
            letters = [f"{{{letter}}}" for letter in letters]
            write_letter_grammar(letters)
        else:
            letters = get_letters()
            write_letter_grammar(letters)

