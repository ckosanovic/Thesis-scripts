#!/usr/bin/perl

my $name = 'sort_variants.pl';
my $version = '0.1';

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $usage = <<"OPTIONS";
NAME		$name
VERSION		$version
SYNOPSIS	Sorts variants from variant_effect_output.txt VEP file to detect positions of consequences of interest (e.g. synonymous_variants, missense_variants) and their impact on genes
USAGE		$name -in variant_effect_output.txt -p product_list.txt -o output.tsv [default: variant_types.tsv] 
OPTIONS
die "$usage\n" unless @ARGV;

my @vep;
my $products;
my $output = 'variant_types.tsv';
GetOptions(
	'p=s' => \$products,
	'in|input=s@{1,}' => \@vep,
	'o|output=s' => \$output
);

### Filling the products database
my %products;
open PROD, "<", "$products" or die "Can't open products file\n";
while(my $dbkey = <PROD>){
	chomp $dbkey;
	if($dbkey =~ /^(\S+)\t(.*)$/){
	my $prot = $1;
	my $prod = $2;
	$products{$prot}=$prod;
	}
}	

###Working on ensembl VEP file
my %variants; my %db;
while(my $file = shift@vep){
	open VEP, "<", "$file" or die "Can't open VEP file\n";
	open OUT, ">", "$output" or die "Can't write to output file\n"; 
	while (my $line = <VEP>){
	chomp $line;
		if ($line =~ /(chromosome\S+)\t(chromosome\S+)\t\S+\t(HOP50_\S+)\tHOP50_\S+\t\S+\t(\S+)[^\n\r]*/){
		my $locus = $3;
		my $var_type = $4;
		$variants{$locus} = $var_type;
			if (($var_type eq 'upstream_gene_variant') or ($var_type eq 'downstream_gene_variant')) {next;}
			else {print OUT "$locus\t$variants{$locus}\n";	##debugging
			}
		}
	}
}

