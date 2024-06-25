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

if [[ $4 == "test" ]]; then
    DICTFILE=$DICTFILE_TEST
    DICTFILE_WORD=$DICTFILE_WORD_TEST
    
    TOKENS=$TOKENS_TEST
    TOKENS_WORD=$TOKENS_WORD_TEST

    TOKENS_ORIGINAL=$TOKENS_ORIGINAL_TEST
    TOKENS_ORIGINAL_SKSP=$TOKENS_ORIGINAL_SKSP_TEST
    TOKENS_WORD_SKSP=$TOKENS_WORD_SKSP_TEST

    MLF_LOCATION_ORIGINAL=$MLF_LOCATION_ORIGINAL_TEST
    MLF_LOCATION_ORIGINAL_SKSP=$MLF_LOCATION_ORIGINAL_SKSP_TEST
    MLF_LOCATION_WORD_SKSP=$MLF_LOCATION_WORD_SKSP_TEST

    MLF_LOCATION=$MLF_LOCATION_TEST
    MLF_LOCATION_WORD=$MLF_LOCATION_WORD_TEST

    GRAMMARFILE=$GRAMMARFILE_TEST
    GRAMMARFILE_WORD=$GRAMMARFILE_WORD_TEST
fi

echo $DICTFILE
echo $DICTFILE_WORD

echo $TOKENS
echo $TOKENS_WORD

echo $TOKENS_ORIGINAL
echo $TOKENS_ORIGINAL_SKSP
echo $TOKENS_WORD_SKSP

echo $MLF_LOCATION_ORIGINAL
echo $MLF_LOCATION_ORIGINAL_SKSP
echo $MLF_LOCATION_WORD_SKSP

echo $MLF_LOCATION
echo $MLF_LOCATION_WORD

echo $GRAMMARFILE
echo $GRAMMARFILE_WORD

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

HLEd -n $TOKENS -i $MLF_LOCATION instr/mktri_internal.led $MLF_LOCATION_ORIGINAL
HLEd -n $TOKENS_CROSS -i $MLF_LOCATION_CROSS instr/mktri_cross.led $MLF_LOCATION_ORIGINAL

rm -f instr/mkcmd_word.led
rm -f instr/mkcmd_letter.led

sort -o $TOKENS_ORIGINAL $TOKENS_ORIGINAL
sort -o $TOKENS_ORIGINAL_SKSP $TOKENS_ORIGINAL_SKSP
sort -o $TOKENS_WORD $TOKENS_WORD
sort -o $TOKENS_WORD_SKSP $TOKENS_WORD_SKSP

echo "Generating single letter/word context grammar files ...."
python scripts/gen_grammar.py --label_loc $3/ --grammar_file $GRAMMARFILE --grammar_type letter
python scripts/gen_grammar.py --label_loc $3/ --grammar_file $GRAMMARFILE_WORD --grammar_type word
python scripts/gen_grammar.py --label_loc $3/ --grammar_file $GRAMMARFILE_WORD_CROSS --grammar_type cross_word

echo "Generating phrase list for language modeling"
python scripts/gen_phrases.py --label_loc $3/ --phrases_loc $SENTENCES_FILE

echo "Generating dict (tri2letter/tri2word) files ...."
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type letter --dict_loc $DICTFILE
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type cross_letter --dict_loc $DICTFILE_CROSS
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type word --dict_loc $DICTFILE_WORD
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type cross_word --dict_loc $DICTFILE_CROSS_WORD

