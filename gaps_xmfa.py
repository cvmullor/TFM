import sys
import re
import glob
import os

## Corregir xmfa

fxmfa = sys.argv[1] # archivo xmfa
outfile = "wgaps_" + fxmfa

# leer cabecera (#...)
with open(fxmfa, "r") as myf:
	lines = myf.readlines()
	lall = list(map(str.strip, lines))

# entrada:nombrearchivo
seqname_index = {} 
for entry in lall:
	heads = re.search("#Sequence..*File\t[a-zA-Z0-9.]*", entry)
	stop = re.search(">\s\d", entry)
	if heads:
		temp = heads.group(0).split("\t")
		name = temp[1]
		entry = re.search("\d\d*", temp[0])
		seqname_index[entry.group(0)] = name
	elif stop:
		break
nseq = len(seqname_index) # n de seqs en el aln

print(seqname_index) ##

# n de bloques
nblocks = lall.count("=")
print(nblocks, "blocks")

# leer xmfa, completar los archivos con bloques separados
block = 0
for line in lall:
	if "#" in line:
		with open(outfile, "a") as xmfa:
			xmfa.write(line + "\n")
	elif line == "=":
		block += 1
	elif ">" in line:
		blockfile = "block" + str(block) + ".fa"
		key = line[2]
		seqname = seqname_index[key]
		with open(blockfile, "a") as bkf:
			bkf.write("\n" + line + "\n")
	else:
		with open(blockfile, "a") as bkf:
			bkf.write(line)

# leer archivos .fa, añadir gaps, concatenar en nuevo xmfa
for fa in glob.glob("*.fa"):
	with open(fa, "r") as myf:
		lines = myf.readlines()
		lall2 = list(map(str.strip, lines[1:]))
	blength = len(lall2[1])
	conserved = []
	for line in lall2:
		if ">" in line:
			if line[3] == ":":
				conserved.append(line[2])
			else:
				conserved.append(line[2:4])
	if len(conserved) < nseq:
		for key in seqname_index.keys():
			if key not in conserved:
				#estructura cabecera ==> > 1:0-0 + a.fa
				header = "> " + key + ":0-0 + " + seqname_index[key]
				gaps = "-" * blength
				with open(fa, "a") as new:
					new.write("\n" + header + "\n" + gaps)
	with open(fa, "a") as new:
		new.write("\n=\n")
	with open(fa, "r") as myf:
		lines = myf.readlines()
		lall2 = list(map(str.strip, lines[1:]))
	with open(outfile, "a") as final:
		for line in lall2:
			final.write(line + "\n")

# eliminar archivos de bloques
for fa in glob.glob("*.fa"):
	os.remove(fa)

