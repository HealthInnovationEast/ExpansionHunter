#!/usr/bin/env Rscript

## for installation process
# BiocManager::install(c("GenomicAlignments"))
# # results in request for huge update of dependencies
# install.packages('argparser')

# Calculate the mean absolute purity (MAP) for every loci in a bam file
# MAP is defined as the average percentage of bases matching the reference across all reads that alignment to a repeat

# Folder contains sorted/index bamlets in genotypes subfolder with .vcf.gz and index

library(argparser, quietly=TRUE)
# create parser
p <- arg_parser("Incorporate MAP values from alignments into the VCF file")
# add args
p <- add_argument(p, 'variants', type="character", help = 'File containing EH variants')
p <- add_argument(p, 'bamfile', type="character", help = 'BAM File from EH')
p <- add_argument(p, 'vcffile', type="character", help = 'VCF file from EH')
p <- add_argument(p, 'multi_strs', type="character", help = 'Text file containing multi-str variants (not handled)')
p <- add_argument(p, 'folder', type="character", help = 'Path for intermediate files')
p <- add_argument(p, 'outdir', type="character", help = 'Path for final output file')
p <- add_argument(p, 'outfile', type="character", help = 'Name for final output file, probably Sample Name')
p <- add_argument(p, 'threads', type="integer", help = 'Max cpus/threads')
# Parse the command line arguments
argv <- parse_args(p)

variants <- argv$variants
bamfile <- argv$bamfile
vcffile <- argv$vcffile
multi_str <- argv$multi_strs
folder <- argv$folder
outdir <- argv$outdir
outfile <- argv$outfile
threads <- argv$threads

library(tidyr)
library(dplyr)
library(data.table)
library(stringr)
library('GenomicAlignments')
library(Rsamtools)

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
add_tag <- function(folder, sample,  MAP){
  #filepath <- paste0(folder, sample, ".vcf.gz")
  # Merge variants list with MAP scores
  df <- merge(read.table(variants, col.names= c('locus', 'CHROM', 'POS')),
              MAP, by='locus', all.x = T) %>%
              select(CHROM, POS, map) %>%
              replace(is.na(.), '.')
  # Create temp dir and write bcf annotation file to a temp directory
  system(paste0('mkdir -p ', folder, 'temp'))
  write.table(df, paste0(folder,'temp/temp.annot.tab'), sep='\t', quote=F, row.names = F, col.names = F)
  # Sort zip and index annotation file
  system(paste0('sort -V -k1,1 -k2,2 ', folder,'temp/temp.annot.tab >> ', folder,'temp/temp.sorted_annot.tab'))
  runbgzip(paste0('--threads ', threads, ' ', folder, 'temp/temp.sorted_annot.tab'))
  runtabix(paste0('-s1 -b2 -e2 ', folder, 'temp/temp.sorted_annot.tab.gz'))
  # Run bcftools to annotate the vcf with MAP values
  runbcftools(paste0('annotate --threads ', threads,  ' -a ', folder, 'temp/temp.sorted_annot.tab.gz -h ', folder, 'annot.hdr -c CHROM,POS,FMT/MAP ', vcffile, '.gz -Oz -o ', outdir, outfile, '.MAP.vcf.gz'))
  runtabix(paste0(outdir, outfile, '.MAP.vcf.gz'))
  system(paste0("rm ", folder, "temp/temp*"))
  }


# Write header line for annotation and store in inputs directory
write('##FORMAT=<ID=MAP,Number=1,Type=Float,Description="Mean Absolute Purity">', file=paste0(folder,'annot.hdr'), append=FALSE)

# This script takes the reads that overlap a locus with only one repeat
# and combines the CIGAR strings for all the reads overlapping that locus, saving the output in the temp directory
temp_file = paste0(folder, "temp_data.txt")
system(paste('map.sh', bamfile, multi_str, temp_file, threads))
MAP <- calc_map_vect(temp_file)
add_tag(folder, sample, MAP)
#Error checking script looks to see if the final annotated vcf has more than 1000 missing values or MAP values lower than 0.8.
print("starting error_check_map.sh")
system(paste('error_check_map.sh', paste0(outdir, outfile, '.MAP.vcf.gz')))
print("Done")
