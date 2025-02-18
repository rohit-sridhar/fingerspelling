#!/bin/ksh

typeset -a train_participants=("93" "227" "161" "254" "2")
typeset -a train_seeds=("1248" "2248" "3248" "4248" "5248" "6248" "7248" "8248" "9248" "10248")

typeset -a val_participants=("93" "227" "161" "254" "2")
typeset -a val_seeds=("1248" "2248" "3248" "4248" "5248" "6248" "7248" "8248" "9248" "10248")

typeset -a thresholds=(1 2 4 6 8)
typeset -a interpolations=(1 2)
typeset -a hmmdefs=("6state-pca20" "6state-pca20-gmm2")

############################## CROSS PT CROSS SD VALIDATION NO INTERPOLATION ##############################
for train_participant in "${train_participants[@]}"; do
for val_participant in "${val_participants[@]}"; do
    for train_seed in "${train_seeds[@]}"; do
    for val_seed in "${val_seeds[@]}"; do
        for threshold in "${thresholds[@]}"; do
        for hmmdef in "${hmmdefs[@]}"; do
            python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/val/pt${val_participant}/sd${val_seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/val/pt${val_participant}/sd${val_seed}/label/ --test_model_path ./models/supplemental/dl_cmp/dim20/thr${threshold}/train/pt${train_participant}/sd${train_seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 --results_csv ./output/top_5_pt_results/results_pt${train_participant}_pt${val_participant}_val.csv --ip_values -300 -250 -200 -150 -100 -50 -10 0 10 50 100 200 300 --test_model --prepare_data --clear_hresults
        done
        done
    done
    done
done
done

############################## CROSS PT CROSS SD VALIDATION WITH INTERPOLATION ##############################
for train_participant in "${train_participants[@]}"; do
for test_participant in "${test_participants[@]}"; do
    for train_seed in "${train_seeds[@]}"; do
    for test_seed in "${test_seeds[@]}"; do
        for threshold in "${thresholds[@]}"; do
        for interpolation in "${interpolations[@]}"; do
        for hmmdef in "${hmmdefs[@]}"; do
            python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/val/interpall${interpolation}/pt${val_participant}/sd${val_seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/val/pt${val_participant}/sd${val_seed}/label/ --test_model_path ./models/supplemental/dl_cmp/dim20/thr${threshold}/train/interpall${interpolation}/pt${train_participant}/sd${train_seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 --results_csv ./output/top_5_pt_results/results_pt${train_participant}_pt${val_participant}_val.csv --ip_values -300 -250 -200 -150 -100 -50 -10 0 10 50 100 200 300 --test_model --prepare_data --clear_hresults
        done
        done
        done
    done
    done
done
done

