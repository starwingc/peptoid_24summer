# Storing all the data processed as .csv or .json 

### Unprocessed Data 

peptoids.json: data sparcing from 'http://127.0.0.1:5000/api/peptoids'
residues.json: data sparcing from 'http://127.0.0.1:5000/api/residues'
peptoids.csv: peptoids info from peptoid data bank
residues.csv: residues info from peptoid data bank 


sequences.csv: NMR Solution peptoids sequence 

smiles.csv: NMR Solution peptoids SMILE (needs to check, since it looks like some of the sequences don't have according SMILE in data bank, but most should have) 

capped_smiles.csv: replace the * in smile.csv into the 'CC(=O)' and 'N(C)C' caps
