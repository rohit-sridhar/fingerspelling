#!/bin/ksh

##### For main run
typeset -a participants=()
typeset -a seeds=(1248 2248)
typeset -a val_seeds=(1248 2248)
typeset -a thresholds=(1 4)
typeset -a interpolations=(1)
typeset -a hmmdefs=(6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2)

##### For debug
# typeset -a participants=(03ad)
# typeset -a seeds=(1248 2248)
# typeset -a val_seeds=(1248 2248)
# typeset -a thresholds=(1 4 8)
# typeset -a interpolations=(1)
# typeset -a hmmdefs=(6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2)

dataset="supplemental_gen"
output_dir="results/pt_results/uid/${dataset}"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
echo "Current directory: `pwd`"

if [ ! -d "$root/${output_dir}" ]; then
    mkdir -p "$root/${output_dir}"
fi

pt_idx=$(( SLURM_ARRAY_TASK_ID ))
sd_idx=$(( SLURM_ARRAY_TASK_ID ))

echo ""
echo "PT IDX: ${pt_idx}"
echo ""

############################## USER DEP VALIDATION NO INTERPOLATION ##############################
for participant in "${participants[$pt_idx]}"; do
for seed in "${seeds[@]}"; do
for val_seed in "${val_seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for hmmdef in "${hmmdefs[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/val/pt${participant}/sd${val_seed}/data/ \
        --test_model_path ./models/${dataset}/dim20/thr${threshold}/train/pt${participant}/sd${seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_val.csv \
        --ip_values -300 -150 -10 0 10 150 300 \
        --test_model --prepare_data --clear_hresults
done
done
done
done
done

############################## USER DEP VALIDATION WITH INTERPOLATION ##############################
for participant in "${participants[$pt_idx]}"; do
for seed in "${seeds[@]}"; do
for val_seed in "${val_seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
for hmmdef in "${hmmdefs[@]}"; do
    python scripts/grid_search.py \
        --data_files ./data/${dataset}/dim20/thr${threshold}/val/interpall${interpolation}/pt${participant}/sd${val_seed}/data/ \
        --test_model_path ./models/${dataset}/dim20/thr${threshold}/train/interpall${interpolation}/pt${participant}/sd${seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 \
        --results_csv ${output_dir}/results_pt${participant}_sd${seed}_val.csv \
        --ip_values -300 -150 -10 0 10 150 300 \
        --test_model --prepare_data --clear_hresults
done
done
done
done
done
done

