#!/bin/ksh

##### NOTE This script needs the number of threads to be divisible by len(ptgrps)

##### For main run
typeset -a ptgrp0=(63a1 4c3d f418)
typeset -a ptgrp1=(1d72 3a6e 0ba8)
typeset -a ptgrp2=(a3e7 1bd5 fbb7)
typeset -a ptgrp3=(675f fa10 a3d4)
typeset -a ptgrp4=(f760 dbf9 13e3)
typeset -a ptgrp5=(0a77 fe96 b2d1)

typeset -a ptgrps=(0 1 2 3 4 5)
declare -A ptgrp_map

ptgrp_map[0]=${ptgrp0[@]}
ptgrp_map[1]=${ptgrp1[@]}
ptgrp_map[2]=${ptgrp2[@]}
ptgrp_map[3]=${ptgrp3[@]}
ptgrp_map[4]=${ptgrp4[@]}
ptgrp_map[5]=${ptgrp5[@]}

typeset -a seeds=(1248 2248)
typeset -a thresholds=(1 4)
typeset -a interpolations=(1)
typeset -a hmmdefs=(6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2)

dataset="supplemental_gen"
output_dir="results/pt_results/uid/${dataset}"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
echo "Current directory: `pwd`"

if [ ! -d "$root/${output_dir}" ]; then
    mkdir -p "$root/${output_dir}"
fi

ptgrp_idx=$(( SLURM_ARRAY_TASK_ID / ${#ptgrps[@]} ))

echo ""
echo "PT GRP IDX: ${ptgrp_idx}"
echo ""

############################## USER DEP VALIDATION NO INTERPOLATION ##############################
# for tr_participant in "${participants[$pt_idx]}"; do
# for seed in "${seeds[@]}"; do
# for threshold in "${thresholds[@]}"; do
# for hmmdef in "${hmmdefs[@]}"; do
#     echo python scripts/grid_search.py \
#         --data_files ./data/${dataset}/dim20/thr${threshold}/val/pt${participant}/sd${val_seed}/data/ \
#         --test_model_path ./models/${dataset}/dim20/thr${threshold}/train/pt${participant}/sd${seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_val.csv \
#         --ip_values -150 -10 0 10 150 \
#         --test_model --prepare_data --clear_hresults
# done
# done
# done
# done
# 
# ############################## USER DEP VALIDATION WITH INTERPOLATION ##############################
# for tr_participant in "${participants[$pt_idx]}"; do
# for seed in "${seeds[@]}"; do
# for threshold in "${thresholds[@]}"; do
# for interpolation in "${interpolations[@]}"; do
# for hmmdef in "${hmmdefs[@]}"; do
#     echo python scripts/grid_search.py \
#         --data_files ./data/${dataset}/dim20/thr${threshold}/val/interpall${interpolation}/pt${participant}/sd${val_seed}/data/ \
#         --test_model_path ./models/${dataset}/dim20/thr${threshold}/train/interpall${interpolation}/pt${participant}/sd${seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 \
#         --results_csv ${output_dir}/results_pt${participant}_sd${seed}_val.csv \
#         --ip_values -150 -10 0 10 150 \
#         --test_model --prepare_data --clear_hresults
# done
# done
# done
# done
# done

