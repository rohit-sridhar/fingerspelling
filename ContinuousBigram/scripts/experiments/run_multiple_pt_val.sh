#!/bin/bash

########## NOTE
## Pass 1+ args of paths to results json files
## with the top performing model. This script parses
## it and runs the best model on the train/val data.
########## FIN

base_dataset=supplemental_gen

##### USE BELOW AFTER TESTING ON INITIAL SAMPLE
typeset -a participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
typeset -a results_jsons=($@)
typeset -a datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0)
typeset -a seeds=(1248)
typeset -a thresholds=(0 1)

############################## USER DEP TEST ###############################

output_dir=results/pt_results/tst/${base_dataset}

if [ ! -d ${output_dir} ]; then
    mkdir -p ${output_dir}
fi

for results_json in ${results_jsons[@]}; do 
    if [[ ! -f ${results_json} ]]; then
        echo "Results JSON ${results_json} does not exist. Skipping iteration."
        continue
    fi

    for dataset in ${datasets[@]}; do
    for threshold in ${thresholds[@]}; do
    for participant in ${participants[@]}; do
        model_exists=$(eval jq ".pt${participant}.model_exists" ${results_json})
        if [[ "$model_exists" == "false" ]]; then
            continue
        else
            model_path=$(eval jq ".pt${participant}.model_path" ${results_json})
            model_path=${model_path#?}
            model_path=${model_path%?}
        fi
    
        python scripts/grid_search.py \
            --data_files ./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data/ \
            --test_model_path  ${model_path} \
            --ip_values -25 -10 -5 0 10 \
            --results_csv ${output_dir}/results_pt${participant}_grliwi.csv \
            --test_model --prepare_data --clear_hresults

        python scripts/grid_search.py \
            --data_files ./data/${dataset}/dim20/thr${threshold}/test/pt/${participant}/data/ \
            --test_model_path  ${model_path} \
            --ip_values -25 -10 -5 0 10 \
            --results_csv ${output_dir}/results_pt${participant}_grliwph.csv \
            --test_model --prepare_data --clear_hresults --use_phrase
    done
    done
    done
done

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
    for participant in ${participants[@]}; do
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

