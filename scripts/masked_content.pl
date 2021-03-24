#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'masked_content.pl';
my $version = 0.1;

my $options = <<"OPTIONS";

NAME		$name
VERSION		$version
SYNOPSIS	Calculate the masked content of a chromosome by a sliding window of nucleotides
USAGE		masked_content.pl -fa *.fsa -out *.N.tsv -w 1000 -s 500

OPTIONS:
-fa (--fasta)		FASTA file
-out (--output)		Desired output file name [Default: .N.tsv]
-w (--window)		Window size [Default: 1000]
-s (--step)		Size of step [Default: 500]

OPTIONS

die "$options\n" unless @ARGV;

my $fasta;
my $output = '.N.tsv';
my $window = 1000;
my $step = 500;

GetOptions(
        'fa|fasta=s' => \$fasta,
        'out|output=s'  => \$output,
	'w|window=i' => \$window,
	's|step=s' => \$step
);

my %sequences = (); #initializing an empty hash of sequences 
open FASTA, "<", "$fasta" or die "Cannot open file\n"; #read from fasta file
open OUT, ">", "$fasta.N.tsv"; #write to the output file
my @names = (); ## creating a blank array that will be reinitialized with every new file
my $key = undef;
	while (my $line = <FASTA>){ #iterating through a single FASTA file line per line
        	chomp $line; #removing the automatic new line
		if ($line =~ /^>(\S+)/){ #search for pattern match of the FASTA header
                	$key = $1; #storing first regex capturing group, the header, in $key
                        push (@names, $key); #adds key to end of the list of header names
                 }
                else {
                      $sequences{$key} .= $line; ## Adding the sequence to the proper key
                }
	}
	while (my $name = shift@names){
                print OUT "\n>$name\n"; ## Printing FASTA header
                my $sequences = $sequences{$name};
                my $length = length($sequences{$name});
                print OUT "Length of sequence: $length\n";
		print OUT "Range\tN count\tN%\n";
                my $N;
                for (my $x = 0; $x <= $length - ($window-1); $x+=$step){ #sliding by 500, window of 1000
                        $N = 0;
			my $string = substr($sequences{$name}, $x, $window);
                        my $size = length$string;
                        my @nucleotide = unpack("(A1)*", $string); #unpacking nt, one by one, repeat until end of the string 
                        while (my $base = shift@nucleotide){
				if ($base =~ /N|n/){$N++;}
			}
			my $percent = sprintf("%.1f", ($N/$size)*100); #formatting percent with one floating point 
			my $term = $x + $size - 1; #end of the sequence 
			print OUT "$x - $term\t$N\t$percent\n";
                }
        }


	

