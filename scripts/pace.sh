#!/bin/bash

##### Copy HTK Files over
rsync -H --progress ./ContinuousBigram/commands/commands_tri_internal.all rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands

#### Copy all train and val data
base_dataset=supplemental_gen
typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)

#### Sync everything under specific pt dirs
# rsync -rHR --progress ./ContinuousBigram/data/${dataset}/dim20/thr0/./train/pt03ad ./ContinuousBigram/data/${dataset}/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/${dataset}/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/label/${dataset}/dim20/thr0/./train/pt03ad ./ContinuousBigram/label/${dataset}/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/${dataset}/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/data/${dataset}/dim20/thr0/./train/pt3f8b ./ContinuousBigram/data/${dataset}/dim20/thr0/./val/pt3f8b rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/${dataset}/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/label/${dataset}/dim20/thr0/./train/pt3f8b ./ContinuousBigram/label/${dataset}/dim20/thr0/./val/pt3f8b rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/${dataset}/dim20/thr0/

#### Sync everything under the all/train/val/test dir
for dataset in ${datasets[@]}; do
    rsync -rHR --progress ./ContinuousBigram/data/${dataset}/dim20/thr0/./all ./ContinuousBigram/data/${dataset}/dim20/thr0/./train ./ContinuousBigram/data/${dataset}/dim20/thr0/./val ./ContinuousBigram/data/${dataset}/dim20/thr0/./test rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/${dataset}/dim20/thr0/
    rsync -rHR --progress ./ContinuousBigram/label/${dataset}/dim20/thr0/./all ./ContinuousBigram/label/${dataset}/dim20/thr0/./train ./ContinuousBigram/label/${dataset}/dim20/thr0/./val ./ContinuousBigram/label/${dataset}/dim20/thr0/./test rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/${dataset}/dim20/thr0/
done

