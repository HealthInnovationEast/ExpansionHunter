FROM rocker/r-base:4.2.2
# Install packages
RUN R -e "install.packages(c('tidyr', 'dplyr', 'data.table', 'stringr', 'Rsamtools'),
                           dependencies=TRUE, 
                           repos='http://cran.rstudio.com/')"
RUN R -e "packageDescription('tidyr')$Version" / && sleep 5
                           