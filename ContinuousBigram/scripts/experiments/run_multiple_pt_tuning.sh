#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@

############################## SET OUTPUT DIR ##############################
output_dir=${ROOT}/results/pt_results/tot
if [[ -n "${bootstrap}" ]]; then
    output_dir=${ROOT}/results/pt_results/tot_bts
fi

if [ ! -d "${output_dir}" ]; then
    mkdir -p "${output_dir}"
fi

set_slurm_subsets_if_exists participants

############################## TRAIN MULTIPLE (DIM10) ##############################
# Default
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults ${bootstrap} ${debug}
done
done
done
done

# # Force align
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --prepare_data --clear_hresults --force_align ${debug}
# done
# done
# done
# done

# Cross word
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults --cross_word ${bootstrap} ${debug}
done
done
done
done

# # Full cov
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --prepare_data --clear_hresults --full_cov ${debug}
# done
# done
# done
# done

# ############################## TRAIN MULTIPLE (DIM20) ##############################
# # Default
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca20-gmm1-skip1 4state-pca20-gmm1-skip1 5state-pca20-gmm1-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --no_multi_process --prepare_data --clear_hresults ${debug}
# done
# done
# done
# done
# 
# # Force align
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca20-gmm1-skip1 4state-pca20-gmm1-skip1 5state-pca20-gmm1-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --no_multi_process --prepare_data --clear_hresults --force_align ${debug}
# done
# done
# done
# done
# 
# # Cross word
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca20-gmm1-skip1 4state-pca20-gmm1-skip1 5state-pca20-gmm1-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --no_multi_process --prepare_data --clear_hresults --cross_word ${debug}
# done
# done
# done
# done
# 
# # Full cov
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca20-gmm1-skip1 4state-pca20-gmm1-skip1 5state-pca20-gmm1-skip1 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --no_multi_process --prepare_data --clear_hresults --full_cov ${debug}
# done
# done
# done
# done
# 
# ############################## TRAIN MULTIPLE (PCA10) ##############################
# for dataset in ${datasets[@]}; do
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/pca10/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --hmmdefs 3state-pca10-gmm2-skip 3state-pca10-gmm2-skip1 3state-pca10-gmm2 4state-pca10-gmm2-skip 4state-pca10-gmm2-skip1 4state-pca10-gmm2 5state-pca10-gmm2-skip 5state-pca10-gmm2-skip1 5state-pca10-gmm2 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --prepare_data --clear_hresults ${debug}
# done
# done
# done
# done
# 
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

