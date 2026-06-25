#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@

# echo ""
# echo "STARTING IMPORT OF ${datasets[@]}"
# echo ""
# 
# ############################## IMPORT ALL (DIM20) ##############################
# 
# for dataset in ${datasets[@]}; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_rh.pq.all \
#         --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/all/data \
#         --bar_position 0 --bar_description "main_train (all)" \
#         --method import ${debug}
# done
# 
############################## PREP ALL (DIM20) ##############################

echo ""
echo "STARTING DATA PREPARATION OF ${datasets[@]}"
echo ""

for dataset in ${datasets[@]}; do
    ${ROOT}/scripts/grid_search.py \
    --data_files ${ROOT}/data/${dataset}/dim20/thr0/all/data \
    --prepare_data_only --prepare_data_all ${debug}
done

#########################################################################################################################################################################################
################################################################################ !!! OLD IMPORTS !!! ####################################################################################
#########################################################################################################################################################################################
# ############################## IMPORT ALL (DELPOL20) ##############################
# 
# for dataset in ${datasets[@]}; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_polar_delta_rh.pkl.all \
#         --new_data_loc ./data/${dataset}/delpol20/thr0/all/data \
#         --method import
# done
# 
# ############################## IMPORT ALL (POL20) ##############################
# 
# for dataset in ${datasets[@]}; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_polar_rh.pkl.all \
#         --new_data_loc ./data/${dataset}/pol20/thr0/all/data \
#         --method import
# done
# 
# ############################## IMPORT ALL (DEL20) ##############################
# 
# for dataset in ${datasets[@]}; do
#     ${ROOT}/scripts/modify_data.py \
#         --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_delta_rh.pkl.all \
#         --new_data_loc ./data/${dataset}/del20/thr0/all/data \
#         --method import
# done
# 
# ################################################################################
