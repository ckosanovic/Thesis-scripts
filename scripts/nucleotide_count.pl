#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $name = 'nucleotide_count.pl';
my $version = 0.1;

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Calculate the GC content by counting the number of ATCGs per chromosome from a multi-fasta file
USAGE           nucleotide_count.pl -fa *.fsa -out *.GC.tsv

OPTIONS:
-fa (--fasta)   FASTA file
-out (--output) Desired output file name [Default: .GC.tsv]

OPTIONS

die "$options\n" unless @ARGV;

my @fasta;
my $output = '.GC.tsv';


GetOptions(
	'fa|fasta=s@{1,}' => \@fasta,
	'out|output=s'	=> \$output
);

my %sequences = (); #initializing an empty hash
#working on the multi-fasta file containing the chromosome sequences 
while (my $fasta = shift@fasta){ #taking previously initialized fasta file from ARGV, iterates through files
	open FASTA, "<", "$fasta" or die "Cannot open file\n"; #read from fasta file
	open OUT, ">", "$fasta.GC.tsv"; #write to the output file
	print OUT "CONTIG\tA COUNT\tT COUNT\tGC COUNT\tSEQUENCE LENGTH\tGC%\n"; 
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
        my @nucleotide = unpack("(A1)*", $sequences); #unpack each nt, one by one
        my $GC = 0;
        my $A = 0; my $T = 0;
	    while (my $base = shift@nucleotide){
            if ($base =~ /[Aa]/){$A++;}
                elsif ($base =~ /[Tt]/){$T++;}
                elsif ($base =~ /[GCgc]/){$GC++;}}
				my $size = length$sequences;
                my $percent = sprintf("%.1f", ($GC/$size)*100);
                print OUT "$name\t$A\t$T\t$GC\t$size\tGC%$percent\n";			      
	}
}


