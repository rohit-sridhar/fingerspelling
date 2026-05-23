#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

base_dataset=supplemental_gen
output_dir="general_results/tot/${base_dataset}"

typeset -a seeds=(1248)

# Assumes we're in ContinuousBigram dir TODO make it abs path later
if [ ! -d "results/${output_dir}" ]; then
    mkdir -p "results/${output_dir}"
fi

############################## TRAIN MULTIPLE DIM20;PCA10;POL20;PCAPOL10 ##############################
#         --hmmdefs 6state-pca20-gmm4 6state-pca20-gmm4-skip \
for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr0/train/general/sd${seed}/data/ \
        --hmmdefs 6state-pca20 \
        --results_csv ./results/${output_dir}/results_${dataset}.csv \
        --num_its 10 --num_tri_its 10 \
        --clear_hresults --prepare_data --test_model
done
done

# for dataset in ${datasets[@]}; do
# for seed in "${seeds[@]}"; do
#     python scripts/grid_search.py \
#         --data_files ./data/${dataset}/pca10/thr0/train/general/sd${seed}/data/ \
#         --hmmdefs 6state-pca10-gmm4 6state-pca10-gmm4-skip \
#         --results_csv ./results/${output_dir}/results_${dataset}.csv \
#         --num_its 10 --num_tri_its 10 \
#         --clear_hresults --prepare_data
# done
# done
