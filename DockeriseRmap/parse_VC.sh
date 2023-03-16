#!/bin/bash
# script to create the files variants.txt and multi_str.txt
# input 1 should be bgzipped and tabixed vcf produced by expansionhunter
# input 2 should be the variant catalogue used to run expansionhunter

set -ue

bcftools query -f '%VARID %CHROM %POS\n' $1 > variants.txt
# bcftools query -f '%VARID %CHROM %POS\n' $1 | perl -ne '($a) = $_ =~ m/([^_]+:[0-9]+[-][0-9]+ [^ ]+ [0-9]+)$/; $a =~ s/[:-]/_/g; print qq{$a\n};' > variants.txt
jq -r '.[] | select(.LocusStructure | gsub("[^\\(]";"") | length >= 2) | .LocusId' $2 > multi_str.txt


# bcftools query -f '%VARID\t%CHROM\t%POS\n' work/97/77a595102a414fd14e877ddc6a7ff1/sorted.vcf.gz | perl -ane '$F[0] =~ m/([0-9]+)[-]([0-9]+)$/; print $F[1]."_".$1."_".$2.qq{\t$F[1]\t$1\n};'
