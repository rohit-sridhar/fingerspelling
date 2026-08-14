#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@

typeset -a data_groups=(general pt-split)

set_slurm_subsets_if_exists data_groups seeds

output_dir=${ROOT}/results/general_results/tot

if [ ! -d "${output_dir}" ]; then
    mkdir -p "${output_dir}"
fi

############################## TRAIN MULTIPLE DIM10 ##############################
for dataset in ${datasets[@]}; do
for seed in ${seeds[@]}; do
for data_group in ${data_groups[@]}; do
    results_csv=${output_dir}/results_dg${data_group}_sd${seed}_tuning.csv

    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/train/${data_group}/sd${seed}/data/ \
        --hmmdefs 6state-pca10-gmm2 6state-pca10-gmm2-skip1 \
        --results_csv ${results_csv} \
        --num_its 500 --num_tri_its 100 \
        --clear_hresults --prepare_data

    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/train/${data_group}/sd${seed}/data/ \
        --hmmdefs 6state-pca10-gmm2 6state-pca10-gmm2-skip1 \
        --results_csv ${results_csv} \
        --num_its 500 --num_tri_its 100 \
        --force_align --clear_hresults --prepare_data

    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/train/${data_group}/sd${seed}/data/ \
        --hmmdefs 6state-pca10-gmm2 6state-pca10-gmm2-skip1 \
        --results_csv ${results_csv} \
        --num_its 500 --num_tri_its 100 \
        --cross_word --clear_hresults --prepare_data

    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/train/${data_group}/sd${seed}/data/ \
        --hmmdefs 6state-pca10-gmm2 6state-pca10-gmm2-skip1 \
        --results_csv ${results_csv} \
        --num_its 500 --num_tri_its 100 \
        --full_cov --clear_hresults --prepare_data
    
done
done
done

# ############################## TRAIN MULTIPLE DIM20 ##############################
# for dataset in ${datasets[@]}; do
# for seed in ${seeds[@]}; do
# for data_group in ${data_groups[@]}; do
#     results_csv=${output_dir}/results_dg${data_group}_sd${seed}_tuning.csv
# 
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/train/${data_group}/sd${seed}/data/ \
#         --hmmdefs 6state-pca20-gmm2 6state-pca20-gmm2-skip1 \
#         --results_csv ${results_csv} \
#         --num_its 500 --num_tri_its 100 \
#         --clear_hresults --prepare_data
# 
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/train/${data_group}/sd${seed}/data/ \
#         --hmmdefs 6state-pca20-gmm2 6state-pca20-gmm2-skip1 \
#         --results_csv ${results_csv} \
#         --num_its 500 --num_tri_its 100 \
#         --force_align --clear_hresults --prepare_data
# 
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/train/${data_group}/sd${seed}/data/ \
#         --hmmdefs 6state-pca20-gmm2 6state-pca20-gmm2-skip1 \
#         --results_csv ${results_csv} \
#         --num_its 500 --num_tri_its 100 \
#         --cross_word --clear_hresults --prepare_data
# 
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/train/${data_group}/sd${seed}/data/ \
#         --hmmdefs 6state-pca20-gmm2 6state-pca20-gmm2-skip1 \
#         --results_csv ${results_csv} \
#         --num_its 500 --num_tri_its 100 \
#         --full_cov --clear_hresults --prepare_data
#     
# done
# done
# done

