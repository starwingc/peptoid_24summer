#!/bin/bash

# Load GROMACS module
# module load gromacs/2021.2
# replace the name in text file
# sed 's/19AE1-4-A_protonated/18AC2-7-A/g' runme.sh > runme_temp.sh && mv runme_temp.sh runme.sh

# make an peptoid.itp file 
cp 18AC2-7-A_GMX.top 18AC2-7-A.itp    

# Edit the itp file, change the follwing mass of the molecule in itp file if end with NHE :

   287   H     11   NHE   HN1  287     0.231500      1.00800 ; qtot 4.768
   288   H     11   NHE   HN2  288     0.231500      1.00800 ; qtot 5.000

# make an top file 
# make sure to command out the [default] and the [systems] [molecules] section

cat >> 18AC2-7-A.top  <<EOL
; Include force field parameters
#include "/usr/local/gromacs/share/gromacs/top/amber99.ff/forcefield.itp"

; Include Peptoid
#include "./18AC2-7-A.itp"

[ system ]
 18AC2-7-A

[ molecules ]
; Compound        nmols
 18AC2-7-A        1 

EOL


# Add a box
gmx editconf -f 18AC2-7-A_GMX.gro -o 18AC2-7-A_boxed.gro -c -d 1 -bt cubic

# Make an solvated top file
cp 18AC2-7-A.top 18AC2-7-A_sol.top

# Solvate the molecule with water
gmx solvate -cp 18AC2-7-A_boxed.gro -cs meoh_320_box.gro -o 18AC2-7-A_sol.gro -p 18AC2-7-A_sol.top

# Modify the topology file to add solvent parameters to 18AC2-7-A_sol.top
cat >> 18AC2-7-A_sol.top <<EOL

; Include meoh model
#include "./meoh_320_box.itp"

EOL

# modified the meoh_320_box.itp, change the name as UNL:
cat >> meoh_320_box.itp <<EOL

[ moleculetype ]
;name            nrexcl
 UNL  3
 
EOL

# Make an ion top file 
cp 18AC2-7-A_sol.top 18AC2-7-A_ion.top

#Create ion.tpr
gmx grompp -f mdp/ion.mdp -c 18AC2-7-A_sol.gro -p 18AC2-7-A_ion.top -o ion.tpr

# Neutralize the molecule
echo 8 | gmx genion -s ion.tpr -o 18AC2-7-A_ion.gro -p 18AC2-7-A_ion.top -pname NA -nname CL -neutral # Choose the UNL

# Modify the topology file to add solvent parameters to 18AC2-7-A_sol.top
cat >> 18AC2-7-A_ion.top <<EOL

; Include Ion model
#include "/usr/local/gromacs/share/gromacs/top/amber99.ff/ions.itp"

EOL

# Make an index file for our solvated+neutralized  peptoid
echo "\!28&\!29\nname 30 peptoid\nq\n" | gmx make_ndx -f 18AC2-7-A_ion.gro -o index.ndx 
echo "q" | gmx make_ndx -n index.ndx #131 


# Prepare a EM.tpr file
gmx grompp -f mdp/em.mdp -c 18AC2-7-A_ion.gro -p 18AC2-7-A_ion.top -n index.ndx -o em_ion.tpr -maxwarn 2

#Run the EM 
gmx mdrun -nt 1 -v -s em_ion.tpr -c em_ion.gro -o em_ion.trr
# 4.1558567e+01 on atom 527

# Prepare a NVT.tpr file
gmx grompp -f mdp/nvt.mdp -c em_ion.gro -p 18AC2-7-A_ion.top -n index.ndx -o nvt_ion.tpr -maxwarn 2

#Run the NVT 
gmx mdrun -nt 1 -v -s nvt_ion.tpr -c nvt_ion.gro -o nvt_ion.trr

# Check the run 
echo "16\n0\n" |gmx energy -f ener.edr -o temperature.xvg

# Prepare a NPT.tpr file
gmx grompp -f mdp/npt.mdp -c nvt_ion.gro -p 18AC2-7-A_ion.top -n index.ndx -o npt_ion.tpr -maxwarn 2

#Run the NPT 
gmx mdrun -nt 1 -v -s npt_ion.tpr -c npt_ion.gro -o npt_ion.trr 

# Check the run 
echo "18\n0\n" |gmx energy -f ener.edr -o temperature.xvg

# Prepare for productive run 
gmx grompp -f mdp/prod.mdp -c npt_ion.gro -t state.cpt -p 18AC2-7-A_ion.top -o prod.tpr -maxwarn 2


