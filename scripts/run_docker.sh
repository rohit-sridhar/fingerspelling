#!/bin/bash

# root="/home/lab-workstation/ServerData"
root="$1"

mb_pipe_path="$root/Mobile-Data-Processing-Pipeline"
phrase_data_path="$root/sign_language_videos/phrase_data"
parquet_path="$root/parquet"

# continuous_bigram_dim8_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.dim8"
# continuous_bigram_dim12_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.dim12"
continuous_bigram_path="$root/hmm_modeling/fingerspelling/ContinuousBigram"
islr_path="$root/hmm_modeling/islr/ContinuousBigram"

continuous_bigram_ss_path="$root/hmm_modeling/silentspeller/ContinuousBigram"
continuous_bigram_path_matthew="$root/hmm_modeling/matthew/ContinuousBigram"

if [ "$2" == "ls" ]; then
    sudo docker ps -a
    exit 0
fi

if [ "$3" == "" ]; then
    echo "Specify a container name when calling launch, run or rm"
    exit 0
fi

if [ "$2" == "launch" ]; then
    if [ "$3" == "islr" ]; then
        sudo docker run \
            -dit \
            -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
            -v "$islr_path":/root/islr/ContinuousBigram \
            --name $3 rohitsridhar91/asl_sign_recognizer:v1.2
    elif [ "$3" == "phrase" ]; then
        sudo docker run \
            -dit \
            -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
            -v "$phrase_data_path":/root/phrase_data \
            --name $3 rohitsridhar91/asl_sign_recognizer:v1.2
    elif [ "$3" == "fingerspelling" ]; then
        sudo docker run \
            -dit \
            -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
            -v "$parquet_path":/root/kaggle \
            -v "$continuous_bigram_ss_path":/root/silentspeller/ContinuousBigram \
            -v "$continuous_bigram_path":/root/fingerspelling/ContinuousBigram \
            --name $3 rohitsridhar91/asl_sign_recognizer:v1.2
    elif [ "$3" == "fingerspelling_matthew" ]; then
        sudo docker run \
            -dit \
            -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
            -v "$parquet_path":/root/kaggle \
            -v "$continuous_bigram_path_matthew":/root/fingerspelling/ContinuousBigram \
            --name $3 rohitsridhar91/asl_sign_recognizer:v1.2
    fi
    
    if [ "$4" != "" ]; then
        sudo docker cp "$4" $3:/root
        echo "$4 copied to $3:/root"
    fi
elif [ "$2" == "run" ]; then
    sudo docker exec -it $3 /bin/bash
elif [ "$2" == "rm" ]; then
    sudo docker stop $3
    sudo docker rm $3
else
    echo "Specify either launch (create the container), run (resume the existing container), rm (remove existing container), or ls"
fi
