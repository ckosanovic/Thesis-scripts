#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'proteins_shared.pl';
my $version = 0.2;

my $options = <<'OPTIONS';

NAME             $name
VERSION          $version
SYNOPSIS         Determine shared vs. unique proteins from output of a homology search (diamond)
USAGE            proteins_shared.pl -e  min_evalue  -l protein_list -b blast_hits

OPTIONS:
-e (--evalue)  minimum determined BLAST e-value [default = 1e-10]
-l (--list)    list of proteins [and products] queried against database
-b (--blast)   BLAST/DIAMOND tabular output (outfmt 6)

OPTIONS
die "\n$options\n\n" unless@ARGV;

my $evalue = 1e-10;
my $list; 
my @blast;

GetOptions(
	'e|evalue=s' => \$evalue,
	'l|list=s' => \$list,
	'b|blast=s@{1,}' => \@blast
);

while (my $file = shift@blast){
	open HIT, "<$file";
	open LIST, "<$list";
	open OUT, ">$file.$evalue.shared";
	open OUT2, ">$file.$evalue.unique";

	my %hits = ();
	while (my $line = <HIT>){ #iterating line per line through BLAST (fmt 6) file 
		chomp $line;
		if ($line =~/^HOP50_\S+/){
			my @column = split("\t", $line); #splitting file by columns
                        my $locus = $column[0]; #storing 1st element from column in $locus
                        my $hit = $column[1]; #storing 2nd element from column in $hit
                        my $ev = $column[10]; #storing 11th element from column in $ev
			if ($ev <= $evalue){ #only keeping hits below e-value cutoff
				$hits{$locus} = $locus;
				print "Working on: $hits{$locus}\n"; ## Debugging
			}
		}
	}
	while (my $line = <LIST>){ #iterating through list of protein and product, line per line
	chomp $line;
		if ($line =~ /^#/){next;}
		else {
			my @array = split("\t",$line); #splitting line per tab
			my $prot = $array[0]; #capturing 1st item in array
			my $prod = $array[1]; #capturing 2nd item in array 
			if (exists $hits{$prot}){print OUT "$prot\t$prod\n"}
			else {print OUT2 "$prot\t$prod\n";}
				
		}
	}
}
