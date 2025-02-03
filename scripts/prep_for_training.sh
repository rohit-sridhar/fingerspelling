#!/bin/bash

#####
## Arg 1: Absolate path to original fingerspelling directory (hard link metadat from)
## Arg 2: Absolute path to new fingerspelling directory (hard link metadata to)
##### IMPORTANT: The paths must end with ContinuousBigram/

ln -s $1/logs $2/logs
ln -s $1/data $2/data
ln -s $1/label $2/label
ln -s $1/results $2/results
ln -s $1/models $2/models

mkdir $2/ext
mkdir $2/output
mkdir $2/trainsets
mkdir $2/testsets
touch $2/trainsets/training-extfiles0
touch $2/testsets/testing-extfiles0

cp -r $1/commands $2/
cp -r $1/dict $2/
cp -r $1/grammar $2/
cp -r $1/mlf $2/
