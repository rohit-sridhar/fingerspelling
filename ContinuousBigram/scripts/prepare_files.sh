#!/bin/ksh

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

echo "Housekeeping ...."
find $2/* -type f | sort -V  > datafiles
rm -rf ext/data/
rm -f ext/done
mkdir ext/data/
cp -r $3/* ext/data/

OPTIONS_FILE=$1

echo "Generating ext files ...."
scripts/gen_ext_files.sh $OPTIONS_FILE
find ext/data/*.ext -type f | xargs readlink -f | sort -V > all-extfiles

echo "Generating mlf (letter/word/phrase) files ...."
scripts/gen_mlf_split.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_letter
scripts/gen_mlf_word.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_word
scripts/gen_mlf_word.sh datafiles ext $OPTIONS_FILE "1" > mlf/labels.mlf_word_sksp
scripts/gen_mlf_phrase.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_phrase

echo "Generating commands (word, tri, cross) and MLF (tri/cross) files ...."
touch mkcmd_word.led
HLEd -n commands/commands_word mkcmd_word.led mlf/labels.mlf_word
HLEd -n commands/commands_word_isolated mkcmd_word.led mlf/labels.mlf_word_sksp
HLEd -n commands/commands_tri_internal -i mlf/labels.mlf_tri_internal mktri_internal.led mlf/labels.mlf_letter
HLEd -n commands/commands_tri_cross -i mlf/labels.mlf_tri_cross mktri_cross.led mlf/labels.mlf_letter
rm -f mkcmd_word.led

echo "Generating single letter/word context grammar files ...."
python scripts/gen_grammar.py --label_loc $3/ --grammar_type letter
python scripts/gen_grammar.py --label_loc $3/ --grammar_type word

echo "Generating dict (tri2letter/tri2word) files ...."
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type letter --dict_loc dict/dict_tri2letter
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type word --dict_loc dict/dict_tri2word
