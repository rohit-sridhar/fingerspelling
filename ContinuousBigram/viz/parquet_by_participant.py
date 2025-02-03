import argparse
import os

import pandas as pd

from tqdm import tqdm

from constants import *

def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("--participant_id", type=int, default=2, help="Participant ID.")

    return parser.parse_args()

def process_pq_files(pq_files, seq_ids):
    all_data = []
    indices = []

    columns = None

    for pq_file in tqdm(pq_files):
        pq_file_path = os.path.join(SUPPLEMENTAL_LANDMARKS, pq_file)
        pq_data = pd.read_parquet(pq_file_path)
        
        pq_data = pq_data.loc[pq_data.index.isin(seq_ids)].reset_index()
        if columns is None:
            columns = pq_data.columns
        
        all_data.extend(pq_data.values.tolist())

    all_data = pd.DataFrame(all_data)
    all_data.columns = columns
    
    all_data = all_data.astype({"sequence_id" : int, "frame" : int})
    all_data = all_data.set_index("sequence_id")
    
    return all_data

if __name__ == "__main__":
    args = parse_args()
    print(args)

    metadata = pd.read_csv(SUPPLEMENTAL_METADATA)
    metadata = metadata[metadata.participant_id == args.participant_id]
    
    pq_files = os.listdir(SUPPLEMENTAL_LANDMARKS)
    seq_ids = set(metadata.sequence_id.tolist())
    all_data = process_pq_files(pq_files, seq_ids)
    
    pt_parquet = os.path.join(LOCAL_DATA, f"participant{args.participant_id}.parquet")
    all_data.to_parquet(pt_parquet)

    print(all_data)
    print(set(all_data.index.values.tolist()))

