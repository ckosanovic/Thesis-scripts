#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'weighted_variants.pl';
my $version = 0.1;

my $usage = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Assigns weight to the variants found in the TSV files based on type (SNP, indel size)
USAGE           weighted_variants.pl -f *.tsv -o file.sorted.tsv
NOTE            The input TSV file was generated with get_genes_with_SNPS.pl and the VCF file of interest,
                .embl and .tbl files from the reference genome and the curated list of protein products to provide the product name for each gene
OPTIONS:

-f (--file)     TSV files
-o (--output)   Desired output file prefix

OPTIONS

die "$usage\n" unless@ARGV;

my @tsv;
my $output;

GetOptions(
         'f|file=s@{1,}' => \@tsv,
         'o|output=s' => \$output
);

while (my $file = shift@tsv){
        open TSV,"<$file"; $file =~ s/.tsv$//;
        open OUT, ">$file.sorted.tsv";
        my %chrom;
        my $weight;
        print OUT "Contig\tPosition\tReference\tAlternate\tLocation\tLocus_tag\tProduct\tAssigned Weight\tVariant type\n";
        while (my $line = <TSV>){
                chomp $line;
                if ($line =~ /^Contig/){next;}
                else{
                        my @column = split("\t", $line);
                        my $contig = $column[0];
                        my $pos = $column[1];
                        my $ref = $column[2];
                        my $alt = $column[3];
			my $type = $column[5];
			my $tag = $column[6];
			my $product = $column[7];
                if ((length($ref) == 1) && (length($alt) == 1)){ ##SNP
                        $weight = length($ref);
                        $chrom{$contig}[0] +=1;
                        print OUT "$contig\t$pos\t$ref\t$alt\t$type\t$tag\t$product\t$weight\tSNP\n";
                        }
                elsif (length($ref) > length($alt)){ ##deletion
                        $weight = length($ref);
                        $chrom{$contig}[1] +=1;
			print OUT "$contig\t$pos\t$ref\t$alt\t$type\t$tag\t$product\t$weight\tDeletion\n";
                        }
                elsif (length($ref) < length($alt)){ ##insertion
                        $weight = length($alt);
                        $chrom{$contig}[2] +=1;
                        print OUT "$contig\t$pos\t$ref\t$alt\t$type\t$tag\t$product\t$weight\tInsertion\n";
                        }
                }
        }
         print "Contig\tSNPs\tDeletions\tInsertions\n";
         for (sort(keys%chrom)){
                my $key = $_;
                print "$key";
		for (0..2){print "\t$chrom{$key}[$_]";}
                print "\n";
                }

}

