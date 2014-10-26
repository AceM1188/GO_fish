package GO_Terms;
# file: GO_Terms.pm!
use base 'Exporter';
use strict;
use warnings;
use GO::AppHandle;
use Data::Dumper;
use List::MoreUtils qw/ uniq /;

our @EXPORT = qw(go_terms);

sub go_terms{

my @org = qw(-d mygo -dbuser gofish -dbauth gofish -port 4085 -h localhost);

my $genus = shift;

my $apph = GO::AppHandle->connect(\@org);

my $goterm = shift;

my $assocs = $apph->get_associations(-term=>{acc=>$goterm});

my @golist;

foreach my $assoc (@{$assocs}) {
    if ($assoc->gene_product->species->genus eq "$genus"){
	push @golist,uc( $assoc->gene_product->symbol); 
    }
}

@golist = uniq @golist;

return @golist;

}
1;
