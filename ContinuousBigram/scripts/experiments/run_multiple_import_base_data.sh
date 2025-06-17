#!/bin/ksh

base_dataset=supplemental_gen
data_split=all

typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)

############################## IMPORT MULTIPLE (FILL NA) ##############################

echo ""
echo "STARTING IMPORT"
echo ""

pid=()
for dataset in ${datasets[@]}; do
    python scripts/modify_data.py \
        --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_${dataset}_rh.pkl.${data_split} \
        --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/data \
        --char_map_file /data/deep_learning/fingerspelling_torch/${base_dataset}_character_to_prediction_index.json \
        --method import &
    pid+=("$!")
done
wait "${pid[@]}"

