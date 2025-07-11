#/bin/ksh

TORCH_ROOT=/data/deep_learning/fingerspelling_torch

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

