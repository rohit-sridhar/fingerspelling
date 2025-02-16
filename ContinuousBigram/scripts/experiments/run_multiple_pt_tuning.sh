#!/bin/ksh

typeset -a participants=("93" "227" "161" "254" "2")
typeset -a seeds=("1248" "2248" "3248" "4248" "5248" "6248" "7248" "8248" "9248" "10248")
typeset -a thresholds=(1 2 4 6 8)
typeset -a interpolations=(1 2)

############################## TRAIN MULTIPLE NO INTERPOLATION ##############################
for participant in "${participants[@]}"; do
    for seed in "${seeds[@]}"; do
        for threshold in "${thresholds[@]}"; do
            python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/pt${participant}/sd${seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/pt${participant}/sd${seed}/label/ --hmmdefs 6state-pca20 6state-pca20-gmm2 --results_csv ./output/pt_results/results_pt${participant}_tuning.csv --prepare_data --clear_hresults
        done
    done
done

############################## TRAIN MULTIPLE WITH INTERPOLATION ##############################

for participant in "${participants[@]}"; do
    for seed in "${seeds[@]}"; do
        for threshold in "${thresholds[@]}"; do
            for interpolation in "${interpolations[@]}"; do
                python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/interpall${interpolation}/pt${participant}/sd${seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/pt${participant}/sd${seed}/label/ --hmmdefs 6state-pca20 6state-pca20-gmm2 --results_csv ./output/pt_results/results_pt${participant}_tuning.csv --prepare_data --clear_hresults
            done
        done
    done
done

