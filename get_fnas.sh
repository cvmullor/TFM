#! /bin/bash

# Descargar fnas (genoma completo) de FTP GenBank
# input: csv descargadas de ncbi genome con lista de genomas

ls *.csv | sed 's/.csv//g' | while read csvfile; do
	awk -F "," '{ if (NR != 1) {print $20} }' $csvfile.csv | sed 's/ *$//' > $csvfile.list.txt
done

ls *.csv | sed 's/.csv//g' | while read listfile; do
	mkdir $listfile.dir
	cat $listfile.list.txt | sed 's/\r$//' | while read link; do 
		wget $link/*.fna.gz
	done
	rm *from*
	gzip -d *.gz
	mv *.fna $listfile.dir
done
