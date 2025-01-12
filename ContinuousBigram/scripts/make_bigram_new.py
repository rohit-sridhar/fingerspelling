import re
import os
import pickle

import numpy as np
import pandas as pd
import math

from utils import *

SENTENCES_FILE = os.path.join(GRAMMAR_ROOT, "sentences.txt")
BIGRAM_PKL = os.path.join(OUTPUT_ROOT, "bigram_pt93.pickle")
RESULTS_MLF = "ext/result.mlf_word0.db"

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
    count_array = np.round(count_array, decimals=1)
    all_trigrams = []

    for i in phrases:
        wordlist = i.split()
        trigram_tmp = getNGrams(wordlist, 3)
        for one_trigram in trigram_tmp:
            count_array[token_map[one_trigram[0]], token_map[one_trigram[1]], token_map[one_trigram[2]]] = count_array[token_map[one_trigram[0]], token_map[one_trigram[1]], token_map[one_trigram[2]]] + 1

            all_trigrams.append(one_trigram)

    count_array = count_array ** BASE_PARAMETER + CONSTANT_PARAMETER
    # count_array[token_map[ENTER]] = count_array[token_map[EXIT]] - CONSTANT_PARAMETER

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

def execute_ngram(bigram_weight_matrix=None, trigram_weight_matrix=None):
    hvite_out = open(RESULTS_MLF,'r')
    if bigram_weight_matrix is None:
        bigram_weight_matrix = pickle.load(open(BIGRAM_PKL, 'rb'))
    
    phrase_words = load_phrases()
    num_words = get_num_words(phrase_words)
    next_line = hvite_out.readline()
    next_line = hvite_out.readline() # skipping first line ("#!MLF!#")
    while next_line:
        possible_sequences = []
        if "/data/hmm_modeling/fingerspelling/" in next_line: # new video
            next_line = hvite_out.readline()
            sequence = []
            while next_line[0] != ".":
                vals = next_line.split()
                _, _, predicted_token, prob = vals
                prob = float(prob)
                sequence.append((predicted_token, prob))
                next_line = hvite_out.readline()
                if "///" in next_line:
                    possible_sequences.append(sequence)
                    sequence = []
                    next_line = hvite_out.readline()
            next_line = hvite_out.readline()
        else:
            next_line = hvite_out.readline()
        
        _, tokens = read_phrases()
        token_map = get_token_map(tokens)
        best_prob = -math.inf
        best_sequence = None
        prev_token = prev_prev_token = None
        for sequence in possible_sequences:
            total_prob = math.log(1)
            for token, prob in sequence:     
                total_prob = total_prob + prob + (0 if prev_token == None or prev_prev_token == None else math.log(trigram_weight_matrix[token_map[prev_prev_token]][token_map[prev_token]][token_map[token]]))
                prev_prev_token = prev_token
                prev_token = token
            if total_prob > best_prob:
                best_prob = total_prob
                best_sequence = sequence
        print(f"Sequence with trigram   : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")
        
        best_prob = -math.inf
        best_sequence = None
        for sequence in possible_sequences:
            total_prob = math.log(1)
            for token, prob in sequence:
                total_prob = total_prob + prob + (0 if token == "sil0" else math.log(bigram_weight_matrix[prev_token][token]))
                prev_token = token
            if total_prob > best_prob:
                best_prob = total_prob
                best_sequence = sequence
        print(f"Sequence with bigram    : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")

        best_prob = -math.inf
        best_sequence = None
        for sequence in possible_sequences:
            total_prob = math.log(1)
            for token, prob in sequence:
                total_prob = total_prob + prob + (0 if True else math.log(bigram_weight_matrix[prev_token][token]))
                prev_token = token
            if total_prob > best_prob:
                best_prob = total_prob
                best_sequence = sequence
        print(f"Sequence without ngram  : {' '.join(t[0] for t in best_sequence)}; log(prob): {best_prob}")


if __name__ == "__main__":
    bigram_weight_matrix = create_bigram()
    trigram_weight_matrix = create_trigram()
    r = execute_ngram(bigram_weight_matrix, trigram_weight_matrix)


