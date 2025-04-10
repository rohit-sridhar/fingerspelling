#!/bin/bash

##### Copy HTK Files over
rsync -H --progress ./ContinuousBigram/commands/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands
rsync -H --progress ./ContinuousBigram/dict/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/dict
rsync -H --progress ./ContinuousBigram/grammar/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/grammar
rsync -H --progress ./ContinuousBigram/mlf/* rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/mlf

#### Copy all train and val data
dataset="supplemental_gen"

rsync -rH --progress ./ContinuousBigram/data/$dataset/dim20/thr0/all ./ContinuousBigram/data/$dataset/dim20/thr0/train ./ContinuousBigram/data/$dataset/dim20/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dim20/thr0/

rsync -rH --progress ./ContinuousBigram/label/$dataset/dim20/thr0/all ./ContinuousBigram/label/$dataset/dim20/thr0/train ./ContinuousBigram/label/$dataset/dim20/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dim20/thr0/

