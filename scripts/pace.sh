#!/usr/bin/env bash
set -euo pipefail

# pace.sh - sync ContinuousBigram artifacts to PACE cluster
# Usage: pace.sh [REMOTE_USER_HOST] [REMOTE_BASE] [BASE_DATASET]
# Environment variables override positional args: REMOTE_USER_HOST, REMOTE_BASE, BASE_DATASET

REMOTE_USER_HOST="${1:-${REMOTE_USER_HOST:-rsridhar37@login-phoenix.pace.gatech.edu}}"
REMOTE_BASE="${2:-${REMOTE_BASE:-/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram}}"
BASE_DATASET="${3:-${BASE_DATASET:-supplemental_gen}}"

typeset -a datasets=("${BASE_DATASET}" "${BASE_DATASET}_na-thr0.3" "${BASE_DATASET}_drop-na" "${BASE_DATASET}_na-thr0.3_drop-na")

echo "Syncing commands file to ${REMOTE_USER_HOST}:${REMOTE_BASE}/commands"
rsync -H --progress ./ContinuousBigram/commands/commands_tri_internal.all "${REMOTE_USER_HOST}:${REMOTE_BASE}/commands"

for dataset in "${datasets[@]}"; do
    echo "Creating remote dirs for dataset ${dataset}"
    ssh "${REMOTE_USER_HOST}" "mkdir -p ${REMOTE_BASE}/data/${dataset}/dim20/thr0/"
    rsync -rHR --progress ./ContinuousBigram/data/${dataset}/dim20/thr0/./all ./ContinuousBigram/data/${dataset}/dim20/thr0/./train ./ContinuousBigram/data/${dataset}/dim20/thr0/./val ./ContinuousBigram/data/${dataset}/dim20/thr0/./test "${REMOTE_USER_HOST}:${REMOTE_BASE}/data/${dataset}/dim20/thr0/"

    ssh "${REMOTE_USER_HOST}" "mkdir -p ${REMOTE_BASE}/label/${dataset}/dim20/thr0/"
    rsync -rHR --progress ./ContinuousBigram/label/${dataset}/dim20/thr0/./all ./ContinuousBigram/label/${dataset}/dim20/thr0/./train ./ContinuousBigram/label/${dataset}/dim20/thr0/./val ./ContinuousBigram/label/${dataset}/dim20/thr0/./test "${REMOTE_USER_HOST}:${REMOTE_BASE}/label/${dataset}/dim20/thr0/"
done

