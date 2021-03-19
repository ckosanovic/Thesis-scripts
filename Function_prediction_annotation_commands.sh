### Annotation and function prediction###

# After manual curation of annotations in Apollo (v2.5.0), export curated annotations 
# Select 'Ref Sequence' tab
# Export -> GFF3; select ALL; select GFF3 with FASTA; click Export 

## Creating a single file containing outputs of tRNAscan, RNAmmer and Annotations in .gff3 format ## 

# In /media/FatCat/ckosanovic/RCC138/
mkdir Apollo_annot

## unzip the exported Apollo (v2.5.0) annotations file 
gunzip Annotations.gff3.gz  
## copy tRNascan and RNAmmer files from previous directory into current directory 
cp ../tRNAscan/RCC138_chromosome_correct_polarity.fsa.tRNAs.gff3 ./ 
cp ../RNAmmer/RCC138_chromosome_correct_polarity.fsa ./  

## concatenate tRNA, RNAmmer and Annotation files into new file
cat RCC* Annotations.gff3 > all_genes.gff3 


## Split the WebApollo GFF3 file and create a GFF3 (.gff3) and a FASTA (.fsa) file per contig ##  
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
chmod +x splitGFF3.pl 
./splitGFF3.pl -g all_genes.gff3  


## Store .gff3 files from current directory in separate directory ## 
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
mkdir CAT
mv all_genes.gff3 CAT/
mv Annotations.gff3 CAT/
mv RCC* CAT/


## Converting WebApollo GFF3 annotations to EBML format ##
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
chmod +x WebApolloGFF3toEMBL.pl 
./WebApolloGFF3toEMBL.pl -p HOP50 -g *.gff3 -c 1 
## script converts WebApollo GFF3 files to EMBL files and writes the proteins and RNAs to separate FASTA files with .prot and .RNA extensions 
## Generates locus tags automatically based on provided prefix from NCBI

## Create separate folder for protein queries for function prediction ##
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
cat *.prot > all_proteins.prot
mkdir PROT_QUERIES
mv all_proteins.prot PROT_QUERIES/ 

### Function prediction ### 

## Predicting functions with InterProScan 5 (v5.44-79.0)
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/PROT_QUERIES
chmod +x interproscan.sh
./interproscan.sh

## Downloading the SwissProt/UniProt databases
cd /media/FatCat/UniProt
./get_UniProt.pl -s -t -n 20 -l download.log

## Creating tab-delimited lists of products from the trEMBL and SwissProt FASTA files 
# In /media/FatCat/UniProt
./get_uniprot_products.pl uniprot_sprot.fasta.gz uniprot_trembl.fasta.gz

## Create diamond database in separate folder 
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot
mkdir diamond 

# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
## Create symlinks (i.e. shortcuts) to the .fasta.gz and .list files, in diamond directory. 
ln -s /media/FatCat/UniProt/uniprot_sprot.fasta.gz ./      ## i.e. 1) file of interest 2) new location (./ for current folder) 
ln -s /media/FatCat/UniProt/uniprot_trembl.fasta.gz ./
ln -s /media/FatCat/UniProt/uniprot_sprot.list ./
ln -s /media/FatCat/UniProt/uniprot_trembl.list ./

# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond

diamond makedb --in uniprot_sprot.fasta -d uniprot_sprot #Swiss-Prot database 

diamond makedb --in uniprot_trembl.fasta.gz -d uniprot_trembl #TREMBL database 

diamond makedb --in GCA_007859695.1_ASM785969v1_protein.faa.gz -d CCMP1205 #database for reference genome CCMP1205

## Running BLAST searches against SwissPROT and TREMBL 
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
./uniprot.sh

###Contents of uniprot.sh script### 
#!/usr/bin/bash

## Generating lists of all proteins queries; including those with no hits against SwissProt/UniProt
./get_queries.pl all_proteins.prot

## Running searches against Swiss-PROT
echo 'Querying HOP50 against SwissProt...'
echo 'HOP50 SwissProt searches started on:' >> swissprot.log; date >> swissprot.log
diamond blastp -p 10 -q all_proteins.prot -d ./uniprot_sprot.dmnd -e 1e-10 -k 1 -f 6 -o HOP50.sprot.blastp.6
echo 'HOP50 SwissProt searches completed on:' >> swissprot.log; date >> swissprot.log
./parse_UniProt_BLASTs.pl -q all_proteins.prot.queries -b HOP50.sprot.blastp.6 -e 1e-10 -u uniprot_sprot.list -o HOP50.parsed_sprot.tsv

## Running searches against TREMBL
echo 'Querying HOP50 against TREMBL...'
echo 'HOP50 TREMBL searches started on:' >> trembl.log; date >> trembl.log
diamond blastp -p 10 -q all_proteins.prot -d ./uniprot_trembl.dmnd  -e 1e-10 -k 1 -f 6 -o HOP50.trembl.blastp.6
echo 'HOP50 TREMBL searches completed on:' >> trembl.log; date >> trembl.log
./parse_UniProt_BLASTs.pl -q all_proteins.prot.queries -b HOP50.trembl.blastp.6 -e 1e-10 -u uniprot_trembl.list -o HOP50.parsed_trembl.tsv

## Running searches against CCMP1205
diamond blastp -p 10 -q all_proteins.prot -d CCMP1205.dmnd -e 1e-10 -k 1 -f 6 -o CCMP1205.blastp.6
./parse_UniProt_BLASTs.pl -q all_proteins.prot.queries -b CCMP1205.blastp.6 -e 1e-10 -u uniprot_trembl.list (?GCA_*.products) -o parsed_CCMP.tsv

###

## USAGE information for parse_UniProt_BLASTs.pl ##
# Generates a tab-delimited list of products found/not found with BLAST/DIAMOND searches
# REQUIREMENTS  BLAST/DIAMOND outfmt 6 format
#                Tab-separated accession number/product list ## Can be created with get_uniprot_products.pl
# USAGE           parse_UniProt_BLASTs.pl -b blast_output -e 1e-10 -q query.list -u uniprot_list -o parsed.tsv
#OPTIONS:
#	-b (--blast)    BLAST/DIAMOND tabular output (outfmt 6)
#	-e (--evalue)   E-value cutoff [Default: 1e-10]
#	-q (--query)    List of proteins queried against UniProt
#	-u (--uniprot)  Tab-delimited list of UniProt accesssion numbers/products
#	-o (--output)   Desired output name

## Parsing the result of InterProScan 5, SwissProt/UniProt, and reference CCMP1205 searches ##
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
./parse_annotators.pl \
   -q all_proteins.prot.queries \
   -sl uniprot_sprot.list \
   -sb HOP50.sprot.blastp.6 \
   -tl uniprot_trembl.list \
   -tb HOP50.trembl.blastp.6 \
   -ip all_proteins.interpro.tsv \
   -rl GCA_007859695.1_ASM785969v1_protein.products \
   -rb CCMP1205.blastp.6
   
## USAGE information for parse_annotators.pl
## parses the output of annotators to help assign putative functions to predicted proteins.
#       Annotators are:
#		         - BLASTP/DIAMOND searches against SwissProt/trEMBL databases
#                - InterProScan 5 searches
#                - BLASTP/DIAMOND searches against reference organism (optional)
# USAGE   parse_annotators.pl -q BEOM2.proteins.queries \\
#                -sl sprot.list -sb BEOM2.sprot.blastp.6 \\      ## Searches against SwissProt
#                -tl trembl.list -tb BEOM2.trembl.blastp.6 \\    ## Searches against trEMBL
#                -ip BEOM2.interpro.tsv \\                       ## InterProScan5 searches
#                -rl reference.list -rb reference.blastp.6       ## Searches agasint reference organism (Optional)

### Curating the annotations
# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
curate_annotations.pl -r -i all_proteins.prot.queries.annotations


## USAGE information for curate_annotations.pl
# Displays lists of functions predicted per proteins. User can select or enter desired annotation.
# Creates a tab-delimited .curated list of annotations.
# USAGE           curate_annotations.pl -r -i file.annotations -3D 3d_matches.txt
# OPTIONS:
#-r      Resumes annotation from last curated locus_tag
#-i      Input file (generated from parse_annotators.pl)
#-3D     List of 3D matches from GESAMT searches ## Generated with descriptive_GESAMT_matches.pl

###Further analyses##

##Detect proteins shared between CCMP1205 and RCC138 ##

## Uses the output of diamond blast against CCMP1205 (CCMP1205.blastp.6)
## Requires a diamond BLAST search of CCMP1205 against our genome RCC138 to generate RCC138.blastp.6
## Running searches against RCC138
diamond blastp -p 10 -q GCA_007859695.1_ASM785969v1_protein.faa -d RCC138.dmnd -e 1e-10 -k 1 -f 6 -o RCC138.blastp.6

##Generating lists of shared vs. unique proteins between genomes, comparing the RCC138 protein list against CCMP1205 
proteins_shared.pl -e  min_evalue  -l all_proteins.prot.queries.annotations.curated -b CCMP1205.blastp.6

##Generating lists of shared vs. unique proteins between genomes, comparing the CCMP1205 protein list against RCC138
proteins_shared.pl -e  min_evalue  -l GCA_007859695.1_ASM785969v1_protein.products -b RCC138.blastp.6