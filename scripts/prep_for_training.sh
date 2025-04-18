#!/bin/bash

#####
## Arg 1: Absolate path to original fingerspelling directory (hard link metadata from)
## Arg 2: Absolute path to new fingerspelling directory (hard link metadata to)
##### IMPORTANT: The paths must end with ContinuousBigram/

# mkdir $2/ext
# mkdir $2/models
# mkdir $2/output
# 
# cp -rl $1/logs $2/logs
# cp -rl $1/data $2/data
# cp -rl $1/label $2/label
# cp -rl $1/results $2/results
# cp -rl $1/commands $2/commands
# cp -rl $1/dict $2/dict
# cp -rl $1/grammar $2/grammar
# cp -rl $1/mlf $2/mlf
# cp -rl $1/models/supplemental $2/models/supplemental # This will be generalized later


# Use these commands when transferring to PACE (Commented out for now).
mkdir ContinuousBigram/ext
mkdir ContinuousBigram/models
mkdir ContinuousBigram/output
mkdir ContinuousBigram/logs
mkdir -p ContinuousBigram/data/supplemental_gen/dim20/thr0/train
mkdir -p ContinuousBigram/data/supplemental_gen/dim20/thr0/val
mkdir -p ContinuousBigram/label/supplemental_gen/thr0/train
mkdir -p ContinuousBigram/label/supplemental_gen/thr0/val
mkdir ContinuousBigram/results
mkdir ContinuousBigram/commands
mkdir ContinuousBigram/dict
mkdir ContinuousBigram/grammar
mkdir ContinuousBigram/mlf

