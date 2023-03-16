#!/bin/bash
set -e

mkdir -p test results
cd results
# commit hash as tagged v5.0.0 vcf has error in header (Integer instead of Float)
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/b22e63024b9fb6d481fc02f6a301dbbad74d503f/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam
echo -e 'ATXN7\nATXN8OS' > multi_str.txt
echo -e 'chr1_44835_44867 chr1 44835' > repeats.txt
echo -e 'chr1_151101_151105 chr1 151101' >> repeats.txt
echo -e 'chr1_165954_165962 chr1 165954' >> repeats.txt
cd ..
bgzip -c results/repeats.vcf > test/repeats.vcf.gz
tabix -p vcf test/repeats.vcf.gz
mapV3.r results/repeats.txt results/repeats_realigned.bam test/repeats.vcf results/multi_str.txt test/ test/ repeats 1

bgzip -cd test/repeats.MAP.vcf.gz > test/repeats.MAP.vcf
cat test/repeats.MAP.vcf
rm -r {test,results}
