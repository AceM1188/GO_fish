package parse_cuffdiff;     
#File: parse_cuffdiff.pm                                                                                         
use warnings;
use strict;
#use Data::Dumper;
use base 'Exporter';
our @EXPORT = qw(parse_cuffdiff);
sub parse_cuffdiff{
    my $input = shift;
    my $fold_cutoff = shift;
    my @features;
#my @info;
    my %genes;
    while(my $line = <$input>){
	chomp $line;
	@features = split("\t",$line);
	if($features[13] =~ /yes/) {
        my $significance = $features[0];
        $significance = uc($significance);
#locates genes with indicated significant fold change                                                 

        $genes{$significance}{'Sample 1'} = $features[7];
        $genes{$significance}{'Sample 2'} = $features[8];
        $genes{$significance}{'log2fold'} = $features[9];
        $genes{$significance}{'p-val'} = $features[11];



        #@info = ($significance, $features[7], $features[8], $features[9], $features[11]);                    
#populates array with gene ID, sample 1 expression, sample 2 expression, log2fold change, p-value             

        #print join "\t" , @info,"\n";                                                                        
    }

}
return \%genes;
}
1;
