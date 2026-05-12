#!/bin/bash

##### For all participants
# typeset -a all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
# 
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a data_splits=(train val)

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

##### For trial 
typeset -a seeds=(1248)
typeset -a data_splits=(train val test)

############################## IMPORT MULTIPLE (DIM20) ##############################

echo ""
echo "STARTING IMPORT"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
    # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
    python ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_rh.pq.${data_split} \
        --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/general/sd${seed}/data \
        --method import &
    pid+=("$!")
done
done
done
wait "${pid[@]}"

############################## IMPORT MULTIPLE (PCA10) ##############################

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
    # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
    python ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pca10_rh.pq.${data_split} \
        --new_data_loc ./data/${dataset}/pca10/thr0/${data_split}/general/sd${seed}/data \
        --method import &
    pid+=("$!")
done
done
done
wait "${pid[@]}"

