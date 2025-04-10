#!/bin/ksh

##### For all participants
typeset -a all_participants=(93 161 227 254 2 242 112 31 9 107 188 13 181 26 195 136 241 109 53 216 89 239 22 111 0 95 38 157 196 15 251 253 219 47 73 121 246 166 141 54 223 213 20 99 40 122 27 245 240 221 33 155 128 250 158 117 6 148 135 143 207 175 81 137 63 184 113 56 51 150 217 203)

typeset -a seeds=(1248 2248 3248 4248 5248)
typeset -a data_splits=(train val)

# Two lines below are for slurm jobs
root="/data/hmm_modeling/fingerspelling/ContinuousBigram"
cd $root
pt_idx=$(( SLURM_ARRAY_TASK_ID ))

############################## IMPORT MULTIPLE ##############################

echo ""
echo "STARTING IMPORT"
echo ""

for data_split in ${data_splits[@]}; do
for participant in "${all_participants[@]}"; do
for seed in "${seeds[@]}"; do
    python scripts/modify_data.py \
        --import_data_loc /data/deep_learning/fingerspelling_torch/data/data_thr0_supplemental_sd${seed}_pt${participant}_right.pkl.${data_split} \
        --new_data_loc ./data/supplemental/dl_cmp/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data \
        --method import
done
done
done

