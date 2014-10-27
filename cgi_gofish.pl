#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard :html3);
use CGI::Carp qw(fatalsToBrowser);

my @data_types = qw (cuffdiff cufflinks CGH_array);
my @search_modes = qw (AND OR);
my @results;

print header;
print'<head>                                                                                                                                                        
  <meta http-equiv="Content-type" content="text/html; charset=us-ascii">                                                                                            
  <meta name="viewport" content="width=device-width,initial-scale=1">                                                                                               
                                                                                                                                                                    
  <title>PFB 2014 - GO Fish</title>
  <link rel="stylesheet" href="/css/bootstrap.min.css">
  <link rel="shortcut icon" type="image/png" href="/media/images/favicon.png">                                                                                      
  <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">                                                        
  <link rel="stylesheet" type="text/css" href="/media/css/site.css?_=607c09db59a9e4a8f0f581d6c3abe039">                                                             
  <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.3/css/jquery.dataTables.css">                                                              
  <style type="text/css" class="init">                                                                                                                              
                                                                                                                                                                    
    </style>                                                                                                                                                        
  <script type="text/javascript" src="/media/js/site.js?_=84d810f6d7da51ea6c89371339679ed6"></script>                                                               
  <script type="text/javascript" src="/media/js/dynamic.php?comments-page=examples%2Fbasic_init%2Fzero_configuration.html" async=""></script>                       
  <script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.11.1.min.js"></script>                                                       
  <script type="text/javascript" language="javascript" src="//cdn.datatables.net/1.10.3/js/jquery.dataTables.min.js"></script>                                      
  <script type="text/javascript" language="javascript" src="../resources/demo.js"></script>                                                                         
  <script type="text/javascript" class="init">                                                                                                                      
                                                                                                                                                                    
                                                                                                                                                                    
    $(document).ready(function() {                                                                                                                                  
        $(\'#example\').DataTable({                                                                                                                                 
          paging:false});                                                                                                                                           
    } );                                                                                                                                                            
                                                                                                                                                                    
                                                                                                                                                                    
</script>                                                                                                                                                           
</head>                                                                                                                                                             
                                                                                                                                                                    
<body class="wide comments example">                                                                                                                                
  <a name="top"></a>    


<div class="container-fluid"><h1><a href=""#"">Search gene data with GO terms</a><h3>Model Organism</h3></h1><p>Source organism genus (e.g. Homo, Mus, Drosophila):</p>',start_multipart_form,textarea(-name=>'Genus',-rows=>1,-cols=>40),br,br,h3("Input data"),h4("Data Type:  "), radio_group(-name=>'data_type',-rows=>'3' ,-value=>\@data_types,-default=>$data_types[0]),br,"For cuffdiff: use a p-value cut-off instead of the cuffdiff signicance call:         ", textfield(-name=>'p_value'),br,br,

"For CGH_array: Amplification/Deletion cutoff value:   ",textfield(-name=>'cnv_cutoff'),br,

br,"Upload file here: ",filefield(-name=>'upload_data'),br,h3("GO search"),

"Search parameters:",br,"One per line, can use GO terms (GO:0044822) or key words (use single quotes to group key words)",br,

textarea(-name=>'GO_terms and search terms', -rows=>5, -cols=>40),br,br,

br,"Allowed GO evidence codes","<div class='checkbox'>",checkbox_group(-name=>'ev_codes', -column=> 1, -values => ['IDA','IPI','IGI','IMP','IEP','TAS','IC','NAS','IBA','IEA','ISS','ISO','RCA'], -defaults=> ['IDA','IPI','IGI','IMP','IEP']),"</div>",br,a({href=>"http://geneontology.org/page/guide-go-evidence-codes"},"Meaning of GO evidence codes"),br,br,

"Search type:", br, br, radio_group(-name=>'Search_Mode', -value=>\@search_modes, -default=>$search_modes[0]),br,

br, submit('Search'),'</div>',end_form,hr;


my $organism = param ('Genus');
my $file_upload = param ('upload_data');
my $data_type = param ('data_type');
my $search_mode = param ('Search_Mode');
my $term = param ('GO_terms and search terms');
my @terms = split (/\n/, $term);
my $string = join(" ",  @terms);
my $cnv_cut = param('cnv_cutoff');
my $p_val = param ('p_value');
my $ev_codes = join ("--",param ('ev_codes'));
unless ($ev_codes){
    $ev_codes = '!IEA';
}

unless ($file_upload){
    print '<div class="container-fluid">',h2("Please provide a data file."), br, '</div>';
   # die;
}

my $tmp = "/tmp/gofish.$$";
open (OUT, '>', $tmp) or die "can't write";

while (my $line = <$file_upload>){ 
    print OUT $line;
}

if ($cnv_cut){
    @results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --cnv_cutoff $cnv_cut --evcode $ev_codes --terms $string`;
}
elsif ($p_val){
    @results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --p_value $p_val --evcode $ev_codes --terms $string`;
}
else {
    @results = `/home/gofish/GO_fish.pl --run_mode CGI --organism $organism --data $tmp --data_type $data_type --search_mode $search_mode --evcode $ev_codes --terms $string`;
}




my $count = scalar @results;


for (my $t=0; $t<$count; $t++){
    chomp $results[$t];
    if ( $t==0 ){
	my @lineterms = split("\t", $results[$t]);
	print 

'<a name="top"></a>                                                                                  
                                                                                                      
  <div class="fw-container">                                                                          
    <div class="fw-body">                                                                             
      <div class="content">                                                                           
        <h1 class="page_title">Results!</h1>                                                          
                                                                                                      
        <table id="example" class="display"  width="100%">                             
          <thead>                                                                                     
            <tr>                                                                                      
              <th>',$lineterms[0],'</th>                                                                           
              <th>',$lineterms[1],'</th>                                                                       
              <th>',$lineterms[2],'</th>                                                                         
              <th>',$lineterms[3],'</th>                                                                            
              <th>',$lineterms[4],'</th>                                                                     
                                                                                    
              </tr>                                                                                   
            </thead>                                                                                  
                                                                                                      
          <tfoot>                                                                                     
            <tr>                                                                                      
              <th>',$lineterms[0],'</th>                                                                           
              <th>',$lineterms[1],'</th>                                                                       
              <th>',$lineterms[2],'</th>                                                                         
              <th>',$lineterms[3],'</th>                                                                            
              <th>',$lineterms[4],'</th>                                                                     
                                                                                  
              </tr>                                                                                   
            </tfoot>                                                                                  
 <tbody>'; next;}                 

    my @lineterms = split("\t", $results[$t]);

    print '<tr><td>','<a title="look at gene info" href="http://www.ncbi.nlm.nih.gov/gene/?term=',$lineterms[0],'\
+',lc($organism),'">',$lineterms[0],'</a>','</td><td>',$lineterms[1],'</td><td>',$lineterms[2],'</td><td>',$lineterms[3],'</td><td>',$lineterms[4],'</td></tr>';}                                                                                                        
print            
    '</tbody>                                                                                  
          </table></body>';

my $command = "rm -f $tmp";

system($command);

print end_html;
