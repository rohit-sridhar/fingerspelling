#!/usr/bin/env bash
set -euo pipefail

##################################################################
# All code in the project is provided under the terms specified in
# the file "Public Use.doc" (plaintext version in "Public Use.txt").
#
# If a copy of this license was not provided, please send email to
# haileris@cc.gatech.edu
##################################################################


###############################################################################
# Generate Training and Testing sets for Cross Validation:
#
# generates two files.  one, a list of filenames to be used for training and
# one file will be a list of filenames to be used for testing.
#
# argument 1: a file listing all datafiles to be considered
# argument 2: name of where to save the training file
# argument 3: name of where to save the testing file
# argument 4: script to generate the name of the training/test files
# argument 5: options file for the project (so we can locate the utils dir)
# argument 6: sample size for testing file (will subsample training set)
#
###############################################################################
ALL_FILES=${1:-}
NAME_SCRIPT=${4:-}
TRAINING=`${NAME_SCRIPT} ${2:-} 0`	# generate name for the training file
TESTING=`${NAME_SCRIPT} ${3:-} 0`	# generate name for the testing file
OPTIONS_FILE=${5:-}
SAMPLE_SIZE=${6:-}

. ${OPTIONS_FILE}				# include the project options

cp ${ALL_FILES} ${TRAINING}
cp ${ALL_FILES} ${TESTING}

shuf -n ${SAMPLE_SIZE} ${ALL_FILES} > ${TESTING}
# cat ${ALL_FILES} | sort -R | head -n ${SAMPLE_SIZE} > ${TESTING}
