#!/bin/ksh

## Saving LM Modeling commands here.
ROOT=lang_models

# Init empty wordmap with Name header word_map
LNewMap word_map $ROOT/empty.wmap

# Make a new directory for intermediates
mkdir $ROOT/lm.0

# Collect n grams from sentence file
LGPrep -T 1 -a 1000 -b 1000 -d $ROOT/lm.0 -n 4 -s "Fingerspelling Thr 8 Sentences" $ROOT/empty.wmap grammar/sentences.txt

# Make lm.1 dir
mkdir $ROOT/lm.1

# Bring together n grams (remove dupes).
LGCopy -T 1 -b 200000 -d $ROOT/lm.1 $ROOT/lm.0/wmap $ROOT/lm.0/gram.*

# Make a new directory for intermediates
mkdir $ROOT/lm_thr8

# Seems to do little but add OOV words
LGCopy -T 1 -o -m $ROOT/lm_thr8/thr8.wmap -b 200000 -d $ROOT/lm_thr8/ -w commands/commands_word_isolated $ROOT/lm.0/wmap $ROOT/lm.1/data.*

# Get frequency counts
LFoF -T 1 -n 4 -f 32 $ROOT/lm_thr8/thr8.wmap $ROOT/lm_thr8/thr8.fof $ROOT/lm.1/data.*

# Builds the language model
LBuild -T 1 -n 1 $ROOT/lm_thr8/thr8.wmap $ROOT/lm_thr8/ug $ROOT/lm.1/data.*


