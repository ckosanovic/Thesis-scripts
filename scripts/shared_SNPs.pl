#!/usr/bin/perl

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $name = 'shared_SNPs.pl';
my $version = 0.1;

my $usage = <<"OPTIONS";

NAME		$name
VERSION		$version
SYNOPSIS	Compares detected SNPS from VCF files against a reference VCF to determine shared and unique SNPS.

USAGE		$name -ref reference.vcf -query *.vcf -shared shared.vcf -unique .unique.vcf -inverted inverted.vcf

OPTIONS:

-r (--ref)		Reference VCF file
-q (--query)	Query VCF file/files to compare against reference 
-s (--shared)	File containing SNPs shared between the Reference and Query 
-u (--unique)	File containing SNPs not shared between the Reference and Query
-i (--inverted) File containing exact inversions between reference and query
  
OPTIONS

die "$usage\n" unless @ARGV;

my $reference; #single file
my @query; #can have multiple files
my $shared = 'shared.vcf';
my $unique = 'unique.vcf';
my $inverted = 'inverted.vcf';

GetOptions(
	'r|ref=s' => \$reference, 
	'q|query=s@{1,}' => \@query,
	's|shared=s' => \$shared,
	'u|unique=s' => \$unique,
	'i|inverted=s' => \$inverted
);

my %SNP; #creating a blank hash to be reinitialized with new files
## populating my reference database
open REF, "<", "$reference" or die "Cannot open Ref file\n"; #read from reference VCF file
while (my $line = <REF>){ #iterating through Ref VCF file line per line
	chomp $line; #removing the automatic new line
	if ($line =~ /^#/){next;}
	elsif ($line =~ /^(\S+)\t(\d+)\t\.\t(\w+)\t(\w+)/){
		my $contig = $1;
		my $position = $2;
		my $ref = $3;
		my $alt = $4;
		$SNP{$contig}{$position}[0] = $ref;
		$SNP{$contig}{$position}[1] = $alt;
	}		
}

##working on my queries
while (my $query = shift@query){
	open QUERY, "<", "$query" or die "Cannot open query file\n"; #read from query VCF file
	open OUT1, ">", "$shared"; #write to output file
	open OUT2, ">", "$unique"; #write to output file
	open INV, ">", "$inverted";
	while (my $line = <QUERY>){ #iterating through Ref VCF file line per line
        	chomp $line; #removing the automatic new line
        	if ($line =~ /^#/){next;}
        	elsif ($line =~ /^(\S+)\t(\d+)\t\.\t(\w+)\t(\w+)/){
			my $contig = $1;
			my $position = $2;
			my $ref = $3;
			my $alt = $4;
			if (exists $SNP{$contig}{$position}){
				if ( ($ref eq $SNP{$contig}{$position}[0]) and ($alt eq $SNP{$contig}{$position}[1]) ){print OUT1 "$line\n";}
				else {
					if ( ($ref eq $SNP{$contig}{$position}[1]) and ($alt eq $SNP{$contig}{$position}[0]) ){print INV "$line\n"}
					else{print OUT2 "$line\n";}
				}
			}
			else {print OUT2 "$line\n";}
		}
	}
}

