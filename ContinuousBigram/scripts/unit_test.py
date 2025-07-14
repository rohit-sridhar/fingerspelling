#!/opt/conda/envs/fingerspelling/bin/python

import unittest

from utils import *

class TestLabelUtils(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestLabelUtils, self).__init__(*args, **kwargs)
        self.lab_path_1 = "./label/unit_test/label/7787.lab"
        self.lab_path_2 = "./label/unit_test/label/8980.lab"
        self.lab_path_3 = "./label/unit_test/label/5662.lab"
        self.lab_path_4 = "./label/unit_test/label/6650.lab"
        
        self.labs_1 = ['that', 'agreement', 'is', 'rife', 'with', 'problems']
        self.labs_2 = ['a', 'problem', 'with', 'the', 'engine']
        self.labs_3 = ['i', 'like', 'baroque', 'and', 'classical', 'music']
        self.labs_4 = ['that']
    
    def test_collect_tokens(self):
        ret_val_1 = collect_tokens(self.lab_path_1)
        ret_val_2 = collect_tokens(self.lab_path_2)
        ret_val_3 = collect_tokens(self.lab_path_3)
        ret_val_4 = collect_tokens(self.lab_path_4)
        
        self.assertEqual(ret_val_1, self.labs_1)
        self.assertEqual(ret_val_2, self.labs_2)
        self.assertEqual(ret_val_3, self.labs_3)
        self.assertEqual(ret_val_4, self.labs_4)

class TestJSONUtils(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestJSONUtils, self).__init__(*args, **kwargs)
        self.main_ds = "main_train_drop-na_lininterp0"
        self.supp_ds = "supplemental_gen_drop-na_lininterp0"
        self.supp_gen_path = f"./data/{self.supp_ds}"

    def test_load_json_file(self):
        data_file_dict = load_json_file(DATA_FILE_DICT_FILE)
        is_supplemental = data_file_dict[self.main_ds]["supplemental"]
        supp_gen_path = data_file_dict[self.supp_ds]["data_path"]
        self.assertEqual(is_supplemental, False)
        self.assertEqual(supp_gen_path.startswith(self.supp_gen_path), True)

        supp_char_idx = load_json_file(SUPP_CHAR_MAP_FILE)
        self.assertEqual(supp_char_idx['c'], 3)
        self.assertEqual(supp_char_idx['y'], 25)

if __name__ == "__main__":
    unittest.main()

