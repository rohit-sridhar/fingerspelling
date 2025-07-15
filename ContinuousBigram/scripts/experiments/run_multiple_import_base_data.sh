#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram

. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

echo ""
echo "STARTING IMPORT"
echo ""

for dataset in ${datasets[@]}; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_rh.pkl.all \
        --new_data_loc ./data/${dataset}/dim20/thr0/all/data \
        --method import
done

