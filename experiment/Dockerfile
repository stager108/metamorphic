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

RUN mkdir -p /soft

RUN wget -q https://github.com/Illumina/manta/releases/download/v1.5.0/manta-1.5.0.centos6_x86_64.tar.bz2 -O manta-1.5.0.centos5_x86_64.tar.bz2 \
    && tar xjf manta-1.5.0.centos5_x86_64.tar.bz2  \
    && mv manta-1.5.0.centos6_x86_64 /soft \
    && wget -q https://github.com/Illumina/strelka/releases/download/v2.8.2/strelka-2.8.2.centos5_x86_64.tar.bz2  -O strelka-2.8.2.centos5_x86_64.tar.bz2 \
    && tar xjf strelka-2.8.2.centos5_x86_64.tar.bz2 \
    && mv strelka-2.8.2.centos5_x86_64 /soft 
    
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

RUN pip install sequenza-utils
RUN apt-get update && apt-get install -y r-base

RUN R -e " \
        r = getOption('repos'); \
        r['CRAN'] = 'http://cran.us.r-project.org'; \
        options(repos = r); \
        install.packages('devtools'); \
        library('devtools'); \
        install_github('aroneklund/copynumber'); \
        squash <- 'https://cran.r-project.org/src/contrib/Archive/squash/squash_1.0.8.tar.gz'; \
        install.packages(squash, repos=NULL, type='source'); \
        sequenza <- 'https://cran.r-project.org/src/contrib/Archive/sequenza/sequenza_2.1.2.tar.gz'; \
        install.packages(sequenza, repos=NULL, type='source'); \
        install.packages('dplyr'); \
        opt <- 'https://cran.r-project.org/src/contrib/getopt_1.20.3.tar.gz'; \
        install.packages(opt, repos=NULL, type='source'); \
        install.packages('testthat'); \
        install.packages('VennDiagram'); \
        install.packages('data.table'); \
        install.packages('R.utils'); \
        bedr <- 'https://cran.r-project.org/src/contrib/bedr_1.0.7.tar.gz'; \
        install.packages(bedr, repos=NULL, type='source'); "  
