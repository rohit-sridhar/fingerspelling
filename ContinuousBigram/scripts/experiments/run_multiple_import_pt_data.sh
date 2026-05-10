#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

echo ""
echo "STARTING IMPORT"
echo ""

############################## IMPORT MULTIPLE (TRAIN,VAL) ##############################
# 
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for seed in "${seeds[@]}"; do
# pid=()
# for participant in "${all_participants[@]}"; do
#     python scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_rh.pkl.${data_split} \
#         --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
#         --method import &
#     pid+=("$!")
# done
# wait "${pid[@]}"
# done
# done
# done
# 
############################## IMPORT MULTIPLE (TEST) ##############################

typeset -a data_splits=(test)
# typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0)

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
pid=()
for participant in "${all_participants[@]}"; do
    python ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_pt-${participant}_rh.pkl.all \
        --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/data \
        --method import &
    pid+=("$!")
done
wait "${pid[@]}"
done
done

