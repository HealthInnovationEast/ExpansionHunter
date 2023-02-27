FROM rocker/r-base:4.2.2

USER  root

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
       libcurl4-openssl-dev samtools gawk tabix bcftools curl procps \
       r-cran-tidyr r-cran-dplyr r-cran-data.table r-cran-stringr r-bioc-rsamtools r-cran-argparser r-bioc-genomicalignments \
    && rm -rf /var/lib/apt/lists/*

ENV OPT /opt/cynapse-ccri
ENV PATH $OPT/bin:$PATH
RUN mkdir -p $OPT/bin

COPY /DockeriseRmap/mapV3.r /DockeriseRmap/*.sh $OPT/bin/
RUN chmod ugo+x $OPT/bin/*

RUN cd /tmp && test_script.sh

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

RUN mkdir /workdir
RUN chown ubuntu /workdir

USER ubuntu
WORKDIR /home/ubuntu

ENV OPT /opt/cynapse-ccri
ENV PATH $OPT/bin:$PATH

CMD ["/bin/bash"]
