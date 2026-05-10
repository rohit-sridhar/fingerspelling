#!/bin/bash

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

echo ""
echo "STARTING SEGMENTATION"
echo ""

num_participants=${#all_participants[@]}
num_threads=12   # for now num_participants should be divisible by num_threads
num_iters=$(( $num_participants / $num_threads ))

for (( i = 0; i < $num_iters; i++ )); do
    pid=()
    for (( j = 0; j < $num_threads; j++ )); do
        idx=$(( ($i * $num_threads) + $j ))
        ${ROOT}/scripts/segmentation/make_segmentation.py -vid -pts ${all_participants[$idx]} &
        pid+=("$!")
    done
    wait "${pid[@]}"
done

