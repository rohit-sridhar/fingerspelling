#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

typeset -a data_groups=(general pt-split)
# typeset -a data_splits=(train val test)

set_slurm_subsets_if_exists data_groups data_splits seeds

############################## IMPORT MULTIPLE (DIM10) ##############################

echo ""
echo "STARTING IMPORT"
echo ""

pid=()
for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for data_group in ${data_groups[@]}; do
for seed in "${seeds[@]}"; do
    if [[ ${data_group} == "general" ]]; then
        import_data_loc=${TORCH_ROOT}/data/data_${dataset}_sd${seed}_ctr-fc_rh.pq.${data_split}
    else
        import_data_loc=${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-split_ctr-fc_rh.pq.${data_split}
    fi

    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${import_data_loc} \
        --new_data_loc ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/${data_split}/${data_group}/sd${seed}/data \
        --method import &
    pid+=("$!")
done
done
done
done
wait "${pid[@]}"

############################### prep all (dim10) (train,val,test) ################################

echo ""
echo "STARTING DATA PREPARATION"
echo ""

for dataset in "${datasets[@]}"; do
for data_split in "${data_splits[@]}"; do
for data_group in ${data_groups[@]}; do
for seed in "${seeds[@]}"; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim10/ctr-fc/thr0/${data_split}/${data_group}/sd${seed}/data \
        --prepare_data_only
done
done
done
done

# ############################## IMPORT MULTIPLE (DIM20) ##############################
# 
# echo ""
# echo "STARTING IMPORT"
# echo ""
# 
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for data_group in ${data_groups[@]}; do
# for seed in "${seeds[@]}"; do
#     if [[ ${data_group} == "general" ]]; then
#         import_data_loc=${TORCH_ROOT}/data/data_${dataset}_sd${seed}_rh.pq.${data_split}
#     else
#         import_data_loc=${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-split_rh.pq.${data_split}
#     fi
# 
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${import_data_loc} \
#         --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/${data_group}/sd${seed}/data \
#         --method import
# done
# done
# done
# done
# 
# ############################### prep all (dim20) (train,val,test) ################################
# 
# echo ""
# echo "STARTING DATA PREPARATION"
# echo ""
# 
# for dataset in "${datasets[@]}"; do
# for data_split in "${data_splits[@]}"; do
# for data_group in ${data_groups[@]}; do
# for seed in "${seeds[@]}"; do
#     ${ROOT}/scripts/grid_search.py \
#         --data_files ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/${data_group}/sd${seed}/data \
#         --prepare_data_only
# done
# done
# done
# done
# 
# ############################## IMPORT MULTIPLE (PCA10) ##############################
# 
# pid=()
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for seed in "${seeds[@]}"; do
#     # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pca10_rh.pq.${data_split} \
#         --new_data_loc ${ROOT}/data/${dataset}/pca10/thr0/${data_split}/general/sd${seed}/data \
#         --method import &
#     pid+=("$!")
# done
# done
# done
# wait "${pid[@]}"
# 
# ############################## IMPORT MULTIPLE (PCA10, PT-SPLIT) ##############################
# 
# pid=()
# for dataset in ${datasets[@]}; do
# for data_split in ${data_splits[@]}; do
# for seed in "${seeds[@]}"; do
#     # Code below assumes threshold 0 for all the imported data (should only import thr 0 data)
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-split_pca10_rh.pq.${data_split} \
#         --new_data_loc ${ROOT}/data/${dataset}/pca10/thr0/${data_split}/pt-split/sd${seed}/data \
#         --method import &
#     pid+=("$!")
# done
# done
# done
# wait "${pid[@]}"
# 
