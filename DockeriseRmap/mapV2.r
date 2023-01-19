# Calculate the mean absolute purity (MAP) for every loci in a bam file
# MAP is defined as the average percentage of bases matching the reference across all reads that alignment to a repeat
#!/usr/bin/env Rscript

library(tidyr)
library(dplyr)
library(data.table)
library(stringr)
library('GenomicAlignments')
library(Rsamtools)
library(optigrab)
runbcftools <- function(BCFoptions = "") system(paste('bcftools',BCFoptions))
runtabix <- function(TABIXoptions = "") system(paste('tabix',TABIXoptions))
runbgzip <- function(BGZIPoptions = "") system(paste('bgzip',BGZIPoptions))

# Calculate MAP for each locus
calc_map_vect <- function(temp_file){
  bam_df <- read.table(temp_file, col.names=c("locus", "cigar"))
  loci <- unique(bam_df$locus) # Get loci names
  total_cigars <- tapply(bam_df$cigar, bam_df$locus, paste, sep='', collapse = '') # collapse all cigar strings together for each locus
  maps <- sapply(total_cigars, function(x) round(cigarOpTable(x)[1]/sum(cigarOpTable(x)), 4)) # find percentage of bases matching the reference
  df <- data.frame(map=unname(maps), locus=names(maps))
  return(df)
}

# Add the MAP tag to the vcf file for each loci
# EH vcf files should be compressed and indexed
add_tag <- function(folder, sample, MAP){
  filepath <- paste0(folder, sample, ".vcf.gz")
  # Merge variants list with MAP scores
  df <- merge(read.table(opt_get('variants'), col.names= c('locus', 'CHROM', 'POS')), 
              MAP, by='locus', all.x = T) %>% 
              select(CHROM, POS, map) %>%
              replace(is.na(.), '.')
  # Create temp dir and write bcf annotation file to a temp directory
  system(paste0('mkdir -p ', folder, 'temp'))
  write.table(df, paste0(folder,'temp/temp.annot.tab'), sep='\t', quote=F, row.names = F, col.names = F)
  # Sort zip and index annotation file
  system(paste0('sort -V -k1,1 -k2,2 ', folder,'temp/temp.annot.tab > temp/temp.sorted_annot.tab'))
  runbgzip(paste0(folder, 'temp/temp.sorted_annot.tab'))
  runtabix(paste0('-s1 -b2 -e2 ', folder, 'temp/temp.sorted_annot.tab.gz'))
  # Run bcftools to annotate the vcf with MAP values
  runbcftools(paste0('annotate -a ', folder, 'temp/temp.sorted_annot.tab.gz -h ', folder, 'inputs/annot.hdr -c CHROM,POS,FMT/MAP ', folder, 'genotypes/', sample, '.vcf.gz -Oz -o ', outdir, sample, '.MAP.vcf.gz'))
  runtabix(paste0(outdir, sample, '.MAP.vcf.gz'))
  system("rm temp/temp*")
  }

# Folder contains sorted/index bamlets in genotypes subfolder with .vcf.gz and index
folder <- opt_get('folder')
sample <- opt_get('sample')
multi_str <- opt_get('multi-strs')
# Write header line for annotation and store in inputs directory
write('##FORMAT=<ID=MAP,Number=1,Type=Float,Description="Mean Absolute Purity">', paste0(folder,'inputs/annot.hdr'))
outdir <- opt_get('out')
# This script takes the reads that overlap a locus with only one repeat 
# and combines the CIGAR strings for all the reads overlapping that locus, saving the output in the temp directory
system(paste('sh map.sh', folder, sample, multi_str))

MAP <- calc_map_vect('temp/temp_data.txt')
add_tag(folder, sample, MAP)
#Error checking script looks to see if the final annotated vcf has more than 1000 missing values or MAP values lower than 0.8.
system(paste('sh error_check_map.sh', paste0(outdir, sample, '.MAP.vcf.gz')))

