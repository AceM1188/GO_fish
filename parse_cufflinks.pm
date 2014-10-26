package parse_cufflinks;     
#File: parse_cufflinks.pm
use warnings;
use strict;
use Data::Dumper;
use base 'Exporter';
our @EXPORT = qw(parse_cufflinks);
sub parse_cufflinks{
    my $input = shift;
    open(IN, '<', $input) or die "can't open file $input $!\n";
    my @features;
    my %genes;
while(my $line = <IN>){
    chomp $line;
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
