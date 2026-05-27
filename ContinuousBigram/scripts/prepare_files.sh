#!/bin/ksh

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

OPTIONS_FILE=$1
. ${OPTIONS_FILE}

echo "##### Housekeeping .... #####"
find $2/ -type f | sort -V  > ${DATAFILES_LIST}
echo "#####"
echo ""

if [[ ! -f "${EXT_DIR}/done" ]]; then
    echo "##### Cleaning up ext dir .... #####"
    echo "${OPTIONS_FILE}"
    echo "${EXT_DIR}"
    echo "rm -rf ${EXT_DIR}/*"
    echo ""
    rm -rf ${EXT_DIR}/*
    mkdir ${EXT_DIR}/data/
    find $3/ -name "*.lab" -type f | xargs cp -t ${EXT_DIR}/data/
    echo "#####"
    echo ""
    echo "##### Generating ext files .... #####"
    ${SCRIPTS_DIR}/gen_ext_files.sh ${OPTIONS_FILE}
    echo "#####"
    echo ""
else
    echo "##### Ext files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

find ${EXT_DIR}/data -name "*.ext" -type f | xargs readlink -f | sort -V > ${DATA_SAMPLES}

if [[ ! -f "${MLF_ROOT}/done" ]]; then
    echo "##### Generating mlf letter files .... #####"
    ${SCRIPTS_DIR}/gen_mlf.py --ext_loc ${EXT_DIR}/data/ --datafiles_list ${DATAFILES_LIST} --mlf_file ${MLF_LOCATION_ORIGINAL} --mlf_type letter
    ${SCRIPTS_DIR}/gen_mlf.py --ext_loc ${EXT_DIR}/data/ --datafiles_list ${DATAFILES_LIST} --mlf_file ${MLF_LOCATION_ORIGINAL_SKSP} --mlf_type letter --sksp
    echo "#####"
    echo ""
    
    echo "##### Generating mlf word files .... #####"
    ${SCRIPTS_DIR}/gen_mlf.py --ext_loc ${EXT_DIR}/data/ --datafiles_list ${DATAFILES_LIST} --mlf_file ${MLF_LOCATION_WORD} --mlf_type word
    ${SCRIPTS_DIR}/gen_mlf.py --ext_loc ${EXT_DIR}/data/ --datafiles_list ${DATAFILES_LIST} --mlf_file ${MLF_LOCATION_WORD_SKSP} --mlf_type word --sksp
    echo "#####"
    echo ""

    echo "##### Generating mlf tri letter files #####"
    HLEd -i ${MLF_LOCATION} ${LEDFILE_TRI_INTERNAL} ${MLF_LOCATION_ORIGINAL}
    HLEd -i ${MLF_LOCATION_SKSP} ${LEDFILE_TRI_INTERNAL} ${MLF_LOCATION_ORIGINAL_SKSP}

    # ln -s ${MLF_LOCATION} mlf_loc
    # ln -s ${MLF_LOCATION_ORIGINAL} mlf_loc_original
    # ln -s ${MLF_LOCATION_SKSP} mlf_loc_sksp
    # ln -s ${MLF_LOCATION_ORIGINAL_SKSP} mlf_loc_original_sksp
    # ln -s ${LEDFILE_TRI_INTERNAL} ledfile_tri_int
    # HLEd -i mlf_loc ledfile_tri_int mlf_loc_original
    # HLEd -i mlf_loc_sksp ledfile_tri_int mlf_loc_original_sksp
    # unlink mlf_loc
    # unlink mlf_loc_original
    # unlink mlf_loc_sksp
    # unlink mlf_loc_original_sksp
    # unlink ledfile_tri_int
    echo "#####"
    echo ""
    
#     echo "##### Generating mlf phrase files .... #####"
#     scripts/gen_mlf_phrase.sh ${DATAFILES_LIST} ext ${OPTIONS_FILE} > mlf/labels.mlf_phrase
#     echo "#####"
#     echo ""
    
    echo "1" > ${MLF_ROOT}/done
else
    echo "##### MLF files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

# # echo "##### Generating phrase list for language modeling #####"
# # ${SCRIPTS_DIR}/gen_phrases.py --label_loc $3/ --phrases_loc ${SENTENCES_FILE}
# # echo "#####"
# # echo ""
# 
# if [[ ! -f "${DICTFILE_ROOT}/done" ]]; then
#     echo "##### Generating dict (tri2letter/tri2word) files .... #####"
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type tri_letter --dict_loc ${DICTFILE}
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type tri_letter_whole --dict_loc ${DICTFILE_WHOLE}
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type cross_letter --dict_loc ${DICTFILE_CROSS}
# 
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type tri_word --dict_loc ${DICTFILE_WORD}
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type tri_word_sksp --dict_loc ${DICTFILE_WORD_SKSP}
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type tri_word_whole --dict_loc ${DICTFILE_WORD_WHOLE}
#     ${SCRIPTS_DIR}/gen_dict.py --label_loc $3/ --dict_type cross_word --dict_loc ${DICTFILE_CROSS_WORD}
#     echo "#####"
#     echo ""
#     
#     echo "1" > ${DICTFILE_ROOT}/done
# else
#     echo "##### Dict files exist. Skipping generation #####"
#     echo "#####"
#     echo ""
# fi
# 
# if [[ ! -f "${TOKENS_ROOT}/done" ]]; then
#     echo "##### Generating commands (word, tri, cross) and MLF (tri/cross) files .... #####"
#     touch ${LEDFILE_WORD}
#     touch ${LEDFILE_LETTER}
# 
#     HLEd -b -n ${TOKENS_ORIGINAL} ${LEDFILE_LETTER} ${MLF_LOCATION_ORIGINAL}
#     HLEd -b -n ${TOKENS_ORIGINAL_WHOLE} ${LEDFILE_LETTER} ${MLF_LOCATION_ORIGINAL_WHOLE}
# 
#     HLEd -b -n ${TOKENS_WORD} ${LEDFILE_WORD} ${MLF_LOCATION_WORD}
#     HLEd -b -n ${TOKENS_WORD_SKSP} ${LEDFILE_WORD} ${MLF_LOCATION_WORD_SKSP}
#     HLEd -b -n ${TOKENS_WORD_WHOLE} ${LEDFILE_WORD} ${MLF_LOCATION_WORD_WHOLE}
# 
#     # The first two HLEd commands below output to the same tokens file because
#     # mlf sksp/non sksp letter files both contain spaces
#     ##### This was moved to the mlf creation location
#     HLEd -n ${TOKENS} -i ${MLF_LOCATION} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL}
#     HLEd -n ${TOKENS} -i ${MLF_LOCATION_SKSP} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL_SKSP}
#     HLEd -n ${TOKENS_WHOLE} -i ${MLF_LOCATION_WHOLE} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL_WHOLE}
# 
#     # Not doing cross word modeling
#     # HLEd -n ${TOKENS_CROSS} -i ${MLF_LOCATION_CROSS} instr/mktri_cross.led ${MLF_LOCATION_ORIGINAL}
# 
#     rm -f ${LEDFILE_WORD}
#     rm -f ${LEDFILE_LETTER}
# 
#     sort -o ${TOKENS_ORIGINAL} ${TOKENS_ORIGINAL}
#     sort -o ${TOKENS_ORIGINAL_WHOLE} ${TOKENS_ORIGINAL_WHOLE}
# 
#     sort -o ${TOKENS_WORD} ${TOKENS_WORD}
#     sort -o ${TOKENS_WORD_SKSP} ${TOKENS_WORD_SKSP}
#     sort -o ${TOKENS_WORD_WHOLE} ${TOKENS_WORD_WHOLE}
#     echo "#####"
#     echo ""
# 
#     echo "##### Copy label files back into ext dir (HLEd may have modified them) .... #####"
#     find $3/ -name "*.lab" -type f | xargs cp -t ${EXT_DIR}/data/
#     echo "#####"
#     echo ""
#     
#     echo "1" > ${TOKENS_ROOT}/done
# else
#     echo "##### Commands files exist. Skipping generation #####"
#     echo "#####"
#     echo ""
# fi

# Copy label files into ext dir one last time since HLEd
# modifies the original label files as well

