#!/bin/bash

# ./scripts/prepare_files.sh ./scripts/options.sh ./data/supplemental/dl_cmp/dim20/thr2/train/dup8/data/ ./label/supplemental/dl_cmp/thr2/train/label/
# python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr2/train/dup8/data/ --label_files ./label/supplemental/dl_cmp/thr2/train/label/
# mv models/hmm0.* saved_models/dl_cmp_dup8

./scripts/prepare_files.sh ./scripts/options.sh ./data/supplemental/dl_cmp/dim20/thr2/train/dupall8/data/ ./label/supplemental/dl_cmp/thr2/train/label/
python scripts/grid_search.py --data_files ./data/supplemental/dl_cmp/dim20/thr2/train/dupall8/data/ --label_files ./label/supplemental/dl_cmp/thr2/train/label/
mv models/hmm0.* saved_models/dl_cmp_dupall8

