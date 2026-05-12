#!/usr/bin/env bash
set -euo pipefail

# Usage: run_docker.sh <ls|run|launch|rm> [CONTAINER_NAME] [PROJECTS_ROOT]
# Environment variables (optional): LOCAL_HTK_IMAGE, PROJECTS_PROJECTS_ROOT, FINGERSPELLING_PATH, FS_TRANSFORMERS_PATH, FINGERSPELLING_VIDEO_PATH, ISLR_MPUTILS_OUT_PATH, VIMRC_FILE

usage() {
    echo "Usage: $0 <ls|run|launch|rm> [CONTAINER_NAME] [PROJECTS_ROOT]"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

cmd="$1"
container="${2:-}"
PROJECTS_ROOT="${3:-${PROJECTS_ROOT:-/Users/rohitsridhar/Documents/projects}}"
LOCAL_HTK_IMAGE="${LOCAL_HTK_IMAGE:-rohit_hmm_fingerspelling}"

case "$cmd" in
  ls)
    docker ps -a --format '{{.Names}}\t{{.Status}}'
    ;;
  run)
    if [ -z "$container" ]; then
        echo "Specify container name for run"
        usage
    fi

    docker exec -it "$container" /bin/bash
    ;;
  launch)
    if [ -z "$container" ]; then
        echo "Specify container name when calling launch"
        usage
    fi

    fingerspelling_path="${FINGERSPELLING_PATH:-${PROJECTS_ROOT}/fingerspelling}"
    fs_transformers_path="${FS_TRANSFORMERS_PATH:-${PROJECTS_ROOT}/fs_transformers}"
    fingerspelling_video_path="${FINGERSPELLING_VIDEO_PATH:-${PROJECTS_ROOT}/sign_language_videos/fingerspelling_videos}"
    islr_mputils_out_path="${ISLR_MPUTILS_OUT_PATH:-${PROJECTS_ROOT}/ISLR-ML/mputils/out}"
    vimrc_file="${VIMRC_FILE:-${HOME}/.vimrc}"

    docker run -it --rm \
      --platform linux/arm64 \
      -v "${fingerspelling_path}":"/data/hmm_modeling/fingerspelling" \
      -v "${fs_transformers_path}":"/data/deep_learning/fs_transformers" \
      -v "${fingerspelling_video_path}":"/data/sign_language_videos/fingerspelling_videos:ro" \
      -v "${islr_mputils_out_path}":"/data/deep_learning/ISLR-ML/mputils:ro" \
      -v "${vimrc_file}":"/root/.vimrc:ro" \
      -e HOSTNAME_SERVER="$HOSTNAME" \
      --name "$container" "$LOCAL_HTK_IMAGE"
    ;;
  rm)
    if [ -z "$container" ]; then
        echo "Specify container name for rm"
        usage
    fi

    docker rm -f "$container"
    ;;
  *)
    usage
    ;;
esac

