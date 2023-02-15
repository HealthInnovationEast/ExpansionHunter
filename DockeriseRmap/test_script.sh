#!/bin/bash
set -e

cd /tmp
mkdir -p /tmp/test
mkdir -p /tmp/results
cd /tmp/results
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam
echo -e 'ATXN7\nATXN8OS' > multi_str.txt
echo -e 'chr1_44835_44867\tchr1\t44835' > repeats.txt
echo -e 'chr1_151101_151105\tchr1\t151101' >> repeats.txt
echo -e 'chr1_165954_165962\tchr1\t165954' >> repeats.txt
cd /tmp
bgzip -c /tmp/results/repeats.vcf > /tmp/test/repeats.vcf.gz
tabix -p vcf /tmp/test/repeats.vcf.gz
touch /tmp/test/annot.hdr
mapV3.r /tmp/results/repeats.txt /tmp/results/repeats_realigned.bam /tmp/test/repeats.vcf /tmp/results/multi_str.txt /tmp/test/ /tmp/test/ repeats

exit 1
rm /tmp/test/repeats.MAP.vcf.gz
rm -r /tmp/test
rm -r /tmp/results
