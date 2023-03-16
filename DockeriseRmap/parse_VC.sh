#!/bin/bash
# script to create the files variants.txt and multi_str.txt
# input 1 should be bgzipped and tabixed vcf produced by expansionhunter
# input 2 should be the variant catalogue used to run expansionhunter

set -ue

bcftools query -f '%VARID %CHROM %POS\n' $1 > variants.txt
jq -r '.[] | select(.LocusStructure | gsub("[^\\(]";"") | length >= 2) | .LocusId' $2 > multi_str.txt
