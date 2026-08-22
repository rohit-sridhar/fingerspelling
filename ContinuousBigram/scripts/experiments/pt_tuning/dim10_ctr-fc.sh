#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../../.."

. ${SCRIPT_DIR}/../utils.sh
set_vars $@
set_slurm_subsets_if_exists datasets participants

############################## SET OUTPUT DIR ##############################
subdirs=pt_results/tot
if [[ -n "${bootstrap}" ]]; then
    subdirs=${subdirs}_bts
fi

num_its=(50)
num_final_its=(30)
num_tri_its=(5)
hmmdefs=(3state-dim10 4state-dim10 5state-dim10 6state-dim10 7state-dim20 8state-dim10)
seeds=(1248)
############################## TRAIN MULTIPLE (DIM10) ##############################
# Default
for dataset in ${datasets[@]}; do
    set_output_dir ${subdirs}
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --hmmdefs ${hmmdefs[@]} --num_its ${num_its[@]} --num_final_its ${num_final_its[@]} \
        --num_tri_its ${num_tri_its[@]} --prepare_data --clear_hresults \
        ${bootstrap} ${debug} ${warning}
done
done
done
done

# # Cross word
# for dataset in ${datasets[@]}; do
#     set_output_dir ${subdirs}
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --hmmdefs ${hmmdefs[@]} \
#         --prepare_data --clear_hresults --cross_word \
#         ${bootstrap} ${debug} ${warning}
# done
# done
# done
# done
# 
# if [[ -z "${bootstrap}" ]]; then
#     # Force align
#     for dataset in ${datasets[@]}; do
#         set_output_dir ${subdirs}
#     for threshold in ${thresholds[@]}; do
#     for seed in ${seeds[@]}; do
#     for participant in ${participants[@]}; do
#         ${ROOT}/scripts/grid_search.py \
#             --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#             --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#             --hmmdefs ${hmmdefs[@]} \
#             --prepare_data --clear_hresults --force_align \
#             ${debug} ${warning}
#     done
#     done
#     done
#     done
#     
#     # Full cov
#     for dataset in ${datasets[@]}; do
#         set_output_dir ${subdirs}
#     for threshold in ${thresholds[@]}; do
#     for seed in ${seeds[@]}; do
#     for participant in ${participants[@]}; do
#         ${ROOT}/scripts/grid_search.py \
#             --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#             --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#             --hmmdefs ${hmmdefs[@]} \
#             --prepare_data --clear_hresults --full_cov \
#             ${debug} ${warning}
#     done
#     done
#     done
#     done
# fi

