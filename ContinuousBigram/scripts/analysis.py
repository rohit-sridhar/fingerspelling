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

def _parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        "-mlf", "--master_label_file",
        type=Path,
        help="mlf file for anlaysis."
    )
    
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    log_parent = args.master_label_file.parent / "analysis" 
    log_parent.mkdir(parents=True, exist_ok=True)
    log_file =  log_parent / "mlf_letter.txt"

    out_handler = setup_logger(
        log_file,
        log_level=logging.INFO,
        mode="w"
    )
    logger.info(f"{args=}")

    root_logger.removeHandler(out_handler)
    out_handler.close()
