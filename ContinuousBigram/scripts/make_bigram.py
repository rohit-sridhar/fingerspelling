import re
import os
import pickle

import numpy as np
import pandas as pd
import math

from utils import *

# SENTENCES_FILE = os.path.join(GRAMMAR_ROOT, "sentences.txt")
SENTENCES_FILE = os.path.join("results/bigram_results", "sentences.txt")
BIGRAM_PKL = os.path.join(OUTPUT_ROOT, "bigram_pt93.pickle")
RESULTS_MLF = "results/bigram_results/mlf_results/result.mlf_word0.dp"

def read_phrases():
    f = open(SENTENCES_FILE)
    data = f.read()
    f.close()

    phrases = data.split('\n')[:-1]
    phrases = [phrase.lower() for phrase in phrases]
    phrases = [phrase.split(': ')[1] for phrase in phrases]

    tokens = []
    for phrase in phrases:
        tokens += phrase.split(' ')
    tokens = list(set(tokens))

    tokens.append(ENTER)
    tokens.append(EXIT)

    return phrases, tokens


def get_token_map(tokens):
    token_dict = {}
    count = 0
    for token in tokens:
        token_dict[token] = count
        count += 1

    return token_dict


def modify_phrases(phrases):
    phrases = [ENTER + " " + phrase + " " + EXIT for phrase in phrases]
    return phrases

def getNGrams(wordlist, n):
    return [wordlist[i:i+n] for i in range(len(wordlist)-(n-1))]

def get_bigrams(phrases, tokens, token_map):
    count_array = np.zeros((len(tokens), len(tokens)), dtype=int)
    count_array = np.round(count_array, decimals=1)
    all_bigrams = []

    for i in phrases:
        wordlist = i.split()
        bigram_tmp = getNGrams(wordlist, 2)
        for one_bigram in bigram_tmp:
            count_array[token_map[one_bigram[0]], token_map[one_bigram[1]]] = count_array[token_map[one_bigram[0]], token_map[one_bigram[1]]] + 1
            
            all_bigrams.append(one_bigram)

    count_array = count_array ** BASE_PARAMETER + CONSTANT_PARAMETER
    count_array[token_map[ENTER]] = count_array[token_map[EXIT]] - CONSTANT_PARAMETER

    return count_array

def get_trigrams(phrases, tokens, token_map):
    count_array = np.zeros((len(tokens), len(tokens), len(tokens)), dtype=int)

    all_trigrams = []

    for phrase in phrases:
        wordlist = phrase.split()

        trigram_tmp = getNGrams(wordlist, 3)

        for trigram in trigram_tmp:
            index_1 = token_map[trigram[0]]
            index_2 = token_map[trigram[1]]
            index_3 = token_map[trigram[2]]
            
            count_array[index_1, index_2, index_3] += 1
            
            all_trigrams.append(trigram)

    count_array = count_array ** BASE_PARAMETER + CONSTANT_PARAMETER

    return count_array

def create_bigram():
    phrases, tokens = read_phrases()
    
    token_map = get_token_map(tokens)
    phrases_ = modify_phrases(phrases)

    count_array = get_bigrams(phrases_, tokens, token_map)
    count_array_norm = count_array / count_array.sum()
    weight_matrix = pd.DataFrame(count_array_norm, index=tokens, columns=tokens)

    with open(BIGRAM_PKL, "wb") as f:
        pickle.dump(weight_matrix, f)

    return weight_matrix

def create_trigram():
    phrases, tokens = read_phrases()

    token_map = get_token_map(tokens)
    phrases_ = modify_phrases(phrases)

    count_array = get_trigrams(phrases_, tokens, token_map)
    count_array_norm = count_array / count_array.sum()
    # weight_matrix = pd.DataFrame(count_array_norm, index=tokens, columns=tokens)
    
    weight_matrix = count_array_norm

    #with open(BIGRAM_PKL, "wb") as f:
    #    pickle.dump(weight_matrix, f)

    return weight_matrix

def load_phrases():
    phrase_words = []

    with open(SENTENCES_FILE,'r') as phrases:
        for line in phrases:
            line = line.rstrip().split()
            phrase_words.append(line[1:])

    return phrase_words

def get_num_words(phrase_words):
    num_words = 0

    for phrase in phrase_words:
        for word in phrase:
            num_words += 1

    return num_words

def execute_ngram(filename, bigram_weight_matrix=None, trigram_weight_matrix=None):
    hvite_out = open(filename,'r')
    trigram_result = []
    bigram_result = []
    bigram_file_output = "#!MLF!#"
    original_result = []
    if bigram_weight_matrix is None:
        bigram_weight_matrix = pickle.load(open(BIGRAM_PKL, 'rb'))
    
    phrase_words = load_phrases()
    num_words = get_num_words(phrase_words)
    next_line = hvite_out.readline()
    next_line = hvite_out.readline() # skipping first line ("#!MLF!#")
    while next_line:
        possible_sequences = []
        if "/data/hmm_modeling/fingerspelling/" in next_line: # new video
            bigram_file_output += "\n" + next_line[:-1]
            next_line = hvite_out.readline()
            sequence = []
            while next_line[0] != ".":
                vals = next_line.split()
                start_index, end_index, predicted_token, prob = vals
                prob = float(prob)
                sequence.append((predicted_token, prob, start_index, end_index))
                next_line = hvite_out.readline()
                if "///" in next_line:
                    possible_sequences.append(sequence)
                    sequence = []
                    next_line = hvite_out.readline()
            next_line = hvite_out.readline()
        else:
            next_line = hvite_out.readline()
        

        if trigram_weight_matrix is not None:
            _, tokens = read_phrases()
            token_map = get_token_map(tokens)
            best_prob = -math.inf
            best_sequence = None
            prev_token = prev_prev_token = None
            for sequence in possible_sequences:
                total_prob = math.log(1)
                for token, prob, _, _ in sequence:     
                    total_prob = total_prob + prob + (0 if prev_token == None or prev_prev_token == None else math.log(trigram_weight_matrix[token_map[prev_prev_token]][token_map[prev_token]][token_map[token]]))
                    prev_prev_token = prev_token
                    prev_token = token
                if total_prob > best_prob:
                    best_prob = total_prob
                    best_sequence = sequence
            print(f"Sequence with trigram   : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")
            trigram_result.append(' '.join(t[0] for t in best_sequence))

        best_prob = -math.inf
        best_sequence = None
        for sequence in possible_sequences:
            total_prob = math.log(1)
            for token, prob, _, _ in sequence:
                total_prob = total_prob + prob + (0 if token == "sil0" else math.log(bigram_weight_matrix[prev_token][token]) * 3.5)
                prev_token = token
            if total_prob > best_prob:
                best_prob = total_prob
                best_sequence = sequence
        print(f"Sequence with bigram    : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")
        bigram_result.append(' '.join(t[0] for t in best_sequence))
        
        for t in best_sequence:
            bigram_file_output += "\n" + " ".join([t[2], t[3], t[0], str(t[1])])
        bigram_file_output += "\n///\n."
        best_prob = -math.inf
        best_sequence = None
        for sequence in possible_sequences:
            total_prob = math.log(1)
            for token, prob, _, _ in sequence:
                total_prob = total_prob + prob + (0 if True else math.log(bigram_weight_matrix[prev_token][token]))
                prev_token = token
            if total_prob > best_prob:
                best_prob = total_prob
                best_sequence = sequence
        print(f"Sequence without ngram  : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")
        original_result.append(' '.join(t[0] for t in best_sequence))
        
    return original_result, bigram_result, trigram_result, bigram_file_output

def output_bigram(preds, hvite_lines):
    # This section outputs a basic MLF for usage in CER / HResults
    out_name = RESULTS_MLF + '.out'

    with open(out_name,'w') as out_file:
        for i in range(len(preds)):
            out_file.write(hvite_lines[i*41])
            out_file.write(hvite_lines[i*41+1])
            out_file.write('sil\n')
            out_file.write(preds[i]+"\n")
            out_file.write('sil\n')

def output_bigram_new():
    out_name = RESULTS_MLF + '.out'


if __name__ == "__main__":
    bigram_weight_matrix = create_bigram()
    trigram_weight_matrix = create_trigram()
    directory = 'results/bigram_results/mlf_results'
    filenames = os.listdir(directory)
    phrases, _ = read_phrases()
    original_count = 0
    bigram_count = 0
    trigram_count = 0
    total = 0
    preds = []
    for f in filenames:
        if "word" not in f:
            continue
        f_name = os.path.join(directory + "/", f)
        print(f_name)
        try:
            original, bigram, trigram, bigram_file_output = execute_ngram(f_name, bigram_weight_matrix, trigram_weight_matrix)
            # print("bigram_file_output:")
            # print(bigram_file_output)
        except Exception as e:
            print(f"Error in f_name file: {e}")
            continue
        mlf_out = open("results/bigram_results/mlf_results/mlf_results_out/"+f, "w")
        mlf_out.write(bigram_file_output)
        mlf_out.close()
        for phrase in bigram:
            preds += phrase.split()[1:-1] #skipping sil0 and sil1
        preds.append("return")
        for i in range(len(original)):
            if original[i][len("sil0 "):-len(" sil1")] in phrases:
                original_count += 1
            else:
                print(f'-{original[i][len("sil0 "):-len(" sil1")]}') 
            if bigram[i][len("sil0 "):-len(" sil1")] in phrases:
                bigram_count += 1
            if trigram[i][len("sil0 "):-len(" sil1")] in phrases:
                trigram_count += 1

            total += 1
        print("current score:", (bigram_count/total), (trigram_count/total), (original_count/total))
        
    print("final score:", (bigram_count/total), (trigram_count/total), (original_count/total))
    print("total:", total)

    print(f"preds: \n {preds}")
    

