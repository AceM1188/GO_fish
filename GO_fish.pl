#!/usr/bin/perl
use strict;
use warnings;
use lib "/home/gofish";
use Getopt::Long;
use GO_Terms;
use parse_cuffdiff;
use parse_cufflinks;
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
my $usage = "\nsyntax:\nGO_fish.pl --organism organism   --data data.file"; 
GetOptions ( "organism=s", \$organism,
	     "data=s", \$data_file,
	     "terms=s{1,}", \@terms,
	     "run_mode=s", \$run_mode,
	     "data_type=s", \$data_type,
	     "search_mode=s", \$search_mode,
    );
unless ($terms[0] and $data_file) {
    warn "$usage\n";
    exit();
}
if ($run_mode eq 'command'){  
    open (IN, '<', $data_file);
    $data_file= *IN;
}

#-------------------#
#Search GO with term#
#-------------------#
#Returns gene symbols in an array 

#TEST DATA
#my @go_hits = qw(CASR CDH23 GAB3 GLS);
unshift(@terms,$search_mode,$organism);
my @go_hits = go_terms(@terms);


#--------------------------#
#Parse gene data#
#--------------------------#
#Returns hash reference, contains gene symbol paired with hash containing info 
my %genes;
if ($data_type eq 'cuffdiff') {
    my $parsed_data = parse_cuffdiff($data_file);
    %genes = %{$parsed_data};
}
if ($data_type eq 'cufflinks') {
    my $parsed_data = parse_cufflinks($data_file);
}
#if ($data_type eq 'CGH_array') {
#    my $parsed_data = parse_CGH_array($data_file);
#}
#print Dumper %genes;



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
print "Gene Symbol\tSample 1\tSample 2\tlog2fold\tp-val\n";
foreach my $gene (keys %comphash){
    print "$gene\t",$comphash{$gene}{'Sample 1'},"\t",$comphash{$gene}{'Sample 2'},"\t",$comphash{$gene}{'log2fold'},"\t",$comphash{$gene}{'p-val'},"\n";
}
print '';
