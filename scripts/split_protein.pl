#!/usr/bin/perl

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $name = 'split_protein.pl';
my $version = 0.1;

my $usage = <<OPTIONS;
NAME		$name 
VERSION		$version
SYNOPSIS	Split a larger protein into smaller strings of 500 amino acids 
USAGE		$name -fa .fasta -p product_list -w 500 -s 250

OPTIONS:

-fa (--fasta)		FASTA file
-w (--window)		Width of sliding window (by amino acid) [Default: 500]
-s (--step)			Size of the steps between windows [Default: 250]
OPTIONS
die "\n$usage\n" unless @ARGV; 

my $fasta;
my $prod;
my $window = 500;
my $step = 250;

GetOptions(
        'fa|fasta=s' => \$fasta,
		'p|prod=s' => \$prod,	
		'w|window=i' => \$window,
        's|step=i' => \$step,
);

#### Creating a database of sequences
my %seq; my $key; #initialize an empty hash to later populate with sequences 
open FASTA, "<", "$fasta" or die "Cannot open fasta file\n"; #read from fasta file
while (my $line = <FASTA>){		#iterating through a single FASTA file line per line
	chomp $line;
	if ($line =~ /^>(\S+)/){ $key = $1; }
	else { $seq{$key} .= $line; }## Adding the sequence to the proper key
}

#### Working on my product list
open PROD, "<", "$prod" or die "Cannot open products file\n"; #read from products file
while (my $line = <PROD>){
	chomp $line;
	if ($line =~ /^(\S+)\s+(polyketide synthase)/){
		my $id = $1;
		open OUT, ">", "$id.fasta";
		my $count = 0;
		my $length = length($seq{$id});
		if ($length <= ($window-1)){
			print OUT ">$id\n";
			my @seq = unpack ("(A60)*", $seq{$id});
			while (my $seq = shift@seq){ print OUT "$seq\n"; }
		}
		else {
			for (my $x = 0; $x <= $length - ($window-1); $x+=$step){ #sliding by 250, window of 500
				my $string = substr($seq{$id}, $x, $window);
				$count++;
				my $name = "$id".'_'."$count\n";
				print OUT ">$name";
				my @seq = unpack ("(A60)*", $string);
				while (my $seq = shift@seq){ print OUT "$seq\n"; }
			}
		}
		close OUT;
	}
}				
