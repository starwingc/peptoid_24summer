# Make a new index.ndx file
echo "\!4\nname 16 peptoid\nq\n" | gmx make_ndx -f 18AC1-3-A_sol.gro -o index.ndx

# Grompp the NPT equil
gmx grompp -f mdp/npt.mdp -c nvt_sol.gro -p 18AC1-3-A_sol.top -n index.ndx -o npt_sol.tpr

# run the MD (do NOT continue from `state.cpt`)
gmx mdrun -nt 1 -v -s npt_sol.tpr -c npt_sol.gro -o npt_sol.trr


