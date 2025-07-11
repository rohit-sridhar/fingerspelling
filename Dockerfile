FROM rohitsridhar91/asl_sign_recognizer:latest

WORKDIR /data/hmm_modeling/fingerspelling/ContinuousBigram

RUN mkdir /root/.tmp
RUN pip install dtw-python

RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB 
RUN apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
RUN sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'

ENV ACCEPT_EULA=Y

RUN apt-get update && apt-get upgrade -y && \
        apt-get install -y jq

CMD ["bash"]
