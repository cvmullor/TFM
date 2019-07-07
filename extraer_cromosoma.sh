#! /bin/bash

# Bucle extraer solo cromosoma bacteriano de .fna (seqtk subseq)
# todos los .fna de una carpeta

read -p "New folder: " chrfold
read -p "Genus: " genus
mkdir $chrfold

ls -1 *.fna | while read file;
do
grep "$genus" $file | grep -v "plasmid" | grep -v "extrachromosomal" | sed 's/>//g' > name.txt
cp $file "chr_"$file
seqtk subseq $file name.txt > "chr_$file" 
rm name.txt
done

mv chr_* $chrfold
