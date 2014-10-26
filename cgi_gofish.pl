#!/usr/bin/perl
use strict;
use warnings;
use CGI ':standard';
my @data_types = qw (cuffdiff cufflinks CGH_array);
my @search_modes = qw (AND OR);
my @results;
print header;
print start_html('GO fishing with GO terms'),
    h1('Search gene data with GO terms'),
    start_multipart_form,
    "Source organism genus (e.g. Homo, Mus, Drosophila):",br
    textarea(-name=>'Genus',-rows=>1,-cols=>40),br,br,
    h3("Input data"),
    "Data Type:  ", radio_group(-name=>'data_type',-value=>\@data_types,-default=>$data_types[0]),br,
    "Upload file here: ",filefield(-name=>'upload_data'),br,br, 
    h3("GO search"),
    "Search parameters:",br
    "   Can use GO terms (GO:00000000) or key words (use single quotes to group key words)",br,
    textarea(-name=>'GO_terms and search terms', -rows=>5, -cols=>40),br,br,
    "Search type:", radio_group(-name=>'Search_Mode', -value=>\@search_modes, -default=>$search_modes[0]),br,
submit('Search'),
end_form,
    hr;
my $organism = param ('Genus');
my $file_upload = param ('upload_data');
my $data_type = param ('data_type');
my $search_mode = param ('Search_Mode');
my $term = param ('GO_terms and search terms');
my @terms = split (/\s/, $term);
my $string = join(/ /,  @terms);

#print h2("@results = `GO_fish.pl --mode CGI --organism $organism --data $file_upload --data_type $data_type --search_mode $search_mode --terms @terms`");
#open (IN,'<','omp_v_ngn_gene_exp.diff') or die "can't read";
#$file_upload = *IN;
#$organism = 'Mus';
#$data_type = 'cuffdiff';
#$search_mode = 'AND';
#my $string = 'GO:0045666';

my $tmp = "/tmp/gofish.$$";
open (OUT, '>', $tmp) or die "can't write";
while (my $line = <$file_upload>){ 
    print OUT $line;
}
#my $cmd = "GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --terms $string\n";
@results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --terms $string`;

h3(print join (/--/,@results));
print '';
print end_html;
