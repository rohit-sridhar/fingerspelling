#!/usr/bin/env bash
set -euo pipefail

# pace.sh - sync ContinuousBigram artifacts to PACE cluster
# Usage: pace.sh [BASE_DATASET] [PHOENIX_USER_HOST] [PHOENIX_FS_ROOT]
# Environment variables override positional args: BASE_DATASET, PHOENIX_USER_HOST, PHOENIX_FS_ROOT

BASE_DATASET="${3:-supplemental_gen}"
PHOENIX_USER_HOST="${1:-${PHOENIX_USER_HOST:-rsridhar37@login-phoenix.pace.gatech.edu}}"
PHOENIX_FS_ROOT="${2:-${PHOENIX_FS_ROOT:-/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram}}"

typeset -a datasets=("${BASE_DATASET}" "${BASE_DATASET}_na-thr0.3" "${BASE_DATASET}_drop-na" "${BASE_DATASET}_na-thr0.3_drop-na")

echo "Syncing commands file to ${PHOENIX_USER_HOST}:${PHOENIX_FS_ROOT}/commands"
rsync -H --progress "./ContinuousBigram/commands/commands_tri_internal.all" "${PHOENIX_USER_HOST}:${PHOENIX_FS_ROOT}/commands"

for dataset in "${datasets[@]}"; do
    echo "Creating remote dirs for dataset ${dataset}"
    PHOENIX_DATA_DIR="${PHOENIX_FS_ROOT}/data/${dataset}/dim20/thr0/"
    ssh "${PHOENIX_USER_HOST}" "mkdir -p \"${PHOENIX_DATA_DIR}\""
    rsync -rHR --progress \
        "./ContinuousBigram/data/${dataset}/dim20/thr0/./all" \
        "./ContinuousBigram/data/${dataset}/dim20/thr0/./train" \
        "./ContinuousBigram/data/${dataset}/dim20/thr0/./val" \
        "./ContinuousBigram/data/${dataset}/dim20/thr0/./test" \
        "${PHOENIX_USER_HOST}:${PHOENIX_DATA_DIR}"

    PHOENIX_LABEL_DIR="${PHOENIX_FS_ROOT}/label/${dataset}/dim20/thr0/"
    ssh "${PHOENIX_USER_HOST}" "mkdir -p \"${PHOENIX_LABEL_DIR}\""
    rsync -rHR --progress \
        "./ContinuousBigram/label/${dataset}/dim20/thr0/./all" \
        "./ContinuousBigram/label/${dataset}/dim20/thr0/./train" \
        "./ContinuousBigram/label/${dataset}/dim20/thr0/./val" \
        "./ContinuousBigram/label/${dataset}/dim20/thr0/./test" \
        "${PHOENIX_USER_HOST}:${PHOENIX_LABEL_DIR}"
done

