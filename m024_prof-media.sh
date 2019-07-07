#! /bin/bash

# Profundidad media
# Mismo directorio que .sorted.bam

ls -1 *.sorted.bam | sed 's/.sorted.bam//g' | while read bamfile;
do
	## Posiciones ref. con >0 lecturas mapeadas
	# n lecturas que mapean contra cada posición
	samtools depth -aa $bamfile.sorted.bam | awk '{ if ($3>0) {print $3} }' > $bamfile.nozero.temp
	# profundidad media
	awk -v filename=$bamfile.nozero.temp '{ sum += $0; n++ } END { if (n > 0) print (sum / n) * 2" "filename; }' $bamfile.depth.temp >> mcov_nozero.csv	
done

rm *.temp
