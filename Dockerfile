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

RUN mamba install -c conda-forge bash_kernel nb_conda_kernels

# create scanpy_2021 conda environment with required python packages
COPY scanpy_2021.yaml /tmp
RUN mamba env create --file /tmp/scanpy_2021.yaml

COPY variant_calling.yml /tmp
RUN mamba env create --file /tmp/variant_calling.yml

COPY programming-R.yaml /tmp
RUN mamba env create --file /tmp/programming-R.yaml

COPY chipseq.yml /tmp
RUN mamba env create --file /tmp/chipseq.yml

COPY gwas.yml /tmp
RUN mamba env create --file /tmp/gwas.yml

COPY stats.yml /tmp
RUN mamba env create --file /tmp/stats.yml

COPY spatial-tx.yml /tmp
RUN mamba env create --file /tmp/spatial-tx.yml

RUN yes | unminimize || echo "done"

USER $NB_USER
