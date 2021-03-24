#!/usr/bin/perl

use strict; use warnings; use Getopt::Long qw(GetOptions);
my $name = 'SNP_count.pl';
my $version = 0.1;

my $usage = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Counting the number SNPs by location (CDS, intergenic, intron) and the number of transitions, transversions, or indels per chromosome.

USAGE           $name -file *.tsv -out SNP.count

OPTIONS:

-f (--file)		TSV file(s) of interest 
-o (--out)		Output file of sorted SNPs

OPTIONS

die "$usage\n" unless @ARGV;

my @tsv;
my $output = '.count.tsv';
GetOptions(
        'f|file=s@{1,}' => \@tsv,
        'o|out=s' => \$output
);

while (my $file = shift@tsv){#taking previously initialized TSV file from ARGV
    open TSV, "<", "$file" or die "Cannot open TSV file\n"; #read from TSV file
	open OUT, ">", "$file.count.tsv"; #write to output file
	open IND, ">", "indels.txt";
	open SIT, ">", "transitions.txt";
	open VER, ">", "tranversions.txt";
	my %chrom = ();
	while (my $line = <TSV>){ #iterating through TSV file line per line
		chomp $line; #removing the automatic new line
		if ($line =~/^Contig/){next;}
		elsif ($line =~ /^CP/){next;}
		else{
			my @col = split("\t", $line); 
			my $contig = $col[0];
			my $pos = $col[1];
			my $ref = $col[2]; 
			my $alt = $col[3];
			my $freq = $col[4];
			my $type = $col[5];
			##Counting transversions, transitions and indels per chromosome 	
			if ((length($ref) == 1) && (length($alt) == 1)) {
				if ( (($ref eq 'A') or ($ref eq 'G')) && (($alt eq 'T') or ($alt eq 'C')) ) {$chrom{$contig}[0] += 1; print VER "$line\n";}	
				elsif ( (($ref eq 'T') or ($ref eq 'C')) && (($alt eq 'A') or ($alt eq 'G')) ) {$chrom{$contig}[0] += 1; print VER "$line\n";}
				elsif ( (($ref eq 'A') and ($alt eq 'G')) || (($ref eq 'G') and ($alt eq 'A')) ) {$chrom{$contig}[1] += 1; print SIT "$line\n";}
				elsif ( (($ref eq 'T') and ($alt eq 'C')) || (($ref eq 'C') and ($alt eq 'T')) ) {$chrom{$contig}[1] += 1; print SIT "$line\n";}
			}
			if ((length($ref) > 1) || (length($alt) > 1)) {$chrom{$contig}[2] += 1; print IND "$line\n";}
			##Counting position of SNP per chromosome 
			if ($type =~ /intergenic/){$chrom{$contig}[3] += 1;}
			elsif ($type =~ /CDS/){$chrom{$contig}[4] += 1;}
			elsif ($type =~ /intron/){$chrom{$contig}[5] += 1;}
		}
	}
	print OUT "Chromosome\tTransversions\tTransitions\tIndels\tIntergenic\tCDS\tIntrons\n";
	for (sort(keys%chrom)){
		my $key = $_;
		print OUT "$key";
		for (0..5){print OUT "\t$chrom{$key}[$_]";}
		print OUT "\n";
	}
}  
