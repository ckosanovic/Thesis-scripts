#!/usr/bin/perl

use strict; use warnings; 

my $name = 'pks_domains.pl';
my $version = 0.1;

my $usage = <<OPTIONS;

NAME            $name
VERSION         $version
SYNOPSIS        Using the result of transATor, compile lists of domains from the split proteins 
USAGE           $name *.txt 

OPTIONS

die "\n$usage\n" unless @ARGV;

while (my $file = shift@ARGV){ 
        open FILE, "<", "$file" or die "Cannot open file\n"; 
        open OUT1, ">", "$file.missing.out";
        open OUT2, ">", "$file.annot.out";
		my $id;
		while (my $line = <FILE>){
		chomp $line;
			if ($line =~ /^(HOP50_\S+)/){
				$id = $1;
				print OUT2 "$id\n";
				}
			elsif ($line =~ /^(No Annotation)/){
				print OUT1 "$id\n";}
			else {
				print OUT2 "$line\n";} 
		}
	
	}	
	
        


