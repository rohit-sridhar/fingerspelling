#!/bin/ksh

##### This script needs to be modified. Check for what participant models we have.

## Bigger Experiment
# typeset -a train_ptgrps=(fpl111 fpl112 fpl311 fpl312 fpl511 fpl512) 
# typeset -a train_seeds=(1248 2248 3248 4248 5248)
# 
# typeset -a val_ptgrps=(fpl111 fpl112 fpl311 fpl312 fpl511 fpl512) 
# typeset -a val_seeds=(1248 2248 3248 4248 5248)
# 
# typeset -a thresholds=(1 2 4 6 8)
# typeset -a interpolations=(1 2)
# typeset -a hmmdefs=(6state-pca20 6state-pca20-gmm2)

## Pilot Experiment
typeset -a ptgrps=(fpl111 fpl311 fpl511) 
typeset -a seeds=(1248 2248)
typeset -a data_splits=(train val)

# typeset -a val_ptgrps=(fpl111 fpl311 fpl511) 
# typeset -a val_seeds=(1248 2248 3248 4248 5248)

typeset -a thresholds=(1 4 8)
typeset -a interpolations=(1)
typeset -a hmmdefs=(6state-pca20-gmm2 4state-pca20-gmm2 3state-pca20-gmm2)

############################## CROSS PT CROSS SD VALIDATION NO INTERPOLATION ##############################
for seed in "${seeds[@]}"; do
for hmmdef in "${hmmdefs[@]}"; do
for threshold in "${thresholds[@]}"; do
for grp in "${ptgrps[@]}"; do
for data_split in "${data_splits[@]}"; do
        python scripts/grid_search.py \
            --data_files ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/grp${grp}/sd${seed}/data/ \
            --label_files ./label/supplemental/dl_cmp/thr${threshold}/${data_split}/grp${grp}/sd${seed}/label/ \
            --test_model_path ./models/supplemental/dl_cmp/dim20/thr${threshold}/train/grp${grp}/sd${seed}/newMacros_neg10ip_${hmmdef}_20its_5tri-its_tc50 \
            --results_csv ./output/pilot_grp_results/results_grp${grp}_val.csv \
            --ip_values -300 -250 -200 -150 -100 -50 -10 0 10 50 100 200 300 \
            --test_model --prepare_data --clear_hresults
done
done
done
done
done

