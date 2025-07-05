#!/bin/ksh

torch_root=/data/deep_learning/fingerspelling_torch

base_dataset=supplemental_gen
typeset -a datasets=(${base_dataset}_drop-na ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na ${base_dataset}_na-thr0.3_drop-na_lininterp1 ${base_dataset}_na-thr0.5_drop-na ${base_dataset}_na-thr0.5_drop-na_lininterp1)

echo ""
echo "STARTING IMPORT"
echo ""

for dataset in ${datasets[@]}; do
    python scripts/modify_data.py \
        --import_data_loc ${torch_root}/data/data_${dataset}_rh.pkl.all \
        --new_data_loc ./data/${dataset}/dim20/thr0/all/data \
        --char_map_file ${torch_root}/${base_dataset}_character_to_prediction_index.json \
        --method import
done

