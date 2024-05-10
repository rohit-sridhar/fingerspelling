#!/bin/ksh

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

OPTIONS_FILE=$1
. $OPTIONS_FILE

echo "Housekeeping ...."
find $2/* -type f | sort -V  > $DATAFILES_LIST
rm -rf $EXT_DIR/data/
rm -f $EXT_DIR/done
mkdir $EXT_DIR/data/
cp -r $3/* $EXT_DIR/data/


echo "Generating ext files ...."
scripts/gen_ext_files.sh $OPTIONS_FILE
find $EXT_DIR/data/*.ext -type f | xargs readlink -f | sort -V > $DATA_SAMPLES

echo "Generating mlf letter files ...."
# scripts/gen_mlf_split.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_letter
# scripts/gen_mlf_split.sh $DATAFILES_LIST ext $OPTIONS_FILE "1" > mlf/labels.mlf_letter_sksp
python scripts/gen_mlf.py --ext_loc $EXT_DIR/data --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_ORIGINAL --mlf_type letter
python scripts/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_ORIGINAL_SKSP --mlf_type letter --skip_space

echo "Generating mlf word files ...."
# scripts/gen_mlf_word.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_word
# scripts/gen_mlf_word.sh $DATAFILES_LIST ext $OPTIONS_FILE "1" > mlf/labels.mlf_word_sksp
python scripts/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_WORD --mlf_type word
python scripts/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_WORD_SKSP --mlf_type word --skip_space

# echo "Generating mlf phrase files ...."
# scripts/gen_mlf_phrase.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_phrase

echo "Generating commands (word, tri, cross) and MLF (tri/cross) files ...."
touch instr/mkcmd_word.led
touch instr/mkcmd_letter.led

HLEd -b -n $TOKENS_WORD_SKSP instr/mkcmd_word.led $MLF_LOCATION_WORD_SKSP
HLEd -b -n $TOKENS_WORD instr/mkcmd_word.led $MLF_LOCATION_WORD

HLEd -b -n $TOKENS_ORIGINAL_SKSP instr/mkcmd_letter.led $MLF_LOCATION_ORIGINAL_SKSP
HLEd -b -n $TOKENS_ORIGINAL instr/mkcmd_letter.led $MLF_LOCATION_ORIGINAL

HLEd -n commands/commands_tri_internal -i mlf/labels.mlf_tri_internal instr/mktri_internal.led $MLF_LOCATION_ORIGINAL
HLEd -n commands/commands_tri_cross -i mlf/labels.mlf_tri_cross instr/mktri_cross.led $MLF_LOCATION_ORIGINAL

rm -f instr/mkcmd_word.led
rm -f instr/mkcmd_letter.led

sort -o $TOKENS_ORIGINAL $TOKENS_ORIGINAL
sort -o $TOKENS_ORIGINAL_SKSP $TOKENS_ORIGINAL_SKSP
sort -o $TOKENS_WORD $TOKENS_WORD
sort -o $TOKENS_WORD_SKSP $TOKENS_WORD_SKSP

echo "Generating single letter/word context grammar files ...."
python scripts/gen_grammar.py --label_loc $3/ --grammar_type letter
python scripts/gen_grammar.py --label_loc $3/ --grammar_type word

echo "Generating dict (tri2letter/tri2word) files ...."
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type letter --dict_loc dict/dict_tri2letter
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type word --dict_loc dict/dict_tri2word

