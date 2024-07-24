# clean the solvent in gro
echo “20” | gmx editconf -f HREMD.part0001.gro -n index.ndx -o HREMD.part0001_withoutsolvent.gro

# Make a fake tpr
gmx grompp -f em.mdp -c HREMD.part0001_withoutsolvent.gro -p 06AA1-9-A_fep_clean.top -o fake.tpr -maxwarn 3

# Make whole xtc

echo "0" | gmx trjconv -f HREMD.part0001.xtc -s fake.tpr -pbc whole -o HREMD.part0001_whole.xtc
