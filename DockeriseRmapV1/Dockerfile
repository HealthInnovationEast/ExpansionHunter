FROM rocker/r-base:4.2.2
RUN R -e "install.packages(c('tidyr', 'dplyr', 'data.table', 'stringr', 'Rsamtools', 'argparser', 'BiocManager'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(c('GenomicAlignments'))"
COPY /DockeriseRmapV1/mapV1.r /DockeriseRmapV1/mapV1.r
CMD R -e "source('/DockeriseRmapV1/mapV1.r')"
