#!/bin/ksh

##### This script needs to be modified. Check for what participant models we have.

# typeset -a participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a val_seeds=(1248 2248 3248 4248 5248)

##### For debug
typeset -a participants=(03ad)
typeset -a seeds=(1248 2248)
typeset -a val_seeds=(1248 2248)
typeset -a thresholds=(1 4)
typeset -a interpolations=(1)
typeset -a hmmdefs=(6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2)

dataset="supplemental_gen"
output_dir="results/pt_results/val/${dataset}"

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
echo "Current directory: `pwd`"

if [ ! -d "$root/${output_dir}" ]; then
    mkdir -p "$root/${output_dir}"
fi

############################## USER DEP VALIDATION NO INTERPOLATION ##############################
for participant in "${participants[@]}"; do
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
for participant in "${participants[@]}"; do
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

