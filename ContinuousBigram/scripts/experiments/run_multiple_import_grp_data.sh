#!/bin/ksh

##### For trial 
base_dataset=supplemental_gen
typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)
typeset -a pt_grps=(grp1.6 grp2.6 grp3.6 grp4.6 grp5.6)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)

############################## IMPORT MULTIPLE ##############################

echo ""
echo "STARTING IMPORT"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for pt_grp in "${pt_grps[@]}"; do
for seed in "${seeds[@]}"; do
    # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
    python scripts/modify_data.py \
        --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_${dataset}_sd${seed}_${pt_grp}_rh.pkl.${data_split} \
        --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/grp/${pt_grp}/sd${seed}/data \
        --char_map_file /data/deep_learning/fingerspelling_torch/${base_dataset}_character_to_prediction_index.json \
        --method import &
    pid+=("$!")
done
done
done
done
wait "${pid[@]}"

