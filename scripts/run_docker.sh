#!/bin/bash

TAG="latest"

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
        continuous_bigram_path="$root/hmm_modeling/fingerspelling"
        
        fingerspelling_torch_path="$root/deep_learning/fingerspelling_torch"
        fingerspelling_data_path="$root/parquet/asl-fingerspelling"
        
        if [ "$2" == "fingerspelling" ]; then
            sudo docker run \
                -dit \
                -v "$fingerspelling_torch_path":"$fingerspelling_torch_path" \
                -v "$fingerspelling_data_path":"$fingerspelling_data_path" \
                -v "$continuous_bigram_path":"$continuous_bigram_path" \
                -e HOSTNAME_SERVER="$HOSTNAME" \
                --name $2 rohitsridhar91/asl_sign_recognizer:$TAG
        else
            echo "Specify an appropriate image name"
        fi
        
        if [[ "$4" != "" ]] && [[ "$1" == "launch" ]]; then
            sudo docker cp "$4" $2:/root
            echo "$4 copied to $2:/root"
        fi
    else
        echo "Specify either launch (create the container), run (resume the existing container), rm (remove existing container), or ls"
    fi
fi

