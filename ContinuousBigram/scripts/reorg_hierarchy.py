import os
import subprocess
import shutil

from glob import glob

GR_PATH_IDX = -2

def get_mv_pairs(filelist):
    pairs = []
    for filepath in filelist:
        split_path = filepath.split(os.path.sep)
        
        filename = split_path[-1]
        new_filename = get_new_filename(filename, split_path[GR_PATH_IDX])

        new_split_path = split_path[:GR_PATH_IDX] + [new_filename]
        new_filepath = os.path.sep.join(new_split_path)
        
        pairs.append((filepath, new_filepath))
    return pairs

def get_new_filename(filename, grammar_type):
    if filename.startswith('output.'):
        split_name = filename.split('_')
    elif filename.startswith('hresults.'):
        ct = filename.count('_') - 1
        split_name = filename.rsplit('_', ct)
    
    split_name.insert(1, grammar_type)
    return '_'.join(split_name)

def verify_pairs(pairs):
    orig = set()
    new = set()

    for pair in pairs:
        orig.add(pair[0])
        new.add(pair[0])

    print(f"Orig: {len(orig)}")
    print(f"New: {len(new)}")

def move_pairs(pairs):
    for pair in pairs:
        # print(pair)
        subprocess.run(["mv", pair[0], pair[1]])

def delete_dirs(dir_list):
    for dir_file in dir_list:
        os.rmdir(dir_file)

def verify_data(data_files):
    ct_dict = sort_and_count(data_files)
    verify_data_dirs(ct_dict)
    return ct_dict

def sort_and_count(data_files):
    ct_dict = {}

    for data_file in data_files:
        split_path = data_file.split(os.path.sep)

        main_key = '_'.join(split_path[2:4])
        gr_key = split_path[4]

        if main_key not in ct_dict:
            ct_dict[main_key] = {}
        
        if gr_key not in ct_dict[main_key]:
            ct_dict[main_key][gr_key] = []

        ct_dict[main_key][gr_key].append(split_path[-1])
    
    return ct_dict

def verify_data_dirs(data_dict):
    for main_key in data_dict:
        gr_keys = sorted(list(data_dict[main_key].keys()))
        prev_set = set(data_dict[main_key][gr_keys[0]])
        
        for gr_key in gr_keys[1:]:
            curr_set = set(data_dict[main_key][gr_key])
            if curr_set != prev_set:
                raise ValueError("datasets not in sync")
            
            prev_set = curr_set
            
def move_data(data_dict):
    for main_key in data_dict:
        gr_keys = list(data_dict[main_key].keys())
        gr_key = gr_keys[0]
        
        split_path = ['.','data']
        split_path.extend(main_key.split('_'))
        new_split_path = split_path.copy()
        split_path_rm = split_path.copy()

        split_path.extend([gr_key, 'data'])
        new_split_path.extend(['data'])
        
        data_path = os.path.sep.join(split_path)
        new_data_path = os.path.sep.join(new_split_path)
        
        if not os.path.exists(new_data_path):
            os.makedirs(new_data_path)

        for data_file in data_dict[main_key][gr_key]:
            old_data = os.path.sep.join([data_path, data_file])
            new_data = os.path.sep.join([new_data_path, data_file])
            subprocess.run(["mv", old_data, new_data])
        
        os.rmdir(data_path)
        for gr_key in gr_keys[1:]:
            grammar_dir = os.path.sep.join(split_path_rm + [gr_key, 'data'])
            shutil.rmtree(grammar_dir)
            

if __name__ == "__main__":
    # results_files = glob("./results/*/*/*/hresults.*")
    # log_files = glob("./logs/*/*/*/output.*")
    # 
    # result_file_pairs = get_mv_pairs(results_files)
    # log_file_pairs = get_mv_pairs(log_files)
    # 
    # verify_pairs(result_file_pairs)
    # verify_pairs(log_file_pairs)
    # 
    # move_pairs(result_file_pairs)
    # move_pairs(log_file_pairs)
    #  
    # result_grammar_dirs = glob("./results/*/*/gr*")
    # log_grammar_dirs = glob("./logs/*/*/gr*")
    # 
    # delete_dirs(result_grammar_dirs)
    # delete_dirs(log_grammar_dirs)
    
    data_files = glob("./data/*/*/*/data/*")
    ct_dict = verify_data(data_files)
    move_data(ct_dict)

