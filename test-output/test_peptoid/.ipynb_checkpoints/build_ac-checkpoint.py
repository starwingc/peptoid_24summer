#!/usr/bin/env python

import os, sys

### This script uses tleap from AmberTools 
### to build pdb for all trp-cage sequences

tleap_bin = '/Users/starwingchen/anaconda3/envs/AmberTools20/'

# The letter codes for caps are:
#
#    symbol    cap
#    ------    --------
#       +      N-terminal is free amine (NH3+)
#       -      C-terminal is free carboxylate (COO-)
#       <      C-terminal is NH2   (NHE residue in AMBER)
#       >      N-terminal is ACE

sequences = {} 

sequences['06AA1-9-A'] = '<NNNNNNNNN>'

olc2tlc = {'A':'ALA', 'C':'CYS', 'D':'ASP', 'E':'GLU', 'F':'PHE', 'G':'GLY', 'H':'HIS', 'I':'ILE',
           'K':'LYS', 'L':'LEU', 'M':'MET', 'N':'NSP', 'P':'PRO', 'Q':'GLN', 'R':'ARG', 'S':'SER',
           'T':'THR', 'V':'VAL', 'W':'TRP', 'Y':'TYR',
           '+A':'NALA', '+C':'NCYS', '+D':'NASP', '+E':'NGLU', '+F':'NPHE', '+G':'NGLY', '+H':'NHIS', '+I':'NILE',
           '+K':'NLYS', '+L':'NLEU', '+M':'NMET', '+N':'NNSP', '+P':'NPRO', '+Q':'NGLN', '+R':'NARG', '+S':'NSER',
           '+T':'NTHR', '+V':'NVAL', '+W':'NTRP', '+Y':'NTYR',
           'A-':'CALA', 'C-':'CCYS', 'D-':'CASP', 'E-':'CGLU', 'F-':'CPHE', 'G-':'CGLY', 'H-':'CHIS', 'I-':'CILE',
           'K-':'CLYS', 'L-':'CLEU', 'M-':'CMET', 'N-':'CNSP', 'P-':'CPRO', 'Q-':'CGLN', 'R-':'CARG', 'S-':'CSER',
           'T-':'CTHR', 'V-':'CVAL', 'W-':'CTRP', 'Y-':'CTYR',
           '>':'ACE', '<':'NHE' }

###############################
# build all the peptides

for key in sequences.keys():
    s = sequences[key]

    ###  parse the one-letter-code to three-letter
    ### issue with lines 61-65 gives the folowwing error message Traceback (most recent call last):
    ###  File "build.py", line 57, in <module>
    ###      three_letter_sequence = [ olc2tlc[ s[0:2] ] ]
    ###      KeyError: '£S'


    # FIRST, let's translate the single string into a list of codes
    # the single string is confusing, because a two-character '+S' is NSER e.g. while '>S' is { ACE SER ...}

    olc_list = []

    i = 0  # position in the string 
    while i < (len(s)-1):

        #print('Scanning s[i =', i, "] = ", s[i])
        if s[i] == '+':
            olc_list.append(s[i:i+2])
            i += 2
        elif s[i+1] == '-':
            #print('adding', s[i:i+2])
            olc_list.append(s[i:i+2])
            i += 2
        else:
            olc_list.append(s[i])
            i += 1
    
    if i < len(s):
         olc_list.append(s[i])    
         i += 1

    print("olc_list", olc_list)

    three_letter_sequence = [olc2tlc[j] for j in olc_list]
    print("three_letter_sequence", three_letter_sequence)


    if (1):
        ### write the leap input file
        input_filename = key+'.leap'
        fout = open(input_filename, 'w')
        fout.write("""source oldff/leaprc.ff14SB
source leaprc.gaff
loadoff /Users/starwingchen/Voelz_Lab/git/peptoid_24summer/test-output/NNSP/NNSP.off
loadoff /Users/starwingchen/Voelz_Lab/git/peptoid_24summer/test-output/NSP/NSP.off
loadoff /Users/starwingchen/Voelz_Lab/git/peptoid_24summer/test-output/CNSP/CNSP.off
protein = sequence { %s }
savepdb protein %s.pdb
saveAmberParm protein %s.prmtop %s.crd
quit
    """%(  " ".join(three_letter_sequence), key, key, key)  )
        fout.close()

        ### run tleap on the input file
        cmd = '%s -f %s'%(tleap_bin, input_filename)
        os.system(cmd)
        print('>>', cmd)
