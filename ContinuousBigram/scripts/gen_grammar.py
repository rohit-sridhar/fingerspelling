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
        choices=["word", "word_sksp", "letter", "cross_word"],
        help="Grammar type (word or letter)."
    )
    
#################################################################
##### THIS IS THE OLD WAY OF DOING N GRAMS (ALSO INCORRECT) #####
#################################################################

    # parser.add_argument(
    #     "--n_gram",
    #     type=int,
    #     default=1,
    #     help="For now you can only use n >= 1, (positive ints only)."
    # )
    
    parser.add_argument(
        "--label_loc",
        type=str,
        default="./label/thr8/label",
        help="Label file location"
    )
    
    # parser.add_argument(
    #     "--grammar_file",
    #     type=str,
    #     required=True,
    #     help="Grammar file name"
    # )

    return parser.parse_args()

# def check_args(args):
#     if args.n_gram <= 0:
#         raise ValueError("Must pass n_gram > 0 (positive ints only)")

########## GENERIC HELPERS ##########
# def get_grammar_file():
#     root = args.grammar_file_root
#     if args.n_gram is not None:
#         suffix = str(args.n_gram) + "gram" if args.n_gram > 1 else "isolated"
#     else:
#         suffix = "phrase" if args.grammar_type == "word" else "word"
#     
#     return os.path.join(root, SPACE.join([root, args.grammar_type, suffix]))


########## WORD LEVEL GRAMMAR HELPERS ##########
# Get a sorted list of all tokens in the label directory. Does not include
# SPACE or ENTER/EXIT
def get_tokens(n_gram):
    tokens = set()
    files = get_label_files(args.label_loc)
    
    for label_file in files:
        phrase_tokens = collect_tokens(label_file)
        if len(phrase_tokens) <= n_gram:
            # tokens.add(f" {SPACE} ".join(phrase_tokens))
            tokens.add(f" ".join(phrase_tokens))
        else:
            for i in range(len(phrase_tokens) - (n_gram - 1)):
                # tokens.add(f" {SPACE} ".join(phrase_tokens[i:i+n_gram]))
                tokens.add(f" ".join(phrase_tokens[i:i+n_gram]))
    
    return sorted(list(tokens))

# Gets phrases from the label files
def get_phrases():
    phrases = set()
    files = get_label_files(args.label_loc)

    for label_file in files:
        phrase = collect_tokens(label_file)
        phrases.add(f"{SPACE}".join(phrase))
    
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
    if args.grammar_type == "cross_word":
        line_2 = f"({ENTER} < $word > {EXIT})\n"  # This may be incorrect
    else:
        # line_2 = f"({ENTER} < $word {SPACE} > $word {EXIT})\n"
        if args.grammar_type == "word":
            line_2 = f"({ENTER} {{ $word _ }} $word {EXIT})\n"
        elif args.grammar_type == "word_sksp":
            line_2 = f"({ENTER} {{ $word }} $word {EXIT})\n"
    
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
    # check_args(args)
    print(args)
    
    if args.grammar_type == "letter":
        grammar_file = "grammar/grammar_letter_isolated"
    elif args.grammar_type == "word":
        grammar_file = "grammar/grammar_word_isolated"
    else:
        grammar_file = "grammar/grammar_word_isolated_sksp"

    if "letter" not in args.grammar_type:
        # tokens = get_tokens(args.n_gram)
        tokens = get_tokens(1)
        write_word_grammar(tokens, grammar_file)
    else:
        # letters = get_letters(args.n_gram)
        letters = get_letters(1)
        write_letter_grammar(letters, grammar_file)

