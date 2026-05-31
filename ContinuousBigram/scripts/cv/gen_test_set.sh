#!/bin/ksh

###############################################################################
# Generate Testing sets for testing a model. Run prepare_data.sh on the test
# data and labels before running this script, since this script assumes that
# output/all-extfiles exists already.
#
# argument 1: a file listing all datafiles to be considered
# argument 2: name of where to save the testing file
# argument 3: script to generate the name of the test files
#
###############################################################################

ALL_FILES=$1
NAME_SCRIPT=$3

TESTING=`$NAME_SCRIPT $2 0`	# generate name for the testing file
cat $ALL_FILES | sort -R | head -n $4 > $TESTING

