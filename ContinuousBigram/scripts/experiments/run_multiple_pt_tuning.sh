#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@

output_dir=${ROOT}/results/pt_results/tot/

# Assumes we're in ContinuousBigram dir
if [ ! -d "${output_dir}" ]; then
    mkdir -p "${output_dir}"
fi

# --hmmdefs 6state-pca20-gmm2 5state-pca20-gmm2 4state-pca20-gmm2 \
participants=(ab12)
############################## TRAIN MULTIPLE (DIM20) ##############################
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 3state-pca20-gmm2-skip 3state-pca20-gmm2-skip1 3state-pca20-gmm2 4state-pca20-gmm2-skip 4state-pca20-gmm2-skip1 4state-pca20-gmm2 5state-pca20-gmm2-skip 5state-pca20-gmm2-skip1 5state-pca20-gmm2 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults ${debug}
done
done
done
done

# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 4state-pca20-gmm2-skip \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --prepare_data --clear_hresults --cross_word ${debug}
# done
# done
# done
# done

# seeds=(3248 4248 5248)
############################## TRAIN MULTIPLE (PCA10) ##############################
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/pca10/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 3state-pca10-gmm2-skip 3state-pca10-gmm2-skip1 3state-pca10-gmm2 4state-pca10-gmm2-skip 4state-pca10-gmm2-skip1 4state-pca10-gmm2 5state-pca10-gmm2-skip 5state-pca10-gmm2-skip1 5state-pca10-gmm2 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults ${debug}
done
done
done
done

# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/pca10/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca10-gmm2-skip 4state-pca10-gmm2-skip 5state-pca10-gmm2-skip \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --prepare_data --clear_hresults --cross_word ${debug}
# done
# done
# done
# done

