#!/bin/bash

VERSION="v1.3"

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
        continuous_bigram_path="$root/hmm_modeling/fingerspelling"
        
        if [ "$2" == "islr" ]; then
            islr_path="$root/hmm_modeling/islr"
            
            sudo docker run \
                -dit \
                -v "$mb_pipe_path":"$mb_pipe_path" \
                -v "$islr_path":"$islr_path" \
                --name $2 rohitsridhar91/asl_sign_recognizer:$VERSION
        elif [ "$2" == "popsign_experiments" ]; then
            popsign_path="$root/hmm_modeling/popsign"
            popsign_data_path="$root/sign_language_videos/mediapipe"
            
            sudo docker run \
                -dit \
                -v "$mb_pipe_path":"$mb_pipe_path" \
                -v "$continuous_bigram_path":"$continuous_bigram_path" \
                -v "$popsign_path":"$popsign_path" \
                -v "$popsign_data_path":"$popsign_data_path" \
                --name $2 rohitsridhar91/asl_sign_recognizer:$VERSION
        elif [ "$2" == "fingerspelling" ]; then
            # continuous_bigram_benten_path="$root/hmm_modeling/fs.benten"
            # continuous_bigram_hotei_path="$root/hmm_modeling/fs.hotei"
            continuous_bigram_ebisu_path="$root/hmm_modeling/fs.ebisu"
            
            sudo docker run \
                -dit \
                -v "$continuous_bigram_path":"$continuous_bigram_path" \
                -v "$continuous_bigram_ebisu_path":"$continuous_bigram_ebisu_path" \
                --name $2 rohitsridhar91/asl_sign_recognizer:$VERSION
        fi
        
        if [ "$4" != "" ]; then
            sudo docker cp "$4" $2:/root
            echo "$4 copied to $2:/root"
        fi
    else
        echo "Specify either launch (create the container), run (resume the existing container), rm (remove existing container), or ls"
    fi
fi

