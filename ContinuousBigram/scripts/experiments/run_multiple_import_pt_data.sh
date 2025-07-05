#!/bin/ksh

. ./scripts/experiments/utils.sh

############################## IMPORT MULTIPLE (TRAIN,VAL) ##############################
base_dataset=supplemental_gen
typeset -a datasets=(${base_dataset}_drop-na ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na ${base_dataset}_na-thr0.3_drop-na_lininterp1 ${base_dataset}_na-thr0.5_drop-na ${base_dataset}_na-thr0.5_drop-na_lininterp1)
typeset -a all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)

echo ""
echo "STARTING IMPORT"
echo ""

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
pid=()
for participant in "${all_participants[@]}"; do
    python scripts/modify_data.py \
        --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_${dataset}_sd${seed}_pt-${participant}_rh.pkl.${data_split} \
        --new_data_loc ./data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --char_map_file /data/deep_learning/fingerspelling_torch/${base_dataset}_character_to_prediction_index.json \
        --method import &
    pid+=("$!")
done
wait "${pid[@]}"
done
done
done

############################## IMPORT MULTIPLE (TEST) ##############################

# for seed in "${seeds[@]}"; do
# pid=()
# for participant in "${all_participants[@]}"; do
#     python scripts/modify_data.py \
#         --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_${datasets[0]}_pt-${participant}_rh.pkl.all \
#         --new_data_loc ./data/${datasets[0]}/dim20/thr0/test/pt/${participant}/sd${seed}/data \
#         --char_map_file /data/deep_learning/fingerspelling_torch/${base_dataset}_character_to_prediction_index.json \
#         --method import &
#     pid+=("$!")
# done
# wait "${pid[@]}"
# done

