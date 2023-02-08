#!/bin/sh
mkdir -p test
mkdir -p results
cd results
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam
echo 'ATXN7\nATXN8OS' > multi_str.txt
echo 'chr1_44835_44867 chr1 44835\nchr1_151101_151105 chr1 151101\nchr1_165954_165962 chr1 165954' > repeats.txt
cd ..
bgzip -c results/repeats.vcf > test/repeats.vcf.gz
tabix -p vcf test/repeats.vcf.gz
touch test/annot.hdr
Rscript mapV3.r results/repeats.txt results/repeats_realigned.bam test/repeats.vcf results/multi_str.txt test/ test/ repeats
rm test/repeats2.MAP.vcf.gz
rm -r test
rm -r results
