#!/bin/ksh

## Saving LM Modeling commands here.
ROOT=lang_models

## Clean the lang_models/lm.all dir
rm -rf $ROOT/lm.all

# Init empty wordmap with Name header word_map
LNewMap word_map $ROOT/empty.wmap

# Make a new directory for intermediates
mkdir $ROOT/lm.all

# Collect n grams from sentence file
LGPrep -T 1 -d $ROOT/lm.all -n $1 -s "Fingerspelling All Sentences" $ROOT/empty.wmap grammar/sentences.txt

# Make lm.1 dir
# mkdir $ROOT/lm.1

# Bring together n grams (remove dupes).
# LGCopy -T 1 -d $ROOT/lm.1 $ROOT/lm.0/wmap $ROOT/lm.0/gram.*

# Make a new directory for intermediates
# mkdir $ROOT/lm_all

# Seems to do little but add OOV words
# LGCopy -T 1 -o -m $ROOT/lm_all/all.wmap -d $ROOT/lm_all/ -w commands/commands_word_isolated $ROOT/lm.0/wmap $ROOT/lm.1/data.*

# Get frequency counts
LFoF -T 1 -n $1 -f 64 $ROOT/lm.all/wmap $ROOT/lm.all/all.fof $ROOT/lm.all/gram.*

# Builds the language model
lm_file="ng$1_lm"
LBuild -T 1 -n $1 $ROOT/lm.all/wmap $ROOT/lm.all/$lm_file $ROOT/lm.all/gram.*

