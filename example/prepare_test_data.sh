#!/bin/bash
set -uxe

TAG='5.0.0'

# This script downloads the ExpansionHunter test data from:
# https://github.com/Illumina/ExpansionHunter/tree/${TAG}/example/input

mkdir -p test_data
cd test_data
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v${TAG}/example/input/reference.fa
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v${TAG}/example/input/variants.bam
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v${TAG}/example/input/variants.bam.bai
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v${TAG}/example/input/variants.json

# build some extra indicies to prove multiple routes, the expansion hunter image works well for this
docker pull quay.io/wtsicgp/expansion_hunter:5.0.0

## adds csi index to files
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:${TAG} samtools index -c /d/variants.bam
## create cram input
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:${TAG} samtools view -T /d/reference.fa -C -o /d/variants.cram /d/variants.bam
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:${TAG} samtools index /d/variants.cram

## now prepare expansion hunter inputs
# commit hash as tagged v5.0.0 vcf has error in header (Integer instead of Float)
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/b22e63024b9fb6d481fc02f6a301dbbad74d503f/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v${TAG}/example/output/repeats_realigned.bam
echo 'ATXN7\nATXN8OS' > multi_str.txt
echo -e 'ATXN7\nATXN8OS' > multi_str.txt
echo -e 'chr1_44835_44867\tchr1\t44835' > repeats.txt
echo -e 'chr1_151101_151105\tchr1\t151101' >> repeats.txt
echo -e 'chr1_165954_165962\tchr1\t165954' >> repeats.txt
