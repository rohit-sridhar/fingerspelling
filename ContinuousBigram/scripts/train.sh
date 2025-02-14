#!/bin/ksh
##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################

###############################################################################
#
# this boot-straps htk experiments
#
# maintained by brashear@cc.gatech.edu, turtle@cc.gatech.edu
#		haileris@cc.gatech.edu
#
###############################################################################

# NOTES: scripts/train.sh scripts/options.sh &> output
#

# Load in project options (specified on the command line!)
if [ -z "$1" ]; then

	echo "usage: $0 <options file>"
	exit
fi

OPTIONS_FILE=$1
. ${OPTIONS_FILE}


###############################################################################
##########################################################
##########################################################
##							##
##  DO NOT EDIT BELOW THIS LINE 			##
##  unless you know HTK and know what you are doing.	##
##							##
##########################################################
##########################################################

# check options for proper values, verify existence and executability of utils
. ${UTIL_DIR}/check_opts.sh

# When Cross word is enabled this logic may need to be changed
if [[ $NGRAM > 0 ]]; then
    DICTFILE_WORD=$DICTFILE_WORD_SKSP
    GRAMMARFILE_WORD=$GRAMMARFILE_WORD_SKSP
    TOKENS_WORD=$TOKENS_WORD_SKSP
    MLF_LOCATION=$MLF_LOCATION_SKSP
    MLF_LOCATION_WORD=$MLF_LOCATION_WORD_SKSP
    MLF_LOCATION_ORIGINAL=$MLF_LOCATION_ORIGINAL_SKSP
fi

echo "DICTFILE_WORD: $DICTFILE_WORD"
echo "GRAMMARFILE_WORD: $GRAMMARFILE_WORD"
echo "TOKENS_WORD: $TOKENS_WORD"
echo "MLF_LOCATION: $MLF_LOCATION"
echo "MLF_LOCATION_WORD: $MLF_LOCATION_WORD"
echo "MLF_LOCATION_ORIGINAL: $MLF_LOCATION_ORIGINAL"

##############################################################################
##############################################################################
# User Options are ok, This is the important part of the script that does
# the actual work
##############################################################################
##############################################################################

# reads in ${TOKENS} from command file and creates a grammar and dictionary
# assumes that the grammar is a simple, single gesture grammar
typeset -l GEN_GRAMMAR		# make sure it is all lowercase
if [[ "${GEN_GRAMMAR}" == "yes" ]] ||
   [[ "${GEN_GRAMMAR}" == "1" ]]; then

	rm ${GRAMMARFILE}
	rm ${DICTFILE}
	${GRAMMAR_PROG}
fi

# translates ${DATAFILES_LIST} to EXT format (USER) for HTK
# you can read the output of this step by running HList on *.ext

# check to see if we really want to do this


##############################################################################################
############################# This is now handled in grid_search #############################
##############################################################################################

# typeset -l GEN_EXT_FILES	# make sure it is all lowercase
# 
# if [[ "${GEN_EXT_FILES}" == "yes" ]] ||
#    [[ "${GEN_EXT_FILES}" == "1" ]] &&
#    [[ ! -f "${EXT_DIR}/done" ]]; then
# 
#    echo
#    echo "*****************************************************"
#    echo converting data files to .ext files
#    echo "*****************************************************"
#    rm -rf $EXT_DIR/*
#    for n in $(cat ${DATAFILES_LIST});
#    do
# 	 if [[ ! -d `dirname ${EXT_DIR}/$n` ]]; then
# 		echo "Making Directory: `dirname ${EXT_DIR}/$n`"
# 		mkdir -p `dirname ${EXT_DIR}/$n`
# 	 fi
#          ${PREPARE_DATA} $n ${VECTOR_LENGTH} ${EXT_DIR}/$n.ext $SAMPLE_PERIOD
#    #      echo converted $n to `ls ${EXT_DIR} | tail -n 1`  
# 
#    done
#    echo "1" > ${EXT_DIR}/done
# fi


########################################################################
# Prepare data for training/testing
########################################################################

### Set the Cross word files
# if [[ $TRILETTER = "yes" ]] && [[ $CROSS_WORD = "yes" ]]; then
#     TOKENS=$TOKENS_CROSS
#     MLF_LOCATION=$MLF_LOCATION_CROSS
#     DICTFILE=$DICTFILE_CROSS
#     DICTFILE_WORD=$DICTFILE_CROSS_WORD
#     GRAMMARFILE_WORD=$GRAMMARFILE_WORD_CROSS
# fi


# DATA_SAMPLES=all-extfiles

TT_NAME_SCRIPT=$SCRIPTS_DIR/gen_train_test_name.sh      # make consistent names

HMM_BASE_DIR=$HMM_TRAINING
BASE_OUTPUT_MLF=$OUTPUT_MLF
BASE_OUTPUT_MLF_WORD=$OUTPUT_MLF_WORD
BASE_MLF_LOCATION=$MLF_LOCATION
BASE_MLF_LOCATION_GEN=$MLF_LOCATION_GEN

#clean up old training data
rm -f $LOG_RESULTS
rm -f $LOG_RESULTS_WORD
rm -f $DATA_SAMPLES
rm -f $OUTPUT_MLF*
rm -f $OUTPUT_MLF_WORD*
rm -f $WORD_LATTICE*
rm -rf $MLF_LOCATION_GEN/*
for i in ${HMM_TRAINING}*\.*
do
	rm -f $i/*
	rmdir $i
done

# generate a list of all data samples HTK has avaliable to it.
# ls ${EXT_DIR}/*.ext > $DATA_SAMPLES
find ${EXT_DIR}/ | grep "\.ext$" | sort $SORT_OPTION > $DATA_SAMPLES

# if [[ $BIGRAM_LETTER = "yes" ]]; then
#     ${HTKBIN}HLStats -b $BIGRAM_LETTER_FILE -s $ENTER $EXIT -o $TOKENS_ORIGINAL $MLF_LOCATION_ORIGINAL
#     ${HTKBIN}HBuild -n $BIGRAM_LETTER_FILE -s $ENTER $EXIT $TOKENS_ORIGINAL ${WORD_LATTICE}
# else
# fi

${HTKBIN}HParse -l ${GRAMMARFILE} ${WORD_LATTICE}

# if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
#     if [[ $NGRAM_WORD = "yes" ]]; then
#         ${HTKBIN}HLStats -b $BIGRAM_WORD_FILE -s $ENTER $EXIT -o $TOKENS_WORD_SKSP $MLF_LOCATION_WORD_SKSP
#         ${HTKBIN}HBuild -n $BIGRAM_WORD_FILE -s $ENTER $EXIT $TOKENS_WORD_SKSP ${WORD_LATTICE}_word
#     else
#     ${HTKBIN}HParse -l ${GRAMMARFILE_WORD} ${WORD_LATTICE}_word
#     fi
# fi


if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
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
        # mkdir $ROOT/lm.$NGRAM
        # 
        # # Collect n grams from sentence file
        # LGPrep -T 1 -d $ROOT/lm.$NGRAM -n $NGRAM_WORD -s "Fingerspelling All Sentences" $ROOT/empty.wmap grammar/sentences.txt
        # 
        # # Make lm.1 dir
        # # mkdir $ROOT/lm.1
        # 
        # # Bring together n grams (remove dupes).
        # # LGCopy -T 1 -d $ROOT/lm.1 $ROOT/lm.0/wmap $ROOT/lm.0/gram.*
        # 
        # # Make a new directory for intermediates
        # # mkdir $ROOT/lm_all
        # 
        # # Seems to do little but add OOV words
        # # LGCopy -T 1 -o -m $ROOT/lm_all/all.wmap -d $ROOT/lm_all/ -w $TOKENS_WORD_SKSP $ROOT/lm.0/wmap $ROOT/lm.1/data.*
        # 
        # # Get frequency counts
        # LFoF -T 1 -n $NGRAM -f 64 $ROOT/lm.$NGRAM/wmap $ROOT/lm.$NGRAM/all.fof $ROOT/lm.$NGRAM/gram.*
        # 
        # # Builds the language model
        # lm_file="ngram_lm"
        # LBuild -T 1 -n $NGRAM $ROOT/lm.$NGRAM/wmap $ROOT/lm.$NGRAM/$lm_file $ROOT/lm.$NGRAM/gram.*
    fi
fi

MIN_CYCLES=1

# based on the TRAIN_TEST_VALIDATION variable select which script is to be
# used for generating the testing and training set of data.  This variable will
# also determine the number or times training and testing are exectuted
if [[ $TRAIN_TEST_VALIDATION = "CROSS" ]]; then

	TRAIN_TEST_SCRIPT=$SCRIPTS_DIR/cv/gen_cross_val.sh	
	TEST_TRAIN_CYCLES=$MIN_CYCLES

elif [[ $TRAIN_TEST_VALIDATION = "LEAVE_ONE_OUT" ]]; then

	TRAIN_TEST_SCRIPT=$SCRIPTS_DIR/cv/gen_leave_one_out.sh	
	TEST_TRAIN_CYCLES=`cat $DATA_SAMPLES | wc -l`
elif [[ $TRAIN_TEST_VALIDATION = "REPEAT_CROSS" ]]; then

	TRAIN_TEST_SCRIPT=$SCRIPTS_DIR/cv/repeat_cross_val.sh
	TEST_TRAIN_CYCLES=$VALIDATION_ITERATIONS
elif [[ $TRAIN_TEST_VALIDATION = "K_FOLD" ]]; then

	TRAIN_TEST_SCRIPT=$SCRIPTS_DIR/cv/k_fold.sh
	TEST_TRAIN_CYCLES=$VALIDATION_ITERATIONS
elif [[ $TRAIN_TEST_VALIDATION = "TEST_ON_TRAIN" ]]; then

	TRAIN_TEST_SCRIPT=$SCRIPTS_DIR/cv/test_on_train.sh
	TEST_TRAIN_CYCLES=$MIN_CYCLES
else
    echo "invalid testing/training option"
    echo "edit train.sh or options.sh to fix. Exiting ... "
    exit;
fi

# generate the training and testing files, if we're going to
typeset -l GEN_TRAIN_TEST 	# make sure it is all lowercase

if [[ "${GEN_TRAIN_TEST}" == "yes" ]] ||
   [[ "${GEN_TRAIN_TEST}" == "1" ]] ; then
	echo Generating training/test sets, could take a while
	rm -f $TRAINING_BASENAME*
	rm -f $TESTING_BASENAME*
	$TRAIN_TEST_SCRIPT $DATA_SAMPLES $TRAINING_BASENAME $TESTING_BASENAME \
			   $TT_NAME_SCRIPT $OPTIONS_FILE $NUM_TEST_SAMPLES
fi


# based on the type of training/testing validation, iterate through the
# training process
cycle=0; correct=0;
while [[ $cycle -lt $TEST_TRAIN_CYCLES ]]
do

# generate filenames that are dependent on the specific iteration
HMM_TRAINING=$HMM_BASE_DIR$cycle; 
TRAINING=`$TT_NAME_SCRIPT $TRAINING_BASENAME $cycle`
TESTING=`$TT_NAME_SCRIPT $TESTING_BASENAME $cycle`
OUTPUT_MLF=$BASE_OUTPUT_MLF$cycle;
OUTPUT_MLF_WORD=$BASE_OUTPUT_MLF_WORD$cycle;
MLF_LOCATION=$BASE_MLF_LOCATION;
MLF_LOCATION_GEN=${BASE_MLF_LOCATION_GEN}/${cycle};

mkdir ${BASE_MLF_LOCATION_GEN}/${cycle}

## generate the directories to store the iterations of HMM training
hmm_count=0
while [[ $hmm_count -lt $NUM_HMM_DIR ]]
do
    mkdir $HMM_TRAINING.$hmm_count 
    hmm_count=$((hmm_count+1))
done

echo
echo "*****************************************************"
echo Building Models
echo "*****************************************************"
###############################################################################
# now lets build our models 
###############################################################################
# HCompV fills in our mean and variances on the HMM model provided
# -m causes mean evaluation
# -S is the list of EXT files it should use
# -l is the segment label - corresponds to the word we are training on 
# -I is the MLF (Master Label File) - should contain the word list for each ext
#    file 
# -o the label for our output HMM, should be the word its trained on
# -m The covariances of the output HMM are always updated however updating the
#    means must be specifically requested. When this option is set, HCOMPV 
#    updates all the HMM component means with the sample mean computed from 
#    the training files. 
# -M is the directory to store output HMM 
#    (if not given will overwrite the HMMs)
# parameters= HHM file to start with
###############################################################################
# Uses the MLF with single letters
###############################################################################

typeset -l INITIALIZE_HMM	# make sure it is all lowercase
if [[ "${INITIALIZE_HMM}" == "yes" ]] ||
   [[ "${INITIALIZE_HMM}" == "1" ]]; then
	    ## somtimes it works better if you use different topologies for different
	    ## models.
	    ##
	    ## below is an example of how to integrate multiple topologies
		#      if [[ $n = "token1" ]]; then
		#  	HMM_LOCATION=$HMM_TOKEN_1

		#      elif [[ $n = "token2" ]]; then
		#  	HMM_LOCATION=$HMM_TOKEN_2
			
		#      elif [[ $n = "token3" ]]; then
		#  	HMM_LOCATION=$HMM_TOKEN_3
		#      else
		#  	HMM_LOCATION=$HMM_ALL
		#      fi
    
    if [[ $MULTI_PROCESS = "yes" ]]; then
        pid=()
	    for n in $(cat ${TOKENS_ORIGINAL}); do
            if [[ $CUSTOM_SILSP != "yes" ]]; then
                HMM_LOCATION=$HMM_ALL
            elif [[ $n = $ENTER || $n = $EXIT ]]; then
                HMM_LOCATION=$HMM_SIL
            elif [[ $n = $SP ]]; then
                HMM_LOCATION=$HMM_SP
            else
                HMM_LOCATION=$HMM_ALL
            fi

            ${HTKBIN}HCompV -A -T $TRACE_LEVEL -v ${MIN_VARIANCE} -S $TRAINING -l $n 	\
	    		-I $MLF_LOCATION_ORIGINAL -o $n -m -M $HMM_TRAINING.0  	\
	    		$HMM_LOCATION &
            pid+=("$!")
        done
        wait "${pid[@]}"
        
        pid=()
	    for n in $(cat ${TOKENS_ORIGINAL}); do    
            ${HTKBIN}HInit  -A -T $TRACE_LEVEL -v ${MIN_VARIANCE} -M $HMM_TRAINING.1 -l $n 	\
		            -S $TRAINING -I $MLF_LOCATION_ORIGINAL -o $n 	\
		    		$HMM_TRAINING.0/$n &
            pid+=("$!")
	    done
        wait "${pid[@]}"
        
        pid=()
	    for n in $(cat ${TOKENS_ORIGINAL}); do
            ${HTKBIN}HRest  -A  -m 1 -T $TRACE_LEVEL -t -i 30 -v ${MIN_VARIANCE}  -l $n \
		    	-M $HMM_TRAINING.2/ -S $TRAINING 	\
		    	-I $MLF_LOCATION_ORIGINAL $HMM_TRAINING.1/$n &
            pid+=("$!")
	    done
        wait "${pid[@]}"
    else
	    for n in $(cat ${TOKENS_ORIGINAL}); do
            if [[ $CUSTOM_SILSP != "yes" ]]; then
                HMM_LOCATION=$HMM_ALL
            elif [[ $n = $ENTER || $n = $EXIT ]]; then
                HMM_LOCATION=$HMM_SIL
            elif [[ $n = $SP ]]; then
                HMM_LOCATION=$HMM_SP
            else
                HMM_LOCATION=$HMM_ALL
            fi

            ${HTKBIN}HCompV -A -T $TRACE_LEVEL -v ${MIN_VARIANCE} -S $TRAINING -l $n 	\
	    		-I $MLF_LOCATION_ORIGINAL -o $n -m -M $HMM_TRAINING.0  	\
	    		$HMM_LOCATION
            
            gdb --args ${HTKBIN}HInit  -A -T $TRACE_LEVEL -v ${MIN_VARIANCE} -M $HMM_TRAINING.1 -l $n 	\
		            -S $TRAINING -I $MLF_LOCATION_ORIGINAL -o $n 	\
		    		$HMM_TRAINING.0/$n
	  	    
		    ${HTKBIN}HRest  -A  -m 1 -T $TRACE_LEVEL -t -i 30 -v ${MIN_VARIANCE}  -l $n \
		    	-M $HMM_TRAINING.2/ -S $TRAINING 	\
		    	-I $MLF_LOCATION_ORIGINAL $HMM_TRAINING.1/$n
	    done
    fi
else
	cp $HMM_LOCATION $HMM_TRAINING.3/newMacros
fi

echo
echo "*****************************************************"
echo Training Models
echo "*****************************************************"
###############################################################################
# now we train our models
###############################################################################
# HERest updates all of the HMM parameters, that is, means,
# variances, mixture weights and transition probabilies. 
#
# -S is the list of EXT files it should use
# -I is the MLF (Master Label File) - should contain the word list for each ext
# 		file 
# -d this tells where to look for the HMMs
# -M Store output HMM macro model files in the directory dir 
#		(if not given will overwrite the HMMs)
# parameters= hmms to train on (should be our words)
# -m minimum number of training examples for a model
# -o replace file extentions by .ext
# -v f This sets the minimum variance (i.e. diagonal element of the
# covariance matrix) to the real value f (default value 0.0). 
###############################################################################
# Uses the MLF with single letters
# Uses the Tokens file with single letters
###############################################################################


## TLW --> if there is more then one command then this should be newMacros
## TLW --> if there is only one command, then newMacros won't be generated
##	   and we need to use macros named by the commands, in this case
##	   set HMM_MACRO to the empty string, ""
HMM_MACRO="newMacros"
HMM_LOAD_OPT="-H"

## TLW --> added to account for HMM_MACRO
## if HMM_MACRO is the default macro "newMacro" then it must be loaded with
## a -H option.  if it is based on the command names, then it needs to be 
## loaded with -d
if [[ -z ${HMM_MACRO} ]]; then
    HMM_LOAD_OPT="-d";
else
    HMM_MACRO="newMacros";
    HMM_LOAD_OPT="-H";
    
fi

if [[ $MULTI_PROCESS = "yes" ]]; then
	num_lines=`cat $TRAINING | wc -l` #   compute the num lines per file
    lines_per_file=$(($num_lines / $THREADS))
    split -l $lines_per_file $TRAINING "$TRAINING."    # splits train files
fi

if [[ "${INITIALIZE_HMM}" == "yes" ]] || [[ "${INITIALIZE_HMM}" == "1" ]]; then
	## first instance of HERest should be run with the -d option
    if [[ $MULTI_PROCESS = "yes" ]]; then
        pid=()
        i=1
        for train_file in $TRAINING.*; do 
	        ${HTKBIN}HERest -v $MIN_VARIANCE -p $i \
	    		    -A -T $TRACE_LEVEL -S $train_file -d $HMM_TRAINING.2/ \
	    		    -M $HMM_TRAINING.3 -I $MLF_LOCATION_ORIGINAL \
                    ${TOKENS_ORIGINAL} &
            pid+=("$!")
            i=$((i+1))
	    done
        wait "${pid[@]}"

        ${HTKBIN}HERest -v $MIN_VARIANCE -p 0 \
	    		-A -T $TRACE_LEVEL -d $HMM_TRAINING.2/ \
	    		-M $HMM_TRAINING.3 -I $MLF_LOCATION_ORIGINAL \
                ${TOKENS_ORIGINAL} $HMM_TRAINING.3/HER*.acc
    else
	    ${HTKBIN}HERest -v $MIN_VARIANCE \
	    		-A -T $TRACE_LEVEL -S $TRAINING -d $HMM_TRAINING.2/ \
	    		-M $HMM_TRAINING.3 -I $MLF_LOCATION_ORIGINAL ${TOKENS_ORIGINAL}
    fi
fi


## run $NUM_HMM_DIR training iterations over the hmm model.  each iteration
## is stored in a directory $HMM_TRAINING.# where # corresponds to the 
## training iteration.  HERest will be called on hmm.n and stored in hmm.n+1
hmm_count=3

last_iteration=$((NUM_HMM_DIR-1))
if [[ $TRILETTER = "yes" ]] || [[ $TRILETTER = "1" ]]; then
	last_iteration=$((NUM_HMM_DIR-2*TRI_ITERATIONS-4))
fi

while [[ $hmm_count -lt $last_iteration ]]
do
	next_dir=$((hmm_count+1))
    if [[ $MULTI_PROCESS = "yes" ]]; then
        pid=()
        i=1
        for train_file in $TRAINING.*; do
	        ${HTKBIN}HERest -v $MIN_VARIANCE \
	            -A -T $TRACE_LEVEL -S $train_file -p $i	  \
	            $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	            -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION_ORIGINAL  \
                ${TOKENS_ORIGINAL} &
                pid+=("$!")
                i=$((i+1))
        done
        wait "${pid[@]}"

	    ${HTKBIN}HERest -v $MIN_VARIANCE \
	        -A -T $TRACE_LEVEL -p 0	  \
	        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION_ORIGINAL \
            ${TOKENS_ORIGINAL} $HMM_TRAINING.$next_dir/HER*.acc
    else
	    ${HTKBIN}HERest -v $MIN_VARIANCE \
	        -A -T $TRACE_LEVEL -S $TRAINING		  \
	        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION_ORIGINAL ${TOKENS_ORIGINAL}
    fi
	hmm_count=$((hmm_count+1))
done

###############################################################################
# Uses the MLF with triletters
# Uses the Tokens file with triletters
###############################################################################
# if [[ $TRILETTER = "yes" ]] && [[ $CROSS_WORD = "yes" ]]; then
#     TOKENS=$TOKENS_CROSS
#     MLF_LOCATION=$MLF_LOCATION_CROSS
#     DICTFILE=$DICTFILE_CROSS
#     DICTFILE_WORD=$DICTFILE_CROSS_WORD
# fi

if [[ $TRILETTER = "yes" ]] || [[ $TRILETTER = "1" ]]; then
	last_iteration=$((NUM_HMM_DIR-TRI_ITERATIONS-3))

	next_dir=$((hmm_count+1))
	HHEd -A -T $TRACE_LEVEL $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO -M $HMM_TRAINING.$next_dir $HEDFILE1 ${TOKENS_ORIGINAL}
	hmm_count=$((hmm_count+1))

    while [[ $hmm_count -lt $last_iteration ]]
    do
    	next_dir=$((hmm_count+1))
        
        if [[ $MULTI_PROCESS = "yes" ]]; then
            pid=()
            i=1
            for train_file in $TRAINING.*; do
    	        ${HTKBIN}HERest -v $MIN_VARIANCE \
		            -A -T $TRACE_LEVEL -S $train_file -p $i	  \
		            $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		            -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL} &
                pid+=("$!")
                i=$((i+1))
            done
            wait "${pid[@]}"
    	    
            ${HTKBIN}HERest -v $MIN_VARIANCE \
		        -A -T $TRACE_LEVEL -p 0	  \
		        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION  \
                ${TOKENS_ALL} $HMM_TRAINING.$next_dir/HER*.acc
        else
    	    ${HTKBIN}HERest -v $MIN_VARIANCE \
		        -A -T $TRACE_LEVEL -S $TRAINING		  \
		        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL}
        fi
    	hmm_count=$((hmm_count+1))
    done

    last_iteration=$((NUM_HMM_DIR-1))

    next_dir=$((hmm_count+1))
    if [[ $MULTI_PROCESS = "yes" ]]; then
        pid=()
        i=1
        for train_file in $TRAINING.*; do    
            ${HTKBIN}HERest -v $MIN_VARIANCE -p $i \
	        	    -A -T $TRACE_LEVEL -S $train_file -s $STATS	  \
	        	    $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	        	    -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL} &
            pid+=("$!")
            i=$((i+1))
        done
        wait "${pid[@]}"
        
        ${HTKBIN}HERest -v $MIN_VARIANCE -p 0 \
	    	    -A -T $TRACE_LEVEL	-s $STATS	  \
	    	    $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	    	    -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION  \
                ${TOKENS_ALL} $HMM_TRAINING.$next_dir/HER*.acc
	else
        ${HTKBIN}HERest -v $MIN_VARIANCE \
	    	    -A -T $TRACE_LEVEL -S $TRAINING	-s $STATS	  \
	    	    $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
	    	    -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL}
    fi
	hmm_count=$((hmm_count+1))

	next_dir=$((hmm_count+1))
	HHEd -A -T $TRACE_LEVEL $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO -M $HMM_TRAINING.$next_dir $HEDFILE2 ${TOKENS_ALL}
	hmm_count=$((hmm_count+1))

	# Force-align MLFs
	if [[ $FORCE_ALIGN = "yes" ]] || [[ $FORCE_ALIGN = "1" ]]; then
		${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -m -o SW -A -T $TRACE_LEVEL \
			$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO \
			-S $DATA_SAMPLES -I $MLF_LOCATION -i ${MLF_LOCATION_GEN}/labels.mlf $DICTFILE_ALIGN $TOKENS 
		MLF_LOCATION=${MLF_LOCATION_GEN}/labels.mlf
		sed 's/.rec/.lab/g' ${MLF_LOCATION} > ${MLF_LOCATION}_temp
		mv ${MLF_LOCATION}_temp ${MLF_LOCATION}
	fi

    while [[ $hmm_count -lt $last_iteration ]]
    do
    	next_dir=$((hmm_count+1))
        if [[ $MULTI_PROCESS = "yes" ]]; then
    	    pid=()
            i=1
            for train_file in $TRAINING.*; do
                ${HTKBIN}HERest -v $MIN_VARIANCE -p $i \
		            -A -T $TRACE_LEVEL -S $train_file		  \
		            $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		            -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL} &
                pid+=("$!")
                i=$((i+1))
            done
            wait "${pid[@]}"
            
            ${HTKBIN}HERest -v $MIN_VARIANCE -p 0 \
		        -A -T $TRACE_LEVEL                  \
		        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION  \
                ${TOKENS_ALL} $HMM_TRAINING.$next_dir/HER*.acc
        else
    	    ${HTKBIN}HERest -v $MIN_VARIANCE \
		        -A -T $TRACE_LEVEL -S $TRAINING		  \
		        $HMM_LOAD_OPT $HMM_TRAINING.$hmm_count/$HMM_MACRO 	  \
		        -M $HMM_TRAINING.$next_dir -I $MLF_LOCATION ${TOKENS_ALL}
        fi

    	hmm_count=$((hmm_count+1))
    done

    if [[ $EXPORT_MLF = "yes" ]] || [[ $EXPORT_MLF = "1" ]]; then
	    ${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -m -o SWX -A -T $TRACE_LEVEL \
			$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO \
			-S $DATA_SAMPLES -I $MLF_LOCATION_ORIGINAL -i ${MLF_LOCATION_GEN}/labels.mlf_export $DICTFILE $TOKENS_ALL
	fi
fi

if [[ $MULTI_PROCESS = "yes" ]]; then
    rm -rf $TRAINING.*
fi

# echo
# echo "*****************************************************"
# echo Checking our Models
# echo "*****************************************************"
# ###############################################################################
# # now we check our models
# ###############################################################################
# # -H is the HMM to load
# # -S is the list of EXT files it should use
# # -I is the MLF (Master Label File) - should contain the word list for each ext
# # 		file 
# # -i is the MLF file to store output to
# # -a load a label file and create an alignment network for each test file.
# # -n use 'i' tokens to perform N-best recognition.
# # parameters= dictionary file
# # parameters= hmms to use (should correspond to our words)
# ###############################################################################
# 
# ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
# 	$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
# 	-w $WORD_LATTICE -S $TESTING -I $MLF_LOCATION 	\
# 	-i $OUTPUT_MLF $DICTFILE $TOKENS 
# 
# if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
# 	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
# 		$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
# 		-w ${WORD_LATTICE}_word -S $TESTING -I $MLF_LOCATION 	\
# 		-i $OUTPUT_MLF_WORD -n 4 20 $DICTFILE_WORD $TOKENS 
# fi
# 
# # confidence levels
# #HVite -H hmm.7/newMacros -w word.lattice -S $TESTING -I labels.mlf -o output.mlf -n 4 20 dict commands


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
	num_lines=`cat $TESTING | wc -l` #   compute the num lines in test file
    threads=$((num_lines/THREADS))
    
	num_lines=`cat $TESTING | wc -l` #   compute the num lines per file
    lines_per_file=$(($num_lines / $THREADS))
    split -l $lines_per_file $TESTING "$TESTING."     # splits testing files
    pid=()
    
    for test_file in $TESTING.*; do
        OUTPUT_MLF_SUB="$OUTPUT_MLF.${test_file##*.}"
        ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
        	$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
        	-w $WORD_LATTICE -S $test_file -I $MLF_LOCATION 	\
        	-i $OUTPUT_MLF_SUB $DICTFILE $TOKENS_ALL &
        pid+=("$!")

        if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
            OUTPUT_MLF_WORD_SUB="$OUTPUT_MLF_WORD.${test_file##*.}"
        	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
        		$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
        		-w ${WORD_LATTICE}_word -S $test_file -I $MLF_LOCATION 	\
        		-i $OUTPUT_MLF_WORD_SUB -n 4 20 $DICTFILE_WORD $TOKENS_ALL &
            pid+=("$!")
        fi
    done
    wait "${pid[@]}"
    rm -rf $TESTING.*
else
    ${HTKBIN}HVite -p $INSERT_PENALTY -t $PRUNING_THRESHOLD -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
    	$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
    	-w $WORD_LATTICE -S $TESTING -I $MLF_LOCATION 	\
    	-i $OUTPUT_MLF $DICTFILE $TOKENS_ALL
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HVite -p $INSERT_PENALTY -s $GRAMMAR_SCALE_FACTOR -A -T $TRACE_LEVEL 					\
    		$HMM_LOAD_OPT $HMM_TRAINING.$next_dir/$HMM_MACRO 	\
    		-w ${WORD_LATTICE}_word -S $TESTING -I $MLF_LOCATION 	\
    		-i $OUTPUT_MLF_WORD -n 4 20 $DICTFILE_WORD $TOKENS_ALL
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
    output_mlfs=`find ${EXT_DIR} -type f -wholename "$OUTPUT_MLF.*"`
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
     	-p $TOKENS_ORIGINAL $output_mlfs >> $LOG_RESULTS
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
        output_mlfs_word=`find ${EXT_DIR} -type f -wholename "$OUTPUT_MLF_WORD.*"`
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
    		$TOKENS_WORD $output_mlfs_word >> $LOG_RESULTS_WORD
    fi
else
    ${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
     	-p $TOKENS_ORIGINAL $OUTPUT_MLF >> $LOG_RESULTS	
    
    if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
    	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
    		$TOKENS_WORD $OUTPUT_MLF_WORD >> $LOG_RESULTS_WORD
    fi
fi

# update the cycle for the next iteration
cycle=$((cycle+1))

done  # matches the "while" cycles of training


# print the results of HResults of CROSS_VALIDATION
if [[ $TRAIN_TEST_VALIDATION = "CROSS" ]]; then
    startline=`grep -n "Overall Results" ${LOG_RESULTS} |cut -d":" -f 1`
    lastline=`cat ${LOG_RESULTS} |wc -l`
    numlines=`echo $lastline - $startline + 1| bc -l`
    tail -n $numlines ${LOG_RESULTS}
fi

# generate an overall HResults w/ confusion matrix for leave-one-out
if [[ $TRAIN_TEST_VALIDATION = "LEAVE_ONE_OUT" ]] || [[ $TRAIN_TEST_VALIDATION = "REPEAT_CROSS" ]] || [[ $TRAIN_TEST_VALIDATION = "K_FOLD" ]]; then
	rm -f ${BASE_OUTPUT_MLF}-all
	for i in ${BASE_OUTPUT_MLF}*; do
		echo $i
		cat $i >> ${BASE_OUTPUT_MLF}-all
	done
	echo "==========================================================" >> ${LOG_RESULTS}
	echo "OVERALL RESULTS" >> ${LOG_RESULTS}
	echo "==========================================================" >> ${LOG_RESULTS}

	${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -T $TRACE_LEVEL -t -I $MLF_LOCATION_ORIGINAL \
		-p $TOKENS_ORIGINAL ${BASE_OUTPUT_MLF}-all >> $LOG_RESULTS

	if [[ $WORD_LEVEL = "yes" ]] || [[ $WORD_LEVEL = "1" ]]; then
		rm -f ${BASE_OUTPUT_MLF_WORD}-all
		for i in ${BASE_OUTPUT_MLF_WORD}*; do
			echo $i
			cat $i >> ${BASE_OUTPUT_MLF_WORD}-all
		done
		echo "==========================================================" >> ${LOG_RESULTS_WORD}
		echo "OVERALL RESULTS" >> ${LOG_RESULTS_WORD}
		echo "==========================================================" >> ${LOG_RESULTS_WORD}
		${HTKBIN}HResults -A -e "???" $ENTER -e "???" $EXIT -e "???" _ -T $TRACE_LEVEL -t -I $MLF_LOCATION_WORD \
			$TOKENS_WORD ${BASE_OUTPUT_MLF_WORD}-all >> ${LOG_RESULTS_WORD}
	fi
fi
	
# EOF
