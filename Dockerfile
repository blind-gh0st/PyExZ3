FROM debian:buster AS z3
WORKDIR /tmp/z3
RUN DEBIAN_FRONTEND='noninteractive' apt-get update -qy && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -qy \
        git \
        python3 \
        g++ \
        cmake \
        python3-distutils \
        python3-examples && \
        git clone http://github.com/Z3Prover/z3.git --branch z3-4.8.7 /tmp/z3 && \
    python3 /tmp/z3/scripts/mk_make.py --python && \
    cd build && \
    make && \
    cd / && \
    tar -cvJf /z3-archive.tar.xz \
        /tmp/z3/*

FROM debian:buster AS pyexz3
COPY --from=z3 /z3-archive.tar.xz /z3-archive.tar.xz
RUN DEBIAN_FRONTEND='noninteractive' apt-get update -qy && \
    DEBIAN_FRONTEND='noninteractive' apt-get install -qy \
        git \
        python3 \
        graphviz \
        graphviz-dev \
        python3-numpy \
        python3-scipy \
        python3-pip \
        python3-sexpdata \
        python3-coverage \
        python3-cvxopt \
        libatlas-base-dev \
        cmake \
        gfortran && \
    pip3 install -U cvxpy && \
    mkdir -p /tmp/z3 && \
    tar -xvf /z3-archive.tar.xz -C / && \
    cd /tmp/z3/build && \
    make install && \
    useradd -m -s /bin/bash pyexz3 && \
    git clone https://github.com/thomasjball/PyExZ3.git /home/pyexz3/PyExZ3 && \
    chown -R pyexz3:pyexz3 /home/pyexz3/PyExZ3 && \
    apt-get remove --purge -qy \
        git && \
    apt-get autoremove -qy && \
    cd / && \
    rm -rf /tmp/z3 z3-archive.tar.xz && \
    sed -i.bak '1s;^;#!/usr/bin/env python3\n;' /home/pyexz3/PyExZ3/pyexz3.py && \
    chmod +x /home/pyexz3/PyExZ3/pyexz3.py && \
    echo 'export PATH=$PATH:/home/pyexz3/PyExZ3' | tee -a /home/pyexz3/.bashrc
USER pyexz3
WORKDIR /home/pyexz3/PyExZ3
CMD ["python3","run_tests.py","test"]