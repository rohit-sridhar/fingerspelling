import argparse
import os

from glob import glob
from utils import *

global args

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--grammar_type",
        type=str,
        default="word",
        choices=["word", "letter"],
        help="Grammar type (word or letter)."
    )
    
    parser.add_argument(
        "--n_gram",
        type=int,
        default=1,
        help="Generates n gram grammar. For n = 1, it is an isolated word grammar. For n = None, it uses the whole phrase."
    )
    
    parser.add_argument(
        "--label_loc",
        type=str,
        default="./label/thr8/label",
        help="Label file location"
    )
    
    return parser.parse_args()

########## GENERIC HELPERS ##########
def get_grammar_file():
    root = "grammar"
    if args.n_gram is not None:
        suffix = str(args.n_gram) + "gram" if args.n_gram > 1 else "isolated"
    else:
        suffix = "phrase" if args.grammar_type == "word" else "word"
    
    return os.path.join(root, SPACE.join([root, args.grammar_type, suffix]))


########## WORD LEVEL GRAMMAR HELPERS ##########
# Get a sorted list of all tokens in the label directory. Does not include
# SPACE or ENTER/EXIT
def get_tokens(n_gram):
    tokens = set()
    files = get_label_files(args.label_loc)
    
    for label_file in files:
        phrase_tokens = collect_tokens(label_file)
        if len(phrase_tokens) <= n_gram:
            tokens.add(f" {SPACE} ".join(phrase_tokens))
        else:
            for i in range(len(phrase_tokens) - (n_gram - 1)):
                tokens.add(f" {SPACE} ".join(phrase_tokens[i:i+n_gram]))
    
    return sorted(list(tokens))

# Gets phrases from the label files
def get_phrases():
    phrases = set()
    files = get_label_files(args.label_loc)

    for label_file in files:
        phrase = collect_tokens(label_file)
        phrases.add(f" {SPACE} ".join(phrase))
    
    return list(phrases)


########## LETTER LEVEL GRAMMAR HELPERS ##########
# Get a sorted list of all tokens in the label directory
def get_letters(n_gram):
    tokens = get_tokens(1)  # Get tokens to get letters from them
    letters = set([SPACE])
    
    for token in tokens:
        if len(token) <= n_gram:
            letters.add(" ".join([*token]))
        else:
            for i in range(len(token) - (n_gram - 1)):
                letters.add(" ".join(token[i:i+n_gram]))

    return sorted(list(letters))

# Gets phrases from the label files
def get_words():
    tokens = get_tokens(1)  # Pass n gram 1 to just get tokens
    words = set()

    for token in tokens:
        word = ' '.join([*token])
        words.add(word)
    
    return list(words)

########## WORD LEVEL GRAMMAR WRITERS ##########
# Grammar for 1 gram
def write_word_grammar(tokens, grammar_file):
    token_options = ' | '.join(tokens)
    
    line_1 = f"$word = {token_options};\n"
    line_2 = f"({ENTER} {{ $word {SPACE} }} $word {EXIT})\n"
    
    with open(grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

# Force the phrase (none gram)
def write_word_grammar_phrase(phrases, grammar_file):
    phrase_options = ' | '.join(phrases)

    line_1 = f"$phrase = {phrase_options};\n"
    line_2 = f"({ENTER} $phrase {EXIT})\n"

    with open(grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

########## LETTER LEVEL GRAMMAR WRITERS ##########
def write_letter_grammar(letters, grammar_file):
    letter_options = ' | '.join(letters)

    line_1 = f"$char = {letter_options};\n"
    line_2 = f"({ENTER} < $char > {EXIT})\n"
    
    with open(grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    grammar_file = get_grammar_file()

    if args.grammar_type == "word":
        if args.n_gram is None:
            phrases = get_phrases()
            write_word_grammar_phrase(phrases, grammar_file)
        else:
            tokens = get_tokens(args.n_gram)
            write_word_grammar(tokens, grammar_file)
    else:
        if args.n_gram is None:
            words = get_words()
            write_word_grammar(words, grammar_file)
        else:
            letters = get_letters(args.n_gram)
            write_letter_grammar(letters, grammar_file)

