#!/bin/ksh

##### For all participants
# typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)
# typeset -a all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a thresholds=(1 2 4 6 8)
# typeset -a interpolations=(1 2)

##### For debug 
typeset -a all_participants=(03ad)
typeset -a seeds=(1248)
typeset -a data_splits=(train val)

typeset -a thresholds=(1 4) 
# typeset -a interpolations=(1 2)

dataset=supplemental_gen

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
pt_idx=$(( SLURM_ARRAY_TASK_ID ))
cd $root
echo "Current directory: `pwd`"

############################## THRESHOLD MULTIPLE ##############################

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo "PT IDX: ${pt_idx}"
echo "DATASET: ${dataset}"
echo ""

for data_split in ${data_splits[@]}; do
for participant in "${all_participants[$pt_idx]}"; do
for seed in "${seeds[@]}"; do
for threshold in "${thresholds[@]}"; do
    python scripts/modify_data.py \
        --data_loc data/${dataset}/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data \
        --new_data_loc data/${dataset}/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data \
        --method fpl_threshold \
        --fpl_threshold ${threshold}
done
done
done
done

############################## INTERPOLATE MULTIPLE ##############################

# echo ""
# echo "STARTING INTERPOLATION"
# echo ""
#
# for data_split in ${data_splits[@]}; do
# for participant in "${all_participants[$pt_idx]}"; do
# for seed in "${seeds[@]}"; do
# for threshold in "${thresholds[@]}"; do
# for interpolation in "${interpolations[@]}"; do
#     python scripts/modify_data.py \
#         --data_loc data/${dataset}/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data \
#         --new_data_loc data/${dataset}/dim20/thr${threshold}/${data_split}/interpall${interpolation}/pt${participant}/sd${seed}/data \
#         --method interpolation \
#         --num_interpolations ${interpolation} \
#         --interp_all
# done
# done
# done
# done
# done

