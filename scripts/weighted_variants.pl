#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'weighted_variants.pl';
my $version = 0.1;

my $usage = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Assigns weight to the variants found in the VCF files based on type (SNP, indel size)
USAGE           weighted_variants.pl -v *.vcf -o file.tsv 

OPTIONS:

-v (--vcf)      VCF files
-o (--output)   Desired output file prefix 

OPTIONS

die "$usage\n" unless@ARGV;

my @vcf;
my $output;

GetOptions(
	 'v|vcf=s@{1,}' => \@vcf,       
	 'o|output=s' => \$output       
);

while (my $file = shift@vcf){
    open VCF,"<$file"; $file =~ s/.vcf$//;
	open OUT, ">$file.tsv";
	my %chrom;
	my $weight;
	print OUT "Contig\tPosition\tReference\tAlternate\tAssigned Weight\tVariant type\n";
        while (my $line = <VCF>){
                chomp $line;
                if ($line =~ /^#/){next;}
                else{
			my @column = split("\t", $line);
			my $contig = $column[0];
               		my $pos = $column[1];
                	my $ref = $column[3];
               		my $alt = $column[4];
		if ((length($ref) == 1) && (length($alt) == 1)){ ##SNP
			$weight = length($ref); 
			$chrom{$contig}[0] +=1; 
			print OUT "$contig\t$pos\t$ref\t$alt\t$weight\tSNP\n";
			}
		elsif (length($ref) > length($alt)){ ##deletion
			$weight = length($ref);
			$chrom{$contig}[1] +=1;
			print OUT "$contig\t$pos\t$ref\t$alt\t$weight\tDeletion\n";
			}
		elsif (length($ref) < length($alt)){ ##insertion
			$weight = length($alt);
			$chrom{$contig}[2] +=1;
			print OUT "$contig\t$pos\t$ref\t$alt\t$weight\tInsertion\n";
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
