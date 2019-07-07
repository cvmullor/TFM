#! /bin/bash

# Llamada de variantes (SNPs) y obtener secuencias consenso

readsp=$1 # path/to/reads
bamdir=$2 # path/to/sorted.bam [end: "/"]

ls $readsp/*.fastq \
 | sed -e "s/$readsp\///g" \
 | sed 's/.fastq//g' \
 | awk '{ if ($1 ~ /R1/) {print} }' > sample_list.temp

# vcf - solo variantes
ls all_indexes/*.fna \
 | sed -e 's/all_indexes\///g' \
 | sed 's/.fna//g' \
 | while read reference;
 do
	cat sample_list.temp \
	 | while read sample;
	 do
		samtools mpileup -u -f all_indexes/$reference.fna $bamdir$sample.$reference.sorted.bam \
		 | bcftools call -vmO v --skip-variants indels -o $sample.$reference.raw.vcf
	 done
done

# Variant filtering
# Excluir = "QUAL<40 || DP<10 || MQ<30 || DP>2xavg", SNPs cerca de indels (<10 bp), llamadas heterozigotas
ls *.raw.vcf \
 | sed 's/.raw.vcf//g' \
 | while read raw
 do
	bcftools query -f '%DP\n' $raw.raw.vcf \
	 | awk -v filename=$raw '{ sum += $0; n++ } END { if (n > 0) print (sum / n) * 2" "filename; }' >> avg4script.txt
 done;

cat avg4script.txt \
 | while read average name
 do
	# -Oz: output comprimido .vcf
	bcftools filter -g 10 -e '%QUAL<40 || DP<10 || GT!="1/1" || MQ<30 || DP>'$average $name.raw.vcf -Oz -o $name.flt.vcf.gz
	bcftools index $name.flt.vcf.gz
 done;

rm avg4script.txt

# Consensus calling (bcftools consensus)
ls all_indexes/*.fna \
 | sed -e 's/all_indexes\///g' \
 | sed 's/.fna//g' \
 | while read reference;
 do
	cat sample_list.temp \
	 | while read sample;
	 do
		cat all_indexes/$reference.fna \
		 | bcftools consensus $sample.$reference.flt.vcf.gz > $sample.$reference.cns.fa
	 done
done
