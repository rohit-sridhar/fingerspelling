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
SCRIPTS_DIR=${PRJ}/scripts			# location of scripts directory
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

MULTI_PROCESS=yes
THREADS=96

#PRUNING_THRESHOLD="50 50 500" #Threshold for alpha-beta pruning, of form "start step-size end"
PRUNING_THRESHOLD=0

HMM_TOPOLOGY_DIR=${PRJ}/hmmdefs

# general HMM_TOPOLOGIES
HMM_LOCATION=$HMM_TOPOLOGY_DIR/4state-pca20-gmm2
HMM_ALL=$HMM_LOCATION
HMM_SIL=$HMM_TOPOLOGY_DIR/3state-pca20-sil-skip-loop
HMM_SP=$HMM_TOPOLOGY_DIR/1state-pca20-sp

ENTER="sil0"
EXIT="sil1"
SP="_"

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
TRILETTER=yes # whether to enable triletter configuration
CROSS_WORD=no # whether triletters should expand across words  TODO

FORCE_ALIGN=no # Use to enable/disable forced alignment during training
EXPORT_MLF=no # Use to export MLF for use outside project
WHOLE_WORD=no

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

OUTPUTFILE_ROOT=${PRJ}/output/dim20/thr1/train/ptfbb7/sd1248

DATAFILES_LIST=${OUTPUTFILE_ROOT}/datafiles			# list of all data files
DATA_SAMPLES=${OUTPUTFILE_ROOT}/all-extfiles

NUM_TEST_SAMPLES=100

#######################################################
#################### GRAMMAR FILES ####################
#######################################################

GRAMMARFILE_ROOT=${PRJ}/grammar/dim20/thr1/train/ptfbb7/sd1248

###### USE FOR TRAINING ######
GRAMMARFILE=${GRAMMARFILE_ROOT}/grammar_letter_isolated
GRAMMARFILE_WHOLE=${GRAMMARFILE_ROOT}/grammar_letter_isolated_whole

GRAMMARFILE_WORD=${GRAMMARFILE_ROOT}/grammar_word_isolated
GRAMMARFILE_WORD_SKSP=${GRAMMARFILE_ROOT}/grammar_word_isolated_sksp
GRAMMARFILE_WORD_WHOLE=${GRAMMARFILE_ROOT}/grammar_word_isolated_whole

###### USE FOR CROSS WORD TRILETTER ######
GRAMMARFILE_WORD_CROSS=${GRAMMARFILE_ROOT}/grammar_word_cross

SENTENCES_FILE=${PRJ}/grammar/sentences.txt

#######################################################
##################### DICT FILES ######################
#######################################################

DICTFILE_ROOT=${PRJ}/dict/dim20/thr1/train/ptfbb7/sd1248

###### USE FOR MAIN TRAINING ######
DICTFILE=${DICTFILE_ROOT}/dict_tri2letter
DICTFILE_WHOLE=${DICTFILE_ROOT}/dict_tri2letter_whole

DICTFILE_WORD=${DICTFILE_ROOT}/dict_tri2word
DICTFILE_WORD_SKSP=${DICTFILE_ROOT}/dict_tri2word_sksp
DICTFILE_WORD_WHOLE=${DICTFILE_ROOT}/dict_tri2word_whole

###### USE FOR CROSS WORD TRILETTER ######
DICTFILE_CROSS=${DICTFILE_ROOT}/dict_tri2letter_cross
DICTFILE_CROSS_WORD=${DICTFILE_ROOT}/dict_tri2word_cross

###### USE FOR SINGLE LETTER ######
# DICTFILE=${PRJ}/dict/dict_letter2letter
# DICTFILE_WORD=${PRJ}/dict/dict_letter2word

###### USE FOR ALIGNMNENT ######
DICTFILE_ALIGN=${DICTFILE_ROOT}/dict_tri2tri # Dictionary used during forced alignment

#######################################################
################### COMMANDS FILES ####################
#######################################################

TOKENS_ROOT=${PRJ}/commands/dim20/thr1/train/ptfbb7/sd1248

###### 
# USAGE:
# TOKENS_ORIGINAL is used to initialize letter models. Triletter modeling uses the 
# TOKENS file during triletter iterations.
######
TOKENS_ALL=${PRJ}/commands/commands_tri_internal.all

###### USE FOR INITIAL TRAINING ######
TOKENS_ORIGINAL=${TOKENS_ROOT}/commands_letter
TOKENS_ORIGINAL_WHOLE=${TOKENS_ROOT}/commands_letter_whole
# TOKENS_ORIGINAL_SKSP=${PRJ}/commands/commands_letter_isolated

###### USE FOR MAIN TRAINING ######
TOKENS=${TOKENS_ROOT}/commands_tri_internal
TOKENS_WHOLE=${TOKENS_ROOT}/commands_tri_internal_whole

TOKENS_WORD=${TOKENS_ROOT}/commands_word
TOKENS_WORD_SKSP=${TOKENS_ROOT}/commands_word_sksp
TOKENS_WORD_WHOLE=${TOKENS_ROOT}/commands_word_whole

###### USE FOR CROSS WORD TRILETTER ######
TOKENS_CROSS=${TOKENS_ROOT}/commands_tri_cross

#######################################################
##################### MLF FILES #######################
#######################################################

######
# USAGE:
# MLF_LOCATION_ORIGINAL is used for initial training steps on isolated letters.
# Triletter modeling uses the MLF_LOCATION file for training.
######

MLF_ROOT=${PRJ}/mlf/dim20/thr1/train/ptfbb7/sd1248

###### USE FOR INITIAL TRAINING ######
# The mlf letter files below BOTH contain spaces
# despite one being designated sksp.

MLF_LOCATION_ORIGINAL=${MLF_ROOT}/labels.mlf_letter # used for building model and results
MLF_LOCATION_ORIGINAL_SKSP=${MLF_ROOT}/labels.mlf_letter_sksp # used for building model and results
MLF_LOCATION_ORIGINAL_WHOLE=${MLF_ROOT}/labels.mlf_letter_whole # used for building model and results

###### USE FOR MAIN TRAINING ######
MLF_LOCATION=${MLF_ROOT}/labels.mlf_tri_internal
MLF_LOCATION_SKSP=${MLF_ROOT}/labels.mlf_tri_internal_sksp
MLF_LOCATION_WHOLE=${MLF_ROOT}/labels.mlf_tri_internal_whole

MLF_LOCATION_WORD=${MLF_ROOT}/labels.mlf_word
MLF_LOCATION_WORD_SKSP=${MLF_ROOT}/labels.mlf_word_sksp
MLF_LOCATION_WORD_WHOLE=${MLF_ROOT}/labels.mlf_word_whole

###### USE FOR CROSS WORD TRILETTER ######
MLF_LOCATION_CROSS=${MLF_ROOT}/labels.mlf_tri_cross

###### USE FOR SINGLE LETTER ######
# MLF_LOCATION=${PRJ}/mlf/labels.mlf_letter
# MLF_LOCATION_WORD=${PRJ}/mlf/labels.mlf_word

MLF_LOCATION_GEN=${MLF_ROOT}/gen # Generated MLFs

WORD_LATTICE=${OUTPUTFILE_ROOT}/word.lattice
# BIGRAM_LETTER_FILE=${OUTPUTFILE_ROOT}bigram.letter

WORD_SKSP=yes
LM_DIR=${PRJ}/lang_models

HEDFILE1=${PRJ}/instr/mktri1_silsp.hed
HEDFILE2=${PRJ}/instr/mktri2_tc.4state-pca20-gmm2.hed

LEDFILE_UNIQ=dim20_thr1_train_ptfbb7_sd1248
LEDFILE_WORD=${PRJ}/instr/mkcmd_word.${LEDFILE_UNIQ}.led
LEDFILE_LETTER=${PRJ}/instr/mkcmd_letter.${LEDFILE_UNIQ}.led

STATS=${OUTPUTFILE_ROOT}/stats
						#
						#
GEN_EXT_FILES=no				# yes or no: generate .ext data
						# files (say yes unless they
						# have already been generated!

PREPARE_DATA=${UTIL_DIR}/prepare		# program for creating HTK-
						# readable data from text

EXT_DIR=${PRJ}/ext/dim20/thr1/train/ptfbb7/sd1248
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

LOG_RESULTS=${PRJ}/results/dim20/thr1/train/ptfbb7/sd1248/hresults.log_letter_neg10ip_4state-pca20-gmm2_20its_5tri-its_tc50
LOG_RESULTS_WORD=${PRJ}/results/dim20/thr1/train/ptfbb7/sd1248/hresults.log_word_neg10ip_4state-pca20-gmm2_20its_5tri-its_tc50

HMM_TEMP_DIR=${PRJ}/models/dim20/thr1/train/ptfbb7/sd1248
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
# TRAINING_DIR=${PRJ}/trainsets

TRAINING_BASENAME="${OUTPUTFILE_ROOT}/training-extfiles"	# all lists of training files
						# will be named this with an
					    	# index number appended to it.

# WARNING: files in directory with this		#
# 	   basename will be erased!!		#
#
#  rm -f $TEST_BASENAME*
# TESTING_DIR=${PRJ}/testsets

TESTING_BASENAME="${OUTPUTFILE_ROOT}/testing-extfiles"	# all lists of testing files
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
