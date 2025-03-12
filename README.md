## Setting up

### benten Access:
* Login via shh (terminal):
```sh
ssh [gt_user]@benten.cc.gatech.edu
```
### Clone fingerspelling_torch repo

* Navigate into /home/[gt_user]
* Create a new directory 'hmm' for fingerspelling HMMs 
* Clone the fingerspelling repository in this directory (_You might need to generate a new Personal Access Token on GitHub for authentication purpose_):
```sh
git clone https://USERNAME:TOKEN@github.com/rohit-sridhar/fingerspelling.git
```

### Create a new Docker container

* Navigate into /fingerspelling/scripts
* Modify one of the "elif" conditions the run_docker script and add your own docker container name, for instance:
```sh
elif [ "$2" == "[container_name]" ]; then
    sudo docker run \
        -dit \
        -v "/data/hmm_modeling/fingerspelling:/data/hmm_modeling/fingerspelling" \
        -v "/home/[gt_user]/hmm/fingerspelling:/home/[gt_user]/hmm/fingerspelling" \
        -e HOSTNAME_SERVER="$HOSTNAME" \
        --name $2 rohitsridhar91/asl_sign_recognizer:$TAG
```
* Launch the container (with the path to your local root) using this command:
```sh
./run_docker.sh launch container_name /home/[gt_user]/hmm
```
* After launching the container, we can always start our docker container by running:
```sh
./run_docker.sh run container_name
```

### Training an HMM model
* Inside your docker container, navigate to fingerspelling/ContinuousBigram and run these commands:
```sh
mkdir ext
mkdir models
mkdir output
mkdir trainsets
mkdir testsets
mkdir logs
mkdir results
mkdir commands
mkdir dict
mkdir grammar
mkdir mlf
touch trainsets/training-extfiles0
touch testsets/testing-extfiles0
ln -s /data/hmm/fingerspelling/ContinuousBigram/data/ [YOUR_ABS_PATH]/ContinuousBigram/data
ln -s /data/hmm/fingerspelling/ContinuousBigram/label/ [YOUR_ABS_PATH]/ContinuousBigram/label
```
* Navigate back to fingerspelling/scripts and run the following command, which has an example of an existing data path:
```sh
./scripts/prepare_files.sh ./scripts/options.sh ./data/supplemental/dl_cmp/dim20/thr1/train/interpall2/pt254/sd4248/data/ ./label/supplemental/dl_cmp/thr1/train/pt254/sd4248/label/
```
* To train the model using the same data path, run:
```sh
python3 scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr4/train/interpall1/pt93/sd1248/data/ --label_files ./label/supplemental/dl_cmp/thr4/train/pt93/sd1248/label/
```
* The grid_search script will output the locations of the results and logs.

## Fixing Errors
### FlatCluster: Failed to make 4 clusters at iter 0 ERROR
* Reason: Too many Gaussian Mixture Models (GMMs) for the data
* Some basic information on hmmdefs:
    * hmmdefs are the HMM Definition Files
        - HMM Structure:
            - `<BeginHMM>` ... `<EndHMM>`: Marks the start and end of the HMM definition.
            - `<NumStates> 3`: Specifies that this HMM has **3 states** (state indices: 1, 2, 3).
            - `<VecSize> 20`: Defines the **feature vector dimension** (20 features per observation).
        - `HInit`  → Initializing an HMM in HTK
        - Algorithm tries to cluster data into several Gaussian models within each state
        - HMM Topologies:
            - Refers to the structure of an HMM defining:
                - `<NumStates>` : Number of states
                - `<NumMixes>` : Number of Gaussian Mixtures per state (We need more data to do this)
                - `<Mean>`, `<Variance>`
                - `<TransP>` : Transition Probabilities
* To fix the error, we have to change  `<NumMixes>` = 1. 
* The HMM Definition file to be changed can be found in fingerspelling/scripts/options.sh
