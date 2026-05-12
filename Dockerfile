FROM rohitsridhar91/asl_sign_recognizer:latest

WORKDIR /data/hmm_modeling/fingerspelling/ContinuousBigram

RUN mkdir /root/.tmp

RUN pip install dtw-python
RUN pip install numpy pyarrow fastparquet

# RUN apt-get install --reinstall ca-certificates
# RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB 
# RUN apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
# RUN sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'
# RUN apt-get update --ignore-missing
# RUN apt-get upgrade --ignore-missing -y

RUN apt-get install -y jq

# ENV ACCEPT_EULA=Y

CMD ["bash"]
