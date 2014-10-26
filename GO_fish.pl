#!/usr/bin/perl
use strict;
use warnings;
use lib "/home/gofish";
use Getopt::Long;
use GO_Terms;
use parse_cuffdiff;
use parse_cufflinks;
use parse_cgh;
use Data::Dumper;

#-------------------------------------------#
#Can enter default values for arguments here#
#-------------------------------------------#
my $organism;
my $search_mode= 'AND';
my $run_mode = 'command'; #defaults to command line unless called by cgi script
my $data_file;
my $data_type;
my @terms; #= 'GO:0045666' #test data for Neurog1
my $usage = "\nsyntax:\nGO_fish.pl --organism Genus --data data.file --data_type cuffdiff/cufflinks --search_mode 'AND'/'OR' --terms GO:0000000/'key words'\n"; 
GetOptions ( "organism=s", \$organism,
	     "data=s", \$data_file,
	     "terms=s{1,}", \@terms,
	     "run_mode=s", \$run_mode,
	     "data_type=s", \$data_type,
	     "search_mode=s", \$search_mode,
    );
unless ($terms[0] and $data_file and $data_type) {
    warn "$usage\n";
    exit();
}
open (IN, '<', $data_file) or die "can't open";
$data_file = *IN;


#-------------------#
#Search GO with term#
#-------------------#
#Returns gene symbols in an array 

#TEST DATA
#my @go_hits = qw(CASR CDH23 GAB3 GLS);
unshift(@terms,$search_mode,$organism);
my @go_hits = go_terms(@terms);
#print Dumper @go_hits;
print '';
#--------------------------#
#Parse gene data#
#--------------------------#
#Returns hash reference, contains gene symbol paired with hash containing info 
my %genes;
my $parsed_data;
if ($data_type eq 'cuffdiff') {
    $parsed_data = parse_cuffdiff($data_file);
}
if ($data_type eq 'cufflinks') {
    $parsed_data = parse_cufflinks($data_file);
}
if ($data_type eq 'CGH_array') {
    $parsed_data = parse_cgh($data_file);
}
%genes = %{$parsed_data};
#print Dumper %genes;
#print '';


#--------------------------------#
#Recover GO hits from parsed data#
#--------------------------------#
my %comphash;
foreach my $hit (@go_hits){
    if ($genes{$hit}){
        $comphash{$hit} = $genes{$hit};
    }
}
#print Dumper %comphash;


#--------------------------------------------#
#Print tab delimited GO hits with parsed data#
#--------------------------------------------#
if ($data_type eq 'cuffdiff') {
    print "Gene Symbol\tSample 1\tSample 2\tlog2fold\tp-val\n";
    foreach my $gene (keys %comphash){
	print "$gene\t",$comphash{$gene}{'Sample 1'},"\t",$comphash{$gene}{'Sample 2'},"\t",$comphash{$gene}{'log2fold'},"\t",$comphash{$gene}{'p-val'},"\n";
    }
}

 if ($data_type eq 'cufflinks') {
     print "Gene Symbol\tFPKM\tLow Confidence Interval\tHigh Confidence Interval\tGene Coordinates\n";
     foreach my $gene (keys %comphash){
         print "$gene\t",$comphash{$gene}{'fpkm'},"\t",$comphash{$gene}{'conf_lo'},"\t",$comphash{$gene}{'conf_hi'},"\t",$comphash{$gene}{'coord'},"\n";}}


if ($data_type eq 'CGH_array') {
      print "Gene Symbol\tProbe Set\tSample\tp-val\tCopy Number Variation\n";
      foreach my $gene (keys %comphash){
	  foreach my $probeset(keys %{$comphash{$gene}}){
 	    foreach my $sample (keys %{$comphash{$gene}{$probeset}}){
 		print "$gene\t$probeset\t$sample\t",$comphash{$gene}{$probeset}{$sample}{'p-val'}, "\t", $comphash{$gene}{$probeset}{$sample}{'CNV'}, "\n";
 	    }
 	}
      }
}
