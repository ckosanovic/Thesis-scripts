#!/usr/bin/perl

my $name = 'gene_var_type.pl';
my $version = 0.1;

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME            $name
VERSION         $version
SYNOPSIS        Parsing output of all_COG_genes.pl (all_COG_products.tsv) with variant_types.tsv file to determine location, product, COG assignment and variant type per gene	 
USAGE           gene_var_type.pl -in all_COG_products.tsv -var variant_types.tsv -out [default: gene_var_type.tsv]

OPTIONS:
-i (--in)      Input file using the output of all_COG_genes.pl [all_COG_products.tsv] listing locus tag, product and COG assignment
-v (--var)     Input file using output of sort_variants.pl [variant_types.tsv] listing locus tag and variant type
-o (--out)     Output file containing location, product, COG assignment, and variant type   
OPTIONS

die "\n$options\n\n" unless @ARGV;

my $in; my $var; 
my $out = 'gene_var_type.tsv';

GetOptions(
        'v|var=s' => \$var,
        'i|in=s' => \$in,
	'o|out=s' => \$out
);

### Filling the variant database
my %var_type;
open VAR, "<", "$var" or die "Can't open products file\n";
while(my $dbkey = <VAR>){
        chomp $dbkey;
        if($dbkey =~ /^(\S+)\t(.*)$/){
                my $locus = $1;
                my $type = $2;
                push (@{$var_type{$locus}}, $type);
        }
}

## Working on COG file; checking if the locus_tags within are found the the var_type database above
open IN, "<", "$in" or die "Can't open input file\n";
open OUT, ">", "$out" or die "Can't write output file\n";
print OUT '## Locus tag'."\t".'Product'."\t".'COG assignment'."\t";
print OUT 'Total # variants'."\t".'Missense'."\t".'Synonymous'."\t".'Intron variant'."\t".'Intergenic variant'."\t";
print OUT 'Inframe insertion'."\t".'Inframe deletion'."\t".'Frameshift variant'."\t".'Protein altering variant'."\t";
print OUT 'Splice region variant'."\t".'Splice acceptor variant'."\t".'Splice donor variant'."\t".'Coding sequence variant'."\t".'Stop gained'."\t";
print OUT 'Start lost'."\t".'Stop lost'."\t".'Start retained variant'."\t".'Stop retained variant'."\n";

my %features;
while (my $line = <IN>){
	chomp $line;
	my @column = split("\t", $line);
	my $locus_tag = $column[0];
	my $product = $column[1];
	my $COG = $column[2];
        if (exists $var_type{$locus_tag}){
                $features{$locus_tag}[0] = $product;
                $features{$locus_tag}[1] = $COG;
                $features{$locus_tag}[2] = scalar @{$var_type{$locus_tag}};
                foreach my $element (@{$var_type{$locus_tag}}){ 
                        if ($element eq 'missense_variant'){ $features{$locus_tag}[3] += 1; }
                        elsif ($element eq 'synonymous_variant'){ $features{$locus_tag}[4] += 1; }
                        elsif ($element eq 'intron_variant'){ $features{$locus_tag}[5] += 1; }
                        elsif ($element eq 'intergenic_variant'){ $features{$locus_tag}[6] += 1; }
                        elsif ($element eq 'inframe_insertion'){ $features{$locus_tag}[7] += 1; }
                        elsif ($element eq 'inframe_deletion'){ $features{$locus_tag}[8] += 1; }
                        elsif ($element eq 'frameshift_variant'){ $features{$locus_tag}[9] += 1; }
                        elsif ($element eq 'protein_altering_variant'){ $features{$locus_tag}[10] += 1; }
                        elsif ($element eq 'splice_region_variant'){ $features{$locus_tag}[11] += 1; }
                        elsif ($element eq 'splice_acceptor_variant'){ $features{$locus_tag}[12] += 1; }
                        elsif ($element eq 'splice_donor_variant'){ $features{$locus_tag}[13] += 1; }
                        elsif ($element eq 'coding_sequence_variant'){ $features{$locus_tag}[14] += 1; }
                        elsif ($element eq 'stop_gained'){ $features{$locus_tag}[15] += 1; }
                        elsif ($element eq 'start_lost'){ $features{$locus_tag}[16] += 1; }
                        elsif ($element eq 'stop_lost'){ $features{$locus_tag}[17] += 1; }
                        elsif ($element eq 'start_retained_variant'){ $features{$locus_tag}[18] += 1; }
                        elsif ($element eq 'start_retained_variant'){ $features{$locus_tag}[19] += 1; }
                }
        }
}

## Performing a summary of location, product, COG assignment and variant type per gene...
for my $key (sort(keys%features)){
        print OUT "$key\t"."$features{$key}[0]\t"."$features{$key}[1]\t"."$features{$key}[2]\t";
        if (defined $features{$key}[3]){print OUT "$features{$key}[3]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[4]){print OUT "$features{$key}[4]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[5]){print OUT "$features{$key}[5]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[6]){print OUT "$features{$key}[6]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[7]){print OUT "$features{$key}[7]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[8]){print OUT "$features{$key}[8]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[9]){print OUT "$features{$key}[9]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[10]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[11]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[12]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[13]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[14]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[15]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[16]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[17]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[18]\t";}
        else{ print OUT "0\t";}
        if (defined $features{$key}[10]){print OUT "$features{$key}[19]\n";}
        else{ print OUT "0\n";}
}
