#!/bin/bash

base_dataset=supplemental_gen
output_dir="pt_results/tot/${dataset}"

# Assumes we're in ContinuousBigram dir
if [ ! -d "results/${output_dir}" ]; then
    mkdir -p "results/${output_dir}"
fi

##### For supplemental gen participants
typeset -a datasets=(${base_dataset}_drop-na ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na ${base_dataset}_na-thr0.3_drop-na_lininterp1 ${base_dataset}_na-thr0.5_drop-na ${base_dataset}_na-thr0.5_drop-na_lininterp1)
typeset -a all_participants=(f418 63a1 a362 2f35 d05c 8e3b 494d d69c c82a e3c0 0ba8 9d2b c0df ed8e f066 cf84 9b23 1f91 e0f7 2ff7 675f 0bea b718 4f1e fa10 13e3 812c 1bd5 917d 99cb ab12 fede a3e7 03ad a021 19d3 1f86 6b92 7f32 39e5 a6ed d3ab 6f68 a95b 4ddc dbf9 51f5 f9ea bd21 163a 39a6 fe96 3f8b 4c3d b2d1 5d33 d478 fbb7 5b63 9ed9 1d72 f760 3a6e 3d12 0a77 9ff4 80fe a442 e4fa 711d a3d4 8c4d)
typeset -a seeds=(1248)
typeset -a thresholds=(0)

############################## TRAIN MULTIPLE NO INTERPOLATION ##############################
for dataset in ${datasets[@]}; do
for threshold in ${thresholds[@]}; do
for seed in ${seeds[@]}; do
for participant in ${all_participants[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/pt/${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 5state-pca20-gmm2 4state-pca20-gmm2 \
        --results_csv ./results/$output_dir/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done

