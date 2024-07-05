#!/bin/bash

# Load GROMACS and MPI modules
module load gromacs/2021.2
module load mpi/openmpi

# Use 4 thread
export OMP_NUM_THREADS=4

# Define the state directories for the multidir flag
state_dirs=$(echo state_{0..5} | tr ' ' ' ')

# Run the GROMACS mdrun command with the multidir flag
mpirun -np 24 mdrun_mpi -deffnm HREMD -dhdl dhdl.xvg -replex 5000 -multidir $state_dirs -noappend -ntomp 4 -v

