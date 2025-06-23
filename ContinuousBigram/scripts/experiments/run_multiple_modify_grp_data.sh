#!/bin/bash

base_dataset=supplemental_gen

##### For pilot 
typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)
typeset -a pt_grps=(grp1.6 grp2.6 grp3.6 grp4.6 grp5.6)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)
typeset -a thresholds=(1 4)
typeset -a interpolations=(1)

##### For debug 
# typeset -a all_participants=(03ad)
# typeset -a seeds=(1248 2248)
# typeset -a data_splits=(train val)
# typeset -a thresholds=(1 4) 
# typeset -a interpolations=(1)

############################## THRESHOLD MULTIPLE ##############################

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for pt_grp in "${pt_grps[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/${dataset}/dim20/thr0/${data_split}/grp/${pt_grp}/sd${seed}/data \
        --new_data_loc ./data/${dataset}/dim20/thr${threshold}/${data_split}/grp/${pt_grp}/sd${seed}/data \
        --method fpl_threshold \
        --fpl_threshold ${threshold} &
    pid+=("$!")
done
done
done
done
done
wait "${pid[@]}"

############################## INTERPOLATE MULTIPLE ##############################

echo ""
echo "STARTING INTERPOLATION"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
for pt_grp in "${pt_grps[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/${dataset}/dim20/thr${threshold}/${data_split}/grp/${pt_grp}/sd${seed}/data \
        --new_data_loc ./data/${dataset}/dim20/thr${threshold}/${data_split}/interpall${interpolation}/grp/${pt_grp}/sd${seed}/data \
        --method interpolation \
        --num_interpolations ${interpolation} \
        --interp_all &
    pid+=("$!")
done
done
done
done
done
done
wait "${pid[@]}"

