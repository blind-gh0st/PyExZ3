FROM debian:buster
RUN apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    apt update && \
    DEBIAN_FRONTEND='noninteractive' apt upgrade -qy && \
    DEBIAN_FRONTEND='noninteractive' apt install -qy --fix-missing git \
                                                     python3 \
                                                     graphviz \
                                                     graphviz-dev \
                                                     g++ \
                                                     make \
                                                     python3-examples \
                                                     libgmp-dev \
                                                     libboost-all-dev \
                                                     default-jdk \
                                                     swig \
                                                     python3-dev \
                                                     cmake \
                                                     python3-numpy \
                                                     python3-scipy \
                                                     python3-pip \
                                                     python3-sexpdata \
                                                     python3-coverage \
                                                     python3-cvxopt \
                                                     libatlas-base-dev \
                                                     wget \
                                                     gfortran && \
    pip3 install -U cvxpy && \
    git clone https://github.com/Z3Prover/z3.git --branch z3-4.8.7 /tmp/z3 && \
    git clone https://github.com/CVC4/CVC4.git --branch 1.7 /tmp/CVC4 && \
    git clone https://github.com/thomasjball/PyExZ3.git /PyExZ3
WORKDIR /tmp/z3
RUN python3 scripts/mk_make.py --python
WORKDIR /tmp/z3/build
RUN make && \
    make install
WORKDIR /tmp/CVC4
RUN ./contrib/get-antlr-3.4 && \
    export PYTHON_CONFIG=/usr/bin/python3-config && \
    ./configure.sh production \
                --portfolio \
                --optimized \
                --antlr-dir=/tmp/CVC4/antlr-3.4 \
                --language-bindings=python \
                --python3
WORKDIR /tmp/CVC4/build
RUN make && \
    make install
WORKDIR /
WORKDIR /PyExZ3
CMD ["python3","run_tests.py","test"]
