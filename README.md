# IMAtoPHYLIP
convert IMa2 file to individual PHYLIP files

This script is designed to read an IMa2 file and output each locus to a separate Phylip file named for the locus/contig

The input IMa2 file must be specified

Optionally, a string matching exactly (in whole or part) locus names can be supplied; otherwise script assumes output is from dDocent/rad_haplotyper

Optionally, a space can be inserted after X number of characters; assumes all OTU names are the same length


Usage: perl SCRIPT.pl -i/--imafile path [-l/--locus_string string] [-p/--space_after_position integer]

example usage:

perl IMAtoPHYLIP.pl -i rad_haplotyper_output.ima.txt -l dDocent -p 10
