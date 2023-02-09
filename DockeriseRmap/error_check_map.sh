#!/bin/sh
lowmap=$(bcftools query -f '[\t%MAP]\n' $1 | awk '$1 < 0.8 {print $0}' | wc -l)
if [ "$lowmap" -gt 1000 ]; then
    echo "Warning: More than 1000 low MAP values (<0.8) or missing values found in $1"
fi
