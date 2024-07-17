# Create a em.mdp 

# make a fake.tpr file
gmx grompp -f em.mdp -c HREMD_withoutwater.part0001.gro -p 19AF1-10-A_fep_clean.top -o fake.tpr -maxwarn 3

# Create trajectories file 
gmx trjconv -f HREMD.part0001.xtc -s fake.tpr -pbc whole -o HREMD.part0001_whole.xtc
 
