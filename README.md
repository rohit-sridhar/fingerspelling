# HMM Modeling for Fingerspelling
This directory contains HMM Modeling code for Fingerspelling. Instructions to train and test models are below.

The folder ContinuousBigram contains shell scripts and python scripts that prepare data and train models on the data. The data and labels are not provided in the repo, but it is expected that the user trains models on fingerspelling data. Support for silentspeller data is coming soon. You must pull a docker image to use the scripts in the models.

## Basic Setup
The initial setup includes pulling the Docker image and using `scripts/run_docker.sh` to manage the containers. `scripts/run_docker.sh` is currently shared with other projects, so all local filepath references may not comport.

### Installing the Docker Image
Run the command below to pull the docker image:
`docker image pull rohitsridhar91/asl_sign_recognizer:v1.2`

### Using the run docker script

