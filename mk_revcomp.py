import sys
import Bio
from Bio.Seq import Seq

cds = sys.argv[1]
outfile = "revcomp_" + cds

# Leer archivo
with open(cds, "r") as myf:
	lines = myf.readlines()
	lall = list(map(str.strip, lines))

final_mfa = []
rev = False
# Reversa complementaria si se indica
for line in lall:
	if line[0] == ">":
		if line[-1] == "+":
			rev = False
		elif line[-1] == "-":
			rev = True
		final_mfa.append(line)
	else:
		if rev == False:
			final_mfa.append(line)
		elif rev == True:
			seq = Seq(line)
			rc = str(seq.reverse_complement())
			final_mfa.append(rc)

with open (outfile, "a") as outf:
	for line in final_mfa:
		outf.write(line + "\n")

			
			
