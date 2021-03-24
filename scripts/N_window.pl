#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'N_window.pl';
my $version = 0.1;

my $options = <<"OPTIONS";

NAME		$name;
VERSION		$version;
SYNOPSIS	Calculates the repeat content per chromosome by counting N occurences by a sliding window of nt
VERSION		N_window.pl -fa *.fsa -out *.N_window.tsv 

OPTIONS:
-fa (--fasta)	Input FASTA file
-out (--output)	Desired output file name
-w (--window)	Width of sliding window (by nucleotide) [Default: 1000]
-s (--step)     Size of the steps between windows [Default: 500]

OPTIONS

die "$options" unless @ARGV;

my @fasta;
my $output = '.N_window.tsv';
my $window = 1000; 
my $step = 500;

GetOptions(
	'fa|fasta=s@{1,}' => \@fasta,
	'o|output=s' => \$output,
	'w|window=i' => \$window,
	's|step=i' => \ $step
);

my %sequences = (); 
while (my $fasta = shift@fasta){ #working on the multi-fasta file containing the chromosome sequences 
        open FASTA, "<", "$fasta" or die "Cannot open file\n";
        open OUT, ">", "$fasta.N_window.tsv";
        print OUT "#chr START END N_count\n";
        my @names = (); ## creating a blank array that will be reinitialized with every new file
        my $key = undef;
        while (my $line = <FASTA>){ #iterating through a single FASTA file line per line
                chomp $line; 
                if ($line =~ /^>(\w+)/){ #search for FASTA header
                        $key = $1; #storing the header in $key
                        push (@names, $key); #adds key to end of the array of header names
                 }
                else {
                      $sequences{$key} .= $line; ## adding the sequence to the proper key
 		}
         }
         while (my $name = shift@names){
                my $sequences = $sequences{$name};
                my $length = length($sequences{$name});
                my $N; #initialize the variable
                for (my $x = 0; $x <= $length - ($window-1); $x+=$step){ #sliding window of 1000 with step of 500
                        $N = 0; #starts N count at zero as loop iterates through each window
                        my $string = substr($sequences{$name}, $x, $window);
                        my $size = length$string;
                        my @nucleotide = unpack("(A1)*", $string); #unpacking nt, one by one
                        while (my $base = shift@nucleotide){
				if ($base =~ /N|n/){$N++;}
				}
        	        my $term = $x + $size - 1; #end of seq
                	print OUT "$name $x $term $N\n"; 
		}
        }
}


