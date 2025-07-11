#!/bin/bash

. ./scripts/experiments/utils.sh

echo ""
echo "STARTING IMPORT"
echo ""

############################## IMPORT MULTIPLE (GRP RND; DROP NA; INTERP 1) ##############################
base_dataset=supplemental_gen
typeset -a datasets=(${base_dataset}_drop-na ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na ${base_dataset}_na-thr0.3_drop-na_lininterp1 ${base_dataset}_na-thr0.5_drop-na ${base_dataset}_na-thr0.5_drop-na_lininterp1)
typeset -a pt_grps=(grp.rnd*.2 grp.rnd*.3 grp.rnd*.6 grp.rnd*.12)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)

for dataset in ${datasets[@]}; do
for seed in ${seeds[@]}; do
for data_split in ${data_splits[@]}; do
pid=()
for pt_grp in ${pt_grps[@]}; do
    # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
    typeset -a import_files=(${TORCH_ROOT}/data/data_${dataset}_sd${seed}_${pt_grp}_rh.pkl.${data_split})
    for import_file in ${import_files[@]}; do
        filename=$(eval basename "${import_file}")
        grp_name=$(get_name_from_filename "$filename" "grp.rnd")

        python scripts/modify_data.py \
            --import_data_loc ${import_file} \
            --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/grp/${grp_name}/sd${seed}/data \
            --char_map_file ${TORCH_ROOT}/${base_dataset}_character_to_prediction_index.json \
            --method import &
    done
pid+=("$!")
done
wait "${pid[@]}"
done
done
done

############################## IMPORT MULTIPLE (GRP PILOT) ##############################

# base_dataset=supplemental_gen
# typeset -a datasets=(${base_dataset} ${base_dataset}_na-thr0.3 ${base_dataset}_drop-na ${base_dataset}_na-thr0.3_drop-na)
# typeset -a pt_grps=(grp1.6 grp2.6 grp3.6 grp4.6 grp5.6)
# typeset -a seeds=(1248)
# typeset -a data_splits=(train val)
# 
# pid=()
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for pt_grp in ${pt_grps[@]}; do
# for seed in ${seeds[@]}; do
#     # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
#     python scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_${pt_grp}_rh.pkl.${data_split} \
#         --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/grp/${pt_grp}/sd${seed}/data \
#         --char_map_file ${TORCH_ROOT}/${base_dataset}_character_to_prediction_index.json \
#         --method import &
#     pid+=("$!")
# done
# done
# done
# done
# wait "${pid[@]}"

