#!/usr/bin/perl                                                                 

use strict;
use warnings;
use Data::Dumper;
use lib "/home/gofish/";
use parsecuff;


my $gref = parsecuffseq("/home/gofish/omp_v_ngn_gene_exp.diff");

my %genes = %{$gref};

print Dumper %genes;

my @gohits = qw(GAB1 GAB2 GAB3 GLS);

my %comphash;

foreach my $hit (@gohits)
{
    if ($genes{$hit})
    {
	$comphash{$hit} = $genes{$hit};
    }

}

print Dumper %comphash;
