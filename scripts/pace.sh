#!/bin/bash

##### Copy HTK Files over
# rsync -H --progress ./ContinuousBigram/commands/commands_tri_internal.all rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands

#### Copy all train and val data
dataset="supplemental_gen"

# rsync -rHR --progress ./ContinuousBigram/data/$dataset/dim20/thr0/./train/pt03ad ./ContinuousBigram/data/$dataset/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/label/$dataset/dim20/thr0/./train/pt03ad ./ContinuousBigram/label/$dataset/dim20/thr0/./val/pt03ad rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/data/$dataset/dim20/thr0/./train/pt3f8b ./ContinuousBigram/data/$dataset/dim20/thr0/./val/pt3f8b rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/label/$dataset/dim20/thr0/./train/pt3f8b ./ContinuousBigram/label/$dataset/dim20/thr0/./val/pt3f8b rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dim20/thr0/

# rsync -rHR --progress ./ContinuousBigram/data/$dataset/dim20/thr0/./train ./ContinuousBigram/data/$dataset/dim20/thr0/./val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/$dataset/dim20/thr0/

rsync -rHR --progress ./ContinuousBigram/label/$dataset/dim20/thr0/./train ./ContinuousBigram/label/$dataset/dim20/thr0/./val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/$dataset/dim20/thr0/
