#!/bin/ksh

##### For all participants
# typeset -a all_participants=(93 227 161 254 2 242 112 31 9 107)
# 
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a data_splits=(train val)
# 
# typeset -a thresholds=(1 2 4 6 8)
# typeset -a interpolations=(1 2)

##### For debug 
typeset -a all_participants=(03ad)
typeset -a seeds=(1248 2248)
typeset -a data_splits=(train val)
typeset -a thresholds=(1 4) 
typeset -a interpolations=(1)

dataset=supplemental

############################## THRESHOLD MULTIPLE ##############################

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

for data_split in ${data_splits[@]}; do
for participant in "${all_participants[@]}"; do
pid=()
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/$dataset/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data \
        --new_data_loc ./data/$dataset/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data \
        --method fpl_threshold \
        --fpl_threshold ${threshold} &
    pid+=("$!")
done
done
wait "${pid[@]}"
done
done

############################## INTERPOLATE MULTIPLE ##############################

echo ""
echo "STARTING INTERPOLATION"
echo ""

for data_split in ${data_splits[@]}; do
for participant in "${all_participants[@]}"; do
for seed in "${seeds[@]}"; do
pid=()
for threshold in "${thresholds[@]}"; do
for interpolation in "${interpolations[@]}"; do
    python scripts/modify_data.py \
        --data_loc ./data/$dataset/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data \
        --new_data_loc ./data/$dataset/dim20/thr${threshold}/${data_split}/interpall${interpolation}/pt${participant}/sd${seed}/data \
        --method interpolation \
        --num_interpolations ${interpolation} \
        --interp_all &
    pid+=("$!")
done
done
wait "${pid[@]}"
done
done
done

