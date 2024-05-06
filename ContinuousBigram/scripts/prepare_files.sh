#!/bin/ksh

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

echo "Housekeeping ...."
find $2/* -type f | sort -V  > output/datafiles
rm -rf ext/data/
rm -f ext/done
mkdir ext/data/
cp -r $3/* ext/data/

OPTIONS_FILE=$1
. $OPTIONS_FILE

echo "Generating ext files ...."
scripts/gen_ext_files.sh $OPTIONS_FILE
find ext/data/*.ext -type f | xargs readlink -f | sort -V > output/all-extfiles

echo "Generating mlf letter files ...."
# scripts/gen_mlf_split.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_letter
# scripts/gen_mlf_split.sh $DATAFILES_LIST ext $OPTIONS_FILE "1" > mlf/labels.mlf_letter_sksp
python scripts/gen_mlf.py --ext_loc ./ext/data/ --datafiles_list ./output/datafiles --mlf_file ./mlf/labels.mlf_letter --mlf_type letter
python scripts/gen_mlf.py --ext_loc ./ext/data/ --datafiles_list ./output/datafiles --mlf_file ./mlf/labels.mlf_letter_sksp --mlf_type letter --skip_space

echo "Generating mlf word files ...."
# scripts/gen_mlf_word.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_word
# scripts/gen_mlf_word.sh $DATAFILES_LIST ext $OPTIONS_FILE "1" > mlf/labels.mlf_word_sksp
python scripts/gen_mlf.py --ext_loc ./ext/data/ --datafiles_list ./output/datafiles --mlf_file ./mlf/labels.mlf_word --mlf_type word
python scripts/gen_mlf.py --ext_loc ./ext/data/ --datafiles_list ./output/datafiles --mlf_file ./mlf/labels.mlf_word_sksp --mlf_type word --skip_space

echo "Generating mlf phrase files ...."
scripts/gen_mlf_phrase.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_phrase

echo "Generating commands (word, tri, cross) and MLF (tri/cross) files ...."
touch instr/mkcmd_word.led
touch instr/mkcmd_letter.led

HLEd -b -n commands/commands_word_isolated instr/mkcmd_word.led mlf/labels.mlf_word_sksp
HLEd -b -n commands/commands_word instr/mkcmd_word.led mlf/labels.mlf_word

HLEd -b -n commands/commands_letter_isolated instr/mkcmd_letter.led mlf/labels.mlf_letter_sksp
HLEd -b -n commands/commands_letter instr/mkcmd_letter.led mlf/labels.mlf_letter

HLEd -n commands/commands_tri_internal -i mlf/labels.mlf_tri_internal instr/mktri_internal.led mlf/labels.mlf_letter
HLEd -n commands/commands_tri_cross -i mlf/labels.mlf_tri_cross instr/mktri_cross.led mlf/labels.mlf_letter

rm -f instr/mkcmd_word.led
rm -f instr/mkcmd_letter.led

echo "Generating single letter/word context grammar files ...."
python scripts/gen_grammar.py --label_loc $3/ --grammar_type letter
python scripts/gen_grammar.py --label_loc $3/ --grammar_type word

echo "Generating dict (tri2letter/tri2word) files ...."
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type letter --dict_loc dict/dict_tri2letter
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type word --dict_loc dict/dict_tri2word
