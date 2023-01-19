FROM rocker/r-base:4.2.2
RUN R -e "install.packages(c('tidyr', 'dplyr', 'data.table', 'stringr', 'Rsamtools', 'argparser', 'BiocManager'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN apt-get update -y && apt-get install -y libcurl4-openssl-dev
RUN R -e "BiocManager::install(c('GenomicAlignments'))"
COPY /DockeriseRmap/mapV3.r /DockeriseRmap/mapV3.r
RUN Rscript DockeriseRmap/mapV3.r results/repeats.vcf results/repeats_realigned.bam results/multi_str.txt results/ work/ repeats
