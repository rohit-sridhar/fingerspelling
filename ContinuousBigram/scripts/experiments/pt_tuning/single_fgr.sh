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
hmmdefs=(3state-dim2 4state-dim2 5state-dim2)
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

if [[ -z "${bootstrap}" ]]; then
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
fi

