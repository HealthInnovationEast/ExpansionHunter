#!/bin/bash
set -uxe

TAG='v5.0.0'

# This script downloads the ExpansionHunter test data from:
# https://github.com/Illumina/ExpansionHunter/tree/${TAG}/example/output

mkdir -p results
cd results
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/output/repeats_realigned.bam

echo -e 'ATXN7\nATXN8OS' > results/multi_str.txt
echo -e 'chr1_44835_44867 chr1 44835\nchr1_151101_151105 chr1 151101\nchr1_165954_165962 chr1 165954' > results/repeats.txt
