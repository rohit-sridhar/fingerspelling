#!/bin/bash

python mediapipe_overlay.py -s /data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train/ -p /data/deep_learning/ISLR-ML/mputils/out/landmarks/supplemental_gen_nan_rng0.1_0.3.parquet -d overlay_videos/nan_rng0.1_0.3/
python mediapipe_overlay.py -s /data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train/ -p /data/deep_learning/ISLR-ML/mputils/out/landmarks/supplemental_gen_nan_rng0.3_0.5.parquet -d overlay_videos/nan_rng0.3_0.5/
python mediapipe_overlay.py -s /data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train/ -p /data/deep_learning/ISLR-ML/mputils/out/landmarks/supplemental_gen_nan_rng0.5_0.7.parquet -d overlay_videos/nan_rng0.5_0.7/
python mediapipe_overlay.py -s /data/sign_language_videos/fingerspelling_videos/dmk_v1/video_clips/dmk_v1-train/ -p /data/deep_learning/ISLR-ML/mputils/out/landmarks/supplemental_gen_nan_rng0.7_0.9.parquet -d overlay_videos/nan_rng0.7_0.9/
