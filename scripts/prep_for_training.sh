#!/bin/bash

ln -s $1/logs $2/logs
ln -s $1/data $2/data
ln -s $1/label $2/label
ln -s $1/results $2/results
ln -s $1/commands $2/commands
ln -s $1/dict $2/dict
ln -s $1/grammar $2/grammar
ln -s $1/mlf $2/mlf

mkdir $2/ext
mkdir $2/models
mkdir $2/output
mkdir $2/trainsets
mkdir $2/testsets
touch $2/trainsets/training-extfiles0
touch $2/testsets/testing-extfiles0
cp -r $1/commands $2/
cp -r $1/dict $2/
cp -r $1/grammar $2/
cp -r $1/mlf $2/
