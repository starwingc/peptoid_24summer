#!/bin/bash

# Load GROMACS module
# module load gromacs/2021.2

# Add a large box
gmx editconf -f 19AE1-4-A_protonated_GMX.gro -o 19AE1-4-A_protonated_boxed.gro -c -d 1.5 -bt cubic

# Make an index file
echo "q" | gmx make_ndx -f 19AE1-4-A_protonated_boxed.gro -o index.ndx

# Do an energy minimization (EM) in vacuum
gmx grompp -f em_star.mdp -c 19AE1-4-A_protonated_boxed.gro -p 19AE1-4-A_protonated_GMX.top -n index.ndx -o em_vacuum.tpr -maxwarn 1

# Submit the energy minimization job to node
gmx mdrun -v -s em_vacuum.tpr -c em_vacuum.gro -o em_vacuum.trr

# Do an NVT in vacuum
gmx grompp -f nvt_VAV.mdp -c em_vacuum.gro -p 19AE1-4-A_protonated_GMX.top -n index.ndx -o nvt_vacuum.tpr -maxwarn 1

# Submit the NVT run
gmx mdrun -v -s nvt_vacuum.tpr -c nvt_vacuum.gro -o nvt_vacuum.trr

