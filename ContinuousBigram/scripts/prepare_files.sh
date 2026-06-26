#!/usr/bin/env bash
set -euo pipefail

#### This script generates all ext files, all mlf files
#### (mlf letter/word and mlf_tri/cross), 1 context letter/
#### word grammars, and the triletter letter/word dicts.
#### It also generates the word commands (tri, cross, and
#### single word). It does not generate the commands letters
#### file. That is simple to generate (26 letters + sil + space).

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
    echo "Error: You must pass exactly 3 or 4 arguments."
    exit 1
fi

options="${1:-}"
data_loc="${2:-}"
label_loc="${3:-}"
prep_all_flag="${4:-}"

[[ ${prep_all_flag} == "all" ]] && prep_all_flag=1 || prep_all_flag=0

# if [ "${prep_all_flag}" != "all" ] && [ -n "${prep_all_flag}" ]; then
#     echo ""
# fi

OPTIONS_FILE=${options}
. ${OPTIONS_FILE}

echo "##### Housekeeping .... #####"
find ${data_loc}/ -type f | sort -V  > ${DATAFILES_LIST}
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
    find ${label_loc} -name "*.lab" -type f | xargs cp -lt ${EXT_DIR}/data/
    echo "#####"
    echo ""
    echo "##### Generating ext files .... #####"
    ${SCRIPTS_DIR}/gen_ext_files.sh ${OPTIONS_FILE}
    echo "Exit Code: ${?}"
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
    HLEd -i ${MLF_LOCATION_CROSS} ${LEDFILE_TRI_CROSS} ${MLF_LOCATION_ORIGINAL}

    echo "#####"
    echo ""
     
    echo "1" > ${MLF_ROOT}/done
else
    echo "##### MLF files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

if [[ ${prep_all_flag} -eq 0 ]]; then
    echo "Dict/Tokens/Grammar won't be prepared. Call with \"all\" to generate them."
    exit 0
fi

################################################################################################## DICT/TOKENS ##################################################################################################
# Run only when preparing all data

if [[ ! -f "${DICTFILE_ROOT}/done" ]]; then
    echo "##### Generating dict (tri2letter/tri2word) files .... #####"
    ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type tri_letter --dict_loc ${DICTFILE}
    # ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type tri_letter_whole --dict_loc ${DICTFILE_WHOLE}
    ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type cross_letter --dict_loc ${DICTFILE_CROSS}

    ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type tri_word --dict_loc ${DICTFILE_WORD}
    ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type tri_word_sksp --dict_loc ${DICTFILE_WORD_SKSP}
    # ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type tri_word_whole --dict_loc ${DICTFILE_WORD_WHOLE}
    ${SCRIPTS_DIR}/gen_dict.py --label_loc ${label_loc} --dict_type cross_word --dict_loc ${DICTFILE_WORD_CROSS}
    echo "#####"
    echo ""
    
    echo "1" > ${DICTFILE_ROOT}/done
else
    echo "##### Dict files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

if [[ ! -f "${TOKENS_ROOT}/done" ]]; then
    echo "##### Generating commands (word, tri, cross) .... #####"
    touch ${LEDFILE_WORD}
    touch ${LEDFILE_LETTER}

    HLEd -n ${TOKENS_ORIGINAL} ${LEDFILE_LETTER} ${MLF_LOCATION_ORIGINAL}
    # HLEd -n ${TOKENS_ORIGINAL_WHOLE} ${LEDFILE_LETTER} ${MLF_LOCATION_ORIGINAL_WHOLE}

    HLEd -n ${TOKENS} ${LEDFILE_TRI_INTERNAL} ${MLF_LOCATION_ORIGINAL}
    HLEd -n ${TOKENS} ${LEDFILE_TRI_INTERNAL} ${MLF_LOCATION_ORIGINAL_SKSP}
    HLEd -n ${TOKENS_CROSS} ${LEDFILE_TRI_CROSS} ${MLF_LOCATION_ORIGINAL}

    HLEd -n ${TOKENS_WORD} ${LEDFILE_WORD} ${MLF_LOCATION_WORD}
    HLEd -n ${TOKENS_WORD_SKSP} ${LEDFILE_WORD} ${MLF_LOCATION_WORD_SKSP}
    # HLEd -n ${TOKENS_WORD_WHOLE} ${LEDFILE_WORD} ${MLF_LOCATION_WORD_WHOLE}

    # The first two HLEd commands below output to the same tokens file because
    # mlf sksp/non sksp letter files both contain spaces. Even the non sksp MLF
    # file contains spaces since spaces are only removed on the word level. In this case,
    # instead it is better to add a space to the end of the final word in the phrase
    # as well.
    ##### This was moved to the mlf creation location
    # HLEd -n ${TOKENS} -i ${MLF_LOCATION} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL}
    # HLEd -n ${TOKENS} -i ${MLF_LOCATION_SKSP} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL_SKSP}
    # HLEd -n ${TOKENS_WHOLE} -i ${MLF_LOCATION_WHOLE} instr/mktri_internal.led ${MLF_LOCATION_ORIGINAL_WHOLE}

    rm -f ${LEDFILE_WORD}
    rm -f ${LEDFILE_LETTER}

    sort -o ${TOKENS_ORIGINAL} ${TOKENS_ORIGINAL}
    # sort -o ${TOKENS_ORIGINAL_WHOLE} ${TOKENS_ORIGINAL_WHOLE}

    sort -o ${TOKENS_WORD} ${TOKENS_WORD}
    sort -o ${TOKENS_WORD_SKSP} ${TOKENS_WORD_SKSP}
    # sort -o ${TOKENS_WORD_WHOLE} ${TOKENS_WORD_WHOLE}
    echo "#####"
    echo ""

    echo "##### Copy label files back into ext dir (HLEd may have modified them) .... #####"
    find ${label_loc} -name "*.lab" -type f | xargs cp -lt ${EXT_DIR}/data/
    echo "#####"
    echo ""
    
    echo "1" > ${TOKENS_ROOT}/done
else
    echo "##### Commands files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

if [[ ! -f "${GRAMMARFILE_ROOT}/done" ]]; then
    echo "##### Generating grammar (letter, word) .... #####"
    ${SCRIPTS_DIR}/gen_grammar.py --label_loc ${label_loc} --grammar_file ${GRAMMARFILE}
    ${SCRIPTS_DIR}/gen_grammar.py --label_loc ${label_loc} --grammar_file ${GRAMMARFILE_WORD}
    ${SCRIPTS_DIR}/gen_grammar.py --label_loc ${label_loc} --grammar_file ${GRAMMARFILE_WORD_SKSP}
    echo "#####"

    echo "1" > ${GRAMMARFILE_ROOT}/done
else
    echo "##### Grammar files exist. Skipping generation #####"
    echo "#####"
    echo ""
fi

################################################################################################## OLD CODE ##################################################################################################

################################################## MLF Code
#     echo "##### Generating mlf phrase files .... #####"
#     scripts/gen_mlf_phrase.sh ${DATAFILES_LIST} ext ${OPTIONS_FILE} > mlf/labels.mlf_phrase
#     echo "#####"
#     echo ""

#     ln -s ${MLF_LOCATION} mlf_loc
#     ln -s ${MLF_LOCATION_ORIGINAL} mlf_loc_original
#     ln -s ${MLF_LOCATION_SKSP} mlf_loc_sksp
#     ln -s ${MLF_LOCATION_ORIGINAL_SKSP} mlf_loc_original_sksp
#     ln -s ${LEDFILE_TRI_INTERNAL} ledfile_tri_int
#     HLEd -i mlf_loc ledfile_tri_int mlf_loc_original
#     HLEd -i mlf_loc_sksp ledfile_tri_int mlf_loc_original_sksp
#     unlink mlf_loc
#     unlink mlf_loc_original
#     unlink mlf_loc_sksp
#     unlink mlf_loc_original_sksp
#     unlink ledfile_tri_int
# 
################################################## Phrase List Code
# # echo "##### Generating phrase list for language modeling #####"
# # ${SCRIPTS_DIR}/gen_phrases.py --label_loc ${label_loc} --phrases_loc ${SENTENCES_FILE}
# # echo "#####"
# # echo ""
# 

