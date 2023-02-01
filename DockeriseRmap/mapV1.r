#!/usr/bin/env Rscript

## for installation process
# BiocManager::install(c("GenomicAlignments"))
# # results in request for huge update of dependencies
# install.packages('argparser')

# Calculate the mean absolute purity (MAP) for every loci in a bam file
# MAP is defined as the average percentage of bases matching the reference across all reads that alignment to a repeat

library(argparser, quietly=TRUE)
# create parser
p <- arg_parser("Incorporate MAP values from alignments into the VCF file")
# add args
p <- add_argument(p, 'sample', type="character", help = 'Sample Name')
p <- add_argument(p, 'folder', type="character", help = 'Folder containing the EH outputs in a subdirectory called genotypes')
p <- add_argument(p, 'variants', type="character", help = 'File containing EH variants')
p <- add_argument(p, 'multi_strs', type="character", help = 'File containing multi-str variants (not handled)')
p <- add_argument(p, 'outfile', type="character", help = 'Path for final output file')
# Parse the command line arguments
argv <- parse_args(p)

sample <- argv$sample
folder <- argv$folder
variants <- argv$variants
multi_str_f <- argv$multi_strs
outfile <- argv$outfile

library(tidyr)
library(dplyr)
library(data.table)
library(stringr)
library('GenomicAlignments')
library(Rsamtools)

runbcftools <- function(BCFoptions = "") system(paste('bcftools',BCFoptions))
runtabix <- function(TABIXoptions = "") system(paste('tabix',TABIXoptions))
runbgzip <- function(BGZIPoptions = "") system(paste('bgzip',BGZIPoptions))
#Extract the cigar string from a list of split elements of a sequence graph cigar string

extract_cigar <- function(x) {
  return(paste0(x[seq(2, length(x), 2)], collapse = ""))
}

# Extract cigar strings for reads in the vicinity of STRs
# The input BAM file must be sorted and indexed
dfp <- function(folder, sample, multi_str_f){
  multi_str <- read.table(multi_str_f)[[1]] #List of multi-str loci to filter out. This function does not yet handle multi-repeat STRs
  path_bam <- paste0(folder,'genotypes/', sample, '_sorted.bam')
  bamFile <- BamFile(path_bam)
  params <- ScanBamParam(tag = 'XG') #Extract the XG tag from the BAM file
  bam_df <- scanBam(bamFile, param=params)
  bam_df <- data.table('tag' = bam_df[[1]][["tag"]][["XG"]]) %>%
    filter(str_count(tag, '\\[') > 1) %>% # Only keep reads that overlap the repeat
    separate(tag, into=c('locus', 'str_pos', 'graph_cigar'), sep=',') %>%
    select(locus, graph_cigar) %>%
    filter(!locus %in% multi_str) %>%
    mutate(split_cgar = stringr::str_split(graph_cigar, "\\[|\\]")) %>%
    select(locus, split_cgar)

  bam_df[, cigar := purrr::map(split_cgar, extract_cigar)]

  bam_df <- bam_df %>%
    select(locus, cigar)
  return(bam_df)
}

# Calculate MAP for each locus
calc_map_vect <- function(bam_df){
  loci <- unique(bam_df$locus) # Get loci names
  total_cigars <- tapply(bam_df$cigar, bam_df$locus, paste, sep='', collapse = '') # collapse all cigar strings together for each locus
  maps <- tapply(total_cigars, loci, function(x) cigarOpTable(x)[1]/sum(cigarOpTable(x))) # find percentage of bases matching the reference
  df <- data.frame(map=unname(maps), locus=names(maps))
  return(df)
}
# Add the MAP tag to the vcf file for each loci
# EH vcf files should be compressed amd indexed
add_tag <- function(folder, sample, variants, MAP){
  filepath <- paste0(folder, sample, ".vcf.gz")
  # Merge variants list with MAP scores
  df <- merge(read.table(variants, col.names= c('locus', 'CHROM', 'POS')),
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
  runbcftools(paste0('annotate -a ', folder, 'temp/temp.sorted_annot.tab.gz -h ', folder, 'inputs/annot.hdr -c CHROM,POS,FMT/MAP ', folder, 'genotypes/', sample, '.vcf.gz -Oz -o ', outfile, sample, '.MAP.vcf.gz'))
  }

# Folder contains sorted/index bamlets in genotypes subfolder with .vcf.gz and index

# Write header line for annotation
write('##FORMAT=<ID=MAP,Number=1,Type=Float,Description="Mean Absolute Purity">', paste0(folder,'inputs/annot.hdr'))

bam_df <- dfp(folder, sample, multi_str_f)
MAP <- calc_map_vect(bam_df)
add_tag(folder, sample, variants, MAP)
