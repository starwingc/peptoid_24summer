#!/bin/bash

# Load GROMACS module
# module load gromacs/2021.2

# Edit the top file, change the follwing mass of the molecule in top file :

    82    H     5   NHE   HN1   82     0.231500      1.00000 ; qtot 2.769
    83    H     5   NHE   HN2   83     0.231500      1.00000 ; qtot 3.000

# Add a box
gmx editconf -f 19AE1-4-A_protonated_GMX.gro -o 19AE1-4-A_protonated_boxed.gro -c -d 1 -bt cubic

# Make an solvated top file
cp 19AE1-4-A_protonated_GMX.top 19AE1-4-A_protonated_sol.top

# Solvate the molecule with water
gmx solvate -cp 19AE1-4-A_protonated_boxed.gro -cs spc216.gro -o 19AE1-4-A_protonated_sol.gro -p 19AE1-4-A_protonated_sol.top


# Modify the topology file to add solvent parameters to 19AE1-4-A_protonated_sol.top
cat >> 19AE1-4-A_protonated_sol.top <<EOL

; Include force field parameters
#include "/usr/local/gromacs/share/gromacs/top/amber99.ff/forcefield.itp"

; Include TIP3P water model
#include "/usr/local/gromacs/share/gromacs/top/amber99.ff/tip3p.itp"

EOL

# Directly add the solvent molecule to 19AE1-4-A_protonated_sol.top

cat >> 19AE1-4-A_protonated_sol.top <<EOL

; Add these lines to atom types
 HW       1           1.008    0.0000    A     0.00000e+00   0.00000e+00
 OW       8          16.000    0.0000    A     3.15061e-01   6.36386e-01

; Add this section below
[ moleculetype ]
; molname       nrexcl
SOL             2

[ atoms ]
; id  at type     res nr  res name  at name  cg nr  charge    mass
  1   OW          1       SOL       OW       1      -0.834    16.00000
  2   HW          1       SOL       HW1      1       0.417     1.00800
  3   HW          1       SOL       HW2      1       0.417     1.00800

#ifndef FLEXIBLE
[ settles ]
; OW	funct	doh	dhh
1       1       0.09572 0.15139
[ exclusions ]
1	2	3
2	1	3
3	1	2
#else
[ bonds ]
; i     j       funct   length  force_constant
1       2       1       0.09572 502416.0   0.09572        502416.0
1       3       1       0.09572 502416.0   0.09572        502416.0
[ angles ]
; i     j       k       funct   angle   force_constant
2       1       3       1       104.52  628.02      104.52  628.02

EOL

# Make an index file of the solvated peptoid
echo "\nname 17 peptoid\nq\n" | gmx make_ndx -f 19AE1-4-A_protonated_sol.gro -o index.ndx

# Check the index file 
echo "q" | gmx make_ndx -n index.ndx

# make an em_fpeptoid.mdp for frozen the peptoid only 
cp em.mdp em_fpeptoid.mdp

cat >> em_fpeptoid.mdp <<EOL

; Freeze water
freezegrps      = peptoid
freezedim       = Y Y Y

EOL

# Do a EM with peptoid frozen
gmx grompp -f em_fpeptoid.mdp -c 19AE1-4-A_protonated_sol.gro -p 19AE1-4-A_protonated_sol.top -n index.ndx -o em_sol_fpeptoid.tpr -maxwarn 1 #ignore the 1 warning of the Ewald electrostatics since the net charge are 3 

# Run the EM 
gmx mdrun -nt 1 -v -s em_sol_fpeptoid.tpr -c 19AE1-4-A_protonated_sol.gro -o em_sol_fpeptoid.trr

# make an em_fwater.mdp for frozen the water only 

# Do a EM with water frozen
gmx grompp -f em_fwater.mdp -c 19AE1-4-A_protonated_sol.gro -p 19AE1-4-A_protonated_sol.top -n index.ndx -o em_sol_fwater.tpr -maxwarn 1 #ignore the 1 warning of the Ewald electrostatics since the net charge are 3 

# Run the EM 
gmx mdrun -nt 1 -v -s em_sol_fwater.tpr -c 19AE1-4-A_protonated_sol.gro -o em_sol_fwater.trr

# Do a EM of no freezing anything
gmx grompp -f em.mdp -c 19AE1-4-A_protonated_sol.gro -p 19AE1-4-A_protonated_sol.top -n index.ndx -o em_sol.tpr -maxwarn 1 

# Run the EM 
gmx mdrun -nt 1 -v -s em_sol.tpr -c 19AE1-4-A_protonated_sol.gro -o em_sol.trr


#add an ion.mdp file from voelzlab/tutorials/gmx_protein/ion.mdp

# generate an ion.tpr file 
cp 19AE1-4-A_protonated_sol.top 19AE1-4-A_protonated_ion.top
gmx grompp -f ion.mdp -c 19AE1-4-A_protonated_sol.gro -p 19AE1-4-A_protonated_ion.top -o ion.tpr

# Neutralize the molecule
echo 16 | gmx genion -s ion.tpr -o 19AE1-4-A_protonated_ion.gro -p 19AE1-4-A_protonated_ion.top -pname NA -nname CL -neutral

# Modify the topology file to add Cl ion parameters

cat >> 19AE1-4-A_protonated_ion.top <<EOL

; Add these lines to atom types
 Cl       17         35.453   -1.0000    A     4.47766e-01   1.48913e-01

; Add this section below
[ moleculetype ]
; molname       nrexcl
Cl              1

[ atoms ]
; id    at type         res nr  residu name     at name  cg nr  charge
1       Cl              1       CL              CL       1      -1.00000

; Change the end CL to Cl under [molecules]
EOL

# Make an index file for our solvated+neutralized  peptoid
echo "\!23\nname 24 peptoid\nq\n" | gmx make_ndx -f 19AE1-4-A_protonated_ion.gro -o index.ndx

# Check the index.ndx name 

echo "q" | gmx make_ndx -n index.ndx

# Do a EM with peptoid frozen
gmx grompp -f em_fpeptoid.mdp -c 19AE1-4-A_protonated_ion.gro -p 19AE1-4-A_protonated_ion.top -n index.ndx -o em_ion_fpeptoid.tpr -maxwarn 1 # 

# Run the EM 
gmx mdrun -nt 1 -v -s em_ion_fpeptoid.tpr -c 19AE1-4-A_protonated_ion.gro -o em_ion_fpeptoid.trr

# make an em_fwaterion.mdp 

# Do a EM with peptoid frozen
gmx grompp -f em_fwaterion.mdp -c 19AE1-4-A_protonated_ion.gro -p 19AE1-4-A_protonated_ion.top -n index.ndx -o em_ion_fwaterion.tpr -maxwarn 1 #ignore the 1 warning of the Ewald electrostatics since the net charge are 3 

# Run the EM 
gmx mdrun -nt 1 -v -s em_ion_fwaterion.tpr -c 19AE1-4-A_protonated_ion.gro -o em_ion_fwaterion.trr

# Prepare a energy minimization file
gmx grompp -f em.mdp -c 19AE1-4-A_protonated_ion.gro -p 19AE1-4-A_protonated_ion.top -n index.ndx -o em_ion.tpr -maxwarn 1

# Submit the energy minimization job to node
gmx mdrun -nt 1 -v -s em_ion.tpr -c 19AE1-4-A_protonated_ion.gro -o em_ion.trr
#qsub em.qsub

#add an nvt.mdp file from voelzlab/tutorials/gmx_protein/nvt.mdp

# Do a NVT with peptoid frozen

# Generate the NVT file
gmx grompp -f nvt_fpeptoid.mdp -c 19AE1-4-A_protonated_ion.gro -p 19AE1-4-A_protonated_ion.top -n index.ndx -o nvt_fpeptoid.tpr -maxwarn 1

# Run NVT
gmx mdrun -nt 1 -v -s nvt_fpeptoid.tpr -c nvt_fpeptoid.gro -o nvt_fpeptoid.trr
#qsub nvt.qsub


