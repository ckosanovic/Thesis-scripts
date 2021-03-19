### Read Mapping and Variant Calling of the RCC138 and CCMP1205 genomes ###

## Concatenate Illumina Run_v1 and Run_v2 for total sequenced data 
/media/FatCat/ckosanovic/RCC138/Illumina_MiSeq_datasets
mkdir Run_v1v2
cat RCC138_R1.fastq RCC138_v2_R1.fastq > RCC138_v1v2_R1.fastq
cat RCC138_R2.fastq RCC138_v2_R2.fastq > RCC138_v1v2_R2.fastq

## Filtering RCC138 Illumina reads using fastp 0.20.0

fastp \
-w 10 \
-i RCC138_Run_v1v2_R1.fastq \ 
-I RCC138_Run_v1v2_R2.fastq \ 
-o RCC138_Run_R1.output.fastq \ 
-O RCC138_Run_R2.output.fastq \ 
-M 30 \ ##attempted 32 but would not accept value over 30
-r \
-l 100

## Filtering CCMP1205 Illumina reads using fastp 0.20.0

fastp \
-w 10 \
-i CCMP1205_PE_R1.fastq \
-I CCMP1205_PE_R2.fastq \
-o CCMP1205_R1.output.fastq \
-O CCMP1205_R2.output.fastq \
-M 30 \
-r \
-l 100

## substitute Run in RCC138_Run_R1.fastq to reflect file name (e.g. v1, v2, v1v2)

### Versions ### 
# fastp 0.20.0
# get_SNPs version 1.9i
# SamTools 1.11
# Minimap2 2.14-r883
# VarScan.v2.4.4

### Determination of sequencing depth using the read mapping only feature, excluding variant calling
### RCC138 on RCC138 ###

## To get original sequencing depth, perform mapping with -rmo using raw unfiltered data
## Using get_SNPs version 1.9i in folder 
# In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_RCC138/read_map_only/Raw_seq_data
/media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/get_SNPs.pl \
--fasta /media/FatCat/ckosanovic/RCC138/RCC138_FINAL_2020_05_28.fasta \
--pe1 /media/FatCat/ckosanovic/RCC138/Illumina_MiSeq_datasets/Run_v1v2/RCC138_v1v2_R1.fastq \
--pe2 /media/FatCat/ckosanovic/RCC138/Illumina_MiSeq_datasets/Run_v1v2/RCC138_v1v2_R2.fastq \
--mapper minimap2 \
-preset sr \
-bam \
--threads 16 \
-rmo
 
## To get the sequencing depth used during assembly, perform mapping with -rmo using AfterQC data  
# In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_RCC138/read_map_only/AfterQC_filtering
/media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/get_SNPs.pl \
--fasta /media/FatCat/ckosanovic/RCC138/RCC138_FINAL_2020_05_28.fasta \
--pe1 RCC138_R1.good.fq.gz \
--pe2 RCC138_R2.good.fq.gz \
--mapper minimap2 \
-preset sr \
-bam \
--threads 16 \
-rmo  

### RCC138 average sequencing depth ###

##Run_v1v2
# Illumina unfiltered 159x
# Illumina AfterQC filtering (assembly) 106x
# Illumina Run_v1v2 Fastp filtering 64x

# Oxford Nanopore unfiltered 208.45x
# Total RCC138 unfiltered seq depth 367x

## Average sequencing depth for CCMP1205
# Illumina unfiltered 200.47x
# PacBio unfiltered 19.55x
# Total 220x

### Masking repeats on the RCC138 genome and CCMP1205 genome 
##RepeatMasker version 4.1.1
##run with nhmmscan version 3.2.1

RepeatMasker \
-pa 16 \
-e hmmer \
-nolow \
-no_is \
RCC138_FINAL_2020_05_28.fasta

RepeatMasker \
-pa 16 \
-e hmmer \
-nolow \
-no_is \
CCMP1205_genome.fasta
   
##didn't work with -species arabidopsis
##used the default query species, homo sapiens
 
##MAPPING MASKED GENOME WITH REPEAT MASKER FOR VARIANT CALLING 
##Automated following read mapping and variant calling steps using the SSRG pipeline found on https://github.com/PombertLab/SSRG
##Mapping RCC138 filtered reads (Ilumina Run_v1_v2) against the unmasked and masked (RepeatMasker) RCC138 genome 
##Mapping CCMP1205 filtered reads (Ilumina) against the unmasked and masked (RepeatMasker) CCMP1205 genome 
##Mapping RCC138 filtered reads (Ilumina Run_v1_v2) against the unmasked and masked RepeatMasker) CCMP1205 genome 
##Mapping CCMP1205 filtered reads (Ilumina) against the unmasked and masked (RepeatMasker) RCC138 genome

##After filtering with fastp, use fastp output files for mapping 
##changed min-reads from 50 to 15 due to decreased sequencing depth after filtering 
##Using most recent fasta file with changes to chromosome 18
##Upgraded to SamTools version 1.11 after SamTools 1.10 was crashing 

#In /media/FatCat/ckosanovic/RCC138/RepeatMasker
/media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/get_SNPs.pl \
--fasta *.fasta *.masked \
--pe1 *R1.output.fastq  \
--pe2 *R2.output.fastq  \
--mapper minimap2 \
--preset sr \
--bam \
--caller varscan2 \
--type both \
--var /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/VarScan.v2.4.4.jar \
--min-var-freq 0.2 \
--min-reads2 15 \
--threads 16

##FILTERED (by allelic frequency -min 10,-max90) and MASKED 
##Generating a tab-delimited list of variants and their location (CDS, RNA, intron, intergenic).
##Using the VCF files created by mapping fastp filtered RCC138 sequenced data on the RCC138 genome
## Get genes with SNPs
#In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_RCC138/Run_v1v2
./get_genes_with_SNPs.pl \
-vcf RCC138_v1v2_R1.output.fastq.RCC138_FINAL_2020_05_28.fasta.masked.minimap2.both.sorted.10.90.vcf \
-embl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.embl \
-tbl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.tbl \
-p /media/FatCat/ckosanovic/RCC138/Apollo_annot/all_genes.prod \
-o RCC138_SNP_filtered.tsv

##RCC138 vs. CCMP1205 SNP comparison MASKED and FILTERED  
##FILTERED/SORTED (by allelic frequency -min 10,-max90) and MASKED
##Comparing SNPS from RCC138 VCF files against CCMP1205 VCF to determine shared and unique SNPS
#In /media/FatCat/ckosanovic/RCC138/RepeatMasker/minimap2.varscan2.VCFs
./shared_SNPs.pl \
-ref CCMP1205_R1.output.fastq.CCMP1205_genome.fasta.masked.minimap2.both.sorted.10.90.vcf \
-query RCC138_v1v2_R1.output.fastq.CCMP1205_genome.fasta.masked.minimap2.both.sorted.10.90.vcf \
-shared RCC_on_CCMP_shared.vcf \
-unique RCC_on_CCMP_unique.vcf \
-inverted RCC_on_CCMP_inverted.vcf

##CCMP1205 vs. RCC138 SNP comparison MASKED and FILTERED  
##FILTERED/SORTED (by allelic frequency -min 10,-max90) and MASKED
##Comparing SNPS from RCC138 VCF files against CCMP1205 VCF to determine shared and unique SNPS
#In /media/FatCat/ckosanovic/RCC138/RepeatMasker/minimap2.varscan2.VCFs
./shared_SNPs.pl \
-ref RCC138_v1v2_R1.output.fastq.RCC138_FINAL_2020_05_28.fasta.masked.minimap2.both.sorted.10.90.vcf \
-query CCMP1205_R1.output.fastq.RCC138_FINAL_2020_05_28.fasta.masked.minimap2.both.sorted.10.90.vcf \
-shared CCMP_on_RCC_shared.vcf \
-unique CCMP_on_RCC_unique.vcf \
-inverted CCMP_on_RCC_inverted.vcf

##UNFILTERED and UNMASKED
##Generating a tab-delimited list of variants and their location (CDS, RNA, intron, intergenic).
##Using the VCF files created by mapping fastp filtered RCC138 sequenced data on the RCC138 genome
## Get genes with SNPs
#In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_RCC138/Run_v1v2
/media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/get_genes_with_SNPs.pl \
-vcf ./minimap2.varscan2.VCFs/*.vcf \
-embl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.embl \
-tbl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.tbl \
-p /media/FatCat/ckosanovic/RCC138/Apollo_annot/all_genes.prod \
-o RCC138_SNP.tsv
 
##FILTERED and MASKED 
##Generating a tab-delimited list of variants and their location (CDS, RNA, intron, intergenic).
##Using the VCF files created by mapping fastp filtered RCC138 sequenced data on the RCC138 genome
## Get genes with SNPs
#In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_RCC138/Run_v1v2
./get_genes_with_SNPs.pl \
-vcf RCC138_v1v2_R1.output.fastq.RCC138_FINAL_2020_05_28.fasta.masked.minimap2.both.sorted.10.90.vcf \
-embl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.embl \
-tbl /media/FatCat/ckosanovic/RCC138/Apollo_annot/*.tbl \
-p /media/FatCat/ckosanovic/RCC138/Apollo_annot/all_genes.prod \
-o RCC138_SNP_filtered.tsv

./get_genes_with_SNPs.pl \  
-vcf CCMP1205_R1.output.fastq.CCMP1205_genome.fasta.masked.minimap2.both.sorted.10.90.vcf \
-embl /media/FatCat/ckosanovic/CCMP1205/EMBL_with_introns/*.embl \ 
-tbl /media/FatCat/ckosanovic/CCMP1205/TBL/*.tbl \
-p /media/FatCat/ckosanovic/CCMP1205/Verified_products_ALL.list
-o CCMP1205_on_CCMP1205_SNP.tsv

##UNMASKED and UNFILTERED -- used for comparison to snpEff output
######Using the VCF files created by mapping fastp unfiltered RCC138 sequenced data on the CCMP1205 genome
## Get genes with SNPs
#In /media/FatCat/ckosanovic/RCC138/Variant_ID/SNPs/SSRG/RCC138_on_CCMP1205/sorted_SNPs
./get_genes_with_SNPs.pl \
-vcf RCC138_v1v2_R1.output.fastq.CCMP1205_genome.fasta.minimap2.both.vcf \
-embl /media/FatCat/ckosanovic/CCMP1205/EMBL_with_introns/*.embl \
-tbl /media/FatCat/ckosanovic/CCMP1205/TBL/*.tbl \
-p /media/FatCat/ckosanovic/CCMP1205/Verified_products_ALL.list \
-o RCC138_on_CCMP1205_SNP.tsv
