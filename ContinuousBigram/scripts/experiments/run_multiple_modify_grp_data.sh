#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh

if [[ $1 != "supplemental_gen" && $1 != "main_train" ]]; then
    echo "you can only pass supplemental_gen or main_train as the first arg for now. tbd add more datasets"
    exit 1
fi

##### For pilot 
base_dataset=$1
typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0 ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na_lininterp1)
typeset -a pt_grps=(grp.rnd*.2 grp.rnd*.3 grp.rnd*.6 grp.rnd*.12)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)
typeset -a thresholds=(1)

############################## THRESHOLD MULTIPLE ##############################

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for seed in ${seeds[@]}; do
for data_split in ${data_splits[@]}; do
for pt_grp in ${pt_grps[@]}; do
for threshold in ${thresholds[@]}; do
    typeset -a data_files=(./data/${dataset}/dim20/thr0/${data_split}/grp/${pt_grp}/sd${seed}/data/)
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
wait "${pid[@]}"

