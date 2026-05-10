#!/bin/bash

# Specify your image name here. Dockerfile builds from rohitsridhar91/torch_tflite_convert
local_image="rohit_hmm_fingerspelling"

if [ "$1" == "build" ]; then
    sudo docker build --no-cache -t $local_image .
elif [ "$1" == "launch" ]; then
    # continuous_bigram_path="/scratch/fingerspelling"
    continuous_bigram_path="/data/hmm_modeling/fingerspelling"
    fingerspelling_torch_path="/data/deep_learning/fs_transformers"
    fingerspelling_video_path="/data/sign_language_videos/fingerspelling_videos"
    islr_mputils_out_path="/data/deep_learning/ISLR-ML/mputils"
    vimrc_file="$HOME/.vimrc"
#     bashrc_file="$HOME/.bashrc"
    
    if [ "$2" == "" ]; then
        echo "Specify a container name when calling launch"
        exit 1
    fi
    
    sudo docker run \
        -it --rm \
        -v "$continuous_bigram_path":"/data/hmm_modeling/fingerspelling" \
        -v "$fingerspelling_torch_path":"/data/deep_learning/fs_transformers":ro \
        -v "$fingerspelling_video_path":"/data/sign_language_videos/fingerspelling_videos":ro \
        -v "$islr_mputils_out_path":"/data/deep_learning/ISLR-ML/mputils":ro \
        -v "$vimrc_file":"/root/.vimrc":ro \
        -e HOSTNAME_SERVER="$HOSTNAME" \
        --name $2 $local_image
elif [ "$1" == "enter" ]; then
    sudo docker exec -it $2 /bin/bash
else
    echo "Specify either launch (spin up a container) or build (build image) or enter (step into running container)"
fi

#     bashrc_file="$HOME/.bashrc"
#         -v "$bashrc_file":"/root/.bashrc":ro \
