#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT="${SCRIPT_DIR}/../.."

. ${SCRIPT_DIR}/utils.sh
set_vars $1

base_dataset=supplemental_gen
output_dir="general_results/tot/${base_dataset}"

typeset -a seeds=(1248)
typeset -a ips=(-10 -9 -8 -7 -6 -5 -4 -3 -2 -1)
# typeset -a ips=(-10 0 5 10 12 15 20 30 50 75 100 150)
# typeset -a ips=(-100 -50 -20 -15 -12)

# Assumes we're in ContinuousBigram dir TODO make it abs path later
if [ ! -d "${ROOT}/results/${output_dir}" ]; then
    mkdir -p "${ROOT}/results/${output_dir}"
fi

############################## TRAIN MULTIPLE DIM20;PCA10;POL20;PCAPOL10 ##############################
        # --num_its 1000 --num_tri_its 1000 \
        # --hmmdefs 6state-pca20-gmm4-skip \
for data_split in ${data_splits[@]}; do
for dataset in ${datasets[@]}; do
for seed in "${seeds[@]}"; do
    ${ROOT}/scripts/grid_search.py \
        --data_files ${ROOT}/data/${dataset}/dim20/thr0/${data_split}/general/sd${seed}/data/ \
        --results_csv ${ROOT}/results/${output_dir}/results_${dataset}_${data_split}.csv \
        --test_model_path ${ROOT}/models/supplemental_gen_drop-na_lininterp0/dim20/thr0/train/general/sd1248/newMacros_6state-pca20-gmm4-skip_1000its_1000tri-its_tc50 \
        --ip_values "${ips[@]}" --clear_hresults --prepare_data --test_model
done
done
done

