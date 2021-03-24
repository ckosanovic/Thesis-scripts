#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'SNP_high_density.pl';
my $version = 0.1;

my $usage = <<OPTIONS;

NAME            $name
VERSION         $version
SYNOPSIS        Locate regions with a variant count greater than 10
USAGE           $name -in file.snp -out file.count.tsv 
##NOTE			using the output from VCF_to_Circos.pl where variant distributions from VCF files are calculated per sliding window of 500

OPTIONS:
-in (--input)        Input .snp file
-out (--output)      Desired output file name [Default: .count.tsv]

OPTIONS

die "$usage" unless @ARGV;

my $input;
my $output;

GetOptions(
        'in|input=s' => \$input,
        'out|output=s'  => \$output
);

open IN, "<", "$input" or die "Cannot open file\n"; #read from input file
open OUT, ">", "$output.count.tsv"; #writing to output file
print OUT "Contig\tStart\tEnd\tSNP count\n";
while (my $line = <IN>){ 
	if ($line =~ /^#/){next;}
	else{
		my @col = split(" ", $line);
        	my $contig = $col[0];
        	my $start = $col[1];
        	my $end = $col[2];
        	my $snp = $col[3];
		if ($snp >= 10){
			print OUT "$contig\t$start\t$end\t$snp\n";
		}
	}
}	
