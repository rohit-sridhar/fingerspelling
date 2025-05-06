FROM rohitsridhar91/asl_sign_recognizer:latest

WORKDIR /data/hmm_modeling/fingerspelling/ContinuousBigram

RUN mkdir /root/.tmp

CMD ["bash"]
