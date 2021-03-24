#!/usr/bin/perl

my $name = 'get_seq_ID.pl';
my $version = '0.1';

use strict; use warnings;

my $usage = <<"OPTIONS";
NAME            $name
VERSION         $version
SYNOPSIS        Generates simple lists of sequence accession numbers from the suspect protein list generated by NCBI
USAGE           get_seq_ID.pl suspect_protein_names.txt
OPTIONS
die "$usage\n" unless @ARGV;

while (my $file = shift@ARGV){
        open IN, "<$file";
        $file =~ s/.txt//; 
        open OUT, ">$file.ID.txt";
        while (my $line = <IN>){
                chomp $line;
                if ($line =~ /(HOP50_[^\n]+)/){print OUT "$1\n";}
        }
}

