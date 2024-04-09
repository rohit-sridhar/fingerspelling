#!/bin/ksh
find $2/* -type f | sort -V  > datafiles
rm -rf ext/data/
rm -f ext/done
mkdir ext/data/
cp -r $3/* ext/data/

OPTIONS_FILE=$1

scripts/gen_ext_files.sh $OPTIONS_FILE
find ext/data/*.ext -type f | xargs readlink -f | sort -V > all-extfiles

scripts/gen_mlf_split.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_letter
scripts/gen_mlf_word.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_word
scripts/gen_mlf_phrase.sh datafiles ext $OPTIONS_FILE > mlf/labels.mlf_phrase

HLEd -n commands/commands_tri_internal -i mlf/labels.mlf_tri_internal mktri_internal.led mlf/labels.mlf_letter
HLEd -n commands/commands_tri_cross -i mlf/labels.mlf_tri_cross mktri_cross.led mlf/labels.mlf_letter

python scripts/gen_tri_dict.py --label_loc $3/ --dict_type letter
python scripts/gen_tri_dict.py --label_loc $3/ --dict_type word
