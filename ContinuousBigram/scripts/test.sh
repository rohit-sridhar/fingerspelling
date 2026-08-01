#!/usr/bin/env bash
set -euo pipefail

##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################

##################################################
# Function defs
##################################################
# set htk files (pre force_alignment)
function set_htk_files {
    HMM_LOAD_OPT="-H"
    LETTER_RESULTS_FILE=$LOG_RESULTS
    WORD_RESULTS_FILE=$LOG_RESULTS_WORD

    if [[ $WORD_SKSP == "yes" ]]; then
        # Grammar files
        GRAMMARFILE_WORD=$GRAMMARFILE_WORD_SKSP
        
        # Dict files
        DICTFILE_WORD=$DICTFILE_WORD_SKSP

        # Tokens files
        TOKENS_WORD=$TOKENS_WORD_SKSP

        # MLF files
        MLF_LOCATION=$MLF_LOCATION_SKSP
        MLF_LOCATION_WORD=$MLF_LOCATION_WORD_SKSP
        MLF_LOCATION_ORIGINAL=$MLF_LOCATION_ORIGINAL_SKSP
    fi

    if [[ $WORD_SKSP_PHRASE == "yes" ]]; then
        GRAMMARFILE_WORD=$GRAMMARFILE_WORD_PHRASE_SKSP
    fi
    
    if [[ $CROSS_WORD == "yes" ]]; then
        # Dict Files
        DICTFILE=$DICTFILE_CROSS
        DICTFILE_WORD=$DICTFILE_WORD_CROSS

        # Token Files
        TOKENS=$TOKENS_CROSS

        # MLF Files
        MLF_LOCATION=$MLF_LOCATION_CROSS
    fi
}

function set_htk_alignment_files {
    # skip word level and have HVite output alignments
    WORD_LEVEL=no
    NETWORK_OPT="-a"
    
    # Output mlfs should be tagged as aligned mlfs
    OUTPUT_MLF="${OUTPUT_MLF}_align"
    
    # TODO Change this later if bootstrapping on alignments works. otherwise delete.
    TEST_DATA=$DATA_SAMPLES


    tri=${1:-}
    if [[ ${tri} = "uni" ]]; then
        MLF_LOCATION=$MLF_LOCATION_ORIGINAL_SKSP
    elif [[ ${tri} = "tri" ]]; then
        # reset mlf/dict for tri mlfs (and use cross if original model is cross word)
        MLF_LOCATION=$MLF_LOCATION_SKSP
        DICTFILE=$DICTFILE_ALIGN
        if [[ $CROSS_WORD = "yes" ]] || [[ $CROSS_WORD = "1" ]]; then
            MLF_LOCATION=$MLF_LOCATION_CROSS
            DICTFILE=$DICTFILE_CROSS_ALIGN
        fi
    else
        echo "pass uni or tri as first arg to set_htk_alignment_files"
        exit 1
    fi
}

# run hvite function does the main model checking
function run_hvite {
    if [[ $MULTI_PROCESS = "yes" ]]; then
        num_lines=`cat $TEST_DATA | wc -l` #   compute the num lines in test file
        lines_per_file=$(($num_lines / $THREADS))
        if [[ $lines_per_file -lt 1 ]]; then
            lines_per_file=1
        fi
        split -l $lines_per_file $TEST_DATA "$TEST_DATA."     # splits testing files
        pid=()
        
        for test_file in $TEST_DATA.*; do
            OUTPUT_MLF_SUB="$OUTPUT_MLF.${test_file##*.}"
            ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
                $HMM_LOAD_OPT $MODEL $NETWORK_OPT -S $test_file -I $MLF_LOCATION \
                -i $OUTPUT_MLF_SUB $DICTFILE $TOKENS &
            pid+=("$!")

            if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
                OUTPUT_MLF_WORD_SUB="$OUTPUT_MLF_WORD.${test_file##*.}"
                    ${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
                        $HMM_LOAD_OPT $MODEL -w ${WORD_LATTICE}_word -S $test_file -I $MLF_LOCATION \
                        -i $OUTPUT_MLF_WORD_SUB -n 4 20 $DICTFILE_WORD $TOKENS &
                pid+=("$!")
            fi
        done
        wait "${pid[@]}"
        rm -rf $TEST_DATA.*
    else
        ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
            $HMM_LOAD_OPT $MODEL ${NETWORK_OPT} \
            -S $TEST_DATA -I $MLF_LOCATION \
            -i $OUTPUT_MLF $DICTFILE $TOKENS 
        
        if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
            ${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
                $HMM_LOAD_OPT $MODEL -w ${WORD_LATTICE}_word \
                -S $TEST_DATA -I $MLF_LOCATION \
                -i $OUTPUT_MLF_WORD -n 4 20 $DICTFILE_WORD $TOKENS
        fi
    fi
}

##################################################
# 
# Arg 1: options shell script
# Arg 2: List of test files
# Arg 3: Saved model (newMacros file)
# Arg 4: Use phrase level grammar
# 
##################################################

OPTIONS_FILE=${1:-}
TEST_DATA=${2:-}
MODEL=${3:-}

. ${OPTIONS_FILE}

# echo "Processing ${TEST_DATA}"
echo "Processing ${TEST_DATA}"

if [ ! -x "${OPTIONS_FILE}" ]; then
   echo "Can't read options file '${OPTIONS_FILE}', make sure the file exists and is readable and executable"
   exit;
fi

rm -f $TEST_DATA*
$SCRIPTS_DIR/cv/gen_test_set.sh $DATA_SAMPLES $TESTING_BASENAME $TT_NAME_SCRIPT $NUM_TEST_SAMPLES

set_htk_files

echo
echo "*****************************************************"
echo "Generating Grammar (using HTK Tools)"
echo "*****************************************************"
${HTKBIN}HParse -l ${GRAMMARFILE} ${WORD_LATTICE}
if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    ${HTKBIN}HParse -l ${GRAMMARFILE_WORD} ${WORD_LATTICE}_word
fi

echo
echo "*****************************************************"
echo "Checking our Models"
echo "*****************************************************"

###############################################################################
# now we check our models
###############################################################################
# -H is the HMM to load
# -S is the list of EXT files it should use
# -I is the MLF (Master Label File) - should contain the word list for each ext
#    file 
# -i is the MLF file to store output to
# -a load a label file and create an alignment network for each test file.
# -n use 'i' tokens to perform N-best recognition.
# parameters= dictionary file
# parameters= hmms to use (should correspond to our words)
###############################################################################

###############################################################################
# Uses the MLF with triletters
# Uses the Tokens file with triletters
# Uses the Dict file with triletters (For both word and letter)
###############################################################################

NETWORK_OPT=
if [[ $FORCE_ALIGN = "yes" ]] || [[ $FORCE_ALIGN = "1" ]]; then 
    # generate uniletter alignments
    set_htk_alignment_files uni
    run_hvite
    awk 'BEGIN {print "#!MLF!#"} /^#!MLF!#/ {next} {if (NF == 4 && $4 ~ /^-?[0-9.]+$/) print $1, $2, $3; else print}' ${OUTPUT_MLF}.* > "${MLF_LOCATION}_bootstrap"
    rm -rf ${OUTPUT_MLF}.*
    
    # generate tri letter alignments
    set_htk_alignment_files tri
    run_hvite
    awk 'BEGIN {print "#!MLF!#"} /^#!MLF!#/ {next} {if (NF == 4 && $4 ~ /^-?[0-9.]+$/) print $1, $2, $3; else print}' ${OUTPUT_MLF}.* > "${MLF_LOCATION}_bootstrap"
    rm -rf ${OUTPUT_MLF}.*
    
    # Exit here for forced alignment. No need to run HResults
    exit 0
else
    # else set to use the generated lattice (from grammar)
    NETWORK_OPT="-w ${WORD_LATTICE}"
    run_hvite
fi

echo
echo "*****************************************************"
echo Testing Models
echo "*****************************************************"

###############################################################################
# now we run the tests
###############################################################################
# -t This option causes a time-aligned transcription of each test file to be
#    output provided that it differs from the reference transcription file
# -I is the MLF (Master Label File) - should contain the word list for each ext
#    file 
# -p This option causes a phoneme confusion matrix to be output.
# -w outputs ROC info that doesn't look quite correct
# -d N : if correct answer is within the top N-Best consider it correctly
#        classified
# parameters= MLF file to load
###############################################################################
# Uses the MLF with triletters
# Uses the Tokens file with triletters
###############################################################################

if [[ $MULTI_PROCESS = "yes" ]]; then
    output_mlfs=`find ${EXT_DIR} -type f -wholename "$OUTPUT_MLF.*"`
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
        -p $TOKENS_ORIGINAL $output_mlfs >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
        output_mlfs_word=`find ${EXT_DIR} -type f -wholename "$OUTPUT_MLF_WORD.*"`
        # ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" $SP -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
        #       $TOKENS_WORD $output_mlfs_word >> $WORD_RESULTS_FILE
        ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" $SP -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
            $TOKENS_WORD $output_mlfs_word >> $WORD_RESULTS_FILE
    fi
else
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
        -p $TOKENS_ORIGINAL $OUTPUT_MLF >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
        ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" $SP -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
            $TOKENS_WORD $OUTPUT_MLF_WORD >> $WORD_RESULTS_FILE
    fi
fi

