### Searching for protein coding genes shared between RCC138 and CCMP1205 ###

### Bidirectional DIAMOND BLAST searches using predicted protein sequence files 

### Running DIAMOND BLAST searches of CCMP1205 (query) against our genome RCC138 (reference)###
## Creating a DIAMOND database from our curated fasta file of all predicted proteins
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
diamond makedb --in all_proteins.prot -d RCC138.dmnd

### Generating lists of all proteins queries ###
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
./get_queries.pl all_proteins.prot

### Using the output of DIAMOND BLAST against CCMP1205 (CCMP1205.blastp.6)
## Requires a DIAMOND BLAST search of CCMP1205 against our genome RCC138 to generate RCC138.blastp.6
## Running CCMP1205 searches against RCC138 ###

# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
diamond blastp \
-p 10 \
-q GCA_007859695.1_ASM785969v1_protein.faa \
-d ./RCC138.dmnd  \
-e 1e-10 \
-k 1 \
-f 6 \
-o RCC138.blastp.6

./parse_UniProt_BLASTs.pl \
-q GCA_007859695.1_ASM785969v1_protein.faa.queries \
-b RCC138.blastp.6 \
-e 1e-10 \
-u uniprot_sprot.list \
-o parsed_RCC138.tsv

###	DIAMOND BLAST searches were completed previously running RCC138 (query) against CCMP1205 (reference)###
## Commands used:

## Running searches against CCMP1205
diamond blastp \
-p 10 \
-q all_proteins.prot \
-d CCMP1205.dmnd \
-e 1e-10 \
-k 1 \
-f 6 \
-o CCMP1205.blastp.6

./parse_UniProt_BLASTs.pl \
-q all_proteins.prot.queries \
-b CCMP1205.blastp.6 \
-e 1e-10 \
-u GCA_007859695.1_ASM785969v1_protein.products \
-o parsed_CCMP.tsv

##Detect proteins shared between CCMP1205 and RCC138 from the output of a homology search (DIAMOND)##

##Usage information and options for proteins_shared.pl
#SYNOPSIS		Determine shared vs. unique proteins from output of a homology search (diamond)
#USAGE			proteins_shared.pl -e  min_evalue  -l protein_list -b blast_hits

#OPTIONS:
#-e (--evalue)	minimum determined BLAST e-value [default = 1e-10]
#-l (--list)	list of proteins [and products] queried against database
#-b (--blast)	BLAST/DIAMOND tabular output (outfmt 6)


##Generating lists of shared vs. unique proteins between genomes, comparing the RCC138 protein list against CCMP1205 
proteins_shared.pl \
-e  min_evalue \
-l all_proteins.prot.queries.annotations.curated \
-b CCMP1205.blastp.6

##Generating lists of shared vs. unique proteins between genomes, comparing the CCMP1205 protein list against RCC138
proteins_shared.pl \
-e  min_evalue \
-l GCA_007859695.1_ASM785969v1_protein.products \
-b RCC138.blastp.6
