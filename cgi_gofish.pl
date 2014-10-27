#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard :html3);
use CGI::Carp qw(fatalsToBrowser);

my @data_types = qw (cuffdiff cufflinks CGH_array);
my @search_modes = qw (AND OR);
my @results;

print header;
print start_html('GO fishing with GO terms'),   
    '<div class="container-fluid">',h1('Search gene data with GO terms'),
    start_multipart_form,
    "Source organism genus (e.g. Homo, Mus, Drosophila):",br
    textarea(-name=>'Genus',-rows=>1,-cols=>40),br,br,
    h3("Input data"),
    "Data Type:  ", radio_group(-name=>'data_type',-value=>\@data_types,-default=>$data_types[0]),br,
    "For cuffdiff: use a p-value cut-off instead of the cuffdiff signicance call", textfield(-name=>'p_value'),br,
    "Upload file here: ",filefield(-name=>'upload_data'),br,br, 
    h3("GO search"),
    "Search parameters:",br
    "One per line, can use GO terms (GO:0044822) or key words (use single quotes to group key words)",br,
    textarea(-name=>'GO_terms and search terms', -rows=>5, -cols=>40),br,br,
    "Search type:", radio_group(-name=>'Search_Mode', -value=>\@search_modes, -default=>$search_modes[0]),br,
submit('Search'),'</div>',
    end_form,
    hr;
my $organism = param ('Genus');
my $file_upload = param ('upload_data');
my $data_type = param ('data_type');
my $search_mode = param ('Search_Mode');
my $term = param ('GO_terms and search terms');
my @terms = split (/\n/, $term);
my $string = join(" ",  @terms);
my $p_val = param ('p_value');

#print h3("search terms:","@terms"), br
#    "search string:",$string, br;
#print h2("@results = `GO_fish.pl --mode CGI --organism $organism --data $file_upload --data_type $data_type --search_mode $search_mode --terms @terms`");
#open (IN,'<','omp_v_ngn_gene_exp.diff') or die "can't read";
#$file_upload = *IN;
#$organism = 'Mus';
#$data_type = 'cuffdiff';
#$search_mode = 'AND';
#my $string = 'GO:0045666';

my $tmp = "/tmp/gofish.$$";
open (OUT, '>', $tmp) or die "can't write";
unless ($file_upload){
    print '<div class="container-fluid">',h2("Please provide a data file."), br, '</div>';
    die;
}

while (my $line = <$file_upload>){ 
    print OUT $line;
}
#my $cmd = "GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --terms $string\n";
#print h3($cmd), br;


#@results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --terms $string`;
#print h3($p_val),br;
if ($p_val){
    @results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --p_value $p_val --terms $string`;
}
else {
    @results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --terms $string`;
}



my $count = scalar @results;

#for (my $t=0; $t<$count; $t++){
#    print "$results[$t]",br;
#}

for (my $t=0; $t<$count; $t++){
    chomp $results[$t];
    if ( $t==0 ){
	my @lineterms = split("\t", $results[$t]);

	print '<div class="container-fluid"><table border="3"><tr>',
	'<th>',$lineterms[0],'</th>',
	'<th>',$lineterms[1],'</th>',
	'<th>',$lineterms[2],'</th>',
	'<th>',$lineterms[3],'</th>',
	'<th>',$lineterms[4],'</th>',
	'</tr>';next;
    }
    my @lineterms = split("\t", $results[$t]);

        print '<tr>',
        '<td>',$lineterms[0],'</td>',
        '<td>',$lineterms[1],'</td>',
        '<td>',$lineterms[2],'</td>',
        '<td>',$lineterms[3],'</td>',
        '<td>',$lineterms[4],'</td>',
    '</tr>';
}
print '</div>';
    
#    }}
#}
#    my @lineterms = split("\t", $results[$t]);
#    foreach my $stuff (@lineterms

#print "@results", br;
print end_html;
