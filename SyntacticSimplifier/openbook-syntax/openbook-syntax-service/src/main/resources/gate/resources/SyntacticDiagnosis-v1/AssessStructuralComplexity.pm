
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

# Values established empirically:
    my $max_num_subordinators = 12;
    my $max_num_coordinators = 8;
    my $max_sentence_length = 107;
    my $max_num_coordinators_subordination_boundaries = 17;
    my $max_structural_complexity = 27450;

    my $original_sentence = $sentence;
    my $print_sentence = $sentence;
    $print_sentence =~ s/<([^>]+)>//g;

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




    my $subordinator_ratio = int(10 * (($num_subordinators) / ($max_num_subordinators)));
#    my $coordinator_ratio = ($num_coordinators + 1) / ($max_num_coordinators + 1);
    my $coordinator_ratio = int(10 * (($num_coordinators) / ($max_num_coordinators)));
    my $coordinator_subordination_boundary_ratio = int(10 * (($num_coordinators_subordination_boundaries) / ($max_num_coordinators_subordination_boundaries)));
    my $sentence_length_ratio = int(10 * (($sentence_length) / ($max_sentence_length)));

    $structural_complexity = int(14.28571429 * ((($num_subordinators/$max_num_subordinators) + ($num_coordinators / $max_num_coordinators) + ($num_coordinators_subordination_boundaries / $max_num_coordinators_subordination_boundaries) + ($sentence_length / $max_sentence_length)) / 4));

    unless($print_sentence eq " \"yyeess\" c=\"w\" p=\"DT\">The multi-millionaire owner of Harrods invited Prince Philip sue him over the allegation and said he had already written to the Prime Minister, the Foreign Secretary and the Home Secretary asking for an investgation into alleged conspiracy Mr Fayed also claimed that the former Conservative cabinet minister Michael Howard had accepted between \"£1m and £1.5m\" in bribes in return for a critical Department of Trade and Industry (DTI) inquiry into the Egyptian-born tycoon's takeover of the House of Fraser stores and Harrods. " | $print_sentence eq " Millionaire chef Marco Pierre White yesterday told a high court libel jury that he had never taken drugs and rarely drank, despite claims in two American newspapers that he had had a 'well-publicised bout with drugs and alcohol Mr White is claiming libel damages for an article published in both the New York Times and the International Herald Tribune, - which are contesting the case and claim the article had caused no damage and had even 'enhanced' the chef's reputation. "){
	open(TEMP_LOG, ">>./sentence_complexity_indices.txt");
	print TEMP_LOG "\[$print_sentence\]\t$sentence_length_ratio\t$coordinator_ratio\t$subordinator_ratio\t$coordinator_subordination_boundary_ratio\t$structural_complexity\n";
	close(TEMP_LOG);

	return($structural_complexity);
    }
}
1;
