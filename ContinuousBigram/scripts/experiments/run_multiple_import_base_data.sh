#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram

. ${ROOT}/scripts/experiments/utils.sh

if [[ $1 != "supplemental_gen" && $1 != "main_train" ]]; then
    echo "you can only pass supplemental_gen or main_train as the first arg for now. tbd add more datasets"
    exit 1
fi

base_dataset=$1
typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0 ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na_lininterp1)

echo ""
echo "STARTING IMPORT"
echo ""

for dataset in ${datasets[@]}; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_rh.pkl.all \
        --new_data_loc ./data/${dataset}/dim20/thr0/all/data \
        --method import
done
#         --char_map_file ${TORCH_ROOT}/${base_dataset}_character_to_prediction_index.json \

