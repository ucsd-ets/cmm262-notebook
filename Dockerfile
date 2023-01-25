FROM ucsdets/datahub-base-notebook:2023.1-stable

USER root

RUN sed -i 's:^path-exclude=/usr/share/man:#path-exclude=/usr/share/man:' \
        /etc/dpkg/dpkg.cfg.d/excludes

# install linux packages
RUN apt-get update && \
    apt-get install tk-dev \
                    tcl-dev \
                    cmake \
                    wget \
                    default-jdk \
                    libbz2-dev \
                    apt-utils \
                    gdebi-core \
                    dpkg-sig \
                    man \
                    man-db \
                    manpages-posix \
                    tree \
                    -y

# STAR
RUN wget https://github.com/alexdobin/STAR/archive/2.5.2b.zip -P /tmp && \
    unzip /tmp/2.5.2b.zip && \
    mv STAR-* /opt/ && \
    rm -rf /tmp/*.zip

# FastQC
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip -P /tmp && \
    unzip /tmp/fastqc_v0.11.5.zip && \
    mv FastQC /opt/ && \
    chmod 755 /opt/FastQC/fastqc && \
    rm -rf /tmp/fastqc_*

RUN mamba install -c conda-forge bash_kernel nb_conda_kernels

# build conda environment with required r packages
COPY r-bio.yaml /tmp
RUN mamba env create --file /tmp/r-bio.yaml

# linux hack to remove paths to default R
RUN rm -rf /opt/conda/bin/R /opt/conda/lib/R && \
    ln -s /opt/conda/envs/r-bio/bin/R /opt/conda/bin/R

# # create py-bio conda environment with required python packages
COPY py-bio.yaml /tmp
RUN mamba env create --file /tmp/py-bio.yaml

# create scanpy_2021 conda environment with required python packages
COPY scanpy_2021.yaml /tmp
RUN mamba env create --file /tmp/scanpy_2021.yaml

COPY spatial-tx.yml /tmp
RUN mamba env create --file /tmp/spatial-tx.yml
    
COPY variant_calling.yml /tmp
RUN mamba env create --file /tmp/variant_calling.yml

COPY programming-R.yaml /tmp
RUN mamba env create --file /tmp/programming-R.yaml

COPY chipseq.yml /tmp
RUN mamba env create --file /tmp/chipseq.yml

RUN yes | unminimize || echo "done"

USER $NB_USER
