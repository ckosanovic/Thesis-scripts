#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'GC_window.pl';
my $version = 0.1;

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Calculate the GC content of a chromosome by a sliding window of nucleotides
USAGE           GC_window.pl -fa *.fsa -out *.GC.window.tsv

OPTIONS:
-fa (--fasta)   FASTA file
-out (--output) Desired output file name [Default: .GC.window.tsv]
-w (--window)	Width of sliding window (by nucleotide)	[Default: 1000]
-s (--step)		Size of the steps between windows [Default: 500]

OPTIONS

die "$options\n" unless @ARGV;

my @fasta;
my $output = '.GC.window.tsv';
my $window = 1000;
my $step = 500;

GetOptions(
        'fa|fasta=s@{1,}' => \@fasta,
        'out|output=s'  => \$output,
		'w|window=i' => \$window,
		's|step=i' => \$step
);

my %sequences = (); #initializing an empty hash
#working on the multi-fasta file containing the chromosome sequences
while (my $fasta = shift@fasta){ #taking previously initialized fasta file from ARGV, iterates through files
        open FASTA, "<", "$fasta" or die "Cannot open file\n"; #read from fasta file
        open OUT, ">", "$fasta.GC.window.tsv"; #write to the output file
		print OUT "CONTIG\tSEQUENCE LENGTH\tRANGE\tGC COUNT\t%GC\n";
        my @names = (); ## creating a blank array that will be reinitialized with every new file
        my $key = undef;
        while (my $line = <FASTA>){ #iterating through a single FASTA file line per line
            	chomp $line; #removing the automatic new line
            	if ($line =~ /^>(\w+)/){ #search for pattern match of the FASTA header
                    $key = $1; #storing first regex capturing group, the header, in $key
                    push (@names, $key); #adds key to end of the list of header names
            	}	
            	else {
                	$sequences{$key} .= $line; ## Adding the sequence to the proper key
            	}
        	}
         while (my $name = shift@names){
            	my $sequences = $sequences{$name};
				my $length = length($sequences{$name});
				my $GC; #initialize the variable               
				for (my $x = 0; $x <= $length - ($window-1); $x+=$step){ #sliding window of 1000 with step of 500
					$GC = 0; #starts GC count at zero as loop iterates through each window
					my $string = substr($sequences{$name}, $x, $window);
					my $size = length$string;
					my @nucleotide = unpack("(A1)*", $string); #unpacking nucleotide, one by one
					while (my $base = shift@nucleotide){
						if ($base =~ /G|g|C|c/){$GC++;}
					}
					my $percent = sprintf("%.1f", ($GC/$size)*100);
					my $term = $x + $size - 1; #end of seq
					print OUT "$name\t$length\t$x - $term\t$GC\t$percent\n"; #printing contig,length of sequence, range, GC count, %GC
            	}
			}
}


