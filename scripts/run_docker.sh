#!/bin/bash

if [ "$1" == "ls" ]; then
    sudo docker ps -a
    exit 0
else
    if [ "$2" == "" ]; then
        echo "Specify a container name when calling launch, run or rm"
        exit 1
    fi
    
    if [ "$1" == "run" ]; then
        sudo docker exec -it $2 /bin/bash
    elif [ "$1" == "rm" ]; then
        sudo docker stop $2
        sudo docker rm $2
    elif [ "$1" == "launch" ]; then
        if [ "$3" == "" ]; then
            echo "Specify a local root for local path mounts when calling launch. (third arg)"
            exit 1
        fi
        
        root="$3"
        
        mb_pipe_path="$root/Mobile-Data-Processing-Pipeline"
        islr_path="$root/hmm_modeling/islr/ContinuousBigram"
        phrase_data_path="$root/sign_language_videos/phrase_data"
        
        if [ "$2" == "islr" ]; then
            sudo docker run \
                -dit \
                -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
                -v "$islr_path":/root/islr/ContinuousBigram \
                --name $2 rohitsridhar91/asl_sign_recognizer:v1.2
        elif [ "$2" == "phrase" ]; then
            sudo docker run \
                -dit \
                -v "$mb_pipe_path":/root/Mobile-Data-Processing-Pipeline \
                -v "$phrase_data_path":/root/phrase_data \
                --name $2 rohitsridhar91/asl_sign_recognizer:v1.2
        elif [ "$2" == "fingerspelling" ]; then
            continuous_bigram_path="$root/hmm_modeling/fingerspelling/ContinuousBigram"
            # continuous_bigram_ebisu_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.ebisu"
            # continuous_bigram_hotei_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.hotei"
            continuous_bigram_ss_path="$root/hmm_modeling/silentspeller/ContinuousBigram"
            main_pipeline_ss_path="$root/hmm_modeling/silentspeller/MainPipeline"
            
            sudo docker run \
                -dit \
                -v "$continuous_bigram_ss_path":/root/silentspeller/ContinuousBigram \
                -v "$main_pipeline_ss_path":/root/silentspeller/MainPipeline \
                -v "$continuous_bigram_path":/root/fingerspelling/ContinuousBigram \
                --name $2 rohitsridhar91/asl_sign_recognizer:v1.2
        fi
        
        if [ "$4" != "" ]; then
            sudo docker cp "$4" $2:/root
            echo "$4 copied to $2:/root"
        fi
    else
        echo "Specify either launch (create the container), run (resume the existing container), rm (remove existing container), or ls"
    fi
fi

# root="/home/lab-workstation/ServerData"

# parquet_path="$root/parquet"

# continuous_bigram_dim8_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.dim8"
# continuous_bigram_dim12_path="$root/hmm_modeling/fingerspelling/ContinuousBigram.dim12"

