#!/bin/bash

rsync -rH --progress ./ContinuousBigram/commands/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/commands
rsync -rH --progress ./ContinuousBigram/dict/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/dict
rsync -rH --progress ./ContinuousBigram/grammar/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/grammar
rsync -rH --progress ./ContinuousBigram/mlf/ rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/mlf

rsync -rH --progress ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/all ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/train ./ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/data/supplemental/dl_cmp/dim20/thr0

rsync -rH --progress ./ContinuousBigram/label/supplemental/dl_cmp/thr0/all ./ContinuousBigram/label/supplemental/dl_cmp/thr0/train ./ContinuousBigram/label/supplemental/dl_cmp/thr0/val rsridhar37@login-phoenix.pace.gatech.edu:/storage/home/hcoda1/5/rsridhar37/p-ts133-0/ASL/fingerspelling/ContinuousBigram/label/supplemental/dl_cmp/thr0

