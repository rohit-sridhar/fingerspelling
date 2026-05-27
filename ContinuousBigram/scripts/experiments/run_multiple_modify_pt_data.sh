#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# File: ROOT/ContinuousBigram/scripts/experiments/run_multiple_modify_pt_data.sh
# Date: 
# Last Modified:

# Description
#   

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

############################## THRESHOLD MULTIPLE (TRAIN, VAL) ##############################

data_splits=(train)
participants=(ab12)

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in ${seeds[@]}; do
for threshold in ${thresholds[@]}; do

if [[ $threshold == 0 ]]; then
    continue
fi

pid=()
for participant in ${participants[@]}; do
    ${ROOT}/scripts/modify_data.py \
        --data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --new_data_loc ${ROOT}/data/${dataset}/dim20/thr${threshold}/${data_split}/pt/${participant}/sd${seed}/data \
        --method fpl_threshold \
        --fpl_threshold ${threshold} &
    pid+=("$!")
done

wait "${pid[@]}"
done
done
done
done

############################## THRESHOLD MULTIPLE (TEST) ##############################
# 
# typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0)
# typeset -a data_splits=(test)
# 
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for threshold in ${thresholds[@]}; do
# if [[ $threshold == 0 ]]; then
#     continue
# fi
# pid=()
# for participant in ${participants[@]}; do
#     python scripts/modify_data.py \
#         --data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/data \
#         --new_data_loc ${ROOT}/data/${dataset}/dim20/thr${threshold}/${data_split}/pt/${participant}/data \
#         --method fpl_threshold \
#         --fpl_threshold ${threshold} &
#     pid+=("$!")
# done
# wait "${pid[@]}"
# done
# done
# done
# 
