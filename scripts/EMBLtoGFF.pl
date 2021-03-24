#!/usr/bin/perl
## Pombert Lab, IIT, 2021
my $name = 'EMBLtoGFF.pl';
my $version = '0.1';

use strict; use warnings; use Bio::SeqIO; use File::Basename; use Getopt::Long qw(GetOptions);

my $usage = <<"OPTIONS";
NAME			$name
VERSION			$version
SYNOPSIS		Converts EMBL files to NCBI GFF format
REQUIREMENTS	BioPerl's Bio::SeqIO module
NOTE			The EMBL (*.embl) and FASTA (*.fsa) files must be in the same folder.
				Requires locus_tags to be defined in the EMBL files.
		
USAGE		EMBLtoGFF.pl -embl *.embl
OPTIONS:
-embl		EMBL files to convert
OPTIONS

die "$usage\n" unless @ARGV;

my @embl;
GetOptions( 'embl=s@{1,}' => \@embl );

### Working on EMBL files
my $locus_tag;
while(my $file = shift@embl){
	open IN, "<", "$file" or die "Can't open EMBL file file: $file\n";
	$file =~ s/.embl$//;
	my ($head, $dir) = fileparse($file);
	open GFF, ">", "$file.gff" or die "Can't create GFF output file: $file.gff\n";

	while(my $line = <IN>){ #reading EMBL file
		chomp $line;
		my @start = ();  my @stop = ();

		if ($line =~ /FT\s+\/locus_tag="(\S+)"/){$locus_tag = $1;} ## Grabbing locus tag from EMBL file 
		
		### Working on CDS
		elsif ($line =~ /FT\s+CDS\s+(\d+)..(\d+)/){ ## Forward, single exon
			my $start = $1; my $stop = $2;
			print GFF "$head\tGenBank\tgene\t$start\t$stop\t\.\t\+\t\.\tID=$locus_tag\n";
			print GFF "$head\tGenBank\tmRNA\t$start\t$stop\t\.\t\+\t\.\tID=${locus_tag}_mRNA;Parent=${locus_tag}\n";
			print GFF "$head\tGenBank\texon\t$start\t$stop\t\.\t\+\t0\tID=${locus_tag}_exon-1;Parent=${locus_tag}_mRNA\n";
			print GFF "$head\tGenBank\tCDS\t$start\t$stop\t\.\t\+\t0\tID=${locus_tag}_cds;Parent=${locus_tag}_mRNA\n";
		}
		elsif ($line =~ /FT \s+CDS\s+complement\((\d+)..(\d+)\)/){ ## Reverse, single exon
			my $start = $1; my $stop = $2;
			print GFF "$head\tGenBank\tgene\t$start\t$stop\t\.\t\-\t\.\tID=$locus_tag\n";
			print GFF "$head\tGenBank\tmRNA\t$start\t$stop\t\.\t\-\t\.\tID=${locus_tag}_mRNA;Parent=${locus_tag}\n";
			print GFF "$head\tGenBank\texon\t$start\t$stop\t\.\t\-\t0\tID=${locus_tag}_exon-1;Parent=${locus_tag}_mRNA\n";
			print GFF "$head\tGenBank\tCDS\t$start\t$stop\t\.\t\-\t0\tID=${locus_tag}_cds;Parent=${locus_tag}_mRNA\n";
		}	
		elsif ($line =~ /FT\s+CDS\s+join\((.*)\)/){ ## Forward, multiple exons
			my @array = split(',',$1);
			while (my $segment = shift@array){
				chomp $segment;
				if ($segment =~ /(\d+)..(\d+)/){
					my $strt = $1; my $stp = $2;
					push (@start, $strt);
					push (@stop, $stp);
				}
			}
			### Printing gene, mRNA, exon and then CDS info
			print GFF "$head\tGenBank\tgene\t$start[0]\t$stop[$#start]\t\.\t\+\t\.\tID=$locus_tag\n";
			print GFF "$head\tGenBank\tmRNA\t$start[0]\t$stop[$#start]\t\.\t\+\t\.\tID=${locus_tag}_mRNA;Parent=${locus_tag}\n";
			my $ex_number = 0;
			for (0..$#start){ 
				$ex_number++;
				print GFF "$head\tGenBank\texon\t$start[$_]\t$stop[$_]\t\.\t\+\t\.\tID=${locus_tag}_exon-${ex_number};Parent=${locus_tag}_mRNA\n";
			}
			for (0..$#start){ print GFF "$head\tGenBank\tCDS\t$start[$_]\t$stop[$_]\t\.\t\+\t0\tID=${locus_tag}_cds;Parent=${locus_tag}_mRNA\n"; }
		}
		elsif ($line =~ /FT\s+CDS\s+complement\(join\((.*)/){ ## Reverse, mutiple exons
			my @array = split(',',$1);
			while (my $segment = shift@array){
				chomp $segment;
				if ($segment =~ /(\d+)..(\d+)/){
					my $strt = $1; my $stp = $2;
					unshift (@start, $strt);
					unshift (@stop, $stp);
				}
			}
			### Printing gene, mRNA, exon and then CDS info
			print GFF "$head\tGenBank\tgene\t$start[0]\t$stop[$#start]\t\.\t\-\t\.\tID=$locus_tag\n";
			print GFF "$head\tGenBank\tmRNA\t$start[0]\t$stop[$#start]\t\.\t\-\t\.\tID=${locus_tag}_mRNA;Parent=${locus_tag}\n";
			my $rev_ex = 0;
			for (0..$#start){
				$rev_ex++;
				print GFF "$head\tGenBank\texon\t$start[$_]\t$stop[$_]\t\.\t\-\t\.\tID=${locus_tag}_exon-${rev_ex};Parent=${locus_tag}_mRNA\n";
			}
			for (0..$#start){ print GFF "$head\tGenBank\tCDS\t$start[$_]\t$stop[$_]\t\.\t\-\t0\tID=${locus_tag}_cds;Parent=${locus_tag}_mRNA\n"; }
		}
	}
}
close IN; close GFF;


