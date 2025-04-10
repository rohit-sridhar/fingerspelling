#!/bin/bash

##### Copy HTK Files over
rsync -H --exclude "*/" --progress ./ContinuousBigram/commands/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands
rsync -H --exclude "*/" --progress ./ContinuousBigram/dict/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/dict
rsync -H --exclude "*/" --progress ./ContinuousBigram/grammar/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/grammar
rsync -H --exclude "*/" --progress ./ContinuousBigram/mlf/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/mlf

# #### Copy PT 93 train and val data
# rsync -rH --progress ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train/pt93 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train
# 
# rsync -rH --progress ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val/pt93 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val
# 
# #### Copy PT 93 train and val labels
# rsync -rH --progress ./ContinuousBigram/label/supplemental/dl_cmp/thr0/train/pt93 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/supplemental/dl_cmp/thr0/train
# 
# rsync -rH --progress ./ContinuousBigram/label/supplemental/dl_cmp/thr0/val/pt93 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/supplemental/dl_cmp/thr0/val
# 
# #### Copy PT 161 train and val data
# rsync -rH --progress ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train/pt161 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train
# 
# rsync -rH --progress ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val/pt161 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val
# 
# #################### Copy PT 161 train and val labels
# rsync -rH --progress ./ContinuousBigram/label/supplemental/dl_cmp/thr0/train/pt161 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/supplemental/dl_cmp/thr0/train
# 
# rsync -rH --progress ./ContinuousBigram/label/supplemental/dl_cmp/thr0/val/pt161 rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/supplemental/dl_cmp/thr0/val

#### Copy all train and val data
dataset="supplemental_gen"
rsync -rH --progress ./ContinuousBigram/data/$dataset/dl_cmp/dim20/thr0/all ./ContinuousBigram/data/$dataset/dl_cmp/dim20/thr0/train ./ContinuousBigram/data/$dataset/dl_cmp/dim20/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dl_cmp/dim20/thr0/

rsync -rH --progress ./ContinuousBigram/label/$dataset/dl_cmp/thr0/all ./ContinuousBigram/label/$dataset/dl_cmp/thr0/train ./ContinuousBigram/label/$dataset/dl_cmp/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dl_cmp/thr0/

