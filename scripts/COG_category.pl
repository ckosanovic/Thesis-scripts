#!/usr/bin/perl

my $name = 'COG_category.pl';
my $version = 0.1;

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Sort variants by COG category obtained from variant calling and eggnog-mapper annotations
USAGE           COG_category.pl -var *.tsv -ann *.annotations -out 

OPTIONS:
-v (--var)	Variants from TSV file created from the VCF of interest
-a (--ann)	Annotation file from the output of eggnog-mapper
-o (--out)	Output file with variants and their corresponding COG functional description    
OPTIONS
die "\n$options\n\n" unless @ARGV;

my $var; my @ann; my $output = 'COG_distribution.txt';
GetOptions(
        'v|var=s' => \$var,
        'a|ann=s@{1,}' => \@ann,
		'o|out=s' => \$output
);

#### Creating a database of tags with descriptions
my %locus_tag; 
my $key;  my $count = 0; my $empty = 0;
while (my $file = shift@ann){
	open ANN, "<", "$file";
	open OUT, ">", "$output";
	while (my $line = <ANN>){
                chomp $line;
                if ($line =~ /^#/){next;}
                else{
                        my @column = split("\t", $line);
			my $locus = $column[0];
			if ($column[20]){ 
				$count++; 
				$locus_tag{$locus} = $column[20]; 
			}
			else {$empty++;}
		}
	}
}	
print OUT "Total COG count in annotation file: $count\n";
print OUT "Number of annotations missing COGs: $empty\n";

### Looking at all COGs found in annotations file
my %annot;
foreach (keys%locus_tag){
	my @letters = unpack("(A1)*", $locus_tag{$_});
	for (@letters){ $annot{$_} += 1; }
}
print OUT "Baseline COGs across all annotations:\n";
foreach (sort(keys%annot)){ print OUT "$_\t$annot{$_}\n"; }

### Working on variants only
open VAR, "<", "$var" or die "Cannot open variants file\n"; #read from tsv file containing variants from vcf file with product names
my %COG;
while (my $line = <VAR>){
        chomp $line;
	if ($line =~ /^Contig/){next;}
	elsif ($line =~ /^chromosome_\d+\s+\d+\s+\w+\s+\w+\s+\S+\s+\w+\s+(HOP50_\w+)\s+[^\n]*/){
		my $locus = $1; #storing locus tag in key
		if (exists $locus_tag{$locus}){
			my @letters = unpack("(A1)*", $locus_tag{$locus});
			for (@letters){ $COG{$_} += 1; }
		}
	}
}
print OUT "Variants\n";
my $sum = 0;
foreach (sort(keys%COG)){ 
	print OUT "$_\t$COG{$_}\n"; 
	$sum+=$COG{$_};
}
print OUT "Total = $sum\n";
