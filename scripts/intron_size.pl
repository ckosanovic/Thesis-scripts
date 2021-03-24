#!/usr/bin/perl

my $name = 'intron_size.pl';
my $version = 0.1;

use strict; use warnings;
use Getopt::Long qw(GetOptions);

my $options = <<"OPTIONS";

NAME            $name;
VERSION         $version;
SYNOPSIS        Calculates the average intron length from .embl files
USAGE           intron_size.pl -in *.embl -out intron_stats.txt 

OPTIONS:

-i (--in)	EMBL file(s) with intron features
-o (--out)	Output file 

OPTIONS

die $options unless @ARGV;

my @embl; my $output = 'intron_stats.txt';

GetOptions(
	'i|in=s@{1,}' => \@embl,
	'o|output=s' => \$output
	);

my $start;
my $end;
my @introns;

while (my $embl = shift@embl){
	open EMBL, "<", $embl or die "Cannot open EMBL file\n";
	open OUT, ">", $output; 
	while (my $line = <EMBL>){
		chomp $line;
		if (($line =~ /FT\s+intron\s+(\d+)..(\d+)/) | ($line =~ /FT\s+intron\s+complement\((\d+)..(\d+)\)/)){	
			$start = $1;
			$end = $2;
			my $intron = ($end - $start) + 1;
			push (@introns, $intron); 
		}
	}
}	

my $count = scalar(@introns);
my $sum;
foreach (@introns){
	$sum += $_;
	}
my $average = sprintf("%.1f", ($sum/$count));
print OUT "Sum of intron lengths = $sum\n";
print OUT "Total number of introns = $count\n"; 
print OUT "Average intron length = $average\n";
