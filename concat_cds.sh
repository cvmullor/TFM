#! /bin/bash

# Concatena cds del mismo genoma
# Input: alineamiento de cds (aln del mismo gen [mafft]) 
# Output: cds concatenados en una sola secuencia, alineamiento de core genome

spp=$1 # iniciales especie (e.g. Kp)

afile=$(ls *.aln.fna | head -n1)
ngenom=$(grep ">" $afile | wc -l)

cat *.aln.fna > all.temp

for ((i=1;i<=$ngenom;i++)); do
	grep -A1 "_$i$" all.temp | sed 's/^--$//g' | awk 'NF' | grep -v "^>" | 
	awk -v number="$i" 'BEGIN { ORS=""; print "\n>genome_"number"\n" } { print }' | 
	awk 'NF' >> $spp.core_aln.fa
done


rm all.temp

