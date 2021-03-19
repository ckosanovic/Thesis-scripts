### Preparing for sequence submission to NCBI's GenBank	###

### Adding taxonomic info to FASTA (.fsa) files ###

## Preparing for TBL2ASN, used add_info_to_fasta_headers.pl to add taxonomic information to FASTA (.fsa) files.
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
./add_info_to_fasta_headers.pl *.fsa

# Script edited with the taxonomic information of the desired organism:
#	organism = 'Chloropicon primus RCC138';
#	strain = 'RCC138';
#	lineage = 'cellular organisms; Eukaryota; Viridiplantae; Chlorophyta;';
#	gcode = '1';
#	moltype = 'genomic';
#	chromosome = 0;

### Sequence Deposition in NCBI's GenBank ###

##	concatenate the complete list of curated annotations and corresponding locus tag prefixes with the list of tRNAs and rRNAs
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
cat all_proteins.prot.queries.annotation.curated all_tRNAs.txt all_rRNAs.txt > all_genes.prod

### Converting EMBL files to TBL format for TBL2ASN ###
# The EMBL (*.embl) and FASTA (*.fsa) files must be in the same folder.
# This script requires locus_tags to be defined in the EMBL files.

# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
./EMBLtoTBL.pl -id ITTBIO -p all_genes.prod -embl *.embl 1> STD.log 2>ERROR.log
#	Options for EMBLtoTBL.pl:
#		-id			Desired institute ID [default: IITBIO]
#		-p			Tab-delimited list of locus_tags and their products
#		-embl		EMBL files to convert
#NOTE: This script prints the standard output in STD.log and any errors detected in the ERROR.log file. 

##	All errors were fixed manually in Artemis (v18.1.0) and updated .embl were exported directly
##	EMBLtoTBL.pl run to generate the corrected annotations in TBL format 
##	This was an iterative process, repeated after making corrections to annotations and completed once all erros were resolved
 
### Converting TBL files to ASN (.sqn) format ###
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
./tbl2asn \
-t template.sbt \
-w genome.cmt \
-p ./ \
-g \
-M n \
-Z discrep \
-H 12/31/2021

### Submitting ASN file to GenBank ###
# All desired corrections made in the .embl files and converted to .tbl format
# Generating a single SQN file with tbl2asn for submission to GenBank   
# To generate a single SQN:
./tbl2asn \
-t template.sbt \
-w genome.cmt \
-p ./ \
-g \
-M n \
-Z discrep \
-H 12/31/2021 \
-o RCC138_final_20200827.sqn
# Where the output (-o) is named by organismal strain and submission date in YYYYMMDD format. 