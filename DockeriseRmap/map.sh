#!/bin/bash
set -ue
set -o pipefail
samtools view $1 | awk '{gsub(/XG:Z:/,"",$12); print $12}'| awk '{if(gsub(/\[/,"[")>1) print}' | awk -F "," -v "a=($(<$2))" '!(index(a,$1)) {print $1, $3}' | awk '{$2=gensub(/[^[]*\[([^\]]+)\]/,"\\1", "g", $2);print $1, $2}' > $3
