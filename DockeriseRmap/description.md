# Running the docker image and using it to run the rscript

## Running the docker image

Run with:
`docker run --rm -v /workspaces/ExpansionHunter/results:/results:ro -v /workspaces/ExpansionHunter/results:/results2:rw -ti <Image ID>`

where results is the location of the current data (will be mentioned in A, C, D and E)

## Running the rscript in the docker container

`cd ../..`
`bgzip -c results/repeats.vcf > workdir/repeats.vcf.gz`
`tabix -p vcf workdir/repeats.vcf.gz`
`touch workdir/annot.hdr`
`Rscript mapV3.r results/repeats.txt results/repeats_realigned.bam workdir/repeats.vcf results/multi_str.txt workdir/ results2/ repeats`

Considering the above code in terms of parameters gives:
cd ../..
bgzip -c $A > $A\*.gz
tabix -p vcf $A\*.gz
touch $B/annot.hdr
Rscript mapV3.r $C $D $A\* $E $B $F $G

$A - VCF file with path - results/repeats.vcf
$A\* - VCF file but with workdir path - workdir/repeats.vcf
$B - folder for intermediates - workdir/
$C - variants details list text file with path (example from J) - results/repeats.txt
$D - BAM file with path - results/repeats_realigned.bam
$E - text file with list of exclusions with path- results/multi_str.txt
$F - outdir -  results2/
$G - root string for output - repeats

## Alternative example parameterisation

Seperating the folder names

docker run --rm -v /workspaces/ExpansionHunter/$X:/$X:ro -v /workspaces/ExpansionHunter/$X:/$Y:rw -ti \<Image ID>

cd ../..
bgzip -c $X/$A > $W/$A.gz
tabix -p vcf $W/$A.gz
touch $W/annot.hdr
Rscript mapV3.r $X/$C $X/$D $W/$A $X/$E $W $Y $G

### Files

$A - VCF file - repeats.vcf
$C - variants details list text file with path (example from J) - repeats.txt
$D - BAM file with path - repeats_realigned.bam
$E - text file with list of exclusions with path - multi_str.txt

$G - root string for output - repeats

### Folders

$W - folder for intermediates - workdir
$X - folder with inputs - results
$Y - outdir -  results2
