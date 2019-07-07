#! /bin/bash

# Test de topología (ELW) de todos los aln's con todas las filogenias

trees=$1 # archivo .nwk con todos las filogenias

ls MSA*.fas | while read aln;
do
	nohup iqtree -s $aln -z $trees -m GTR -zb 10000 -zw &
done
