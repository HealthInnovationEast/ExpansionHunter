FROM rocker/r-base:4.2.2

USER  root

RUN apt-get update -y && apt-get install -y libcurl4-openssl-dev samtools gawk tabix bcftools curl --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages(c('tidyr', 'dplyr', 'data.table', 'stringr', 'Rsamtools', 'argparser', 'BiocManager'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(c('GenomicAlignments'))"
COPY /DockeriseRmap/mapV3.r /mapV3.r
COPY /DockeriseRmap/map.sh /map.sh
COPY /DockeriseRmap/error_check_map.sh /error_check_map.sh
COPY /DockeriseRmap/test_script.sh /test_script.sh

RUN /test_script.sh

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

RUN mkdir /workdir
RUN chown ubuntu /workdir

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
