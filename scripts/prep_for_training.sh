#!/bin/bash

#####
## Arg 1: Absolate path to original fingerspelling directory (hard link metadat from)
## Arg 2: Absolute path to new fingerspelling directory (hard link metadata to)
##### IMPORTANT: The paths must end with ContinuousBigram/

mkdir $2/ext
mkdir $2/models
mkdir $2/output


ln -s $1/logs $2/logs
ln -s $1/data $2/data
ln -s $1/label $2/label
ln -s $1/results $2/results
ln -s $1/models/supplemental $2/models/supplemental # This will be generalized later

cp -r $1/commands $2/
cp -r $1/dict $2/
cp -r $1/grammar $2/
cp -r $1/mlf $2/

# Use these commands when transferring to PACE (Commented out for now).
# mkdir ContinuousBigram/ext
# mkdir ContinuousBigram/models
# mkdir ContinuousBigram/output
# mkdir ContinuousBigram/logs
# mkdir -p ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train
# mkdir -p ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val
# mkdir -p ContinuousBigram/label/supplemental/dl_cmp/thr0/train
# mkdir -p ContinuousBigram/label/supplemental/dl_cmp/thr0/val
# mkdir ContinuousBigram/results
# mkdir ContinuousBigram/commands
# mkdir ContinuousBigram/dict
# mkdir ContinuousBigram/grammar
# mkdir ContinuousBigram/mlf


