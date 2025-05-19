#!/bin/ksh

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

OPTIONS_FILE=$1
. $OPTIONS_FILE

echo "CURRENT_DIR: `pwd`"
echo "EXT_DIR: ${EXT_DIR}"
echo "OPTIONS_FILE: ${OPTIONS_FILE}"

echo "##### Housekeeping .... #####"
find $2/ -type f | sort -V  > $DATAFILES_LIST
echo "#####"
echo ""

if [[ ! -f "${EXT_DIR}/done" ]]; then
  echo "##### Cleaning up ext dir .... #####"
  echo "rm -rf $EXT_DIR/*"
#   mkdir $EXT_DIR/data/
#   find $3/ -name "*.lab" -type f | xargs cp -t $EXT_DIR/data/
#   echo "#####"
#   echo ""
#   echo "##### Generating ext files .... #####"
#   $SCRIPTS_DIR/gen_ext_files.sh $OPTIONS_FILE
#   echo "#####"
#   echo ""
else
  echo "##### Ext files exit. Skipping generation #####"
  echo "#####"
  echo ""
fi

# # find $EXT_DIR/data/*.ext -type f | xargs readlink -f | sort -V > $DATA_SAMPLES
# find $EXT_DIR/data/ -name "*.ext" -type f | xargs readlink -f | sort -V > $DATA_SAMPLES
# 
# echo "##### Generating mlf letter files .... #####"
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_ORIGINAL --mlf_type letter
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_ORIGINAL_SKSP --mlf_type letter --sksp
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_ORIGINAL_WHOLE --mlf_type letter --whole_word
# echo "#####"
# echo ""
# 
# echo "##### Generating mlf word files .... #####"
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_WORD --mlf_type word
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_WORD_SKSP --mlf_type word --sksp
# python $SCRIPTS_DIR/gen_mlf.py --ext_loc $EXT_DIR/data/ --datafiles_list $DATAFILES_LIST --mlf_file $MLF_LOCATION_WORD_WHOLE --mlf_type word --whole_word
# echo "#####"
# echo ""
# 
# echo "##### Generating mlf phrase files .... #####"
# scripts/gen_mlf_phrase.sh $DATAFILES_LIST ext $OPTIONS_FILE > mlf/labels.mlf_phrase
# echo "#####"
# echo ""
# 
# echo "##### Generating phrase list for language modeling #####"
# python $SCRIPTS_DIR/gen_phrases.py --label_loc $3/ --phrases_loc $SENTENCES_FILE
# echo "#####"
# echo ""
# 
# echo "##### Generating dict (tri2letter/tri2word) files .... #####"
# python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type tri_letter --dict_loc $DICTFILE
# python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type tri_letter_whole --dict_loc $DICTFILE_WHOLE
# # python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type cross_letter --dict_loc $DICTFILE_CROSS
# 
# python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type tri_word --dict_loc $DICTFILE_WORD
# python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type tri_word_sksp --dict_loc $DICTFILE_WORD_SKSP
# python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type tri_word_whole --dict_loc $DICTFILE_WORD_WHOLE
# # python $SCRIPTS_DIR/gen_dict.py --label_loc $3/ --dict_type cross_word --dict_loc $DICTFILE_CROSS_WORD
# echo "#####"
# echo ""
# 
# 
# echo "##### Generating commands (word, tri, cross) and MLF (tri/cross) files .... #####"
# touch $LEDFILE_WORD
# touch $LEDFILE_LETTER
# echo "#####"
# echo ""
# 
# HLEd -b -n $TOKENS_ORIGINAL $LEDFILE_LETTER $MLF_LOCATION_ORIGINAL
# HLEd -b -n $TOKENS_ORIGINAL_WHOLE $LEDFILE_LETTER $MLF_LOCATION_ORIGINAL_WHOLE
# 
# HLEd -b -n $TOKENS_WORD $LEDFILE_WORD $MLF_LOCATION_WORD
# HLEd -b -n $TOKENS_WORD_SKSP $LEDFILE_WORD $MLF_LOCATION_WORD_SKSP
# HLEd -b -n $TOKENS_WORD_WHOLE $LEDFILE_WORD $MLF_LOCATION_WORD_WHOLE
# 
# # The first two HLEd commands below output to the same tokens file because
# # mlf sksp/non sksp letter files both contain spaces
# HLEd -n $TOKENS -i $MLF_LOCATION instr/mktri_internal.led $MLF_LOCATION_ORIGINAL
# HLEd -n $TOKENS -i $MLF_LOCATION_SKSP instr/mktri_internal.led $MLF_LOCATION_ORIGINAL_SKSP
# HLEd -n $TOKENS_WHOLE -i $MLF_LOCATION_WHOLE instr/mktri_internal.led $MLF_LOCATION_ORIGINAL_WHOLE
# 
# # Not doing cross word modeling
# # HLEd -n $TOKENS_CROSS -i $MLF_LOCATION_CROSS instr/mktri_cross.led $MLF_LOCATION_ORIGINAL
# 
# rm -f $LEDFILE_WORD
# rm -f $LEDFILE_LETTER
# 
# sort -o $TOKENS_ORIGINAL $TOKENS_ORIGINAL
# sort -o $TOKENS_ORIGINAL_WHOLE $TOKENS_ORIGINAL_WHOLE
# 
# sort -o $TOKENS_WORD $TOKENS_WORD
# sort -o $TOKENS_WORD_SKSP $TOKENS_WORD_SKSP
# sort -o $TOKENS_WORD_WHOLE $TOKENS_WORD_WHOLE
# 
# # Copy label files into ext dir one last time since HLEd
# # modifies the original label files as well
# echo "##### Copy label files back into ext dir (HLEd may have modified them .... #####"
# find $3/ -name "*.lab" -type f | xargs cp -t $EXT_DIR/data/
# echo "#####"
# echo ""

