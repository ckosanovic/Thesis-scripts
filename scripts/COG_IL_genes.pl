#!/usr/bin/perl

my $name = 'COG_IL_genes.pl';
my $version = 0.1;

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Parsing eggnog-mapper annotations file and output of variant calling (VCF->TSV) file to determine location and corresponding product 
                containing the COG assignment of interest (I = Lipid transport and Metabolism, L = Replication, Recombination and Repair)	 
USAGE           COG_IL_genes.pl -var *.tsv -ann *.annotations -out

OPTIONS:
-v (--var)      Variants from TSV file created from the VCF of interest
-a (--ann)      Annotation file from the output of eggnog-mapper
-o (--out)     	Output file with variants and their corresponding COG functional description
OPTIONS

die "\n$options\n\n" unless @ARGV;

my $var; my @ann; my $out = 'COG_products.tsv';

GetOptions(
        'v|var=s' => \$var,
        'a|ann=s@{1,}' => \@ann,
	'o|out=s' => \$out
);

#### Creating a database of locus tags with corresponding COG assignments from the eggnog-mapper annotation file
my %locus_tag;
my $key;  my $count = 0;
while (my $file = shift@ann){
        open ANN, "<", "$file";
	open OUT, ">", "$out" or die "Cannot write to output file\n";
        while (my $line = <ANN>){
                chomp $line;
                if ($line =~ /^#/){next;}
                else{
                        my @column = split("\t", $line);
                        my $locus = $column[0];
                        if ($column[20] =~ /([IL])/){ #searching for genes with an I or L COG assignment       
				$count++;
                                $locus_tag{$locus} = $column[20]; #populating the locus_tag database with $locus: COG assignment
                        }
                }
        }
}
print OUT "Total I/L COG assignments in annotation file: $count\n";

### Working on variants only
open VAR, "<", "$var" or die "Cannot open variants file\n"; #read from tsv file containing the variants from the vcf file and products corresponding to locus tags
my %COG; 
my @product_tags;
my $var_sum;
while (my $line = <VAR>){
        chomp $line;
        if ($line =~ /^Contig/){next;}
        elsif ($line =~ /^chromosome_\d+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+(HOP50_\w+)\s+([^\n]*)/){
                my $locus = $1; #storing locus tag in key
		my $product = $2; #storing gene product associated to locus tag
                if (exists $locus_tag{$locus}){ #searching for locus tag from th variant database
			$var_sum++; #counting number I/L assignments among variants
			$COG{$locus}=$product; #populating COG database as locus tag: product
			push (@product_tags, $locus); #adding locus tags corresponding to products into an array
			print "COG assignment: $locus_tag{$locus}\n";
			print "$locus\t$product\n";
		}	 
	}
}
##Creating a database of counts of variant occurences per locus tag 
my %counts;
for (@product_tags) {$counts{$_}++;} #from array of locus tags, locus tag (key) => count
foreach my $keys (keys %counts) {
	print OUT "$keys\t$counts{$keys}\t";		
	if (exists $COG{$keys}){
		print OUT "$COG{$keys}\n";
	}
}
		

my $elements = scalar(@product_tags);
print "Number of variants detected in products: $elements\n";

print OUT "Total I and L assignments among variants: $var_sum\n";

my $sum = 0;
foreach (sort(keys%COG)){
        print "$_\t$COG{$_}\n"; # prints to standard output for debugging
	$sum++;
}
print OUT "Total products with I or L COG assignments= $sum\n";

