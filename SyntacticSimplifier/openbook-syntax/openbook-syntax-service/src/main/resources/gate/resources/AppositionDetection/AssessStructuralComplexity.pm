
# Modifications begun: 19/7/2012
package AssessStructuralComplexity;
use English;
use strict;


sub assessment{
    my ($sentence) = @_;
    my $structural_complexity = 0;

    my $num_subordinators = 0;
    my $num_coordinators = 0;
    my $num_coordinators_subordination_boundaries = 0;
    my $sentence_length = 0;

    my $max_num_subordinators = 8;
    my $max_num_coordinators = 8;
    my $max_sentence_length = 8;
    my $max_num_coordinators_subordination_boundaries = 8;

    my $original_sentence = $sentence;

    while(1){
	if($sentence =~ /^<PC/){
	    $sentence = $POSTMATCH;
	    $num_coordinators_subordination_boundaries++;
	    $sentence_length++;
	}
	elsif($sentence =~ /^CLASS\=\"(SPECIAL|COMBINATORY)\"/){
	    $sentence = $POSTMATCH;
	    $num_coordinators++;
	}
	elsif($sentence =~ /^CLASS\=\"(S|E)([^\"]+)\"/){
	    $sentence = $POSTMATCH;
	    $num_subordinators++;
	}
	elsif($sentence =~ /^CLASS\=\"C(M|I)([^\"]+)\"/){
	    $sentence = $POSTMATCH;
	    $num_coordinators++;
	}
	elsif($sentence =~ /^<w /){
	    $sentence = $POSTMATCH;
	    $sentence_length++;
	}
	elsif($sentence =~ /^./){
	    $sentence = $POSTMATCH;
	    $sentence_length++;
	}
	else{
	    last;
	}
    }

    open(TEMP_LOG, ">>./num_coordinators_subordination_boundaries.txt");
    print TEMP_LOG "\[$original_sentence\]\t$num_coordinators_subordination_boundaries\n";
    close(TEMP_LOG);
    open(TEMP_LOG, ">>./num_subordinators.txt");
    print TEMP_LOG "\[$original_sentence\]\t$num_subordinators\n";
    close(TEMP_LOG);
    open(TEMP_LOG, ">>./num_coordinators.txt");
    print TEMP_LOG "\[$original_sentence\]\t$num_coordinators\n";
    close(TEMP_LOG);
    open(TEMP_LOG, ">>./sentence_lengths.txt");
    print TEMP_LOG "\[$original_sentence\]\t$sentence_length\n";
    close(TEMP_LOG);


    my $subordinator_ratio = ($num_subordinators + 1) / ($max_num_subordinators + 1);
    my $coordinator_ratio = ($num_coordinators + 1) / ($max_num_coordinators + 1);
    my $coordinator_subordination_boundary_ratio = ($num_coordinators_subordination_boundaries + 1) / ($max_num_coordinators_subordination_boundaries + 1);
    my $sentence_length_ratio = ($sentence_length + 1) / ($max_sentence_length + 1);

    $structural_complexity = $subordinator_ratio * $coordinator_ratio * $coordinator_subordination_boundary_ratio * $sentence_length_ratio;


    return($structural_complexity);
}
1;
