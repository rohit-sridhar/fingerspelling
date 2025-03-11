#!/bin/bash

####################### Must be run on benten due to sudo #######################
##### Copy HTK Files over

# ContinuousBigram/commands/supplemental/dl_cmp/dim20/thr1/train/grpfpl311/sd1248/commands_tri_internal
rsync -rH --progress ./ContinuousBigram/commands/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/commands/
rsync -rH --progress ./ContinuousBigram/dict/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/dict/
rsync -rH --progress ./ContinuousBigram/grammar/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/grammar/
rsync -rH --progress ./ContinuousBigram/logs/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/logs/
rsync -rH --progress ./ContinuousBigram/mlf/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/mlf/
rsync -rH --progress ./ContinuousBigram/models/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/models/
rsync -rH --progress ./ContinuousBigram/output/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/output/
rsync -rH --progress ./ContinuousBigram/results/supplemental rsridhar37@benten.cc.gatech.edu:/data/hmm_modeling/fingerspelling/ContinuousBigram/results/

