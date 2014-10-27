package GO_fish;
use warnings;
use strict;
use base 'Exporter';
use GO::AppHandle;
use Data::Dumper;
use List::MoreUtils qw/ uniq /;

our @EXPORT = qw(parse_cgh parse_cufflinks parse_cuffdiff go_terms);
sub go_terms{

    my @org = qw(-d mygo -dbuser gofish -dbauth gofish -port 4085 -h localhost);
    my $apph = GO::AppHandle->connect(\@org);
    my $mode = shift;
    my $genus = shift;
    my $evcode_string = shift;
    my @evcodes = split ("--", $evcode_string);
    $apph->filters({evcodes=>[@evcodes]});
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
                next if(!defined $assoc->gene_product->species->genus);
                if ($assoc->gene_product->species->genus eq $genus){
                    push @golist,uc( $assoc->gene_product->symbol);
                }
            }
        }
    }


    if ($mode eq "AND"){
        foreach my $search(@sterm){
            my @golist2;
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
                next if(!defined $assoc->gene_product->species->genus);
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
            if ($andhash{$key}==scalar @sterm){
                push (@golist, uc($key));

            }
        }
    }

    @golist = uniq(@golist);
    return @golist;
}

sub parse_cuffdiff{
    my $input = shift;
    my $p_cutoff = shift;
    my @features;
    my %genes;
    my $counter = 0;
    while(my $line = <$input>){
        chomp $line;
        if ($counter ==0){
            $counter++;
            next;
        }
        @features = split("\t",$line);
        if ($p_cutoff){
            if($features[11]<$p_cutoff){
                my $significance = $features[0];
                $significance = uc($significance);
                $genes{$significance}{'Sample 1'} = $features[7];
                $genes{$significance}{'Sample 2'} = $features[8];
                $genes{$significance}{'log2fold'} = $features[9];
                $genes{$significance}{'p-val'} = $features[11];
            }
        }
        elsif($features[13] =~ /yes/) {
	    my $significance = $features[0];
	    $significance = uc($significance);
	    $genes{$significance}{'Sample 1'} = $features[7];
	    $genes{$significance}{'Sample 2'} = $features[8];
	    $genes{$significance}{'log2fold'} = $features[9];
	    $genes{$significance}{'p-val'} = $features[11];
    
	}
    }
    return \%genes;
}

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
    return \%genes;
}

sub parse_cgh{
#This script will take a CGH array input file and parse through to produce a hash of gene names and the corresponding patients and metrics (i.e. ABPOEC3G => chr22:..-.. => NA12891 => p-val=0.05 cnv=2)#
#This is a subroutine and will be transferred over to a module with other parsing subroutines.

my $input = shift;
my $cnv_cutoff = shift;

unless ($cnv_cutoff){$cnv_cutoff =0}
#open(IN, '<', $input) or die "can't open file $input $!\n";

my @features;
my %genes;
my $sample;

#--------------------------------------------------------------------#
# Open the file and parse through each line.
#--------------------------------------------------------------------#
while(my $line = <$input>){
    chomp $line;
    @features = split("\t",$line);

    my $id;
    my $chr;
    my $start;
    my $stop;
    my $probeset;
    my $cnv;
    my @multiple;

#--------------------------------------------------------------------#
# Look for the sample name i.e. NA12891.
#--------------------------------------------------------------------#

    if($features[0] =~ /US_/){
	$sample = $features[0];
    }
    
    elsif(($features[8]<0.05) && ($features[9])){
	    $id = $features[9];
	    $id = uc($id);
	    
#--------------------------------------------------------------------#
# If the gene list has multiple genes separated by commas, this
# separates the criteria per each gene.
#--------------------------------------------------------------------#

	   if($id =~ /.+,\s.+/){
	    
	       @multiple = split(/, /,$id);
		    
		    foreach my $individualgene (@multiple){
			$chr = $features[1];
			$start = $features[3];
			$stop = $features[4];
			$probeset = $chr . ':' . $start . '-' . $stop;
			
			if($cnv_cutoff == 0){
			    if($features[6]>$cnv_cutoff){
				$cnv = $features[6];
			    }
			    elsif($features[7]<$cnv_cutoff){
				$cnv = $features[7];
			    }       
			}

			else{
			if ($cnv_cutoff > 0){ 
			    if($features[6]>$cnv_cutoff){
				$cnv = $features[6];
			       }
			    else{next;}
			}
			if ($cnv_cutoff < 0){   
			    if($features[7]<$cnv_cutoff){
				$cnv = $features[7];
			    }
			    else{next;}
			}}
			$genes{$individualgene}{$probeset}{$sample}{'p-val'} = $features[8];
			$genes{$individualgene}{$probeset}{$sample}{'CNV'} = $cnv;
			
		    }
	    }
	    
#--------------------------------------------------------------------#
# If the gene list has only ONE gene, populate the hash with the 
# criteria from that line.
#--------------------------------------------------------------------# 

	 else{
	    $chr = $features[1];
	    $start = $features[3];
	    $stop = $features[4];
	    $probeset = $chr . ':' . $start . '-' . $stop;

	               if($cnv_cutoff == 0){
			    if($features[6]>$cnv_cutoff){
				$cnv = $features[6];
			    }
			    elsif($features[7]<$cnv_cutoff){
				$cnv = $features[7];
			    }       
		       }
	    else{
	               if ($cnv_cutoff > 0){ 
			   if($features[6]>$cnv_cutoff){
				$cnv = $features[6];
			   }
			   else{next;}
			}
		       if ($cnv_cutoff < 0){   
			   if($features[7]<$cnv_cutoff){
				$cnv = $features[7];
			   }
			   else{next;}
		       }
	    }
	       $genes{$id}{$probeset}{$sample}{'p-val'} = $features[8];
	       $genes{$id}{$probeset}{$sample}{'CNV'} = $cnv;
	 }
    }

}
return \%genes;
}

1;
