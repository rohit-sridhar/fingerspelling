FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
WORKDIR /data/hmm_modeling/fingerspelling
RUN mkdir /root/.tmp

RUN dpkg --add-architecture i386
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y \
    build-essential gcc-multilib g++-multilib \
    jq vim autoconf gdb curl \
    libx11-dev:i386 libx11-dev libc6-dev-i386 libc6-dev
# RUN dpkg -i getlibs-all.deb
# RUN getlibs -p libx11-dev

COPY .dockerbuild/* /
RUN /install_tools.sh

# Install core prerequisites and add the deadsnakes PPA
RUN apt-get install -y --no-install-recommends \
    software-properties-common \
    gpg-agent \
    && add-apt-repository ppa:deadsnakes/ppa -y

# Install Python 3.8, pip, and development headers
RUN apt-get install -y --no-install-recommends \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install the correct pip version for Python 3.8
RUN curl -sS https://bootstrap.pypa.io/pip/3.8/get-pip.py | python3.8

# Set Python 3.8 as the default 'python' and 'python3' commands
RUN ln -sf /usr/bin/python3.8 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.8 /usr/bin/python \
    && ln -sf /usr/local/bin/pip3.8 /usr/bin/pip3 \
    && ln -sf /usr/local/bin/pip3.8 /usr/bin/pip

# Verify the installations
RUN python --version && pip --version

# Install python libraries
# RUN pip install dtw-python 
RUN pip install numpy pandas pyarrow fastparquet
RUN pip install tqdm pytest

# Install copilot
RUN curl -fsSL https://gh.io/copilot-install | bash

CMD ["bash"]
