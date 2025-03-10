#!/bin/ksh

## Bigger Experiment
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a ptgrps=(fpl111 fpl112 fpl113 fpl311 fpl312 fpl313 fpl511 fpl512 fpl513)
# typeset -a data_splits=(train val)
# typeset -a thresholds=(1 2 4 6 8)
# typeset -a interpolations=(1 2)

## Pilot Exp
typeset -a seeds=(1248 2248)
typeset -a ptgrps=(fpl111 fpl112 fpl311 fpl312 fpl511 fpl512) 
typeset -a data_splits=(train val)
typeset -a thresholds=(1 4 8)
typeset -a interpolations=(1)

output_dir="grp_results"

############################## TRAIN MULTIPLE NO INTERPOLATION ##############################
for seed in "${seeds[@]}"; do
    for threshold in "${thresholds[@]}"; do
        for grp in "${ptgrps[@]}"; do
            python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/grp${grp}/sd${seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/grp${grp}/sd${seed}/label/ --hmmdefs 6state-pca20 6state-pca20-gmm2 4state-pca20 4state-pca20-gmm2 3state-pca20 3state-pca20-gmm2 --results_csv ./output/$output_dir/results_grp${grp}_tuning.csv --prepare_data --clear_hresults
        done
    done
done

############################## TRAIN MULTIPLE WITH INTERPOLATION ##############################

for seed in "${seeds[@]}"; do
    for threshold in "${thresholds[@]}"; do
        for grp in "${ptgrps[@]}"; do
            for interpolation in "${interpolations[@]}"; do
                python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/train/interpall${interpolation}/grp${grp}/sd${seed}/data/ --label_files ./label/supplemental/dl_cmp/thr${threshold}/train/grp${grp}/sd${seed}/label/ --hmmdefs 6state-pca20 6state-pca20-gmm2 4state-pca20 4state-pca20-gmm2 3state-pca20 3state-pca20-gmm2 --results_csv ./output/$output_dir/results_grp${grp}_tuning.csv --prepare_data --clear_hresults
            done
        done
    done
done

