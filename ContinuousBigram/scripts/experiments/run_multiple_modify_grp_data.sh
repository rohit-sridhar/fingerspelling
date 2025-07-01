#!/bin/bash

base_dataset=supplemental_gen

##### For pilot 
typeset -a datasets=(${base_dataset}_na-thr0.5)
typeset -a pt_grps=(grp.rnd*.2 grp.rnd*.3 grp.rnd*.6 grp.rnd*.12)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)
typeset -a thresholds=(1)
typeset -a interpolations=(0 1)

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
for seed in ${seeds[@]}; do
for interpolation in ${interpolations[@]}; do
for threshold in ${thresholds[@]}; do
for pt_grp in ${pt_grps[@]}; do
    typeset -a data_files=(./data/${dataset}_lininterp${interpolation}/dim20/thr0/${data_split}/grp/${pt_grp}/sd${seed}/data/)
    for data_file in ${data_files[@]}; do
        new_data_file=${data_file/\/thr0\//\/thr${threshold}\/}
        python scripts/modify_data.py \
            --data_loc ${data_file} \
            --new_data_loc ${new_data_file} \
            --method fpl_threshold \
            --fpl_threshold ${threshold} &
            pid+=("$!")
    done
done
done
done
done
done
done
wait "${pid[@]}"

############################## INTERPOLATE MULTIPLE ##############################
##### Interpolation section has been removed since it has been worked into the deep learning repo

