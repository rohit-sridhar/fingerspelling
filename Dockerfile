FROM rohitsridhar91/asl_sign_recognizer:latest

WORKDIR /data/hmm_modeling/fingerspelling/ContinuousBigram

RUN mkdir /root/.tmp

RUN pip install dtw-python
RUN pip install numpy pyarrow fastparquet
RUN pip install pytest

RUN apt-get install -y jq
RUN curl -fsSL https://gh.io/copilot-install | bash

CMD ["bash"]
