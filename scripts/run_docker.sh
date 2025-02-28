#!/bin/bash

# Specify your image name here. Dockerfile builds from rohitsridhar91/torch_tflite_convert
local_image="rohit_hmm_fingerspelling"

if [ "$1" == "build" ]; then
    sudo docker build --no-cache -t $local_image .
elif [ "$1" == "launch" ]; then
    continuous_bigram_path="/data/hmm_modeling/fingerspelling"
    fingerspelling_torch_path="/data/deep_learning/fingerspelling_torch"
    fingerspelling_data_path="/data/parquet/asl-fingerspelling"
    
    if [ "$2" == "" ]; then
        echo "Specify a container name when calling launch"
        exit 1
    fi
    
    sudo docker run \
        -it --rm \
        -v "$fingerspelling_torch_path":"$fingerspelling_torch_path" \
        -v "$fingerspelling_data_path":"$fingerspelling_data_path" \
        -v "$continuous_bigram_path":"$continuous_bigram_path" \
        -e HOSTNAME_SERVER="$HOSTNAME" \
        --name $2 $local_image
else
    echo "Specify either launch (spin up a container) or build (build image)"
fi

