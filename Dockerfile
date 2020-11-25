FROM ucsdets/datahub-base-notebook:2020.2-stable

USER root

# install linux packages
RUN apt-get update && \
    apt-get install tk-dev \
                    tcl-dev \
                    cmake \
                    wget \
                    default-jdk \
                    libbz2-dev \
                    -y

# build conda environment with required r packages & install RStudio into it
COPY r-bio.yaml /tmp
RUN conda env create --file /tmp/r-bio.yaml

ENV RSTUDIO_PKG=rstudio-server-1.2.5042-amd64.deb
ENV RSTUDIO_URL=https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_PKG}
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/envs/r-bio/bin/R/lib"
ENV SHELL=/bin/bash

RUN conda run -n r-bio /bin/bash -c "ln -s /opt/conda/bin/R /usr/bin/R && \
                                      apt-get update && \
                                      apt-get -qq install -y apt-utils gdebi-core dpkg-sig && \
                                      gpg --keyserver keys.gnupg.net --recv-keys 3F32EE77E331692F && \
                                      curl -L ${RSTUDIO_URL} > ${RSTUDIO_PKG} && \
                                      dpkg-sig --verify ${RSTUDIO_PKG} && \
                                      gdebi -n ${RSTUDIO_PKG} && \
                                      rm -f ${RSTUDIO_PKG} && \
                                      echo '/opt/conda/envs/r-bio/bin/R' > /etc/ld.so.conf.d/r.conf && /sbin/ldconfig -v && \
                                      apt-get clean && rm -rf /var/lib/apt/lists/* && \
                                      rm -f /usr/bin/R && \
                                      pip install jupyter-rsession-proxy && \
                                      mkdir -p /etc/rstudio && echo 'auth-minimum-user-id=100' >> /etc/rstudio/rserver.conf && \
                                      ( echo 'http_proxy=${http_proxy-http://web.ucsd.edu:3128}' ; echo 'https_proxy=${https_proxy-http://web.ucsd.edu:3128}' ) >> /opt/conda/envs/r-bio/bin/R/etc/Renviron.site && \
                                      ( echo 'LD_PRELOAD=/opt/k8s-support/lib/libnss_wrapper.so'; echo 'NSS_WRAPPER_PASSWD=/tmp/passwd.wrap'; echo 'NSS_WRAPPER_GROUP=/tmp/group.wrap' ) >> /opt/conda/envs/r-bio/bin/R/etc/Renviron.site && \
									  ipython kernel install --name=r-bio"

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

# set r-bio as default
COPY run_jupyter.sh /
RUN chmod +x /run_jupyter.sh

USER $NB_USER