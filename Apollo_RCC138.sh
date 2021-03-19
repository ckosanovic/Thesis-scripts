#!/usr/bin/bash
##### Creating Apollo Data directories on server Spartacus#####
mkdir media/Data_1/apollo/; 
mkdir /media/Data_1/apollo/data;
chown -R tomcat:jpombert /media/Data_1/apollo/
chown -R jpombert:jpombert /media/Data_1/apollo/data
mkdir /media/Data_1/apollo/data/RCC138
##### Loading the RCC138 genome (FASTA format) in Apollo (v2.5.0) #####
/home/jpombert/Downloads/Apollo-2.5.0/web-app/jbrowse/bin/prepare-refseqs.pl \
  --fasta /media/FatCat/ckosanovic/RCC138/maker/RCC138_chromosomes_correct_polarity.fsa \
  --out /media/Data_1/apollo/data/RCC138
##### Creating BLAT Databases for homology search with faToTwoBit #####
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit
chmod a+x faToTwoBit
mkdir /media/Data_1/apollo/data/RCC138/twoBit
faToTwoBit \
  /media/FatCat/ckosanovic/RCC138/maker/RCC138_chromosomes_correct_polarity.fsa \
  /media/Data_1/apollo/data/RCC138/twoBit/RCC138.2bit
##### Adding the organism to Apollo (name = primus_RCC138) #####
/home/jpombert/Downloads/Apollo-2.5.0/docs/web_services/examples/groovy/add_organism.groovy \
  -name primus_RCC138 \
  -genus Chloropicon \
  -species primus \
  -url http://localhost:8085/apollo/ \
  -directory /media/Data_1/apollo/data/RCC138 \
  -blatdb /media/Data_1/apollo/data/RCC138/twoBit/RCC138.2bit \
  -username jpombert@iit.edu \
  -password 'xxx'
##### Loading MAKER (v3.01.03) annotations #####
# In /media/FatCat/ckosanovic/RCC138/maker/ANNOT_RCC138/
# Splitting annotations per source
splitMakerGFF.pl *.gff
## User annotations; loading MAKER gene predictions [Augustus (v3.3.3) with CCMP1205 gene model] directly as user annotations # -p => password
for k in {01..20}; do \ 
/home/jpombert/Downloads/Apollo-2.5.0/tools/data/add_features_from_gff3_to_annotations.pl \
  -U localhost:8085/apollo -u jpombert@iit.edu -p 'xxx' \
  -i /media/FatCat/ckosanovic/RCC138/maker/ANNOT_RCC138/chromosome_${k}.augustus.gff \
  -t match \
  -e match_part \
  -o "primus_RCC138"; \
done
# Annotation track; Augustus (v3.3.3) predictions with the CCMP1205 gene model
for k in {01..20}; do \
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/maker/ANNOT_RCC138/chromosome_$k.augustus.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "orange-80pct"}' \
  --trackLabel MAKER_AUG_CCMP1205 \
  --out /media/Data_1/apollo/data/RCC138; \
done
# Annotation track; repeats identified with RepeatMasker (v4.1.0)
for k in {01..20}; do \
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/maker/ANNOT_RCC138/chromosome_$k.repeats.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "magenta-80pct"}' \
  --trackLabel REPEATS \
  --out /media/Data_1/apollo/data/RCC138; \
done
## Annotation track; Prodigal (v2.6.3) predictions (to highlight possible open reading frames)
# In /media/FatCat/ckosanovic/RCC138/prodigal
prodigal -c -f gff -i RCC138_chromosomes_correct_polarity.fsa -o RCC138.gff
splitGFF3.pl -g RCC138.gff
for k in {01..20}; do /home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/prodigal/chromosome_$k.gff3 \
  --type CDS --subfeatureClasses '{"CDS": "orange-80pct"}' \
  --trackLabel PRODIGAL \
  --out /media/Data_1/apollo/data/RCC138; \
done
##### Creating a BLAST database from the RCC138 genome (NCBI-BLAST 2.10.0+) #####
# In /media/FatCat/ckosanovic/RCC138
mkdir BLAST; mkdir BLAST/DB
cd BLAST/DB/
makeblastdb -in ../RCC138_chromosomes_correct_polarity.fsa -dbtype nucl -out RCC138
cd ../
## BLASTN homology searches against the RCC138 genome (NCBI-BLAST 2.10.0+)
# Using the Chloropicon primus CCMP1205, Klebsormididium nitens NIES-2285
# and Chlorella variabilis NC64A cds data as queries
ln -s ORIGINALS/GCF_000147415.1_v_1.0_cds_from_genomic.fna Chlorella_cds_from_genomic.fna;
ln -s ORIGINALS/GCA_000708835.1_ASM70883v1_cds_from_genomic.fna Klebsormidium_cds_from_genomic.fna;
ln -s ORIGINALS/GCA_007859695.1_ASM785969v1_cds_from_genomic.fna C_primus_CCMP1205_cds_from_genomic.fna;
get_FnaProducts.pl \
  Chlorella_cds_from_genomic.fna \
  C_primus_CCMP1205_cds_from_genomic.fna \
  Klebsormidium_cds_from_genomic.fna

for file in *genomic.fna; do \
export PREFIX=`echo $file | sed s/.fna//`;
blastn \
  -num_threads 16 \
  -query $file \
  -db DB/RCC138 \
  -evalue 1e-05 \
  -outfmt 6 \
  -out $PREFIX.blastn.6;
done

## Loading results of BLASTN (NCBI-BLAST 2.10.0+) homology searches in Apollo (v2.5.0) as annotation tracks
TBLASTN_to_GFF3.pl *.blastn.6
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/C_primus_CCMP1205_cds_from_genomic.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "brightgreen-80pct"}' \
  --trackLabel C_primus_CCMP1205_blastn \
  --out /media/Data_1/apollo/data/RCC138

/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/Chlorella_cds_from_genomic.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "brightgreen-80pct"}' \
  --trackLabel Chlorella_blastn \
  --out /media/Data_1/apollo/data/RCC138

/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/Klebsormidium_cds_from_genomic.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "brightgreen-80pct"}' \
  --trackLabel Klebsormidium_blastn \
  --out /media/Data_1/apollo/data/RCC138

## TBLASTN homology searches against the RCC138 genome (NCBI-BLAST 2.10.0+)
# Using the Chloropicon primus CCMP1205, Klebsormididium nitens NIES-2285
# and Chlorella variabilis NC64A protein data as queries
# segmentation fault with num_threads, running analyses without it

# Chloropicon primus CCMP1205
tblastn \
  -query GCA_007859695.1_ASM785969v1_protein.faa \
  -db DB/RCC138 \
  -evalue 1e-05 \
  -outfmt 6 \
  -out C_primus_CCMP1205.tblastn.6

# Klebsormidium nitens NIES-2285 
#(https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/708/835/GCA_000708835.1_ASM70883v1/GCA_000708835.1_ASM70883v1_protein.faa.gz)
tblastn \
  -query GCA_000708835.1_ASM70883v1_protein.faa \
  -db DB/RCC138 \
  -evalue 1e-05 \
  -outfmt 6 \
  -out Klebsormidium_nitens.tblastn.6

# Chlorella variabilis NC64A 
#(https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/147/415/GCF_000147415.1_v_1.0/GCF_000147415.1_v_1.0_protein.faa.gz)
tblastn \
  -query GCF_000147415.1_v_1.0_protein.faa \
  -db DB/RCC138 \
  -evalue 1e-05 \
  -outfmt 6 \
  -out Chlorella_variabilis.tblastn.6

## Loading results of TBLASTN (NCBI-BLAST 2.10.0+) homology searches in Apollo (v2.5.0) as annotation tracks
ln -s ORIGINALS/GCA_000708835.1_ASM70883v1_protein.faa Klebsormidium_nitens.faa;
ln -s ORIGINALS/GCA_007859695.1_ASM785969v1_protein.faa C_primus_CCMP1205.faa;
ln -s ORIGINALS/GCF_000147415.1_v_1.0_protein.faa Chlorella_variabilis.faa;

getProducts.pl \
  Klebsormidium_nitens.faa \
  C_primus_CCMP1205.faa \
  Chlorella_variabilis.faa

TBLASTN_to_GFF3.pl \
  Klebsormidium_nitens.tblastn.6 \
  C_primus_CCMP1205.tblastn.6 \
  Chlorella_variabilis.tblastn.6

# Annotation track; Chloropicon primus CCMP1205 (CCMP1205_tblastn)
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/C_primus_CCMP1205.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "magenta-80pct"}' \
  --trackLabel CCMP1205_tblastn \
  --out /media/Data_1/apollo/data/RCC138

# Annotation track; Klebsormidium_tblastn
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/Klebsormidium_nitens.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "green-80pct"}' \
  --trackLabel Klebsormidium_tblastn \
  --out /media/Data_1/apollo/data/RCC138

# Annotation track; Chlorella_tblastn
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BLAST/Chlorella_variabilis.gff \
  --type match,match_part \
  --subfeatureClasses '{"match_part": "blue-80pct"}' \
  --trackLabel Chlorella_tblastn \
  --out /media/Data_1/apollo/data/RCC138

##### Searching the RCC138 genome for transfer RNAs with tRNAscan-2.0 (v2.0.4) #####
# In /media/FatCat/ckosanovic/RCC138/tRNAscan
run_tRNAscan.pl RCC138_chromosomes_correct_polarity.fsa
tRNAscan_to_GFF3.pl *.tRNAs
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/tRNAscan/RCC138_chromosomes_correct_polarity.fsa.tRNAs.gff \
  --type tRNA \
  --trackLabel tRNAscan-SE \
  --out /media/Data_1/apollo/data/RCC138

##### Searching the RCC138 genome for ribosomal RNAs with RNAmmer (v1.2) #####
# In /media/FatCat/ckosanovic/RCC138/RNAmmer
run_RNAmmer.pl euk RCC138_chromosomes_correct_polarity.fsa
RNAmmer_to_GFF3.pl *.gff2
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/RNAmmer/RCC138_chromosomes_correct_polarity.fsa.gff \
  --type rRNA \
  --trackLabel RNAmmer \
  --out /media/Data_1/apollo/data/RCC138

##### Mapping RNA data from C. primus CCMP1205 against the RCC138 genome with HISAT2; #####
# Using CCMP1205 RNA data on RCC138 
# In /media/FatCat/ckosanovic/RCC138
mkdir HISAT2; 
cd HISAT2/;
ln -s ../maker/RCC138_chromosomes_correct_polarity.fsa

# Downloading CCMP1205 RNA data by SFTP:
# Chloropicon_RNA_S1_L001_R1_001.fastq.gz
# Chloropicon_RNA_S1_L001_R2_001.fastq.gz
fastqc *.fastq.gz	## Checking data quality with FASTQC (v0.11.8)
firefox *.html		## Based on FASTQC, filtering required; universal illumina adapters + low QS bases
# Filtering out low quality bases and/or adapter sequences from RNA data with FASTP (v0.20.0)
fastp \
  -w 10 \
  -i Chloropicon_RNA_S1_L001_R1_001.fastq.gz \
  -I Chloropicon_RNA_S1_L001_R2_001.fastq.gz \
  -o R1.fastp.fastq \
  -O R2.fastp.fastq \
  -M 30 \
  -r \
  -l 100

fastqc *.fastp.fastq	## Re-checking data quality with FASTQC (v0.11.8)
firefox *.html			## Better quality 

# Mapping data with HISAT2 (v2.1.0)
hisat2-build RCC138_chromosomes_correct_polarity.fsa RCC138
export THREADS=16
hisat2 \
  -p $THREADS \
  --phred33 \
  -x RCC138 \
  -1 R1.fastp.fastq \
  -2 R2.fastp.fastq \
  --max-intronlen 5000 \
  -S RCC138.sam

# 96.19% overall alignment rate; mapping CCMP1205 data on RCC138 works fine

# Converting to BAM format with Samtools (v1.10) + htslib (v1.10)
samtools view -@ $THREADS -bS RCC138.sam -o RCC138_hisat2.bam
samtools sort -@ $THREADS -o RCC138_hisat2_sorted.bam RCC138_hisat2.bam 
samtools index -@ $THREADS RCC138_hisat2_sorted.bam
rm RCC138.sam RCC138_hisat2.bam;

## Loading HISAT2 in Apollo
mkdir  /media/Data_1/apollo/data/RCC138/bam/;
cp \
  /media/FatCat/ckosanovic/RCC138/HISAT2/RCC138_hisat2_sorted.bam* \
  /media/Data_1/apollo/data/RCC138/bam/
  
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/add-bam-track.pl \
  --bam_url bam/RCC138_hisat2_sorted.bam \
  --label HISAT2_CCMP1205 \
  --key "HISAT2_CCMP1205" \
  -i /media/Data_1/apollo/data/RCC138/trackList.json
  
##### Mapping RNA data from C. primus CCMP1205 against the RCC138 genome with PASS (v2.31) #####
# http://pass.cribi.unipd.it/
# In /media/FatCat/ckosanovic/RCC138/
mkdir PASS; cd PASS;
ln -s ../maker/RCC138_chromosomes_correct_polarity.fsa
ln -s ../HISAT2/R1.fastp.fastq
ln -s ../HISAT2/R2.fastp.fastq
cat R1.fastp.fastq R2.fastp.fastq > all.fastp.fastq 

# Running without paired-ends
export THREADS=16
pass  \
  -p 111111101111111 \
  -d RCC138_chromosomes_correct_polarity.fsa  \\
  -check_block 5000 \
  -fastq all.fastp.fastq \
  -cpu $THREADS  \
  -flc 1 \
  -seeds_step 3 \
  -g 2 \
  -fid 90 \
  -b \
  -fle 50 \
  -sam > results.sam
  
# Converting to BAM format with Samtools (v1.10) + htslib (v1.10)
samtools view -@ $THREADS -bS results.sam -o RCC138_PASS.bam
samtools sort -@ $THREADS -o RCC138_PASS_sorted.bam RCC138_PASS.bam 
samtools index -@ $THREADS RCC138_PASS_sorted.bam
rm results.sam RCC138_PASS.bam

## Loading BAM into Apollo
cp \
  /media/FatCat/ckosanovic/RCC138/PASS/RCC138_PASS_sorted.bam* \
  /media/Data_1/apollo/data/RCC138/bam/
 
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/add-bam-track.pl \
  --bam_url bam/RCC138_PASS_sorted.bam \
  --label PASS_CCMP1205 \
  --key "PASS_CCMP1205" \
  -i /media/Data_1/apollo/data/RCC138/trackList.json

##### Running BRAKER (v2.1.5) to predict genes on the RCC138 genome #####
# Using the alignment generated by mapping the CCMP1205 RNAseq data onto RCC138
# In /media/FatCat/ckosanovic/RCC138
mkdir BRAKER; cd BRAKER/;
ln -s ../maker/RCC138_chromosomes_correct_polarity.fsa 
ln -s ../HISAT2/RCC138_hisat2_sorted.bam 

# Running BRAKER (v2.1.5)
braker.pl \
  --cores=16 \
  --species=RCC138 \
  --genome=RCC138_chromosomes_correct_polarity.fsa \
  --bam=RCC138_hisat2_sorted.bam \
  --workingdir=Braker_RCC138_gff3 \
  --gff3

# Initially hintsfile.gff, genemark_hintsfile.gff and train.gb were created properly,
# but train.f.gb was blank.
# Problem was due to a change in the output of GeneMark-ES after version 4.47 
# see https://github.com/Gaius-Augustus/BRAKER/issues/126. 
# The regex in filterGenesIn_mRNAname.pl was broken in Augustus v3.3.3 but fixed afterwards: 
# if ( $_ =~ m/transcript_id \"([^"]*)\"/ ) {
# Fixed the regex in /opt/augustus-3.3.3/scripts/filterGenesIn_mRNAname.pl accordingly.

# Loading BRAKER annotations into Apollo
/home/jpombert/Downloads/Apollo-2.5.0/jbrowse/bin/flatfile-to-json.pl \
  --gff /media/FatCat/ckosanovic/RCC138/BRAKER/Braker_RCC138_gff3/augustus.hints.gff3 \
  --type mRNA \
  --trackLabel BRAKER \
  --out /media/Data_1/apollo/data/RCC138;

# NOTE: reordered the BRAKER track to appear next to the MAKER track.