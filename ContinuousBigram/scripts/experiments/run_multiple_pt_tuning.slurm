#!/bin/ksh

##### For all participants
# typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)
# typeset -a seeds=(1248 2248 3248 4248 5248 6248 7248 8248 9248 10248)

# typeset -a thresholds=(1 2 4 6 8)

##### For participants (top 15)
# typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195)
##### For participants (second 15)
# typeset -a all_participants=(136 241 109 53 216 89 239 22 111 0 95 38 157 196 15)
##### For participants (third 15)
# typeset -a all_participants=(251 253 219 47 73 121 246 166 141 54 223 213 20 99 40)
##### For participants (fourth 15)
# typeset -a all_participants=(122 27 245 240 221 33 155 128 250 158 117 6 148 135 143)

##### For all supplemental gen participants
# typeset -a all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
# 
typeset -a seeds=(1248 2248 3248 4248 5248)
typeset -a thresholds=(1 4 8)
typeset -a interpolations=(1 2)

##### For debug
typeset -a all_participants=(03ad)
# typeset -a seeds=(1248)
# typeset -a thresholds=(1 4)
# typeset -a interpolations=(1)

dataset="supplemental_gen"
output_dir="pt_results/tot/${dataset}"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
echo "Current directory: `pwd`"

if [ ! -d "$root/results/${output_dir}" ]; then
    mkdir -p "$root/results/${output_dir}"
fi

sd_idx=$(( SLURM_ARRAY_TASK_ID ))
# pt_idx=$(( SLURM_ARRAY_TASK_ID ))
# pt_idx=$((SLURM_ARRAY_TASK_ID / ${#seeds[@]}))
# sd_idx=$((SLURM_ARRAY_TASK_ID % ${#seeds[@]}))

echo ""
echo "SD IDX: ${sd_idx}"
echo ""

# --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2 \
############################## TRAIN MULTIPLE NO INTERPOLATION ##############################
for seed in "${seeds[$sd_idx]}"; do
for threshold in "${thresholds[@]}"; do
for participant in "${all_participants[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/pt${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2 \
        --results_csv ./results/$output_dir/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done

############################## TRAIN MULTIPLE WITH INTERPOLATION ##############################
for seed in "${seeds[$sd_idx]}"; do
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
for participant in ${all_participants[@]}; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/train/interpall${interpolation}/pt${participant}/sd${seed}/data/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2 \
        --results_csv ./results/$output_dir/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done

