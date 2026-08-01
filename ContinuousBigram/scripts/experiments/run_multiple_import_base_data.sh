#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $@

# Delete sll dirs before creating. Extremely dangerous. Use with caution.
# find ${ROOT} -name "supplemental_gen_drop-na_lininterp0" -type d -print0 | xargs -0 rm -rfv

############################## IMPORT ALL (DIM20) ###############################

echo ""
echo "STARTING IMPORT"
echo ""

for dataset in ${datasets[@]}; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_rh.pq.all \
        --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/all/data \
        --bar_description "importing base ${dataset}" --method import \
        ${debug}
done

############################### PREP ALL (DIM20) ################################

echo ""
echo "STARTING DATA PREPARATION"
echo ""

for dataset in ${datasets[@]}; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim20/thr0/all/data \
        --prepare_data_only --prepare_data_all ${debug}
done

# ############################## IMPORT ALL (DELPOL20) ###########################
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
