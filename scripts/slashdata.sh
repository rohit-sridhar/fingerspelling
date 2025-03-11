#!/bin/bash

####################### Must be run on benten due to sudo #######################
##### Copy HTK Files over

# ContinuousBigram/commands/supplemental/dl_cmp/dim20/thr1/train/grpfpl311/sd1248/commands_tri_internal
scp -r ./ContinuousBigram/commands/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/commands/
scp -r ./ContinuousBigram/dict/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/dict/
scp -r ./ContinuousBigram/grammar/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/grammar/
scp -r ./ContinuousBigram/logs/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/logs/
scp -r ./ContinuousBigram/mlf/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/mlf/

##### Redo with rsync pattern matching to exclude acc files
# scp -r ./ContinuousBigram/models/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/models/
##### 

scp -r ./ContinuousBigram/output/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/output/
scp -r ./ContinuousBigram/results/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/results/

