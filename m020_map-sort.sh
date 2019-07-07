#! /bin/bash

# Mapear, convertir a sam->bam, ordenar
# Lanzar script en nohup

readsp=$q # path/to/reads

ls $readsp*.fastq \
 | sed -e "s/$readsp\///g" \
 | sed 's/.fastq//g' \
 | awk '{ if ($1 ~ /R2/) {print $0"\n"} else {print $0" "}}' ORS="" \
 | while read fastqR1 fastqR2; # print "read.R1 read.R2"
do
	ls all_indexes/*.fna \
	 | sed -e 's/all_indexes\///g' \
	 | sed 's/.fna//g' \
	 | while read reference;
	do
		bwa mem -t 8 all_indexes/$reference.fna $readsp$fastqR1.fastq $readsp$fastqR2.fastq 2>nohup_bwa.out \
		 | samtools sort -@8 -o $fastqR1.$reference.sorted.bam - 2>nohup_sort.out
	done
done;

# + Indexar sorted.bam -> .sorted.bam.bai
ls *.sorted.bam \
 | while read srtfile;
do 
	samtools index $srtfile
done
