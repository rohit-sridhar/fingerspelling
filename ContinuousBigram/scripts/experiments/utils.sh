#/bin/ksh

TORCH_ROOT=/data/deep_learning/fs_transformers

typeset -a seeds=(1248)
typeset -a data_splits=(train val)
typeset -a datasets=()
typeset -a all_participants=()
typeset -a thresholds=(0 1)

function set_vars {
    base_dataset=$1
    # datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0 ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na_lininterp1)
    datasets=(${base_dataset}_drop-na_lininterp0)
    if [[ $1 == "supplemental_gen" ]]; then
        all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
    elif [[ $1 == "main_train" ]]; then
        all_participants=(bf49 7c12 711d 7abf 740f 580e 80fe f608 c82a 63a1 b16e e4fa e96d a362 c7d4 3d12 6e0d 9d2b bb26 812c c2fc 0bea 13e3 e9e5 c9de f9ea 7f32 51ee ca14 adfa 0d7b 1c64 46e0 9b23 4c3d 1f90 494d 4f1e 2ff7 fe96 e98b 259b 8f6f 3a6e 39e5 a442 2f35 9e67 b718 b7fc eac7 a3e7 f418 d230 0ba8 a6ed 39a6 e3c0 163a f760 92c6 851d c371 19d3 bf98 a72e d8ef 92b7 fc15 e2ca f709 ef07 1d72 03ad fb10 917d f066 ab12 51f5 d69c fbb7 bd21 8e3b 110f 675f d3ab 1bd5 196b bc24 1f86 ca00 c0df 1f91 2a7a)
    else
        echo "you can only pass supplemental_gen or main_train as the first arg for now. tbd add more datasets."
        exit 1
    fi
}

typeset -a seeds=(1248)
typeset -a data_splits=(train val)
typeset -a datasets=()
typeset -a all_participants=()

function set_vars {
    base_dataset=$1
    # datasets=(${base_dataset}_drop-na_lininterp0 ${base_dataset}_na-thr0.3_drop-na_lininterp0 ${base_dataset}_drop-na_lininterp1 ${base_dataset}_na-thr0.3_drop-na_lininterp1)
    datasets=(${base_dataset}_drop-na_lininterp0)
    if [[ $1 == "supplemental_gen" ]]; then
        # all_participants=(3f8b 13e3 494d b2d1 c0df d3ab 8e3b fe96 8c4d a3d4 3a6e 3d12 f9ea 2ff7 e0f7 ed8e 51f5 a362 a6ed 0ba8 812c 03ad a021 a442 1d72 711d a95b fa10 1bd5 6b92 5b63 bd21 1f91 917d fbb7 4ddc ab12 dbf9 99cb 39e5 4f1e 63a1 163a c82a f418 9d2b b718 39a6 4c3d 675f 9b23 9ed9 d478 f066 e3c0 fede 0a77 0bea d05c 9ff4 f760 7f32 80fe 19d3 6f68 a3e7 cf84 d69c 1f86 2f35 e4fa 5d33)
        all_participants=(6f68)
    elif [[ $1 == "main_train" ]]; then
        # all_participants=(bf49 7c12 711d 7abf 740f 580e 80fe f608 c82a 63a1 b16e e4fa e96d a362 c7d4 3d12 6e0d 9d2b bb26 812c c2fc 0bea 13e3 e9e5 c9de f9ea 7f32 51ee ca14 adfa 0d7b 1c64 46e0 9b23 4c3d 1f90 494d 4f1e 2ff7 fe96 e98b 259b 8f6f 3a6e 39e5 a442 2f35 9e67 b718 b7fc eac7 a3e7 f418 d230 0ba8 a6ed 39a6 e3c0 163a f760 92c6 851d c371 19d3 bf98 a72e d8ef 92b7 fc15 e2ca f709 ef07 1d72 03ad fb10 917d f066 ab12 51f5 d69c fbb7 bd21 8e3b 110f 675f d3ab 1bd5 196b bc24 1f86 ca00 c0df 1f91 2a7a)
        all_participants=(bf49)
    else
        echo "you can only pass supplemental_gen or main_train as the first arg for now. tbd add more datasets."
        exit 1
    fi
}

function get_seeded_random {
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}


function get_name_from_filename {
    name=""
    num_delims=$(($(eval echo "$1" | tr -cd '_' | wc -c) + 1))
    i=1
    
    while (( i <= $num_delims )); do
        name="$(cut -d'_' -f"$i" <<<"$1")"
        if [[ "$name" == "$2"* ]]; then
            break
        fi
        i=$(( i+1 ))
    done
    
    echo "$name"
}

