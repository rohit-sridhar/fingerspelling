#!/bin/ksh

typeset -a participants=("93" "227" "161" "254" "2")
typeset -a seeds=("1248" "2248" "3248" "4248" "5248" "6248" "7248" "8248" "9248" "10248")
typeset -a data_splits=("train" "val")

############################## IMPORT MULTIPLE ##############################

echo ""
echo "STARTING IMPORT"
echo ""

for data_split in ${data_splits[@]}; do
    for participant in "${participants[@]}"; do
        for seed in "${seeds[@]}"; do
            python scripts/modify_data.py --data_loc /data/deep_learning/fingerspelling_torch/data/data_thr0_supplemental_sd${seed}_pt${participant}_right.pkl.${data_split} --new_data_loc ./data/supplemental/dl_cmp/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data --new_label_loc ./label/supplemental/dl_cmp/thr0/${data_split}/pt${participant}/sd${seed}/label/ --method import
        done
    done
done


############################## THRESHOLD MULTIPLE (TRAIN) ##############################
typeset -a thresholds=(1 2 4 6 8)

echo ""
echo "STARTING FRAME PER LETTER THRESHOLD"
echo ""

for data_split in ${data_splits[@]}; do
    for participant in "${participants[@]}"; do
        for seed in "${seeds[@]}"; do
            for threshold in "${thresholds[@]}"; do
                python scripts/modify_data.py --data_loc ./data/supplemental/dl_cmp/dim20/thr0/${data_split}/pt${participant}/sd${seed}/data --label_loc ./label/supplemental/dl_cmp/thr0/${data_split}/pt${participant}/sd${seed}/label --new_data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data --new_label_loc ./label/supplemental/dl_cmp/thr${threshold}/${data_split}/pt${participant}/sd${seed}/label --method fpl_threshold --fpl_threshold ${threshold}
            done
        done
    done
done

############################## INTERPOLATE MULTIPLE (TRAIN) ##############################
typeset -a interpolations=(1 2)

echo ""
echo "STARTING INTERPOLATION"
echo ""

for data_split in ${data_splits[@]}; do
    for participant in "${participants[@]}"; do
        for seed in "${seeds[@]}"; do
            for threshold in "${thresholds[@]}"; do
                for interpolation in "${interpolations[@]}"; do
                    python scripts/modify_data.py --data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/pt${participant}/sd${seed}/data --label_loc ./label/supplemental/dl_cmp/thr${threshold}/${data_split}/pt${participant}/sd${seed}/label --new_data_loc ./data/supplemental/dl_cmp/dim20/thr${threshold}/${data_split}/interpall${interpolation}/pt${participant}/sd${seed}/data --method interpolation --num_interpolations ${interpolation} --interp_all
                done
            done
        done
    done
done

