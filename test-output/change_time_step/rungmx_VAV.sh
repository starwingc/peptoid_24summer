# Make an index file for our solvated+neutralized  peptoid
echo "\!23\nname 24 peptoid\nq\n" | gmx make_ndx -f em.gro -o index.ndx

## can remove the second line for position constraint in voelzlab/tutorials/gmx_protein/nvt.mdp or ignore the warning 
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p 19AE1-4-A_protonated_GMX.top -n index.ndx  -o nvt.tpr
gmx mdrun -v -s nvt.tpr

### submit the NVT run
#### mpirun mdrun_mpi -s nvt.tpr -deffnm nvt 

# qsub nvt.qsub 

### check if the NVT run is good 

#gmx energy -f nvt.edr -o temperature.xvg
#16
#0

##if the driftnumber is small, then it is good 


### using the nvt file make the npt.tpr

