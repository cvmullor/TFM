#! /bin/bash

# Bucle stats y flagstats
# Mismo directorio que los .sorted.bam

pref=$1

mkdir $pref.stats

ls -1 *.sorted.bam | sed 's/.sorted.bam//g' | while read bamfile;
do
	samtools flagstat $bamfile.sorted.bam >$bamfile.flagstats.txt
	samtools stats $bamfile.sorted.bam >$bamfile.stats.txt
done

mv *stats.txt $pref.stats
