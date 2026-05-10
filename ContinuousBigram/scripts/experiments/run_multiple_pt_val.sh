#!/bin/bash

########## NOTE
## Pass 1+ args of paths to results json files
## with the top performing model. This script parses
## it and runs the best model on the train/val data.
########## FIN

ROOT=/data/hmm_modeling/fingerspelling/ContinuousBigram
. ${ROOT}/scripts/experiments/utils.sh
set_vars $1

##### USE BELOW AFTER TESTING ON INITIAL SAMPLE
datasets=(${base_dataset}_drop-na_lininterp0)
thresholds=(0)
typeset -a results_jsons=(${@:2})

if [[ $2 == "" ]]; then
    echo "Pass 1 or more results JSON files as the second+ arg(s)"
    exit 1
fi

############################## USER DEP ALL ###############################

# output_dir=${ROOT}/results/pt_results/udp_all/${base_dataset}
# 
# if [[ ! -d ${output_dir} ]]; then
#     mkdir -p ${output_dir}
# fi
# 
# for results_json in ${results_jsons[@]}; do 
#     if [[ ! -f ${results_json} ]]; then
#         echo "Results JSON ${results_json} does not exist. Skipping iteration."
#         continue
#     fi
# 
#     for dataset in ${datasets[@]}; do
#     for threshold in ${thresholds[@]}; do
#     for participant in ${all_participants[@]}; do
#         model_exists=$(eval jq ".pt${participant}.model_exists" ${results_json})
#         if [[ "$model_exists" == "false" ]]; then
#             continue
#         else
#             model_path=$(eval jq ".pt${participant}.model_path" ${results_json})
#             model_path=${model_path#?}
#             model_path=${model_path%?}
#         fi
#     
#         python scripts/grid_search.py \
#             --data_files ./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data/ \
#             --test_model_path  ${model_path} \
#             --ip_values -5 \
#             --results_csv ${output_dir}/results_pt${participant}_grliwi.csv \
#             --test_model --prepare_data --clear_hresults
# 
#         python scripts/grid_search.py \
#             --data_files ./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data/ \
#             --test_model_path  ${model_path} \
#             --ip_values -5 \
#             --results_csv ${output_dir}/results_pt${participant}_grliwph.csv \
#             --test_model --prepare_data --clear_hresults --use_phrase
#     done
#     done
#     done
# done

# --ip_values -25 -10 -5 0 10 \

############################## USER DEP VALIDATION ###############################

output_dir=results/pt_results/val/${base_dataset}

if [ ! -d ${output_dir} ]; then
    mkdir -p ${output_dir}
fi

for results_json in ${results_jsons[@]}; do 
    if [[ ! -f ${results_json} ]]; then
        echo "Results JSON ${results_json} does not exist. Skipping iteration."
        continue
    fi

    for dataset in ${datasets[@]}; do
    for seed in ${seeds[@]}; do
    for threshold in ${thresholds[@]}; do
    for participant in ${all_participants[@]}; do
        model_exists=$(eval jq ".pt${participant}.model_exists" ${results_json})
        if [[ "$model_exists" == "false" ]]; then
            continue
        else
            model_path=$(eval jq ".pt${participant}.model_path" ${results_json})
            model_path=${model_path#?}
            model_path=${model_path%?}
        fi
    
        python scripts/grid_search.py \
            --data_files ./data/${dataset}/dim20/thr${threshold}/val/pt/${participant}/sd${seed}/data/ \
            --test_model_path  ${model_path} \
            --ip_values -200 -100 -50 -25 0 \
            --results_csv ${output_dir}/results_pt${participant}_sd${seed}.csv \
            --test_model --prepare_data --clear_hresults
    done
    done
    done
    done
done

# if [[ ! -d ./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data ]]; then
#     echo "./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data does not exist"
# fi

