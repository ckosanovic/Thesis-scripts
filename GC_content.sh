### Determining the GC content of the RCC138 genome ###

## Calculating the GC content per chromosome
## script calculates the GC content by counting the number of ATCGs per chromosome from a multi-fasta file 

# In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
./nucleotide_count.pl \
-fa RCC138_FINAL_2020_05_28.fasta \
-out RCC138_FINAL_2020_05_28.fasta.GC.tsv

## Calculating the GC content per sliding window (width 1000) with a step of 500
## Usage options for GC_window.pl
#OPTIONS:
#-fa (--fasta)	FASTA file
#-out (--output)	Desired output file name [Default: .GC.window.tsv]
#-w (--window)	Width of sliding window (by nucleotide) [Default: 1000]
#-s (--step)		Size of the steps between windows [Default: 500]

## In /media/FatCat/ckosanovic/RCC138/Apollo_annot/diamond
./GC_window.pl \
-fa RCC138_FINAL_2020_05_28.fasta \
-out RCC138_FINAL_2020_05_28.fasta.GC.window.tsv

## Plotting GC content to Circos
## Usage options for GC_content_to_Circos.pl
#OPTIONS:
#-f (--fasta)	Input files in fasta format
#-o (--ouput)	Output file names prefix [Default: genome]
#-c (--color)	Color for genotype [Default: black]
#-s (--step)		Size of the steps between windows [Default: 500]
#-w (--window)	Width of the sliding windows [Default: 1000]

# In /media/FatCat/ckosanovic/RCC138/CIRCOS/GC_content
./GC_content_to_Circos.pl -f RCC138_FINAL_2020_05_28.fasta -s 500 -w 1000
