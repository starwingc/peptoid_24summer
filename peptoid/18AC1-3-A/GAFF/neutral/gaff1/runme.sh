#!/bin/bash

# Load GROMACS module
# module load gromacs/2021.2
# replace the name in text file
# sed 's/19AE1-4-A_protonated/18AC1-3-A/g' runme.sh > runme_temp.sh && mv runme_temp.sh runme.sh

# make an peptoid.itp file 
cp 18AC1-3-A_GMX.top 18AC1-3-A.itp    
# make sure to command out the [default] and the [systems] [molecules] section

#make a top file 
cat >> 18AC1-3-A.top  <<EOL
; Include force field parameters
#include "/usr/local/gromacs/share/gromacs/top/amber99.ff/forcefield.itp"

; Include Peptoid
#include "./18AC1-3-A.itp"

[ system ]
 18AC1-3-A

[ molecules ]
; Compound        nmols
 18AC1-3-A        1 

EOL


# Add a box
gmx editconf -f 18AC1-3-A_GMX.gro -o 18AC1-3-A_boxed.gro -c -d 1 -bt cubic

# Make an solvated top file
cp 18AC1-3-A.top 18AC1-3-A_sol.top

# Solvate the molecule with water
gmx solvate -cp 18AC1-3-A_boxed.gro -cs meoh_320_box.gro -o 18AC1-3-A_sol.gro -p 18AC1-3-A_sol.top

# Modify the topology file to add solvent parameters to 18AC1-3-A_sol.top
cat >> 18AC1-3-A_sol.top <<EOL

; Include meoh model
#include "./meoh_320_box.itp"

EOL

# modified the meoh_320_box.itp, change the name as UNL:
cat >> meoh_320_box.itp <<EOL

[ moleculetype ]
;name            nrexcl
 UNL  3
 
EOL


# Make an index file for our solvated+neutralized  peptoid
echo "\!4\nname 16 peptoid\nq\n" | gmx make_ndx -f 18AC1-3-A_sol.gro -o index.ndx 
echo "q" | gmx make_ndx -n index.ndx #62


# Prepare a EM.tpr file
gmx grompp -f mdp/em.mdp -c 18AC1-3-A_sol.gro -p 18AC1-3-A_sol.top -n index.ndx -o em_sol.tpr 

#Run the EM 
gmx mdrun -nt 1 -v -s em_sol.tpr -c em_sol.gro -o em_sol.trr
# 8.9275345e+01 on atom 40

# Prepare a NVT.tpr file
gmx grompp -f mdp/nvt.mdp -c em_sol.gro -p 18AC1-3-A_sol.top -n index.ndx -o nvt_sol.tpr

#Run the NVT 
gmx mdrun -nt 1 -v -s nvt_sol.tpr -c nvt_sol.gro -o nvt_sol.trr

# Check the run 
echo "16\n0\n" |gmx energy -f ener.edr -o temperature.xvg

# Grompp the NPT equil
gmx grompp -f mdp/npt.mdp -c nvt_sol.gro -p 18AC1-3-A_sol.top -n index.ndx -o npt_sol.tpr

# run the MD (do NOT continue from `state.cpt`)
gmx mdrun -nt 1 -v -s npt_sol.tpr -c npt_sol.gro -o npt_sol.trr

# Check the run 
echo "18\n0\n" |gmx energy -f ener.edr -o temperature.xvg

# Prepare for productive run 
gmx grompp -f mdp/prod.mdp -c npt_sol.gro -t state.cpt -p 18AC1-3-A_sol.top -o prod.tpr


