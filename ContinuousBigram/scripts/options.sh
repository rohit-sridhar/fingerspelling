#!/bin/ksh
##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################

##############################################################################
#
# USER MODIFICATION SECTION -- user specific files
#
##############################################################################
						######      Comments     #####
						##############################
						#
PRJ=`pwd`	# path to the current project
SCRIPTS_DIR=$PRJ/scripts			# location of scripts directory
						# for this project.
						#
# UTIL_DIR=/usr/local/gt2k/utils			# location of utils directory
UTIL_DIR=/gt2k/utils
                        #
						#
# VECTOR_LENGTH=60				# number of elements in your
VECTOR_LENGTH=20				# number of elements in your
						# feature vector. This is the
						# number of observations per
						# state for the HMMs.
						#
MIN_VARIANCE=0.01				# don't let the
						# variance fall below
						# this value during
						# HMM training

INSERT_PENALTY=-10	#Penalize model for too many word insertion/deletion
						#If too many deletions, increase
						#If too many insertions, decrease

GRAMMAR_SCALE_FACTOR=0

SAMPLE_PERIOD=1000

MULTI_PROCESS="yes"
# THREADS=8           # For Hotei
THREADS=32        # For Ebisu
# THREADS=96        # For Benten

#PRUNING_THRESHOLD="50 50 500" #Threshold for alpha-beta pruning, of form "start step-size end"
PRUNING_THRESHOLD=0

HMM_TOPOLOGY_DIR=${PRJ}/hmmdefs

# general HMM_TOPOLOGIES
HMM_LOCATION=$HMM_TOPOLOGY_DIR/6state-pca20-gmm4
HMM_ALL=$HMM_LOCATION
HMM_SIL=$HMM_TOPOLOGY_DIR/3state-pca20-sil-skip-loop
HMM_SP=$HMM_TOPOLOGY_DIR/1state-pca20-sp

ENTER="sil0"
EXIT="sil1"
SP="_"

BIGRAM_LETTER=no   # Whether a bigram word net should be used (letter level)
BIGRAM_WORD=no   # Whether a bigram word net should be used (letter level)
CUSTOM_SILSP=yes   # Whether HMM_SIL/HMM_SP should be used

# whether or not to initialize the starting model in a generic way:
INITIALIZE_HMM=yes				# if you have a good initial
						# guess at your model as your
						# starting HMM, say no here.
						# otherwise, it is better
						# to let HTK initialize for you
						#
GEN_TRAIN_TEST=yes				# whether or not to generate
						# new test/train sets. if
						# you have made your own
						# or wish to reuse old sets,
						# set this to no.  otherwise
						# yes.

WORD_LEVEL=yes # whether to process data as word level or letter level
# WORD_LEVEL=no # whether to process data as word level or letter level
TRILETTER=yes # whether to enable triletter configuration
CROSS_WORD=no # whether triletters should expand across words  TODO

FORCE_ALIGN=no # Use to enable/disable forced alignment during training
EXPORT_MLF=no # Use to export MLF for use outside project

NUM_HMM_DIR=20 # number of hmm dirs to generate, has a direct relation to number of times HERest is called
TRI_ITERATIONS=5 # number of HERest calls to make for triletter stages

TRAIN_TEST_VALIDATION="TEST_ON_TRAIN"
#TRAIN_TEST_VALIDATION="K_FOLD"
#TRAIN_TEST_VALIDATION="REPEAT_CROSS"
#TRAIN_TEST_VALIDATION="CROSS"
#TRAIN_TEST_VALIDATION="LEAVE_ONE_OUT"

SORT_OPTION="-V" #Use this for alphabetic data order and sampling
#SORT_OPTION="-R" # Use this for randomized data order and sampling
	
VALIDATION_ITERATIONS=10 #Number of repeats or folds

TT_NAME_SCRIPT=$SCRIPTS_DIR/gen_train_test_name.sh      # make consistent names

DATAFILES_LIST=${PRJ}/output/datafiles			# list of all data files
DATA_SAMPLES=${PRJ}/output/all-extfiles

GRAMMARFILE=${PRJ}/grammar/grammar_letter_isolated
GRAMMARFILE_WORD=${PRJ}/grammar/grammar_word_isolated

###### USE FOR TRILETTER ######
DICTFILE=${PRJ}/dict/dict_tri2letter
DICTFILE_WORD=${PRJ}/dict/dict_tri2word

###### USE FOR SINGLE LETTER ######
# DICTFILE=${PRJ}/dict/dict_letter2letter
# DICTFILE_WORD=${PRJ}/dict/dict_letter2word

###### USE FOR ALIGNMNENT ######
DICTFILE_ALIGN=${PRJ}/dict/dict_tri2tri # Dictionary used during forced alignment

###### USE TO MODEL LETTERS/WORDS WITHOUT SPACE ######
# TOKENS_ORIGINAL=${PRJ}/commands/commands_letter_isolated # used for building model
# TOKENS_WORD=${PRJ}/commands/commands_word_isolated

###### 
# USAGE:
# TOKENS_ORIGINAL is used to initialize letter models. Triletter modeling uses the 
# TOKENS file during triletter iterations.
######
TOKENS_ORIGINAL=${PRJ}/commands/commands_letter
TOKENS_WORD_SKSP=${PRJ}/commands/commands_word_isolated

###### USE FOR TRILETTER MODELING #####
TOKENS=${PRJ}/commands/commands_tri_internal
TOKENS_WORD=${PRJ}/commands/commands_word   # (I think this should be changed to have triletters ... ?)

###### USE FOR SINGLE LETTER MODELING ######
# TOKENS=${PRJ}/commands/commands_letter
# TOKENS_WORD=${PRJ}/commands/commands_word

###### 
# USAGE:
# MLF_LOCATION_ORIGINAL is used for initial training steps on isolated letters.
# Triletter modeling uses the MLF_LOCATION file for training.
######
MLF_LOCATION_ORIGINAL=${PRJ}/mlf/labels.mlf_letter # used for building model and results
MLF_LOCATION_WORD_SKSP=${PRJ}/mlf/labels.mlf_word_sksp

###### USE FOR TRILETTER ######
MLF_LOCATION=${PRJ}/mlf/labels.mlf_tri_internal
MLF_LOCATION_WORD=${PRJ}/mlf/labels.mlf_word

###### USE FOR SINGLE LETTER ######
# MLF_LOCATION=${PRJ}/mlf/labels.mlf_letter
# MLF_LOCATION_WORD=${PRJ}/mlf/labels.mlf_word # (I think this should be changed to have triletters ... ?)

MLF_LOCATION_GEN=${PRJ}/mlf/gen # Generated MLFs

WORD_LATTICE=${PRJ}/output/word.lattice
BIGRAM_LETTER_FILE=${PRJ}/output/bigram.letter
BIGRAM_WORD_FILE=${PRJ}/output/bigram.word

HEDFILE1=${PRJ}/instr/mktri1_silsp.hed
HEDFILE2=${PRJ}/instr/mktri2.hed
STATS=${PRJ}/output/stats
						#
						#
GEN_EXT_FILES=no				# yes or no: generate .ext data
						# files (say yes unless they
						# have already been generated!

PREPARE_DATA=${UTIL_DIR}/prepare		# program for creating HTK-
						# readable data from text

EXT_DIR=${PRJ}/ext				# This is where HTK will put
						# .ext files it generates
						#
GEN_GRAMMAR=no				# yes or no: generate grammar
						# and dict files using the
						# specified GRAMMAR_PROG program

GRAMMAR_PROG=${UTIL_DIR}/create_grammar.pl      # program to create a simple 
						# grammar and dict from a list
						# of commands

OUTPUT_MLF=${EXT_DIR}/result.mlf_letter		# where HTK stores results
						# must be in the same dir as
						# .ext files
OUTPUT_MLF_WORD=${EXT_DIR}/result.mlf_word

LOG_RESULTS=${PRJ}/results/dim20/thr8/grliwi/hresults.log_letter_neg10ip_6state-pca20-gmm4_20its_5tri-its_tc50_silsp
LOG_RESULTS_WORD=${PRJ}/results/dim20/thr8/grliwi/hresults.log_word_neg10ip_6state-pca20-gmm4_20its_5tri-its_tc50_silsp

HMM_TEMP_DIR=${PRJ}/models			# directory for storing
						# intermediate models during
						# iterations of training

HMM_TRAINING=${HMM_TEMP_DIR}/hmm		# base name for iterations of
						# HMM training.  will be a 
						# a directory with .# appended
						# to it where # is the
						# iteration of HERest 
						#
# WARNING: files in directory with this		#
# 	   basename will be erased!!		#
#
#  rm -f $TRAINING_BASENAME*
TRAINING_DIR=${PRJ}/trainsets
TRAINING_BASENAME="${TRAINING_DIR}/training-extfiles"	# all lists of training files
						# will be named this with an
					    	# index number appended to it.
# WARNING: files in directory with this		#
# 	   basename will be erased!!		#
#
#  rm -f $TEST_BASENAME*
TESTING_DIR=${PRJ}/testsets
TESTING_BASENAME="${TESTING_DIR}/testing-extfiles"	# all lists of testing files
						# will be named this with an
					    	# index number appended to it.
						#
TRACE_LEVEL=1					# level of debugging
						#
${HTKBIN=}					# check to see if the path of
	#example:  ${HTKBIN=/usr/local/bin/}	# HTK is set as an environment
    						# variable if not, then use the
						# specified location.  
					    	# now it is set to NULL which
						# means that it will look in 
				   		# your path if left this way.
						# Be sure to include the 
						# trailing slash!
						#
PROMPT_B4_RM="no"				# Prompt before removing files
						# that exist.  can be "yes",
						# "no", or "".  if the value
						# is "no" or "" then files will
						# overwritten without checking
