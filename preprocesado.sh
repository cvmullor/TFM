#! /bin/bash

# Procesado previo #

# Bucle FastQC
for file in *.fastq; do fastQC -f fastq $file; done

# Cutadapt
ls *.fastq* \
 | awk '{ if ($1 ~ /_R2/) {print $0"\n"} else {print $0" "}}' ORS="" \
 | while read fastqR1 fastqR2 
	do
		cutadapt -a file:adaptadores_BB.fasta -A file:adaptadores_BB.fasta -o $fastqR1.1.cut.fq -p $fastqR2.2.cut.fq $fastqR1 $fastqR2
	done

# Renombrar
rename 's/.fastq.cut.fq/.cut.fastq/g' *

# Prinseq (MTB: -min_len 30)
ls *.cut.fastq* \
 | awk '{ if ($1 ~ /R2/) {print $0"\n"} else {print $0" "}}' ORS="" \
 | while read fastqR1 fastqR2 
	do
		perl prinseq-lite.pl -fastq $fastqR1 -fastq2 $fastqR2 -min_len 50 -min_qual_mean 20 -ns_max_p 10 -trim_qual_right 20 2>>stats.txt
	done

# Guardar en carpeta archivos prinseq con singletons
mkdir singletons
mv *good*singletons* singletons/

# 2º Bucle FastQC (sobre las lecturas que han pasado filter/trimming)
for file in *_prinseq_good_*.fastq; do fastQC -f fastq $file; done
