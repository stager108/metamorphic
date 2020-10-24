FROM python:3

RUN apt-get update
RUN apt-get update && \
    apt-get -y install gcc mono-mcs && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install cython pysam

RUN pip3 install InSilicoSeq

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


RUN mkdir $HOME/bin

RUN wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz && tar -xvzf velvet_1.2.10.tgz
RUN make -C velvet_1.2.10
RUN cp velvet_1.2.10/velvetg $HOME/bin && cp velvet_1.2.10/velveth $HOME/bin

RUN git clone https://github.com/adamewing/exonerate.git
RUN cd exonerate && autoreconf -fi  && ./configure && make && make install

RUN pip install cython && pip install pysam

RUN git clone https://github.com/adamewing/bamsurgeon.git
RUN export PATH=$PATH:$HOME/bin && cd bamsurgeon && python3 setup.py install

RUN mkdir build
RUN apt-get update -qq
RUN apt-get install -qq bzip2 gcc g++ make python zlib1g-dev

RUN git clone https://github.com/broadinstitute/picard.git && cd picard/ &&  ./gradlew shadowJar

RUN mkdir -p /soft

RUN wget -q https://github.com/Illumina/manta/releases/download/v1.5.0/manta-1.5.0.centos6_x86_64.tar.bz2 -O manta-1.5.0.centos5_x86_64.tar.bz2 \
    && tar xjf manta-1.5.0.centos5_x86_64.tar.bz2  \
    && mv manta-1.5.0.centos6_x86_64 /soft \
    && wget -q https://github.com/Illumina/strelka/releases/download/v2.8.2/strelka-2.8.2.centos5_x86_64.tar.bz2  -O strelka-2.8.2.centos5_x86_64.tar.bz2 \
    && tar xjf strelka-2.8.2.centos5_x86_64.tar.bz2 \
    && mv strelka-2.8.2.centos5_x86_64 /soft 

RUN pip install biopython==1.77

RUN apt-get update
RUN apt-get install nano
RUN apt-get install mlocate
RUN updatedb

RUN rm *.tar.bz2 *.tgz

RUN mkdir carsonella
RUN mkdir scripts
RUN mkdir results
COPY carsonella_rudii carsonella
COPY scripts scripts
RUN gcc ./scripts/generate_mut.c -o ./scripts/generate_mut.exe
RUN gcc ./scripts/generate_config.c -o ./scripts/generate_config.exe
RUN gcc ./scripts/generate_pack.c -o ./scripts/generate_pack.exe
