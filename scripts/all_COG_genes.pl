#!/usr/bin/perl

my $name = 'all_COG_genes.pl';
my $version = 0.1;

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Parsing eggnog-mapper annotations file and the output of variant calling (VCF->TSV) file to determine location and corresponding product containing the COG assignment	 
USAGE           all_COG_genes.pl -var *.tsv -ann *.annotations -out [default: all_COG_products.tsv]

OPTIONS:
-v (--var)      Variants from TSV file created from the VCF of interest
-a (--ann)      Annotation file from the output of eggnog-mapper
-o (--out)     	Output file with variants and their corresponding COG functional description
OPTIONS

die "\n$options\n\n" unless @ARGV;

my $var; my @ann; 
my $out = 'all_COG_products.tsv';

GetOptions(
        'v|var=s' => \$var,
        'a|ann=s@{1,}' => \@ann,
	'o|out=s' => \$out
);

#### Creating a database of tags with descriptions
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
                        if ($column[20]){       
				$count++;
                                $locus_tag{$locus} = $column[20]; #populating database %locus_tag with $locus: COG assignment
                        }
                }
        }
}
print  "Total COG assignments in annotation file: $count\n";

#### Working on variants only
open VAR, "<", "$var" or die "Cannot open variants file\n"; #read from .tsv file containing the variants from .vcf file and corresponding gene products 
my %COG; #creating new database to store COG-assigned genes detected in variants file 
my @product_tags;
my $var_sum;
my %db;
while (my $line = <VAR>){
        chomp $line;
        if ($line =~ /^Contig/){next;}
        elsif ($line =~ /^chromosome_\d+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+(HOP50_\w+)\s+([^\n]*)/){
                my $locus = $1; #storing locus tag in key
		my $product = $2; #storing gene product associated to locus tag
                if (exists $locus_tag{$locus}){ #searching for locus tag from database among variants
			$var_sum++; #counting number I/L assignments among variants
			$COG{$locus}=$product; #populating COG database as locus tag: product
			push (@product_tags, $locus); #adding locus tags corresponding to products into an array
			my $statement = "$locus\t$product\t$locus_tag{$locus}";
			unless (exists $db{$statement}){
				print OUT "$statement\n"; ##printing tag, product and COG 
				$db{$statement} = 'a'; #initializing the database 
			}
		}	 
	}
}
