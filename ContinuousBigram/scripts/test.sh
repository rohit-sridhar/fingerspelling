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
# Arg 1: options shell script
# Arg 2: List of test files
# Arg 3: Saved model (newMacros file)
# 
##################################################

echo Processing $2

OPTIONS_FILE=$1;

if [ ! -x "${OPTIONS_FILE}" ]; then
   echo "Can't read options file '${OPTIONS_FILE}', make sure the file exists and is readable and executable"
   exit;
fi

. ${OPTIONS_FILE}

rm -f $TESTING_BASENAME*
$SCRIPTS_DIR/cv/gen_test_set.sh $DATA_SAMPLES $TESTING_BASENAME $TT_NAME_SCRIPT


HMM_LOAD_OPT="-H"
TEST_DATA=$2
MODEL=$3
LETTER_RESULTS_FILE=$LOG_RESULTS
WORD_RESULTS_FILE=$LOG_RESULTS_WORD

if [[ $NGRAM > 0 ]]; then
    DICTFILE_WORD=$DICTFILE_WORD_SKSP
    GRAMMARFILE_WORD=$GRAMMARFILE_WORD_SKSP
    TOKENS_WORD=$TOKENS_WORD_SKSP
    MLF_LOCATION=$MLF_LOCATION_SKSP
    MLF_LOCATION_WORD=$MLF_LOCATION_WORD_SKSP
    MLF_LOCATION_ORIGINAL=$MLF_LOCATION_ORIGINAL_SKSP
fi

echo
echo "*****************************************************"
echo "Generating Grammar (using HTK Tools)"
echo "*****************************************************"
# if [[ $BIGRAM_LETTER = "yes" ]]; then
#     ${HTKBIN}HLStats -b $BIGRAM_LETTER_FILE -s $ENTER $EXIT -o $TOKENS_ORIGINAL $MLF_LOCATION_ORIGINAL
#     ${HTKBIN}HBuild -n $BIGRAM_LETTER_FILE -s $ENTER $EXIT $TOKENS_ORIGINAL ${WORD_LATTICE}
# else
${HTKBIN}HParse -l ${GRAMMARFILE} ${WORD_LATTICE}
# fi

if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
#     if [[ $BIGRAM_WORD = "yes" ]]; then
#         ${HTKBIN}HLStats -b $BIGRAM_WORD_FILE -s $ENTER $EXIT -o $TOKENS_WORD $MLF_LOCATION_WORD
#         ${HTKBIN}HBuild -n $BIGRAM_WORD_FILE -s $ENTER $EXIT $TOKENS_WORD ${WORD_LATTICE}_word
#     else
    ${HTKBIN}HParse -l ${GRAMMARFILE_WORD} ${WORD_LATTICE}_word
    if [[ $NGRAM > 0 ]]; then
        echo "Skipping HLM for now"
        # ## Clean the lang_models/lm.all dir
        # rm -rf $LM_DIR/lm.$NGRAM
        # 
        # # Init empty wordmap with Name header word_map
        # LNewMap word_map $LM_DIR/empty.wmap
        # 
        # # Make a new directory for intermediates
        # mkdir $LM_DIR/lm.$NGRAM
        # 
        # # Collect n grams from sentence file
        # echo $NGRAM
        # LGPrep -T 1 -d $LM_DIR/lm.$NGRAM -n $NGRAM -s "Fingerspelling All Sentences" $LM_DIR/empty.wmap grammar/sentences.txt
        # 
        # # Make lm.1 dir
        # # mkdir $LM_DIR/lm.1
        # 
        # # Bring together n grams (remove dupes).
        # # LGCopy -T 1 -d $LM_DIR/lm.1 $LM_DIR/lm.0/wmap $LM_DIR/lm.0/gram.*
        # 
        # # Make a new directory for intermediates
        # # mkdir $LM_DIR/lm_all
        # 
        # # Seems to do little but add OOV words
        # # LGCopy -T 1 -o -m $LM_DIR/lm_all/all.wmap -d $LM_DIR/lm_all/ -w $TOKENS_WORD $LM_DIR/lm.0/wmap $LM_DIR/lm.1/data.*
        # 
        # # Get frequency counts
        # LFoF -T 1 -n $NGRAM -f 64 $LM_DIR/lm.$NGRAM/wmap $LM_DIR/lm.$NGRAM/all.fof $LM_DIR/lm.$NGRAM/gram.*
        # 
        # # Builds the language model
        # lm_file="ngram_lm"
        # LBuild -T 1 -n $NGRAM $LM_DIR/lm.$NGRAM/wmap $LM_DIR/lm.$NGRAM/$lm_file $LM_DIR/lm.$NGRAM/gram.*
    fi
    # fi
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
        ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL	\
        	$HMM_LOAD_OPT $MODEL  \
        	-w $WORD_LATTICE -S $test_file -I $MLF_LOCATION	\
        	-i $OUTPUT_MLF_SUB $DICTFILE $TOKENS &
        pid+=("$!")

        if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
            OUTPUT_MLF_WORD_SUB="$OUTPUT_MLF_WORD.${test_file##*.}"
        	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
        		$HMM_LOAD_OPT $MODEL -z "lat" \
        		-w ${WORD_LATTICE}_word -S $test_file -I $MLF_LOCATION 	\
        		-i $OUTPUT_MLF_WORD_SUB -n 4 20 $DICTFILE_WORD $TOKENS &
            pid+=("$!")
        fi
        
        # HLRescore -p -10.0 -s 0.0 -A -T 1 -w -I mlf/labels.mlf_tri_internal_sksp -i ./ext/result.mlf_word -n lang_models/lm.1/ngram_lm ./commands/commands_word_sksp ./ext/data/*.lat

        # ${HTKBIN}HLRescore -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
        # 	$HMM_LOAD_OPT $MODEL -w -I $MLF_LOCATION -i "$OUTPUT_MLF_WORD.rcr" \
        #     -n $LM_DIR/lm.$NGRAM/$lm_file $TOKENS_WORD $EXT_DIR/data/*.lat &
    done
    wait "${pid[@]}"
    rm -rf $TEST_DATA.*
else
    ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
    	$HMM_LOAD_OPT $MODEL \
    	-w $WORD_LATTICE -S $TEST_DATA -I $MLF_LOCATION \
    	-i $OUTPUT_MLF $DICTFILE $TOKENS 
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL \
    		$HMM_LOAD_OPT $MODEL \
    		-w ${WORD_LATTICE}_word -S $TEST_DATA -I $MLF_LOCATION 	\
    		-i $OUTPUT_MLF_WORD -n 4 20 $DICTFILE_WORD $TOKENS
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
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
     	-p $TOKENS_ORIGINAL $output_mlfs >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
        output_mlfs_word=`find / -type f -wholename "$OUTPUT_MLF_WORD.*"`
    	# ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
    	# 	$TOKENS_WORD $output_mlfs_word >> $WORD_RESULTS_FILE
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
     	    $TOKENS_WORD $output_mlfs_word >> $WORD_RESULTS_FILE
    fi
else
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
     	-p $TOKENS_ORIGINAL $OUTPUT_MLF >> $LETTER_RESULTS_FILE
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
    		$TOKENS_WORD $OUTPUT_MLF_WORD >> $WORD_RESULTS_FILE
    fi
fi

