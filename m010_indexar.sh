#! /bin/bash

# Indexar todas las referencias

refsp=$1 # path/to/references(.fna) [end: "/"]; vacío: dir actual

# 1) Indexar todos los fna con BWA
mkdir all_indexes
ls $refsp*.fna | while read file;
do
	bwa index -a bwtsw $file
	samtools faidx $file
done

cp $refsp*.fna* all_indexes

