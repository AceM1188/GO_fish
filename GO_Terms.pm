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
    my $apph = GO::AppHandle->connect(\@org);
    my $mode = shift;
    my $genus = shift;
    my @sterm = @_;
    
    my @golist;
    my @golist2;
    
    my %andhash;
    my $count = 0;
    my $assocs;
    my $assoc;
    my $term;
    
    if ($mode eq "OR"){
	foreach my $search(@sterm){
	    
	    if ($search=~ /^GO/){
                $term = $apph->get_term({acc=>$search});
                $assocs = $apph->get_associations(
                    -term=>$term
                    );
		
            }
	    else{

		$term = $apph->get_terms(
		    {search=>"*$search*",
		     search_fields=>"name,synonym"}
		    );
		
		$assocs = $apph->get_associations(
		    -term=>$term
		    ); print STDERR "Didn't choke at association!\n";
	    }
	    foreach my $assoc (@{$assocs}) {
		if ($assoc->gene_product->species->genus eq $genus){
		    push @golist,uc( $assoc->gene_product->symbol); 
		}
	    }
	}
    }
    
	
    if ($mode eq "AND"){
	foreach my $search(@sterm){
	    
	    
	    if ($search=~ /^GO/){
		$term = $apph->get_term({acc=>$search});
		$assocs = $apph->get_associations(
		    -term=>$term
		    );
	     
	    }
	    else{
		
		$term = $apph->get_terms(
		    {search=>"*$search*",
		     search_fields=>"name,synonym"}
		    );
		
		
		$assocs = $apph->get_associations(
		    -term=>$term
		    );
	    }
	    
	    
	    foreach my $assoc (@{$assocs}) {
		if ($assoc->gene_product->species->genus eq $genus){
		    push (@golist2, $assoc->gene_product->symbol);
		}
	    }
	    @golist2 = uniq @golist2;
	    foreach my $gene(@golist2){
		$andhash{$gene}++;
		
	    }
	    
	}    
	
	foreach my $key (keys %andhash){
	    $count++;
	    if ($andhash{$key}==$count){
		push (@golist, uc($key));
	    }
	}
    }

    @golist = uniq(@golist);
    return @golist;
}

1;
