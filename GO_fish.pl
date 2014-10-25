#!/usr/bin/perl
use strict;
use warnings;
use lib "/home/gofish";
use Getopt::Long;
#use GO_to_genes;
use parse_cuffdiff;
use Data::Dumper;

#-------------------------------------------#
#Can enter default values for arguments here#
#-------------------------------------------#
my $organism;
my $data_file;
my $GO_term1;
my $usage = "\nsyntax:\nGO_fish.pl --organism organism   --data data.file  --GO_term1 GO_number\n"; 
GetOptions ( "organism=s", \$organism,
	     "data=s", \$data_file,
	     "GO_term1=s", \$GO_term1,
    );
unless ($GO_term1 and $data_file) {
    warn "$usage\n";
    exit();
}

#-------------------#
#Search GO with term#
#-------------------#
#Returns gene symbols in an array 
#my @go_hits = sub go_to_genes ($organism,$GO_term1);

#TEST DATA
my @go_hits = qw(CASR CDH23 GAB3 GLS);



#--------------------------#
#Parse cuffdiff_output data#
#--------------------------#
#Returns hash reference, contains gene symbol paired with hash containing info 
my $parsed_data = parse_cuffdiff($data_file);
my %genes = %{$parsed_data};
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
