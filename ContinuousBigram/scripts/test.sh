#!/bin/ksh
##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################

##################################################
# 
# Arg 1: List of test files
# Arg 2: Where to save letter results
# Arg 3: Where to save word results
# Arg 4: Saved model (newMacros file)
# Arg 5: options shell script
# 
##################################################

echo Processing $1

OPTIONS_FILE=$5;

if [ ! -x "${OPTIONS_FILE}" ]; then
   echo "Can't read options file '${OPTIONS_FILE}', make sure the file exists and is readable and executable"
   exit;
fi

. ${OPTIONS_FILE}
HMM_LOAD_OPT="-H"
TEST_DATA=$1
LETTER_RESULTS_FILE=$2
WORD_RESULTS_FILE=$3
MODEL=$4;

echo
echo "*****************************************************"
echo Generating Grammar
echo "*****************************************************"
if [[ $BIGRAM_LETTER = "yes" ]]; then
    ${HTKBIN}HLStats -b $BIGRAM_LETTER_FILE -s $ENTER $EXIT -o $TOKENS_ORIGINAL_TEST $MLF_LOCATION_ORIGINAL_TEST
    ${HTKBIN}HBuild -n $BIGRAM_LETTER_FILE -s $ENTER $EXIT $TOKENS_ORIGINAL_TEST ${WORD_LATTICE}
else
    ${HTKBIN}HParse -l ${GRAMMARFILE_TEST} ${WORD_LATTICE}
fi

if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    if [[ $BIGRAM_WORD = "yes" ]]; then
        ${HTKBIN}HLStats -b $BIGRAM_WORD_FILE -s $ENTER $EXIT -o $TOKENS_WORD_SKSP_TEST $MLF_LOCATION_WORD_SKSP_TEST
        ${HTKBIN}HBuild -n $BIGRAM_WORD_FILE -s $ENTER $EXIT $TOKENS_WORD_SKSP_TEST ${WORD_LATTICE}_word
    else
	    ${HTKBIN}HParse -l ${GRAMMARFILE_WORD_TEST} ${WORD_LATTICE}_word
    fi
fi

echo
echo "*****************************************************"
echo Checking our Models
echo "*****************************************************"
###############################################################################
# now we check our models
###############################################################################
# -H is the HMM to load
# -S is the list of EXT files it should use
# -I is the MLF (Master Label File) - should contain the word list for each ext
# 		file 
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

if [[ $MULTI_PROCESS = "yes" ]]; then
	num_lines=`cat $TEST_DATA | wc -l` #   compute the num lines in test file
    threads=$((num_lines/THREADS))
    
	num_lines=`cat $TEST_DATA | wc -l` #   compute the num lines per file
    lines_per_file=$(($num_lines / $THREADS))
    split -l $lines_per_file $TEST_DATA "$TEST_DATA."     # splits testing files
    pid=()
    
    for test_file in $TEST_DATA.*; do
        OUTPUT_MLF_SUB="$OUTPUT_MLF.${test_file##*.}"
        ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
        	$HMM_LOAD_OPT $MODEL 	\
        	-w $WORD_LATTICE -S $test_file -I $MLF_LOCATION_TEST 	\
        	-i $OUTPUT_MLF_SUB $DICTFILE_TEST $TOKENS_TEST &
        pid+=("$!")

        if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
            OUTPUT_MLF_WORD_SUB="$OUTPUT_MLF_WORD.${test_file##*.}"
        	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
        		$HMM_LOAD_OPT $MODEL 	\
        		-w ${WORD_LATTICE}_word -S $test_file -I $MLF_LOCATION_TEST 	\
        		-i $OUTPUT_MLF_WORD_SUB -n 4 20 $DICTFILE_WORD_TEST $TOKENS_TEST &
            pid+=("$!")
        fi
    done
    wait "${pid[@]}"
    rm -rf $TEST_DATA.*
else
    ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
    	$HMM_LOAD_OPT $MODEL 	\
    	-w $WORD_LATTICE -S $TEST_DATA -I $MLF_LOCATION_TEST 	\
    	-i $OUTPUT_MLF $DICTFILE_TEST $TOKENS_TEST 
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
    		$HMM_LOAD_OPT $MODEL 	\
    		-w ${WORD_LATTICE}_word -S $TEST_DATA -I $MLF_LOCATION_TEST 	\
    		-i $OUTPUT_MLF_WORD -n 4 20 $DICTFILE_WORD_TEST $TOKENS_TEST
    fi
fi

# confidence levels
#HVite -H hmm.7/newMacros -w word.lattice -S $TESTING -I labels.mlf -o output.mlf -n 4 20 dict commands

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
#	 classified
# parameters= MLF file to load
###############################################################################
# Uses the MLF with triletters
# Uses the Tokens file with triletters
###############################################################################
if [[ $MULTI_PROCESS = "yes" ]]; then
    output_mlfs=`find / -type f -wholename "$OUTPUT_MLF.*"`
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL_TEST \
     	-p $TOKENS_ORIGINAL_TEST $output_mlfs >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
        output_mlfs_word=`find / -type f -wholename "$OUTPUT_MLF_WORD.*"`
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD_TEST \
    		$TOKENS_WORD_TEST $output_mlfs_word >> $WORD_RESULTS_FILE
    fi
else
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL_TEST \
     	-p $TOKENS_ORIGINAL_TEST $OUTPUT_MLF >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD_TEST \
    		$TOKENS_WORD_TEST $OUTPUT_MLF_WORD >> $WORD_RESULTS_FILE
    fi
fi

