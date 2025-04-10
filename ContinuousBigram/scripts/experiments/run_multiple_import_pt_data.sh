#!/bin/ksh

##### For all participants
typeset -a all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)

# typeset -a all_participants=(93 227 161 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)

typeset -a seeds=(1248 2248 3248 4248 5248)
typeset -a data_splits=(train val)

dataset=supplemental_gen

##### For all participants
# typeset -a all_participants=(93 227 161 254 2 242 112 31 9 107)
# 
# typeset -a seeds=(1248 2248 3248 4248 5248)
# typeset -a data_splits=(train val)

############################## IMPORT MULTIPLE ##############################

echo ""
echo "STARTING IMPORT"
echo ""

for data_split in ${data_splits[@]}; do
for participant in "${all_participants[@]}"; do
pid=()
for seed in "${seeds[@]}"; do
    python scripts/modify_data.py \
        --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_thr0_${dataset}_sd${seed}_pt${participant}_right.pkl.${data_split} \
        --new_data_loc ./data/$dataset/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data \
        --char_map_file /data/parquet/asl-fingerspelling/${dataset}_character_to_prediction_index.json \
        --method import &
    pid+=("$!")
done
wait "${pid[@]}"
done
done

