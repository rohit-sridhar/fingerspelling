#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@
set_slurm_subsets_if_exists datasets participants

############################## SET OUTPUT DIR ##############################
subdirs=pt_results/tot
if [[ -n "${bootstrap}" ]]; then
    subdirs=${subdirs}_bts
fi

# --hmmdefs 3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1 \
#hmmdefs=(3state-pca2-gmm1-skip1 4state-pca2-gmm1-skip1 5state-pca2-gmm1-skip1)
hmmdefs=(3state-pca2-gmm1)
############################## TRAIN MULTIPLE (FGR) ##############################
# Default
for fgr in ${fingers[@]}; do
for dataset in ${datasets[@]}; do
    set_output_dir ${subdirs}
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/fgr-${fgr}/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --hmmdefs ${hmmdefs[@]} \
        --prepare_data --clear_hresults \
        ${bootstrap} ${debug} ${warning}
done
done
done
done
done

# Force align
for fgr in ${fingers[@]}; do
for dataset in ${datasets[@]}; do
    set_output_dir ${subdirs}
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/fgr-${fgr}/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --hmmdefs ${hmmdefs[@]} \
        --prepare_data --clear_hresults --force_align \
        ${debug} ${warning}
done
done
done
done
done

# Cross word
for fgr in ${fingers[@]}; do
for dataset in ${datasets[@]}; do
    set_output_dir ${subdirs}
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/fgr-${fgr}/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --hmmdefs ${hmmdefs[@]} \
        --prepare_data --clear_hresults --cross_word \
        ${bootstrap} ${debug} ${warning}
done
done
done
done
done

# Full cov
for fgr in ${fingers[@]}; do
for dataset in ${datasets[@]}; do
    set_output_dir ${subdirs}
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${participants[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/fgr-${fgr}/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
        --hmmdefs ${hmmdefs[@]} \
        --prepare_data --clear_hresults --full_cov \
        ${debug} ${warning}
done
done
done
done
done

# hmmdefs=(3state-pca10-gmm2-skip1 4state-pca10-gmm2-skip1 5state-pca10-gmm2-skip1)
# ############################## TRAIN MULTIPLE (DIM10) ##############################
# # Default
# for dataset in ${datasets[@]}; do
#     set_output_dir ${subdirs}
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --hmmdefs ${hmmdefs[@]} \
#         --prepare_data --clear_hresults ${bootstrap} ${debug} ${warning}
# done
# done
# done
# done
# 
# # Force align
# for dataset in ${datasets[@]}; do
#     set_output_dir ${subdirs}
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --hmmdefs ${hmmdefs[@]} \
#         --prepare_data --clear_hresults --force_align ${debug} ${warning}
# done
# done
# done
# done
# 
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
#         --prepare_data --clear_hresults --cross_word ${bootstrap} ${debug} ${warning}
# done
# done
# done
# done
# 
# # Full cov
# for dataset in ${datasets[@]}; do
#     set_output_dir ${subdirs}
# for threshold in ${thresholds[@]}; do
# for seed in ${seeds[@]}; do
# for participant in ${participants[@]}; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_tuning.csv \
#         --hmmdefs ${hmmdefs[@]} \
#         --prepare_data --clear_hresults --full_cov ${debug} ${warning}
# done
# done
# done
# done
# 
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

