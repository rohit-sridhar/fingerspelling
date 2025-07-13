#!/opt/conda/envs/fingerspelling/bin/python

import unittest

from utils import *

# class TestLabelUtils(unittest.TestCase):
    
    # ./label/supplemental_gen_drop-na_lininterp0/dim20/thr0/all/label/7787.lab
    # def test_collect_tokens(self):


class TestJSONUtils(unittest.TestCase):

    def test_load_json_file(self):
        data_file_dict = load_json_file(DATA_FILE_DICT_FILE)
        is_supplemental = data_file_dict["main_train_drop-na_lininterp0"]["supplemental"]
        supp_gen_path = data_file_dict["supplemental_gen_drop-na_lininterp0"]["data_path"]
        self.assertEqual(is_supplemental, False)
        self.assertEqual(supp_gen_path.startswith("./data/supplemental_gen_drop-na_lininterp0"), True)

        supp_char_idx = load_json_file(SUPP_CHAR_MAP_FILE)
        self.assertEqual(supp_char_idx['c'], 3)
        self.assertEqual(supp_char_idx['y'], 25)

if __name__ == "__main__":
    unittest.main()

