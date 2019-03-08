#!/usr/bin/perl -w

# IMAtoPHYLIP.ph

# This script is designed to read an IMa2 file and output each locus to a separate Phylip file named for the locus/contig
# The input IMa2 file must be specified
# Optionally, a string matching exactly (in whole or part) locus names can be supplied; otherwise script assumes output is from dDocent/rad_haplotyper
# Optionally, a space can be inserted after X number of characters; assumes all OTU names are the same length

# Created by Stuart Willis
# Created on March 1, 2019

# third party modules
use strict;
use Data::Dumper;
use Getopt::Long;

# initialize global variables
my $imafile;
my $locus_string='dDocent';
my $insert_space;
my $space_after_position;
my $i=0;
my $OUTPUT;

GetOptions(	'imafile|i=s' => \$imafile,
			'space_after_position|p=i' => \$space_after_position,
			'locus_string|l=s' => \$locus_string
			);

unless (defined($imafile)) {
	die "\nUsage: perl SCRIPT.pl -i/--imafile path [-l/--locus_string string] [-p/--space_after_position integer]\n";
}

print "\nThe script will be looking for \"$locus_string\" to identify loci.\n";

open (my $INPUT,"<",$imafile) or die "Can't open input file for the following reason: $!.\n"; # opening the input file

# reading in data by line, searching for strings, acting accordingly to set variable or print
while (my $line = readline($INPUT)) { # iterates over each line in the source file
	chomp $line;
	next unless ($line);
	$i++;

#	print "$i\n";
#	print "$i	$line\n";

	if ($line =~ m/^$locus_string/ && $i>5) { #checks for matching locus identifier
		#close previous output file
		my @locus = $line =~ m/^($locus_string[\w]+)[\s]+/;
		print "\nI found \"$locus[0]\" on line $i\n";
		if ($OUTPUT) {  
			print $OUTPUT "\n"; #add extra line to last output
			close ($OUTPUT) or die "The previous output file could not be closed for the following reason: $!.\n"; # closing the input file
		}
		#now make this line into an array to collect 1) contig name (@array[0], 2) length of sequences (@array[3rd from end]), 3) number of individuals (@array[1] to @array[4th from end])
		#my @line_array = split /\t/, $line; # create array with the contents of each line split by tabs
		my @heading_array = split /\s/, $line; # create array with the contents of each line split by spaces
		my $newfile = "$heading_array[0]" . '_phylip.txt';
		print "For locus $heading_array[0], the PHYLIP file will be $newfile\n"; #print to stdout for check
		#check if new potential output file exists
		if (-r $newfile) {
			die "Oops! The file $newfile already exists. Please play again later.\n";	
		}
		#print this information as first line in new output file
		open ($OUTPUT,">",$newfile) or die "Can't open input file for the following reason: $!.\n"; # opening the input file
		my $sequences = 0;
		my $last_pop = $#heading_array-3;
		for (my $j = 1; $j <= $last_pop; $j++) {
			$sequences += $heading_array[$j];
		}
		my $length = $heading_array[$#heading_array-2];
		print "There were $heading_array[$last_pop] alleles in the last population out of $sequences total, each $length base pairs long.\n\n"; #print to stdout for check
		print $OUTPUT "$sequences   $length\n";
	} elsif ($i>5) {
		if ($space_after_position) {
			my ($first,$second) = $line =~ m/^(.{$space_after_position})(.+)$/; #printing line to output file, inserting a single space at position specified 
			my $newline = "$first" . " " . "$second";
			$newline =~ tr/ / /s; #compress any whitespace into a single space, ensuring there is only a single space between "OTU" and "sequence"
			print $OUTPUT "$newline\n"; #to output file		
		} else {
		#printing line to output file, unadulterated
			print $OUTPUT "$line\n"; #to output file
		}
	}
}

close ($OUTPUT) or die "The output file could not be closed for the following reason: $!.\n"; # closing the last output file
close ($INPUT) or die "The input file could not be closed for the following reason: $!.\n"; # closing the input file

