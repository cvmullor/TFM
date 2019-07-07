#! /bin/bash

# nº SNPs
# Mismo dir que .flt.vcf.gz

ls *.flt.vcf.gz \
 | sed 's/.flt.vcf.gz//g' \
 | while read pass
 do
	bcftools stats $pass.flt.vcf | grep '^SN' | cut -f3- >> allstats.txt
done

ls *.flt.vcf.gz | sed 's/.flt.vcf.gz//g' > fltnames.txt
grep "SNPs:" allstats.txt | cut -f2- > nsnps.txt
paste fltnames.txt nsnps.txt > pass_snps.csv
	
rm allstats.txt fltnames.txt nsnps.txt
