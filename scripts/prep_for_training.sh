#!/usr/bin/env bash
set -euo pipefail

# prep_for_training.sh - create ContinuousBigram directory skeleton
# Usage: prep_for_training.sh [ROOT_DIR]
# ROOT_DIR defaults to current directory

ROOT_DIR="${1:-.}"
TARGET_DIR="${ROOT_DIR%/}/ContinuousBigram"

mkdir -p "${TARGET_DIR}/ext" \
         "${TARGET_DIR}/models" \
         "${TARGET_DIR}/output" \
         "${TARGET_DIR}/logs" \
         "${TARGET_DIR}/data" \
         "${TARGET_DIR}/label" \
         "${TARGET_DIR}/results" \
         "${TARGET_DIR}/commands" \
         "${TARGET_DIR}/dict" \
         "${TARGET_DIR}/grammar" \
         "${TARGET_DIR}/mlf"

echo "Created directory skeleton under ${TARGET_DIR}"

