#!/bin/ksh

OPTIONS_FILE=$1
. ${OPTIONS_FILE}

## Saving LM Modeling commands here.
NGRAM=$2

## Clean the lang_models/lm.all dir
rm -rf $LM_DIR/lm.$NGRAM

# Init empty wordmap with Name header word_map
LNewMap word_map $LM_DIR/empty.wmap

# Make a new directory for intermediates
mkdir $LM_DIR/lm.$NGRAM

# Collect n grams from sentence file
LGPrep -T 1 -d $LM_DIR/lm.$NGRAM -n $NGRAM -s "Fingerspelling All Sentences" $LM_DIR/empty.wmap grammar/sentences.txt

# Make lm.1 dir
# mkdir $LM_DIR/lm.1

# Bring together n grams (remove dupes).
# LGCopy -T 1 -d $LM_DIR/lm.1 $LM_DIR/lm.0/wmap $LM_DIR/lm.0/gram.*

# Make a new directory for intermediates
# mkdir $LM_DIR/lm_all

# Seems to do little but add OOV words
# LGCopy -T 1 -o -m $LM_DIR/lm_all/all.wmap -d $LM_DIR/lm_all/ -w $TOKENS_WORD_SKSP $LM_DIR/lm.0/wmap $LM_DIR/lm.1/data.*

# Get frequency counts
LFoF -T 1 -n $NGRAM -f 64 $LM_DIR/lm.$NGRAM/wmap $LM_DIR/lm.$NGRAM/all.fof $LM_DIR/lm.$NGRAM/gram.*

# Builds the language model
lm_file="ngram_lm"
LBuild -T 1 -n $NGRAM $LM_DIR/lm.$NGRAM/wmap $LM_DIR/lm.$NGRAM/$lm_file $LM_DIR/lm.$NGRAM/gram.*

