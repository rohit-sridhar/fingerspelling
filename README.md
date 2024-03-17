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

First check if a container is already launched, using `scripts/run_docker.sh ls`. If it is running, you can either open it by running `scripts/run_docker.sh run {CONTAINER_NAME}` or remove it by running `scripts/run_docker.sh rm {CONTAINER_NAME}`. If it isn't running, launch it by running `scripts/run_docker.sh launch {CONTAINER_NAME} {ROOT}`, where `{ROOT}` is the root directory mentioned in the first paragraph.

## Training the Model
Coming Soon
