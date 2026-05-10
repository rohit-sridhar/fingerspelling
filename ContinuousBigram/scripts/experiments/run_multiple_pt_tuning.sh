#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

output_dir=${ROOT}/results/pt_results/tot/${dataset}

# Assumes we're in ContinuousBigram dir
if [ ! -d "${output_dir}" ]; then
    mkdir -p "${output_dir}"
fi

############################## TRAIN MULTIPLE NO INTERPOLATION ##############################
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${all_participants[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 5state-pca20-gmm2 4state-pca20-gmm2 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done

