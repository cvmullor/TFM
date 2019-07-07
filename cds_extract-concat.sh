#! /bin/bash

# Extraer y concatenar las CDS de las secuencias consenso obtenidas
# al mapear contra una misma referencia
# Alinear todas las consenso

strain=$1 # referencia (e.g. FA_1090)

R1="_R1"

## Referencia ##
# Posiciones de las secuencias codificantes (en archivo .gff)
pos=$(grep "CDS" gff/$strain.gff | awk '{print $4"-"$5","}' ORS='')

# Posiciones + pauta (+ ó -); archivo con nuevas cabeceras
grep "CDS" gff/$strain.gff | awk '{print ">"$4"-"$5"_"$7}' > newhead.$strain

## Consenso ##
ls cns/$strain/ \
 | sed "s/3.cns\/$strain\///g" \
 | awk -F "_R1" '{print $1}' \
 | while read sample;
 do 
	# Extraer esas secuencias en entradas separadas a partir de .fna (emboss)
	~/Documentos/softw/EMBOSS-6.6.0/emboss/extractseq --sequence cns/$strain/$sample$R1*.cns.fasta -reg $pos -separate -outseq cds.$sample.$strain.fas
	
	# Cambiar el nombre de las cabeceras
	# Alineamiento con secuencias en una sola línea
	awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  
		END {printf("\n");}' < cds.$sample.$strain.fas > cds.$sample.$strain.temp
	# Cambiar las cabeceras vacías por las de la lista
	sed '1{/^$/d}' cds.$sample.$strain.temp \
	 | awk 'NR%2==0' \
	 | paste -d'\n' newhead.$strain - > def.cds.$sample.$strain.fas

	rm cds.$sample.$strain.temp
	
	# Reversa complementaria en las CDS que lo requieren (llamar a script Python: mk_revcomp_v1.py)
	python3 mk_revcomp_v1.py def.cds.$sample.$strain.fas
	
	# Concatenar todas las CDS en 1 sola secuencia
	grep -v "^>" revcomp_def.cds.$sample.$strain.fas | awk -v head=$sample"."$strain 'BEGIN { ORS=""; print ">"head".CDS\n" } { print }' > finalcds.$sample.$strain.fasta

	# Remove
	rm cds.$sample.$strain.fas def.cds.$sample.$strain.fas revcomp_def.cds.$sample.$strain.fas
	
	# Añadir nueva línea
	echo -e "\n" >> finalcds.$sample.$strain.fasta
	
done

rm newhead.$strain

cat finalcds.* > finalcds_aln.$strain.fasta # alineamiento de todas las secuencias consenso contra misma ref.

mkdir cds.$strain
mv finalcds* cds.$strain


