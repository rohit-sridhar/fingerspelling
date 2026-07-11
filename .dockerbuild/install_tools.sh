#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -euo pipefail

# File: .dockerbuild/install-htk.sh
# Date: 24-06-2026
# Last Modified:

# Description
#   

# Install gt2k
cd /
tar -xzvf gt2k.tar.gz && rm -rf gt2k.tar.gz
# after unzipping, remove checks for TRAINING/TESTING_DIR in options.sh
sed -i "236,249d" /gt2k/utils/check_opts.sh
sed -i "76s/==/>=/g" /gt2k/utils/standalone_prepare.c
sed -i "145s/sizeof(bob)/sizeof(float)/g" /gt2k/utils/standalone_prepare.c
sed -i "53s/sampPeriod = 2000/sampPeriod = 1000/g" /gt2k/utils/standalone_prepare.c
cd /gt2k/utils
make

# Install HTK (Prep, Config and Make)
cd /
tar -xzvf HTK-3.4.1.tar.gz && rm -rf HTK-3.4.1.tar.gz
# this line uses 8 spaces instead of a tab (HTK bug)
sed -i "77s/^        /\t/g" /htk/HLMTools/Makefile.in
# make label file name buffers longer
sed -i "s/labfn\[80\]/labfn[256]/g" /htk/HTKTools/HCompV.c
sed -i "s/labfn\[80\]/labfn[256]/g" /htk/HTKTools/HInit.c
sed -i "s/labfn\[80\]/labfn[256]/g" /htk/HTKTools/HRest.c
sed -i "s/labfn\[80\]/labfn[256]/g" /htk/HTKTools/HQuant.c
cd /htk

sed -i "111s/-m32 /-m64 /g" configure.ac
autoconf
./configure
make all
make install

