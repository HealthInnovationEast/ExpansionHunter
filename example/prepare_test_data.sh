#!/bin/bash
set -uxe

TAG='v5.0.0'

# This script downloads the ExpansionHunter test data from:
# https://github.com/Illumina/ExpansionHunter/tree/${TAG}/example/input

mkdir -p test_data
cd test_data
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/reference.fa
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.bam
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.bam.bai
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.json

# build some extra indicies to prove multiple routes, the expansion hunter image works well for this
docker pull quay.io/wtsicgp/expansion_hunter:5.0.0

## adds csi index to files
docker run $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools index -c /d/variants.bam
## create cram input
docker run $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools view -T /d/reference.fa -C -o /d/variants.cram /d/variants.bam
docker run $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools index /d/variants.cram
