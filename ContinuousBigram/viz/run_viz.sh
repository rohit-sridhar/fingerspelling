#!/bin/bash

# declare -a pts=(03ad 0a77 0ba8 0bea 13e3 163a 1bd5 1f86 1f91 2f35 2ff7 39a6 39e5 3a6e 3d12 494d 4c3d 4ddc 51f5 5b63 5d33 675f 6b92 6f68 711d 7f32 80fe 812c 8c4d 8e3b 917d 99cb 9b23 9d2b 9ed9 9ff4 a021 a362 a3d4 a3e7 a442 a6ed a95b b2d1 b718 bd21 c82a d05c d478 d69c dbf9 e3c0 e4fa ed8e f066 f418 f9ea fbb7 fe96 fede)
declare -a pts=("03ad" "0a77" "0ba8" "0bea" "13e3") 
# declare -a supp_pts=("93" "227" "161" "254" "2")

# for pt in ${pts[@]};
# do
#     python visualize.py --parquet_file /data/deep_learning/ISLR-ML/mputils/out/landmarks/all_pt.parquet --metadata_file /data/deep_learning/ISLR-ML/mputils/out/metadata/all_pt.csv --pt_id $pt > output/all_pt/$pt.txt 2>&1 &
# done

for pt in ${supp_pts[@]};
do
    python visualize.py --parquet_file /data/deep_learning/ISLR-ML/mputils/out/landmarks/supplemental.parquet --metadata_file /data/parquet/asl-fingerspelling/supplemental_metadata.csv --pt_id $pt > output/supplemental/$pt.txt 2>&1 &
done

