import argparse

SPACE = '_'

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument(
        "--grammar_file",
        type=str,
        default="./grammar/grammar_word_isolated",
        help="Grammar file location"
    )
    
    parser.add_argument(
        "--dict_file",
        type=str,
        default="./dict/dict_tri2word",
        help="Label file location"
    )
    
    return parser.parse_args()

def get_tokens(dict_file):
    with open(dict_file, 'r') as df:
        lines = df.readlines()
    
    tokens = set()
    for line in lines:
        line_arr = line.split(' ')
        if line_arr[0] == SPACE or line_arr[0] == 'sil':
            continue
        tokens.add(line_arr[0])

    return sorted(list(tokens))

def write_grammar(tokens, grammar_file):
    token_options = ' | '.join(tokens)
    line_1 = f"$word = {token_options};\n"
    line_2 = "(sil { $word _ } $word sil)\n"
    with open(grammar_file, 'w') as f:
        f.writelines([line_1, "\n", line_2])

if __name__ == "__main__":
    args = parse_args()
    print(args)
    
    tokens = get_tokens(args.dict_file)
    write_grammar(tokens, args.grammar_file)
