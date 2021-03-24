#!/usr/bin/perl

my $name =	'split_by_chromosome.pl';
my $version =	'0.1';

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME		$name
VERSION		$version
SYNOPSIS	Splits the output of VCF_to_Circos.pl (.snp file) per chromosome
USAGE		split_by_chromosome.pl file.snp 

OPTIONS

die "$options\n" unless @ARGV;

while (my $snp = shift@ARGV){
	open SNP, "<", "$snp";
	while (my $line = <SNP>){
		chomp $line;
		if ($line =~ /^#/){next;} #skipping header
		else{
			my @columns = split(" ", $line);
			open OUT, ">>$columns[0].tsv";
				print OUT "$line\n";
				close OUT;
			
		}
	}
}
