#!/bin/sh
set -e

cd /tmp
mkdir -p /tmp/test
mkdir -p /tmp/results
cd /tmp/results
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam
echo 'ATXN7\nATXN8OS' > multi_str.txt
echo 'chr1_44835_44867 chr1 44835\nchr1_151101_151105 chr1 151101\nchr1_165954_165962 chr1 165954' > repeats.txt
cd /tmp
bgzip -c /tmp/results/repeats.vcf > /tmp/test/repeats.vcf.gz
tabix -p vcf /tmp/test/repeats.vcf.gz
touch /tmp/test/annot.hdr
mapV3.r /tmp/results/repeats.txt /tmp/results/repeats_realigned.bam /tmp/test/repeats.vcf /tmp/results/multi_str.txt /tmp/test/ /tmp/test/ repeats
rm /tmp/test/repeats.MAP.vcf.gz
rm -r /tmp/test
rm -r /tmp/results
