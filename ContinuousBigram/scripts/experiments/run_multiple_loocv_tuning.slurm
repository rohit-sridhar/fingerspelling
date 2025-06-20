#!/bin/bash

##### For all participants
# typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)
# typeset -a seeds=(1248 2248 3248 4248 5248 6248 7248 8248 9248 10248)
# typeset -a thresholds=(1 2 4 6 8)
# typeset -a interpolations=(1 2)

##### For supplemental gen participants
# typeset -a all_participants=(f418 63a1 a362 2f35 d05c 8e3b 494d d69c c82a e3c0 0ba8 9d2b c0df ed8e f066 cf84 9b23 1f91 e0f7 2ff7 675f 0bea b718 4f1e fa10 13e3 812c 1bd5 917d 99cb ab12 fede a3e7 03ad a021 19d3 1f86 6b92 7f32 39e5 a6ed d3ab 6f68 a95b 4ddc dbf9 51f5 f9ea bd21 163a 39a6 fe96 3f8b 4c3d b2d1 5d33 d478 fbb7 5b63 9ed9 1d72 f760 3a6e 3d12 0a77 9ff4 80fe a442 e4fa 711d a3d4 8c4d)
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a thresholds=(1 4)
# typeset -a interpolations=(1)

base_dataset=supplemental_gen
output_dir="loocv_results/tot/${base_dataset}/its_tuning"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
echo "Current directory: `pwd`"

if [ ! -d "$root/results/${output_dir}" ]; then
    mkdir -p "$root/results/${output_dir}"
fi

ds_idx=$(( SLURM_ARRAY_TASK_ID / 20 ))
pt_idx=$(( (SLURM_ARRAY_TASK_ID % 20) / 4 ))
its_idx=$(( (SLURM_ARRAY_TASK_ID % 20) % 4 ))

##### For num its/num tri its tuning
# typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)
typeset -a datasets=(${base_dataset}_na-thr0.3 ${base_dataset}_na-thr0.3_drop-na)
typeset -a all_participants=(ab12 3d12 f066 d3ab 1f86)
typeset -a num_its_arr=(100 500 1000 3000)
typeset -a num_tri_its_arr=(100 500 1000 3000)
typeset -a seeds=(1248)
typeset -a thresholds=(1)
typeset -a interpolations=(1)

##### For debug
# typeset -a all_participants=(03ad)
# typeset -a seeds=(1248 2248)
# typeset -a thresholds=(1 4)
# typeset -a interpolations=(1) 

echo ""
echo "DS IDX: ${ds_idx}"
echo "PT IDX: ${pt_idx}"
echo "ITS IDX: ${its_idx}"
echo "NCORES: `nproc --all`"
echo ""

############################## TRAIN MULTIPLE NO INTERPOLATION NUM_ITS ITER ##############################
for dataset in ${datasets[$ds_idx]}; do
for participant in ${all_participants[$pt_idx]}; do
for num_its in ${num_its_arr[$its_idx]}; do
for seed in ${seeds[@]}; do
for threshold in ${thresholds[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/loocv/${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 \
        --num_its ${num_its} --num_tri_its 3000 \
        --results_csv ./results/$output_dir/results_loocv-${dataset}_${participant}_num-its${num_its}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done
done

############################## TRAIN MULTIPLE NO INTERPOLATION NUM_TRI_ITS ITER ##############################
for dataset in ${datasets[$ds_idx]}; do
for participant in ${all_participants[$pt_idx]}; do
for num_tri_its in ${num_tri_its_arr[$its_idx]}; do
for seed in ${seeds[@]}; do
for threshold in ${thresholds[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/loocv/${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 \
        --num_its 3000 --num_tri_its ${num_tri_its} \
        --results_csv ./results/$output_dir/results_loocv-${dataset}_${participant}_num-tri-its${num_tri_its}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done
done

############################## TRAIN MULTIPLE WITH INTERPOLATION ##############################
for dataset in ${datasets[$ds_idx]}; do
for participant in ${all_participants[$pt_idx]}; do
for seed in ${seeds[@]}; do
for threshold in ${thresholds[@]}; do
for interpolation in ${interpolations[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/interpall${interpolation}/loocv/${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 \
        --results_csv ./results/$output_dir/results_loocv-${dataset}_${participant}_interpall1_fixed_tuning.csv \
        --num_its 3000 --num_tri_its 3000 \
        --prepare_data --clear_hresults
done
done
done
done
done

