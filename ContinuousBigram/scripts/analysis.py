#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
File: scripts/analysis.py
Author: Rohit Sridhar
Date: 01-07-2026
Last Modified: 
Version: X.X

Description:
    <Add Description>
"""

import argparse
import logging

from pathlib import Path
from utils import *

logger = logging.getLogger(__name__)
TS_PER_FRAME = 1000

def _parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "-mlf", "--master_label_file",
        type=Path,
        help="mlf file for anlaysis."
    )

    parser.add_argument(
        "-dbg", "--debug",
        action="store_true",
        help="run in verbose debug mode."
    )
    
    return parser.parse_args()

def analyze_mlf():
    char_frames = {}
    total_frames = []
    with open(args.master_label_file, "r") as f:
        char = None
        start = None
        end = None

        while (line := f.readline()):
            logger.debug(f"{line=}")
            if line[0] in ["#", ".", "\""]:
                if end is not None:
                    total_frames.append(end)
                    char = None
                    start = None
                    end = None
                continue

            start, end, char = line.strip().split(" ")
            start = int(start) / TS_PER_FRAME
            end = int(end) / TS_PER_FRAME

            if char not in char_frames:
                char_frames[char] = []
            char_frames[char].append(end - start)
    
    return char_frames, total_frames

def log_analysis(char_frames, total_frames):
    num_videos = len(total_frames)
    avg_frames = sum(total_frames) / num_videos

    logger.info(f"Total Videos: {num_videos}")
    logger.info(f"Avg Frames per Video: {avg_frames}")
    
    for char in sorted(char_frames.keys()):
        num_times = len(char_frames[char])
        avg_frames = sum(char_frames[char]) / num_times

        logger.info(f"{char} appears {num_times} times with a mean of {avg_frames} frames")

if __name__ == "__main__":
    args = _parse_args()

    log_parent = args.master_label_file.parent / "analysis" 
    log_parent.mkdir(parents=True, exist_ok=True)
    log_file =  log_parent / "mlf_letter.txt"

    out_handler = setup_logger(
        log_file,
        log_level=logging.DEBUG if args.debug else logging.INFO,
        mode="w"
    )
    logger.info(f"{args=}")
    char_frames, total_frames = analyze_mlf()
    log_analysis(char_frames, total_frames)

    root_logger.removeHandler(out_handler)
    out_handler.close()
