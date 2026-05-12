# HMM Modeling for Fingerspelling
This directory contains HMM Modeling code for Fingerspelling. Instructions to train and test models are below.

The folder ContinuousBigram contains shell scripts and python scripts that prepare data and train models on the data. The data and labels are not provided in the repo, but it is expected that the user trains models on fingerspelling data. Support for silentspeller data is coming soon. You must pull a docker image and launch a container to use the scripts. 

## Basic Setup
The initial setup includes pulling the Docker image and using `scripts/run_docker.sh` to manage the containers. `scripts/run_docker.sh` is currently shared with other projects, so all local filepath references may not comport.

### Installing the Docker Image
Run the command below to pull the docker image:
`docker image pull rohitsridhar91/asl_sign_recognizer:v1.2`

### Using the run docker script
The run docker script (`scripts/run_docker.sh`) can list, remove, launch and run (existing) docker containers. The root folder of the folders to be mounted (see path variables a the top of the script) must be passed to the script. Not ever path in the script needs to be mounted. For this repo, only the filepaths corresponding to the fingerspelling container name need to be mounted.

`./scripts/run_docker.sh` takes at most four commands. The first option is the command to be run (`ls`, `run`, `launch`, or `rm`). The second option (not required for `ls`) specifies the container name.  The third option (not required for `ls`, `rm` or `run`) is the root directory mentioned in the previous paragraph andthe fourth option (not required at all) copies a file or folder into the root folder of the container.

First check if a container is already launched, using `scripts/run_docker.sh ls`. If it is running, you can either open it by running `scripts/run_docker.sh run {CONTAINER_NAME}` or remove it by running `scripts/run_docker.sh rm {CONTAINER_NAME}`. If it isn't running, launch it by running `scripts/run_docker.sh launch {CONTAINER_NAME} {PROJECTS_ROOT}`, where `{PROJECTS_ROOT}` is the root directory mentioned in the first paragraph.

## Training the Model
Coming Soon

## Quickstart
1. Build the local Docker image first:
   ./scripts/run_docker.sh build
   (This builds the LOCAL_HTK_IMAGE used by launch; set LOCAL_HTK_IMAGE to override.)

2. (Optional) Pull the base Docker image used for runtime:
   docker image pull rohitsridhar91/asl_sign_recognizer:v1.2

3. Launch the container (example):
   ./scripts/run_docker.sh launch my-fs-container /path/to/projects
   - Or set environment variables to override defaults, e.g.:
     LOCAL_HTK_IMAGE=rohit_hmm_fingerspelling CONTINUOUS_BIGRAM_PATH=/path/to/fingerspelling ./scripts/run_docker.sh launch my-fs-container /path/to/projects

## Important scripts
- scripts/run_docker.sh — manage and launch the Docker container. Usage: run_docker.sh <ls|run|launch|rm> [CONTAINER_NAME] [PROJECTS_ROOT]
- scripts/prep_for_training.sh — creates the ContinuousBigram directory skeleton; run with an optional root:
  ./scripts/prep_for_training.sh /path/to/projects
- scripts/pace.sh — sync data and label artifacts to a remote PACE host. Usage: pace.sh [PHOENIX_USER_HOST] [PHOENIX_FS_ROOT] [BASE_DATASET]

## Configuration
Scripts accept environment variables to avoid hard-coded paths. Key vars:
- LOCAL_HTK_IMAGE, PROJECTS_ROOT
- CONTINUOUS_BIGRAM_PATH, FS_TRANSFORMERS_PATH
- FINGERSPELLING_VIDEO_PATH, ISLR_MPUTILS_OUT_PATH
- VIMRC_FILE

## Notes
- Data and labels are not included in this repository.
- Avoid committing secrets or host-specific credentials. Use environment variables or a local config file outside the repo.
- Run shellcheck on shell scripts: shellcheck scripts/*.sh

## Contributing
See CONTRIBUTING.md for contribution guidelines and commit message requirements.
