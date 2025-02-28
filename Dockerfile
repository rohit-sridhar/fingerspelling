FROM rohitsridhar91/asl_sign_recognizer:latest

# Modify HCompV, HInit and HRest to increase label file string buffer size
RUN sed -i '430s/labfn\[80\]/labfn\[512\]/' /htk/HTKTools/HCompV.c
RUN sed -i '401s/labfn\[80\]/labfn\[512\]/' /htk/HTKTools/HInit.c
RUN sed -i '461s/labfn\[80\]/labfn\[512\]/' /htk/HTKTools/HRest.c

# Recompile HCompV, HInit and HRest
RUN cd /htk/HTKTools/ && make cleanup && make
RUN cp /htk/HTKTools/HCompV /htk/HTKTools/HInit /htk/HTKTools/HRest /usr/local/bin/

# Modify gt2k/utils/check_opts.sh.
# We don't need to check for TRAINING_DIR and TESTING_DIR anymore
RUN sed -i '243,249d' /gt2k/utils/check_opts.sh
RUN sed -i '237,242s/TRAINING_DIR/OUTPUTFILE_ROOT/' /gt2k/utils/check_opts.sh

WORKDIR /data/hmm_modeling/fingerspelling/ContinuousBigram

CMD ["bash"]

