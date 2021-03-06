FROM python:3

RUN apt-get update && \
    apt-get -y install gcc mono-mcs && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && \
    pip install cython pysam && \
    pip3 install InSilicoSeq


RUN mkdir $HOME/bin
ENV PATH=$PATH:$HOME/bin

WORKDIR /root

#install the bareminimum and remove the cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-numpy \
    python3-scipy \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    zlib1g-dev \
    libbz2-dev \
    git \
    wget \
    libncurses5-dev \
    liblzma-dev \
    pkg-config \
    automake \
    autoconf \
    gcc \
    libglib2.0-dev \
    default-jre \
    samtools \
    bcftools \
    bwa \
    && rm -rf /var/lib/apt/lists/*


RUN wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz &&\
    tar -xvzf velvet_1.2.10.tgz && make -C velvet_1.2.10 &&\
    cp velvet_1.2.10/velvetg $HOME/bin && cp velvet_1.2.10/velveth $HOME/bin

RUN git clone https://github.com/adamewing/exonerate.git &&\
    cd exonerate &&\
    autoreconf -fi  &&\
    ./configure &&\
    make &&\
    make install

RUN git clone https://github.com/adamewing/bamsurgeon.git &&\
    export PATH=$PATH:$HOME/bin &&\
    cd bamsurgeon &&\
    python3 setup.py install

RUN mkdir build &&\
    apt-get update -qq &&\
    apt-get install -qq bzip2 gcc g++ make python zlib1g-dev

RUN git clone https://github.com/broadinstitute/picard.git && cd picard/ &&  ./gradlew shadowJar

RUN pip install biopython==1.77

RUN mkdir carsonella &&\
    mkdir scripts &&\
    mkdir results

RUN apt-get update && apt-get install nano mlocate && updatedb
    
COPY . /root

RUN gcc ./scripts/generate_mut.c -o ./scripts/generate_mut.exe && \
     gcc ./scripts/generate_pack.c -o ./scripts/generate_pack.exe &&\
     gcc ./scripts/apply_mut.c -o ./scripts/apply_mut.exe
     
RUN cp velvet_1.2.10/velvetg /bin && cp velvet_1.2.10/velveth /bin

#CMD chmod a+x scripts/* && ./scripts/test_surg_casc_mut.sh test1 test_ins1_ 3 i
