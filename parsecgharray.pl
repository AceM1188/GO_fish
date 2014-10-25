#!/usr/bin/perl                                                                                               
use warnings;
use strict;
use Data::Dumper;

my $input = shift;
open(IN, '<', $input) or die "can't open file $input $!\n";

my @features;
#my @info;
my %genes;
my $sampleID;
my $id;
my $del;
my $amp;

while(my $line = <IN>){
    chomp $line;
    @features = split("\t",$line);
    
    if($features[0] =~ /US_/){
	$sampleID = $features[0];
    }
    
    elsif(($features[8]<0.05) && ($features[9])){
	$id = $features[9];
	$id = uc($id);

	if($features[6]>=1){
	    $amp = $features[6];
	}
	
	elsif($features[7]<=-1){
	    $del = $features[7];
	    }
	    
        #locates genes with indicated significant fold change                                                 
	    
        $genes{$sampleID}{$id}{'p-val'} = $features[8];
        $genes{$sampleID}{$id}{'Amplification'} = $amp;
        $genes{$sampleID}{$id}{'Deletion'} = $del;
    }
    }

        #@info = ($significance, $features[7], $features[8], $features[9], $features[11]);                    
#populates array with gene ID, sample 1 expression, sample 2 expression, log2fold change, p-value             

        #print join "\t" , @info,"\n";                                                                        
    


print Dumper \%genes;
