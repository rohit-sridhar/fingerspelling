#!/usr/bin/env python3

from pathlib import Path
import sys
import os
from types import SimpleNamespace

# Ensure scripts package is importable
SCRIPT_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import gen_dict as gd
from utils import SPACE, ENTER, EXIT


def test_split_list_by_delim():
    lst = ['a', '_', 'b', 'c', '_', 'd']
    out = gd.split_list_by_delim(lst, '_')
    assert out == [['a'], ['b', 'c'], ['d']]


def test_write_uniletter_dict(tmp_path):
    # prepare args and dict location
    dict_file = tmp_path / "dict.txt"
    gd.args = SimpleNamespace(dict_loc=str(dict_file), dict_type='letter')

    letters = ['a', 'c31', 'c32', 'b', SPACE, ENTER, EXIT, 'z', 'd1']
    gd.write_uniletter_dict(letters)

    content = dict_file.read_text().splitlines()
    # should have written a, b, z but not SPACE/ENTER/EXIT
    assert 'a a' in content
    assert 'b b' in content
    assert 'z z' in content
    assert 'c31 c31' in content
    assert 'c32 c32' in content
    assert 'd1 d1' in content
    assert not any(START in line for line in content for START in (SPACE, ENTER, EXIT))

    # Also test passing a list of single-character letters (common upstream shape)
    dict_file2 = tmp_path / "dict2.txt"
    gd.args.dict_loc = str(dict_file2)
    letters2 = ['x', 'y', 'z', 'x1', SPACE, ENTER]
    gd.write_uniletter_dict(letters2)
    content2 = dict_file2.read_text().splitlines()
    assert 'x x' in content2 and 'y y' in content2 and 'z z' in content2
    assert 'x1 x1' in content2


def test_add_triletters_to_dict(tmp_path):
    dict_file = tmp_path / "dict_tri.txt"
    gd.args = SimpleNamespace(dict_loc=str(dict_file), dict_type='cross_letter')

    # single-letter case (string)
    gd.add_triletters_to_dict('x')
    # multi-letter case (string)
    gd.add_triletters_to_dict('abc')
    # multi-letter case (list of tokens with numeric suffixes)
    gd.add_triletters_to_dict(['a', 'b1', 'c'])
    # multi-letter case (list with numeric tokens)
    gd.add_triletters_to_dict(['d1', 'e', 'f2'])
    # multi-word letters list with SPACE delimiting words and numeric tokens
    multi_letters = ['a1', 'b', SPACE, 'c2']
    gd.add_triletters_to_dict(multi_letters)

    lines = dict_file.read_text().splitlines()
    # single-letter should result in 'x x'
    assert 'x x' in lines
    # for 'abc' expect first, middle, last entries (string case)
    assert 'a a+b' in lines
    assert 'b a-b+c' in lines
    assert 'c b-c' in lines
    # for ['a','b1','c'] expect first, middle, last entries (list with numeric)
    assert 'a a+b1' in lines
    assert 'b1 a-b1+c' in lines
    assert 'c b1-c' in lines
    # for ['d1','e','f2'] expect similar entries
    assert 'd1 d1+e' in lines
    assert 'e d1-e+f2' in lines
    assert 'f2 e-f2' in lines
    # for multi_letters list expect triletter entries that include SPACE token and numeric tokens
    assert 'a1 a1+b' in lines
    assert 'b a1-b+_' in lines
    assert '_ b-_+c2' in lines
    assert 'c2 _-c2' in lines


def test_add_uniletter_word_to_dict(tmp_path):
    dict_file = tmp_path / "dict_uniletter_word.txt"
    gd.args = SimpleNamespace(dict_loc=str(dict_file), dict_type='word')

    gd.add_uniletter_word_to_dict('hi')
    # also pass as list of letters
    gd.add_uniletter_word_to_dict(['h', 'e', 'l', 'l', 'o'])
    # list with numeric tokens
    gd.add_uniletter_word_to_dict(['c1', 'd2'])

    content = dict_file.read_text().splitlines()
    # 'hi' -> spaced 'h i', written as 'hi h i'
    assert 'hi h i' in content
    # list version should produce same line
    assert 'hello h e l l o' in content
    # numeric tokens produce combined word and spaced tokens
    assert 'c1d2 c1 d2' in content


def test_add_triletter_word_to_dict_and_sksp(tmp_path):
    dict_file = tmp_path / "dict_word.txt"
    gd.args = SimpleNamespace(dict_loc=str(dict_file), dict_type='tri_word')

    # normal tri_word (string)
    gd.add_triletter_word_to_dict('abc', sksp=False)
    # normal tri_word (list with numeric token)
    gd.add_triletter_word_to_dict(['d1', 'e', 'f'], sksp=False)
    # tri_word_sksp (list)
    gd.add_triletter_word_to_dict(['a1', 'b'], sksp=True)
    # tri_word_sksp (list with numeric)
    gd.add_triletter_word_to_dict(['x2', 'y'], sksp=True)

    lines = dict_file.read_text().splitlines()
    # for 'abc' should include the full entry starting with the word (string case)
    assert any(line.startswith('abc ') for line in lines)
    # for ['d1','e','f'] (list) should include an entry starting with 'd1ef '
    assert any(line.startswith('d1ef ') for line in lines)
    # for sksp cases, at least one line should end with SPACE token
    assert any(line.endswith(SPACE) for line in lines)


def test_add_cross_word_to_dict_variants(tmp_path):
    dict_file = tmp_path / "dict_cross.txt"
    gd.args = SimpleNamespace(dict_loc=str(dict_file), dict_type='cross_word')

    # first=True,last=True (single word phrase) - string
    gd.add_cross_word_to_dict('ab', first=True, last=True)
    # not first, not last - string
    gd.add_cross_word_to_dict('ab', first=False, last=False)
    # variants using lists (including numeric tokens)
    gd.add_cross_word_to_dict(list('gh'), first=True, last=True)
    gd.add_cross_word_to_dict(['i1', 'j2'], first=False, last=False)
    gd.add_cross_word_to_dict(['g1','h2'], first=True, last=True)

    lines = dict_file.read_text().splitlines()
    # first=True,last=True: normal entries
    assert any(line.startswith('ab ') for line in lines)
    assert any(line.startswith('gh ') for line in lines)
    assert any(line.startswith('g1h2 ') for line in lines)
    # not first/not last: entries should include SPACE prefixed/suffixed tokens
    assert any(SPACE + '-' in line or '+' + SPACE in line for line in lines)


def test_ingest_label_file_dispatch(monkeypatch, tmp_path):
    # prepare args
    gd.args = SimpleNamespace(dict_loc=str(tmp_path / "dict_dispatch.txt"), dict_type='tri_word')

    # stub collect_letters_and_tokens to return letters containing a SPACE delimiter
    # letters is a flat list of characters where SPACE denotes token boundary
    letters = ['a1', 'b', SPACE, 'c2', 'd']
    def fake_collect(path):
        return letters, ['a1b', 'c2d']

    monkeypatch.setattr(gd, 'collect_letters_and_tokens', fake_collect)

    # monkeypatch helper functions to record calls
    called = { 'uniletter':0, 'triletter':0, 'uniletter_word':0, 'word':0, 'cross':0 }

    def fake_write_uniletter(letters_arg):
        called['uniletter'] += 1

    def fake_add_triletters(arg):
        called['triletter'] += 1

    def fake_add_uniletter_word(arg):
        called['uniletter_word'] += 1

    def fake_add_word(arg, sksp=False):
        called['word'] += 1

    def fake_add_cross(arg, first=False, last=False):
        called['cross'] += 1

    monkeypatch.setattr(gd, 'write_uniletter_dict', fake_write_uniletter)
    monkeypatch.setattr(gd, 'add_triletters_to_dict', fake_add_triletters)
    monkeypatch.setattr(gd, 'add_uniletter_word_to_dict', fake_add_uniletter_word)
    monkeypatch.setattr(gd, 'add_triletter_word_to_dict', fake_add_word)
    monkeypatch.setattr(gd, 'add_cross_word_to_dict', fake_add_cross)

    # call ingest_label_file which should, for tri_word type, call add_triletter_word_to_dict twice
    gd.ingest_label_file(str(tmp_path / "labels.lab"))
    assert called['word'] == 2

    # change to letter type
    gd.args.dict_type = 'letter'
    gd.ingest_label_file(str(tmp_path / "labels.lab"))
    assert called['uniletter'] == 1

    # change to cross_letter
    gd.args.dict_type = 'cross_letter'
    gd.ingest_label_file(str(tmp_path / "labels.lab"))
    assert called['triletter'] == 1

    # change to cross_word
    gd.args.dict_type = 'cross_word'
    gd.ingest_label_file(str(tmp_path / "labels.lab"))
    # since tokens length is 2, cross called twice (first and last variations)
    assert called['cross'] >= 1
