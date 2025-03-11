#!/bin/ksh

##### For all participants
# typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)

# typeset -a seeds=(1248 2248 3248 4248 5248 6248 7248 8248 9248 10248)
# typeset -a data_splits=(train val)

# typeset -a thresholds=(1 2 4 6 8)

##### For pilot participants (top 15)
typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195)

typeset -a seeds=(1248 2248 3248 4248 5248)
typeset -a data_splits=(train val)

typeset -a thresholds=(1 4 8)
typeset -a interpolations=(1 2)

output_dir="pt_top_15_results"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root

# pt_idx=$(( SLURM_ARRAY_TASK_ID ))
pt_idx=$((SLURM_ARRAY_TASK_ID / ${#seeds[@]}))
sd_idx=$((SLURM_ARRAY_TASK_ID % ${#seeds[@]}))

echo ""
echo "PT IDX: ${pt_idx}"
echo "SD IDX: ${sd_idx}"
echo ""

############################## TRAIN MULTIPLE NO INTERPOLATION ##############################

for participant in "${all_participants[$pt_idx]}"; do
for seed in "${seeds[$sd_idx]}"; do
for threshold in "${thresholds[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/pt${participant}/sd${seed}/data/ \
        --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/pt${participant}/sd${seed}/label/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2 3state-pca20 \
        --results_csv ./results/$output_dir/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done

############################## TRAIN MULTIPLE WITH INTERPOLATION ##############################

for participant in ${all_participants[$pt_idx]}; do
for seed in "${seeds[$sd_idx]}"; do
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/interpall${interpolation}/pt${participant}/sd${seed}/data/ \
        --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/pt${participant}/sd${seed}/label/ \
        --hmmdefs 6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2 3state-pca20 \
        --results_csv ./results/$output_dir/results_pt${participant}_sd${seed}_tuning.csv \
        --prepare_data --clear_hresults
done
done
done
done

