FROM ucsdets/datahub-base-notebook:2020.2-stable

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
                    

# build conda environment with required r packages
COPY r-bio.yaml /tmp
RUN conda env create --file /tmp/r-bio.yaml

ENV RSTUDIO_PKG=rstudio-server-1.2.5042-amd64.deb
ENV RSTUDIO_URL=https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_PKG}
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/envs/r-bio/bin/R/lib"
ENV SHELL=/bin/bash
ENV R_LIB_SITE=/opt/conda/envs/r-bio/lib/R/library

# linux hack to remove paths to default R
RUN rm -rf /opt/conda/bin/R /opt/conda/lib/R && \
    ln -s /opt/conda/envs/r-bio/bin/R /opt/conda/bin/R

# create py-bio conda environment with required python packages
COPY py-bio.yaml /tmp
RUN conda env create --file /tmp/py-bio.yaml && \
    conda run -n py-bio /bin/bash -c "ipython kernel install --name=py-bio"

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

RUN conda install -c conda-forge bash_kernel

# create scanpy_2021 conda environment with required python packages
COPY scanpy_2021.yaml /tmp
RUN conda env create --file /tmp/scanpy_2021.yaml && \
    conda run -n scanpy_2021 /bin/bash -c "ipython kernel install --name=scanpy_2021"

COPY spatial-tx.yml /tmp
RUN conda env create --file /tmp/spatial-tx.yml && \
    conda run -n spatial-tx /bin/bash -c "ipython kernel install --name=spatial-tx"
    
COPY variant_calling.yml /tmp
RUN conda env create --file /tmp/variant_calling.yml && \
    conda run -n variant_calling /bin/bash -c "ipython kernel install --name=variant_calling"

RUN yes | unminimize || echo "done"

RUN apt-get install tree -y

USER $NB_USER
