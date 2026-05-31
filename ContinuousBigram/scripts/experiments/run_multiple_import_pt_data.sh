#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

echo ""
echo "STARTING IMPORT"
echo ""

participants=(ab12)
############################## IMPORT MULTIPLE (TRAIN,VAL,TEST) ##############################

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
pid=()
for participant in "${participants[@]}"; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_rh.pq.${data_split} \
        --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --method import &
    pid+=("$!")
done
wait "${pid[@]}"
done
done
done

