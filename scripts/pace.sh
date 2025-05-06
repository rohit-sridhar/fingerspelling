#!/bin/bash

##### Copy HTK Files over
rsync -H --progress ./ContinuousBigram/commands/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands
rsync -H --progress ./ContinuousBigram/dict/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/dict
rsync -H --progress ./ContinuousBigram/grammar/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/grammar
rsync -H --progress ./ContinuousBigram/mlf/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/mlf

#### Copy all train and val data
dataset="supplemental_gen"

rsync -rHR --progress ./ContinuousBigram/data/$dataset/dim20/thr0/./train/pt03ad ./ContinuousBigram/data/$dataset/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dim20/thr0/

rsync -rHR --progress ./ContinuousBigram/label/$dataset/dim20/thr0/./train/pt03ad ./ContinuousBigram/label/$dataset/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dim20/thr0/

