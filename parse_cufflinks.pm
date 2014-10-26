package parse_cufflinks;     
#File: parse_cufflinks.pm
use warnings;
use strict;
use Data::Dumper;
use base 'Exporter';
our @EXPORT = qw(parse_cufflinks);
sub parse_cufflinks{
    my $input = shift;
    my @features;
    my %genes;
    my $line_counter = 0;
    while(my $line = <$input>){
	chomp $line;
	if ($line_counter == 0) {
	$line_counter++;    next;
	}
	@features = split("\t",$line);
	my $gene = uc($features[0]);
	$genes{$gene}{'fpkm'} = $features[9];
	$genes{$gene}{'conf_lo'} = $features[10];
	$genes{$gene}{'conf_hi'} = $features[11];
	$genes{$gene}{'coord'} = $features[6];
	
}
#    print Dumper %genes;
#    print '';
return \%genes;
}
1;
