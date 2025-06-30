#!/bin/bash

base_dataset=supplemental_gen
output_dir="grp_rnd_results/tot/${base_dataset}"

##### For pilot
# typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)
# typeset -a datasets=(${base_dataset}_na-thr0.3)
# typeset -a pt_grps=(grp1.6 grp2.6 grp3.6 grp4.6 grp5.6)
# typeset -a seeds=(1248)
# typeset -a thresholds=(0 1)
# typeset -a interpolations=(1)

##### For Grp Rnd
typeset -a datasets=(${base_dataset}_na-thr0.5)
typeset -a pt_grps=(grp.rnd*.2 grp.rnd*.3 grp.rnd*.6 grp.rnd*.12)
typeset -a seeds=(1248)
typeset -a thresholds=(0)
# typeset -a interpolations=(1)

# Assumes we're in ContinuousBigram dir
if [ ! -d "results/${output_dir}" ]; then
    mkdir -p "results/${output_dir}"
fi

############################## TRAIN MULTIPLE NO INTERPOLATION (300 300 its) GRP RND ##############################
for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
# pid=()
for pt_grp in "${pt_grps[@]}"; do
    typeset -a data_files=(./data/${dataset}/dim20/thr${threshold}/train/grp/${pt_grp}/sd${seed}/data/)
    if [ "${pt_grp}" == "grp.rnd*.2" ]; then
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file}  \
                --hmmdefs 4state-pca20-gmm2 4state-pca20-gmm2-skip 6state-pca20-gmm2 6state-pca20-gmm2-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    elif [ "${pt_grp}" == "grp.rnd*.3" ]; then
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm3 4state-pca20-gmm3-skip 6state-pca20-gmm3 6state-pca20-gmm3-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    else
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm4 4state-pca20-gmm4-skip 6state-pca20-gmm4 6state-pca20-gmm4-skip \
                --num_its 300 --num_tri_its 300 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    fi
#     pid+=("$!")
done
# wait "${pid[@]}"
done
done
done

############################## TRAIN MULTIPLE NO INTERPOLATION (500 500 its) GRP RND ##############################
for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
# pid=()
for pt_grp in "${pt_grps[@]}"; do
    typeset -a data_files=(./data/${dataset}/dim20/thr${threshold}/train/grp/${pt_grp}/sd${seed}/data/)
    if [ "${pt_grp}" == "grp.rnd*.2" ]; then
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file}  \
                --hmmdefs 4state-pca20-gmm2 4state-pca20-gmm2-skip 6state-pca20-gmm2 6state-pca20-gmm2-skip \
                --num_its 500 --num_tri_its 500 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    elif [ "${pt_grp}" == "grp.rnd*.3" ]; then
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm3 4state-pca20-gmm3-skip 6state-pca20-gmm3 6state-pca20-gmm3-skip \
                --num_its 500 --num_tri_its 500 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    else
        for data_file in ${data_files[@]}; do
            python scripts/grid_search.py \
                --data_files ${data_file} \
                --hmmdefs 4state-pca20-gmm4 4state-pca20-gmm4-skip 6state-pca20-gmm4 6state-pca20-gmm4-skip \
                --num_its 500 --num_tri_its 500 \
                --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp/\*/}.csv \
                --clear_hresults --prepare_data
        done
    fi
#     pid+=("$!")
done
# wait "${pid[@]}"
done
done
done

############################## TRAIN MULTIPLE NO INTERPOLATION (500 500 its) PILOT GRP ##############################
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

############################## TRAIN MULTIPLE WITH INTERPOLATION PILOT GRP ##############################
# for dataset in ${datasets[@]}; do
# for seed in "${seeds[@]}"; do
# for threshold in "${thresholds[@]}"; do
# for interpolation in "${interpolations[@]}"; do
# # pid=()
# for pt_grp in "${pt_grps[@]}"; do
#     python scripts/grid_search.py \
#         --data_files ./data/${dataset}/dim20/thr${threshold}/train/interpall${interpolation}/grp/${pt_grp}/sd${seed}/data/ \
#         --hmmdefs 6state-pca20-gmm2-skip 3state-pca20-gmm2 \
#         --results_csv ./results/${output_dir}/results_${dataset}_${pt_grp}_higher_num_its_tuning.csv \
#         --num_its 200 --num_tri_its 200 \
#         --prepare_data --clear_hresults
# #     pid+=("$!")
# done
# # wait "${pid[@]}"
# done
# done
# done
# done

