#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

output_dir="general_results/tot/${base_dataset}"

typeset -a seeds=(1248)
# Assumes we're in ContinuousBigram dir TODO make it abs path later
if [ ! -d "${ROOT}/results/${output_dir}" ]; then
    mkdir -p "${ROOT}/results/${output_dir}"
fi

############################## TRAIN MULTIPLE DIM20;PCA10;POL20;PCAPOL10 ##############################
# for dataset in ${datasets[@]}; do
# for seed in "${seeds[@]}"; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/pca10/thr0/train/general/sd${seed}/data/ \
#         --hmmdefs 6state-pca10-gmm4-skip \
#         --results_csv ${ROOT}/results/${output_dir}/results_${dataset}.csv \
#         --num_its 1000 --num_tri_its 1000 \
#         --clear_hresults --prepare_data
# done
# done

for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim20/thr0/train/general/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm4-skip \
        --results_csv ${ROOT}/results/${output_dir}/results_${dataset}.csv \
        --num_its 1000 --num_tri_its 1000 \
        --clear_hresults --prepare_data
done
done

