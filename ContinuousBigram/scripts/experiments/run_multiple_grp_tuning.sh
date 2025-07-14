#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh

if [[ $1 != "supplemental_gen" && $1 != "main_train" ]]; then
    echo "you can only pass supplemental_gen or main_train as the first arg for now. tbd add more datasets"
    exit 1
fi

##### For Grp Rnd
base_dataset=$1
typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0 ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na_lininterp1)
typeset -a pt_grps=(grp.rnd*.2 grp.rnd*.3 grp.rnd*.6 grp.rnd*.12)
typeset -a seeds=(1248)
typeset -a thresholds=(0 1)

############################## TRAIN MULTIPLE GRP RND ##############################

output_dir="grp_rnd_results/tot/${base_dataset}"

# Assumes we're in ContinuousBigram dir
if [ ! -d "results/${output_dir}" ]; then
    mkdir -p "results/${output_dir}"
fi

for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for pt_grp in "${pt_grps[@]}"; do
    typeset -a data_files=(./data/${dataset}/dim20/thr${threshold}/train/grp/${pt_grp}/sd${seed}/data/)
    data_files_shuffled=( $(shuf -e "${data_files[@]}" --random-source=<(get_seeded_random 68)) )
    echo "${data_files_shuffled[@]}"

    if [ "${pt_grp}" == "grp.rnd*.2" ]; then
        for data_file in ${data_files_shuffled[@]:0:3}; do
            python scripts/grid_search.py \
                --data_files ${data_file}  \
                --hmmdefs 4state-pca20-gmm2 4state-pca20-gmm2-skip 6state-pca20-gmm2 6state-pca20-gmm2-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    elif [ "${pt_grp}" == "grp.rnd*.3" ]; then
        for data_file in ${data_files_shuffled[@]:0:3}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm3 4state-pca20-gmm3-skip 6state-pca20-gmm3 6state-pca20-gmm3-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    else
        for data_file in ${data_files_shuffled[@]:0:3}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm4 4state-pca20-gmm4-skip 6state-pca20-gmm4 6state-pca20-gmm4-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    fi
done
done
done
done

############################## TRAIN MULTIPLE PILOT GRP ##############################
# for dataset in ${datasets[@]}; do
# for seed in "${seeds[@]}"; do
# for threshold in "${thresholds[@]}"; do
# # pid=()
# for pt_grp in "${pt_grps[@]}"; do
#     python scripts/grid_search.py \
#         --data_files ./data/${dataset}/dim20/thr${threshold}/train/grp/${pt_grp}/sd${seed}/data/ \
#         --hmmdefs 3state-pca20-gmm4 3state-pca20-gmm4-skip 4state-pca20-gmm4 4state-pca20-gmm4-skip \
#         --num_its 500 --num_tri_its 500 \
#         --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp}.csv \
#         --clear_hresults --prepare_data
# #     pid+=("$!")
# done
# # wait "${pid[@]}"
# done
# done
# done

