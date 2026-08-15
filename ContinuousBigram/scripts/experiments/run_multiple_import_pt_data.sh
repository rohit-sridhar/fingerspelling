#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1
set_slurm_subsets_if_exists participants

echo ""
echo "STARTING IMPORT"
echo ""

data_splits=(train val)
############################## IMPORT MULTIPLE (DIM10) (TRAIN,VAL,TEST) ##############################

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
bp=0
pid=()
for participant in "${participants[@]}"; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_ctr-fc_rh.pq.${data_split} \
        --new_data_loc ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --method import --bar_position ${bp} --bar_description "${data_split}|${seed}|${participant}" &
    bp=$((bp+1))
    pid+=("$!")
done
wait "${pid[@]}"
done
done
done

############################### PREP ALL (DIM10) (TRAIN,VAL,TEST) ################################

echo ""
echo "STARTING DATA PREPARATION"
echo ""

for dataset in "${datasets[@]}"; do
for data_split in "${data_splits[@]}"; do
for seed in "${seeds[@]}"; do
for participant in "${participants[@]}"; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --prepare_data_only
done
done
done
done

# ############################## IMPORT MULTIPLE (DIM20) (TRAIN,VAL,TEST) ##############################
# 
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for seed in "${seeds[@]}"; do
# bp=0
# for participant in "${participants[@]}"; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_rh.pq.${data_split} \
#         --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
#         --method import --bar_position ${bp} --bar_description "${data_split}|${seed}|${participant}"
#     bp=$((bp+1))
# done
# done
# done
# done
# 
# ############################### PREP ALL (DIM20) (TRAIN,VAL,TEST) ################################
# 
# echo ""
# echo "STARTING DATA PREPARATION"
# echo ""
# 
# for dataset in "${datasets[@]}"; do
# for data_split in "${data_splits[@]}"; do
# for seed in "${seeds[@]}"; do
# for participant in "${participants[@]}"; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
#         --prepare_data_only
# done
# done
# done
# done
# 
# ############################### IMPORT MULTIPLE (PCA10) (TRAIN,VAL,TEST) ################################
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for seed in "${seeds[@]}"; do
# bp=0
# pid=()
# for participant in "${participants[@]}"; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_pca10_rh.pq.${data_split} \
#         --new_data_loc ${ROOT}/data/${dataset}/pca10/thr0/${data_split}/pt/${participant}/sd${seed}/data \
#         --method import --bar_position ${bp} --bar_description "${data_split}|${seed}|${participant}"
#     bp=$((bp+1))
#     pid+=("$!")
# done
# wait "${pid[@]}"
# done
# done
# done

