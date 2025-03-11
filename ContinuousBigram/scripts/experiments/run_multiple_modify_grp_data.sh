#!/bin/ksh

## Bigger Experiment
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a ptgrps=(fpl111 fpl112 fpl113 fpl311 fpl312 fpl313 fpl511 fpl512 fpl513)
# typeset -a data_splits=(train val)

## Pilot Exp
typeset -a seeds=(1248 2248)
typeset -a ptgrps=(fpl111 fpl112 fpl311 fpl312 fpl511 fpl512) 
typeset -a data_splits=(train val)

############################## IMPORT MULTIPLE ##############################

echo ""
echo "STARTING IMPORT"
echo ""

# data_thr0_supplemental_sd5248_grpfpl112_right.pkl.train

for data_split in ${data_splits[@]}; do
for grp in "${ptgrps[@]}"; do
for seed in "${seeds[@]}"; do
    python scripts/modify_data.py \
        --data_loc /data/deep_learning/fingerspelling_torch/data/data_thr0_supplemental_sd${seed}_grp${grp}_right.pkl.${data_split} \
        --new_data_loc ./data/supplemental/dl_cmp/dim20/thr0/${data_split}/grp${grp}/sd${seed}/data \
        --new_label_loc ./label/supplemental/dl_cmp/thr0/${data_split}/grp${grp}/sd${seed}/label/ \
        --method import
done
done
done


############################## THRESHOLD MULTIPLE (TRAIN) ##############################
## Bigger Experiments
# typeset -a thresholds=(1 2 4 6 8)

## Pilot Experiment
typeset -a thresholds=(1 4 8)

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

for data_split in ${data_splits[@]}; do
for grp in "${ptgrps[@]}"; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/supplemental/dl_cmp/dim20/thr0/${data_split}/grp${grp}/sd${seed}/data \
        --label_loc ./label/supplemental/dl_cmp/thr0/${data_split}/grp${grp}/sd${seed}/label \
        --new_data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/grp${grp}/sd${seed}/data \
        --new_label_loc ./label/supplemental/dl_cmp/thr${threshold}/${data_split}/grp${grp}/sd${seed}/label \
        --method fpl_threshold \
        --fpl_threshold ${threshold}
done
done
done
done

# ############################## INTERPOLATE MULTIPLE (TRAIN) ##############################
## Bigger Experiment
# typeset -a interpolations=(1 2)

## Pilot Experiment
typeset -a interpolations=(1)

echo ""
echo "STARTING INTERPOLATION"
echo ""

for data_split in ${data_splits[@]}; do
for grp in "${ptgrps[@]}"; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/grp${grp}/sd${seed}/data \
        --label_loc ./label/supplemental/dl_cmp/thr${threshold}/${data_split}/grp${grp}/sd${seed}/label \
        --new_data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/interpall${interpolation}/grp${grp}/sd${seed}/data \
        --method interpolation \
        --num_interpolations ${interpolation} \
        --interp_all
done
done
done
done
done

