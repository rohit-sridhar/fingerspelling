#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

echo ""
echo "STARTING IMPORT"
echo ""

# participants=(3f8b 13e3 494d b2d1 ab12)
if [[ -v SLURM_ARRAY_TASK_ID ]]; then
    if [[ ${SLURM_ARRAY_TASK_ID} -ge ${#participants[@]} ]]; then
        echo "The SLUM ARRAY TASK ID is too large. Should be <= num participants"
        exit 1
    fi
    participants=(${participants[${SLURM_ARRAY_TASK_ID}]})
else
    participants=${participants[@]}
fi

############################## IMPORT MULTIPLE (TRAIN,VAL,TEST) ##############################

for dataset in ${datasets[@]}; do
for data_split in ${data_splits[@]}; do
for seed in "${seeds[@]}"; do
bp=0
# pid=()
for participant in "${participants[@]}"; do
    ${ROOT}/scripts/modify_data.py \
        --import_data_loc ${TORCH_ROOT}/data/data_${dataset}_sd${seed}_pt-${participant}_rh.pq.${data_split} \
        --new_data_loc ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/pt/${participant}/sd${seed}/data \
        --method import --bar_position ${bp} --bar_description "${data_split}|${seed}|${participant}"
    bp=$((bp+1))
#     pid+=("$!")
done
# wait "${pid[@]}"
done
done
done

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

