FROM rocker/r-base:4.2.2

USER  root

RUN apt-get update -y && apt-get install -y libcurl4-openssl-dev samtools gawk tabix bcftools curl --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages(c('tidyr', 'dplyr', 'data.table', 'stringr', 'Rsamtools', 'argparser', 'BiocManager'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(c('GenomicAlignments'))"
COPY /DockeriseRmap/mapV3.r /mapV3.r
COPY /DockeriseRmap/map.sh /map.sh
COPY /DockeriseRmap/error_check_map.sh /error_check_map.sh

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

RUN mkdir /workdir
RUN chown ubuntu /workdir

# Add test run
RUN mkdir -p test \
     && mkdir -p results \
     && cd results \
     && curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats.vcf \
     && curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam \
     && echo 'ATXN7\nATXN8OS' > multi_str.txt \
     && echo 'chr1_44835_44867 chr1 44835\nchr1_151101_151105 chr1 151101\nchr1_165954_165962 chr1 165954' > repeats.txt \
     && cd .. \
     && bgzip -c results/repeats.vcf > test/repeats.vcf.gz \
     && tabix -p vcf test/repeats.vcf.gz \
     && touch test/annot.hdr \
     && Rscript mapV3.r results/repeats.txt results/repeats_realigned.bam test/repeats.vcf results/multi_str.txt test/ test/ repeats \
     && rm test/temp/* \
     && rm test/repeats2.MAP.vcf.gz \
     && rm results/*

USER ubuntu
WORKDIR /home/ubuntu



CMD ["/bin/bash"]
