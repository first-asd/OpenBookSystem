# COORDINATED and SUBORDINATED CLAUSES "This sentence may contain multiple
# facts. Sentences are easier to read when each sentence contains one fact." 
# PASSIVE: "This sentence contains a sentence in which the word order is
# different from most sentences. In this sentence, the entity affected by the
# verb (its object) is mentioned before the verb and the agent of the verb (its
# subject) is mentioned after the verb. Sentences are easier to read when the
# subject is mentioned before the verb and the object is mentioned after the
# verb."
# PASSIVE WITH NO SUBJECT: "This sentence contains a sentence in which the
# word order is different from most sentences. In this sentence, the entity
# affected by the verb (its object) is mentioned before the verb and the agent
# of the verb is not mentioned. Sentences are easier to read when the subject
# is mentioned before the verb and the object is mentioned after the verb."


# Modifications begun: 19/7/2012
# Modifications begun: 26/9/2014 (more-structured HTML diagnoses)
package EfficientEditingGuidance;
use English;
use strict;
use LRE;

# $context_length determines the (maximum) character length of the left and
# right context of obstacles displayed for the user.
my $context_length = 25;

sub guidance{
    my ($sentence) = @_;
    my $structural_complexity = 0;

    my $num_subordinators = 0;
    my $num_coordinators = 0;
    my $num_coordinators_subordination_boundaries = 0;
    my $sentence_length = 0;

    my $context_length = 25;

    my $num_SSMA = 0;
    my $num_SSCCV = 0;
    my $num_SSCM = 0;
    my $num_SS = 0;
    my $num_CC = 0;
    my $num_CCV = 0;
    my $num_passives = 0;
    my $num_by_passives = 0;
    my $num_subordinate_passives = 0;
    my $num_initial_adverbials = 0;
    my $num_adverbials = 0;
    my $num_non_initial_conditionals = 0;
    my $num_nic = 0;
    my $num_fIC = 0;
    my $num_cC = 0;
    my $num_AC = 0;

    my $on = 0;
    my $global_tag_number = 0;

    my $SSMA_info = "";
    my $SSCCV_info = "";
    my $SSCM_info = "";
    my $SS_info = "";
    my $CCV_info = "";
    my $CC_info = "";
    my $passive_info = "";

    my %obstacles = ();

    my %SSMA = ();
    my %SSCCV = ();
    my %SSCM = ();
    my %SS = ();
    my %CC = ();
    my %CCV = ();
    my %passives = ();
    my %subordinate_passives = ();
    my %by_passives = ();
    my %initial_adverbials = ();
    my %adverbials = ();
    my %non_initial_conditionals = ();
    my %AdversativeConjunctions = ();
    my %finalIllativeConjunctions = ();
    my %comparativeConjunctions = ();

    my $guidance = "\#\#\#STARTDIAGNOSIS\n<ul class\=\"diagnosis\">\n";

    my $num_signs = 0;

    my $original_sentence = $sentence;
    my $print_sentence = strip_tags($sentence);

    my @finalIllativeConjunctions = ();
    my @AdversativeConjunctions = ();
    my @comparativeConjunctions = ();


    open(FIC, "./finalIllativeConjunctions.txt");
    while(<FIC>){
	my $fic_line = $_;
	chomp($fic_line);
	$fic_line = query_tag($fic_line);
	if($fic_line ne ""){
	    unless($fic_line =~ /\#/){
		push(@finalIllativeConjunctions, $fic_line);
	    }
	}
    }
    close(FIC);


    open(AC, "./AdversativeConjunctions.txt");
    while(<AC>){
	my $ac_line = $_;
	chomp($ac_line);
	$ac_line = query_tag($ac_line);
	if($ac_line ne ""){
	    unless($ac_line =~ /\#/){
		push(@AdversativeConjunctions, $ac_line);
	    }
	}
    }
    close(AC);

    open(CC, "./comparativeConjunctions.txt");
    while(<CC>){
	my $cc_line = $_;
	chomp($cc_line);
	$cc_line = query_tag($cc_line);
	if($cc_line ne ""){
	    unless($cc_line =~ /\#/){
		push(@comparativeConjunctions, $cc_line);
	    }
	}
    }
    close(CC);


    while($original_sentence =~ /<PC ID\=\"([^\"]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>/g){
	my $class = $2;
	my $sign = $3;
	$num_signs++;

	my $prior = $PREMATCH;
	my $rest = $POSTMATCH;
	my $print_prior = strip_tags($prior);
	my $print_rest = strip_tags($rest);



	if(1 == 0){
	    while(length($print_prior) > $context_length){
		$print_prior =~ s/^(\s*)([^\s]+)(\s*)//;
	    }
	    while(length($print_prior) < $context_length){
		$print_prior = " ".$print_prior;
	    }
	    
	    while(length($print_rest) > $context_length){
		$print_rest =~ s/(\s*)([^\s]+)(\s*)$//;
	    }
	    while(length($print_rest) < $context_length){
		$print_rest .= " ";
	    }
	}
	
	
	my $sign_key = $print_prior."<OBSERVATION ID\=\"$on\" CLASS\=\"SIGN\">".$sign."</OBSERVATION>".$print_rest;
#	print("$sign_key\n");


	if($class eq "SSCCV"){
	    $num_SSCCV++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Start\_Subordinate_Clause\"/;
	    $SSCCV{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
	elsif($class eq "SSMA"){
	    $num_SSMA++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Start_Subordinate_Adjective_Phrase\"/;
	    $SSMA{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
	elsif($class eq "SSCM"){
	    $num_SSCM++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Start\_Quote\"/;
	    $SSCM{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
	elsif($class =~ /^SSMAdvP/){
# This class is dealt with later, nothing is needed here
	}
	elsif($class =~ /^SS/){
	    $num_SS++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Starts_Subordinate_Phrase\"/;
	    $SS{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
	elsif($class =~ /^CCV/){
	    $num_CCV++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Links_Coordinate_Clauses\"/;
	    $CCV{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
	elsif($class =~ /^(CM|CC)/){
	    $num_CC++;
	    $sign_key =~ s/\=\"SIGN\"/\=\"Links_Coordinate_Phrases\"/;
	    $CC{$sign_key}++;
	    $obstacles{$sign_key}++;
	}
    }

    if(keys(%SSCCV) > 0){
	$num_SSCCV = keys(%SSCCV);
	my $clauses = "clauses";
	if($num_SSCCV == 1){
	    $clauses =~ s/s$//;
	}
	$guidance .= "<li><p>$num_SSCCV embedded $clauses <span class\=\"advice\" data\-advice\=\"These sentences may contain multiple facts. Texts are easier to read when each sentence contains one fact.\"\/><\/p>\n<ul>\n";


	my $EC_hash_ref = \%SSCCV;

	my $tag_offsets_ref = get_tag_offsets($EC_hash_ref);
	my @tag_offsets = @$tag_offsets_ref;

	my $tag_offset_pairs_ref = \@tag_offsets;
	my ($new_sentence) = aggregate_tags($original_sentence, $tag_offset_pairs_ref, $global_tag_number);

#	$guidance .= ">>>>>>>>>>> ".$new_sentence."\n";

	my $s;
	my $sf;
	while(($s, $sf) = each %SSCCV){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"clause\"><span class\=\"trigger\">".$obstacle."<\/span>".$following_context."<\/span>...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul><\/li>\n";


    }
    if(keys(%SSMA) > 0){
	$num_SSMA = keys(%SSMA);
	my $descriptions = "descriptions";
	if($num_SSMA == 1){
	    $descriptions =~ s/s$//;
	}
	$guidance .= "<li><p>$num_SSMA embedded $descriptions <span class\=\"advice\" data\-advice\=\"These sentences may contain multiple facts. Texts are easier to read when each sentence contains one fact.\"\/><\/p>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %SSMA){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span><span class\=\"embedded-description\">".$following_context."<\/span>...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul><\/li>\n";
    }
    if(keys(%SS) > 0){
	$num_SS = keys(%SS);
	my $phrases = "phrases";
	if($num_SS == 1){
	    $phrases =~ s/s$//;
	}
	$guidance .= "<li><p>$num_SS other embedded $phrases <span class\=\"advice\" data-advice\=\"These sentences may contain multiple facts. Texts are easier to read when each sentence contains one fact.\"\/>\n<\/p>\n<ul\n>";
	my $s;
	my $sf;
	while(($s, $sf) = each %SS){
	    $on++;

	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"phrase\"><span class\=\"trigger\">".$obstacle."<\/span>".$following_context."<\/span>...<\/li>\n";
	    }

#	    $guidance .= "$s\n";
#	    "<OBSERVATION ID\=\"$on\" CLASS\=\"Embedded_Phrase\">$s<\/OBSERVATION>\n";
	}
	$guidance .= "<\/ul>\n<\/li>\n";
    }
    if(keys(%SSCM) > 0){
	$num_SSCM = keys(%SSCM);
	my $quotations = "quotations";
	if($num_SSCM == 1){
	    $quotations =~ s/s$//;
	}
 	$guidance .= "<li><p>$num_SSCM $quotations <span class\=\"advice\" data\-advice\=\"These sentences may contain reported speech, which can be quite complex.\"\/>\n<\/p>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %SSCM){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"quotation\"><span class\=\"trigger\">".$obstacle."<\/span>".$following_context."<\/span>...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul><\/li>\n";
    }
    if(keys(%CCV) > 0){
	$num_CCV = keys(%CCV);
	my $pairs = "pairs";
	if($num_CCV == 1){
	    $pairs =~ s/s$//;
	}
	$guidance .= "<li><p>$num_CCV $pairs of linked clauses <span class\=\"advice\" data\-advice\=\"These sentences may contain multiple facts. Texts are easier to read when each sentence contains one fact.\"\/>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %CCV){
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}

		$guidance .= "<li>...<span class\=\"clause\">".$prior_context."<\/span><span class\=\"trigger\">".$obstacle."<\/span><span class\=\"clause\">".$following_context."<\/span>...<\/li>\n";
	    }


#	    $guidance .= "$s\n";
	}
	$guidance .= "<\/ul>\n<\/li>\n";
    }
    if(keys(%CC) > 0){
	$num_CC = keys(%CC);
	my $pairs = "pairs";
	if($num_CC == 1){
	    $pairs =~ s/s$//;
	}
	$guidance .= "<li><p>$num_CC $pairs of linked phrases <span class\=\"advice\" data\-advice\=\"These sentences may contain multiple facts. Texts are easier to read when each sentence contains one fact.\"\/>\n<\/p>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %CC){
#	    $guidance .= "$s\n";

	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}

		$guidance .= "<li class\=\"example\">...<span class\=\"phrase\">".$prior_context."<\/span><span class\=\"trigger\">".$obstacle."<span><span class\=\"phrase\">".$following_context."<\/span>...<\/li>\n";
	    }

	}
	$guidance .= "<\/ul>\n<\/li>\n";
    }


    if($num_SSCCV > 1){
	$SSCCV_info = $num_SSCCV." embedded clauses";
    }
    elsif($num_SSCCV == 1){
	$SSCCV_info = $num_SSCCV." embedded clause";
    }

    if($num_SSCM == 1){
	$SSCM_info = $num_SSCM." quotation";
    }
    elsif($num_SSCM > 1){
	$SSCM_info = $num_SSCM." quotations";
    }

    if($num_SSMA == 1){
	$SSMA_info = $num_SSMA." descriptive phrase";
    }
    elsif($num_SSMA > 1){
	$SSMA_info = $num_SSMA." descriptive phrases";
    }

    $CCV_info = "There may be ";
    if($num_CCV > 0){
	my $pnccv = $num_CCV + 1;
	$CCV_info = $pnccv." clauses linked together";
    }

    $CC_info = "There may be ";
    if($num_CC > 0){
	my $pnc = $num_CC + 1;
	$CC_info = $pnc." phrases linked together";
    }




    my $unknown_signs = $num_signs - $num_SSCCV - $num_SSMA - $num_SSCM;
    my $unknown_sign_info = "are no other signs of complexity.";

    if($unknown_signs == 1){
	$unknown_sign_info = "is ".$unknown_signs." other sign of possible complexity.";
    }
    elsif($unknown_signs > 1){
	$unknown_sign_info = "are ".$unknown_signs." other signs of possible complexity.";
    }
    elsif($unknown_signs > 0){
	$unknown_sign_info = ".";
    }

    my $link1 = "";
    my $link2 = "";
    my $link3 = ". There ";

    if($SSCCV_info eq ""){
	$link1 = "";

	if($SSMA_info ne "" && $SSCM_info ne ""){
	    $link2 = " and ";
	}
	elsif($SSMA_info eq "" && $SSCM_info eq ""){
	    $link2 = "";
	}
    }
    else{
	if($SSMA_info ne "" && $SSCM_info ne ""){
	    $link1 = ", ";
	    $link2 = ", and ";
	}
	elsif($SSMA_info eq "" && $SSCM_info eq ""){
	    $link1 = "";
	    $link2 = "";
	}
	elsif($SSMA_info ne "" && $SSCM_info eq ""){
	    $link1 = " and ";
	    $link2 = "";
	}
	elsif($SSMA_info eq "" && $SSCM_info ne ""){
	    $link1 = "";
	    $link2 = " and ";
	}

    }


    my $passive_start = "There are passive sentences in this text. In these, the person/thing to which an action is done (the object) is mentioned before the person/thing doing the action (the subject). They can be made more understandable by swapping the positions of the subject and object.\n";
    my @passive_patterns = ("($LRE::any_past_tense_be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_present_tense_be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbd_verb|$LRE::vbn_verb)", "($LRE::any_present_tense_be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::being)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_past_tense_be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::being)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_perfect_have)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::been)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::will)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_present_tense_be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::going)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::to)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::be)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_kind_of_modal)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::be)(\\\s*)($LRE::vbn_verb|$LRE::vbd_verb)", "($LRE::any_kind_of_modal)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::have)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::been)(($LRE::any_kind_of_adverb|\\\s)*)($LRE::vbn_verb|$LRE::vbd_verb)");
    my $pp;


    my $passive_info = "";
    foreach $pp (@passive_patterns){
# if
	while($original_sentence =~ /$pp/g){
	    my $rest = $POSTMATCH;
	    my $prior = $PREMATCH;
	    my $print_pp = $&;
	    $print_pp = strip_tags($print_pp);
	    $on++;

	    my $print_prior = $prior;
	    $print_prior = strip_tags($print_prior);
	    my $print_rest = $rest;
	    $print_rest = strip_tags($print_rest);

	    if(1 == 0){
		while(length($print_prior) > $context_length){
		    $print_prior =~ s/^(\s*)([^\s]+)(\s*)//;
		}
		while(length($print_prior) < $context_length){
		    $print_prior = " ".$print_prior;
		}
		
		while(length($print_rest) > $context_length){
		    $print_rest =~ s/(\s*)([^\s]+)(\s*)$//;
		}
		while(length($print_rest) < $context_length){
		    $print_rest .= " ";
		}
	    }



#	    $passive_info .= $print_prior."<OBSERVATION ID\=\"$on\">".$print_pp."]".$print_rest."\n";


	    if($rest =~ /($LRE::by)/){
		$passive_info = $print_prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Passive\_Verb\">".$print_pp."</OBSERVATION>".$print_rest;

		$by_passives{$passive_info}++;
		$obstacles{$passive_info}++;
	    }
	    elsif($prior =~ /($LRE::any_kind_of_subordinator)(($LRE::any_kind_of_adverb|$LRE::any_kind_of_modal|\s)*?)/){
		$passive_info = $print_prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Passive\_Verb_In_A_Subordinate_Clause\">".$print_pp."</OBSERVATION>".$print_rest;
		$subordinate_passives{$passive_info}++;
		$obstacles{$passive_info}++;
	    }
	    else{
		$passive_info = $print_prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Passive\_Verb_With_No_Subject\">".$print_pp."</OBSERVATION>".$print_rest;
		$passives{$passive_info}++;
		$obstacles{$passive_info}++;
	    }

#	    die "$passive_info\n";
	}
    }

    $num_passives = keys(%passives);
    if(keys(%passives) > 0){
	my $verbs = "verbs";
	if($num_passives == 1){
	    $verbs =~ s/s$//;
	}
	$guidance .= "<li><p>$num_passives passive $verbs with no subject <span class\=\"advice\" data\-advice\=\"The word order of these sentences may be different from that of most sentences. Here, the person or thing affected by the verb (its object) is mentioned before the verb and the agent of the verb (its subject) is not mentioned. Sentences are easier to read when the subject is mentioned before the verb and the object is mentioned after the verb.\"\/>\n<\/p>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %passives){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...<span class\=\"object\">".$prior_context."<\/span><span class\=\"passive\-verb\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li\n>\n";


#	print("\t\t$num_passives passive verbs\n\(Try swapping the position of their subjects and objects. If there is no explicit subject, try adding one before the verb and moving the object so that it appears after the verb. If you can't work out what the subject of the verb is, just ignore the sentence\)\:\n");

	my $passives_hash_ref = \%passives;

	my $tag_offsets_ref = get_tag_offsets($passives_hash_ref);
	my @tag_offsets = @$tag_offsets_ref;

	my $tag_offset_pairs_ref = \@tag_offsets;
	my $temp_string = $original_sentence;
	my $new_sentence;
	($new_sentence) = aggregate_tags($original_sentence, $tag_offset_pairs_ref, $global_tag_number);

# 	$guidance .= ">>>>>>>>>>> ".$new_sentence."\n";
    }

    $num_by_passives = keys(%by_passives);
    if(keys(%by_passives) > 0){
	my $verbs = "verbs";
	if($num_by_passives == 1){
	    $verbs =~ s/s$//;
	}
	$guidance .= "<li><p>$num_by_passives passive $verbs with a subject <span class\=\"advice\" data\-advice\=\"The word order of these sentences is different from that of most sentences. Here, the person or thing affected by the verb (its object) is mentioned before the verb and the agent of the verb (its subject) is mentioned after the verb. Sentences are easier to read when the subject is mentioned before the verb and the object is mentioned after the verb.\"\/>\n<\/p>\n<ul>\n";


	my $s;
	my $sf;
	while(($s, $sf) = each %by_passives){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li>...<span class\=\"object\">".$prior_context."<\/span><span class\=\"trigger\">".$obstacle."<\/span><span class\=\"subject\">".$following_context."<\/span>...<\/LI>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

#	print("\t\t$num_passives passive verbs\n\(Try swapping the position of their subjects and objects. If there is no explicit subject, try adding one before the verb and moving the object so that it appears after the verb. If you can't work out what the subject of the verb is, just ignore the sentence\)\:\n");
	my $p;
	my $pf;
	while(($p,$pf) = each %by_passives){
#	    $guidance .= $p."\n";
#	    print("$p\n");
	}
    }

    $num_subordinate_passives = keys(%subordinate_passives);
    if(keys(%subordinate_passives) > 0){
	my $verbs = "verbs";
	if($num_subordinate_passives == 1){
	    $verbs =~ s/s$//;
	}
	$guidance .= "<li><p>$num_subordinate_passives passive $verbs in a subordinate clause <span class\=\"advice\" data\-advice\=\"These sentences contain multiple facts. Texts are easier to read when each sentence contains a single fact. When converting this sentence to a more readable form, try to ensure that the correct agent of the embedded verb is explicitly mentioned.\"\/>\n<\/p>\n<ul>\n";
	my $s;
	my $sf;
	while(($s, $sf) = each %subordinate_passives){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li span class\=\"example\">...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";


#	print("\t\t$num_passives passive verbs\n\(Try swapping the position of their subjects and objects. If there is no explicit subject, try adding one before the verb and moving the object so that it appears after the verb. If you can't work out what the subject of the verb is, just ignore the sentence\)\:\n");
	my $p;
	my $pf;
	while(($p,$pf) = each %subordinate_passives){
#	    $guidance .= $p."\n";
#	    print("$p\n");
	}
    }

    while($original_sentence =~ /<PC ID\=\"([^\"]+)\" CLASS\=\"SSMAdvP\">([^<]+)<\/PC>/g){
	my $rest = $POSTMATCH;
	my $prior = $PREMATCH;
	my $sign = $&;
	$on++;
	if($rest =~ /($LRE::comma)/){
	    my $adverbial = $PREMATCH;
	    my $adverbial_info = $prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Non_Initial_Adverbial\">".$sign.$adverbial.$&."</OBSERVATION>".$POSTMATCH;
	    my $print_adverbial_info = strip_tags($adverbial_info);
	    $adverbials{$print_adverbial_info}++;
	    $obstacles{$print_adverbial_info}++;
	}
    }
    my $advs = "adverbials";
    $num_adverbials = keys(%adverbials);
    if($num_adverbials == 1){
	$advs =~ s/s$//;
    }
    if($num_adverbials > 0){
# Adverbials could potentially be deleted
	$guidance .= "<li><p>$num_adverbials $advs <span class\=\"advice\" data-advice\=\"Is the adverbial information important\? If not, perhaps it can be deleted.\"\/>\n<\/p>\n<ul>\n"; 

	my $s;
	my $sf;
	while(($s, $sf) = each %adverbials){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"adverbial\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	my $p;
	my $pf;
	while(($p,$pf) = each %adverbials){
#	    $guidance .= $p."\n";
#	    print("$p\n");
	}
    }

    while($original_sentence =~ /<w ([^>]+)>if<\/w>/g){
	my $rest = $POSTMATCH;
	my $prior = $PREMATCH;
	my $if = $&;
	$on++;
	my $nic_entry = $prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Non_Initial_Conditional\">".$if."</OBSERVATION>".$rest;
	$nic_entry = strip_tags($nic_entry);

	my $num_preceding_words = 0;
	while($prior =~ /<w ([^>]+)>([^<]+)<\/w>/g){
	    $num_preceding_words++;
	}
	if($num_preceding_words > 3){
	    $non_initial_conditionals{$nic_entry}++;
	    $obstacles{$nic_entry}++;
	}
    }
    my $conds = "conditionals";
    $num_nic = keys(%non_initial_conditionals);
    if($num_nic == 1){
	$conds =~ s/s$//;
    }
    if($num_nic > 0){
# Adverbials could potentially be deleted
	$guidance .= "<li><p>$num_nic non\-initial $conds <span class\=\"advice\" data\-advice\=\"In these sentences, the conditional clause is mentioned after the main clause. Sentences are easier to understand when the conditional clause precedes the main clause.\"\/>\n<\/p>\n<ul>\n"; 

	my $s;
	my $sf;
	while(($s, $sf) = each %non_initial_conditionals){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span><span class\=\"conditional\">".$following_context."<\/span>...<\/LI>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	my $p;
	my $pf;
	while(($p,$pf) = each %non_initial_conditionals){
#	    $guidance .= $p."\n";
#	    print("$p\n");
	}
    }

    if($original_sentence =~ /<PC ID\=\"([^\"]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/g){
	my $rest = $POSTMATCH;
	my $prior = $PREMATCH;
	my $sign = $&;

	unless($prior =~ /<PC ID\=\"([^\"]+)\" CLASS\=\"SSMAdvP\">([^<]+)<\/PC>/){
	    $on++;
	    my $initial_adverbial = $prior.$sign;
	    my $initial_adverbial_info = "<OBSERVATION ID\=\"$on\" CLASS\=\"Initial_Adverbial\">".$initial_adverbial."</OBSERVATION>".$rest;
	    my $print_initial_adverbial_info = strip_tags($initial_adverbial_info);
	    $initial_adverbials{$print_initial_adverbial_info}++;
	    $obstacles{$print_initial_adverbial_info}++;
	}
    }
    my $advs = "adverbials";
    $num_initial_adverbials = keys(%initial_adverbials);
    if($num_initial_adverbials == 1){
	$advs =~ s/s$//;
    }
    if($num_initial_adverbials > 0){
# Adverbials could potentially be deleted
	$guidance .= "<li><p>$num_initial_adverbials initial $advs <span class\=\"advice\" data\-advice\=\"Is the adverbial information necessary\? If not, perhaps it could be deleted.\"\/><\/p>\n<ul>\n"; 

	my $s;
	my $sf;
	while(($s, $sf) = each %initial_adverbials){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"adverbial\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	my $p;
	my $pf;
	while(($p,$pf) = each %initial_adverbials){
#	    $guidance .= $p."\n";
#	    print("$p\n");
	}
    }
    

    my $i;
    for($i=0; $i < @finalIllativeConjunctions; $i++){
	my $fici = @finalIllativeConjunctions[$i];

	while($original_sentence =~ /$fici/g){
	    my $qm = $&;
	    my $prior = $PREMATCH;
	    my $rest = $POSTMATCH;

	    $on++;
	    my $fIC_entry = $prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Final_Illative_Conjunction\">".$qm."</OBSERVATION>".$rest;
	    $fIC_entry = strip_tags($fIC_entry);

	    my $num_preceding_words = 0;
	    while($prior =~ /<w ([^>]+)>([^<]+)<\/w>/g){
		$num_preceding_words++;
	    }
	    if($num_preceding_words > 3){
		$finalIllativeConjunctions{$fIC_entry}++;
		$obstacles{$fIC_entry}++;
	    }
	}
    }

    for($i=0; $i < @AdversativeConjunctions; $i++){
	my $fici = @AdversativeConjunctions[$i];

	while($original_sentence =~ /$fici/g){
	    my $qm = $&;
	    my $prior = $PREMATCH;
	    my $rest = $POSTMATCH;

	    $on++;
	    my $ac_entry = $prior."<OBSERVATION ID=\"".$on."\" CLASS\=\"Adversative_Conjunction\">".$qm."<\/OBSERVATION>".$rest;
	    $ac_entry = strip_tags($ac_entry);

	    my $num_preceding_words = 0;
	    while($prior =~ /<w ([^>]+)>([^<]+)<\/w>/g){
		$num_preceding_words++;
	    }
	    if($num_preceding_words > 3){
		$AdversativeConjunctions{$ac_entry}++;
		$obstacles{$ac_entry}++;
	    }
	}

    }

    for($i=0; $i < @comparativeConjunctions; $i++){
	my $fici = @comparativeConjunctions[$i];

	while($original_sentence =~ /$fici/g){
	    my $qm = $&;
	    my $prior = $PREMATCH;
	    my $rest = $POSTMATCH;

	    $on++;
	    my $cC_entry = $prior."<OBSERVATION ID\=\"$on\" CLASS\=\"Comparative_Conjunction\">".$qm."</OBSERVATION>".$rest;
	    $cC_entry = strip_tags($cC_entry);

	    my $num_preceding_words = 0;
	    while($prior =~ /<w ([^>]+)>([^<]+)<\/w>/g){
		$num_preceding_words++;
	    }
	    if($num_preceding_words > 3){
		$comparativeConjunctions{$cC_entry}++;
		$obstacles{$cC_entry}++;
	    }
	}

    }
#    exit;

    if(keys(%finalIllativeConjunctions) > 0){
	$num_fIC = keys(%finalIllativeConjunctions);
	my $conjunctions = "conjunctions";
	if($num_fIC == 1){
	    $conjunctions =~ s/s$//;
	}
	$guidance .= "<li><p>$num_fIC final\/illative $conjunctions <span class\=\"advice\" data\-advice\=\"Could the highlighted words be replaced by more common ones\?\"\/>\n<\/p>\n<ul>\n";

	my $s;
	my $sf;
	while(($s, $sf) = each %finalIllativeConjunctions){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	my $s;
	my $sf;
	$on++;
	while(($s, $sf) = each %finalIllativeConjunctions){
#	    $guidance .= "$s\n";
	}
    }
    if(keys(%comparativeConjunctions) > 0){
	$num_cC = keys(%comparativeConjunctions);
	my $conjunctions = "conjunctions";
	if($num_cC == 1){
	    $conjunctions =~ s/s$//;
	}
	$guidance .= "<li><p>$num_cC comparative $conjunctions\:<span class\=\"advice\" data\-advice\=\"Could the highlighted words be replaced by more common ones\?\"\/>\n<\/p>\n";
	my $s;
	my $sf;
	$on++;

	my $s;
	my $sf;
	while(($s, $sf) = each %comparativeConjunctions){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li>...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	while(($s, $sf) = each %comparativeConjunctions){
#	    $guidance .= "$s\n";
	}
    }
    if(keys(%AdversativeConjunctions) > 0){
	$num_AC = keys(%AdversativeConjunctions);
	my $conjunctions = "conjunctions";
	$on++;
	if($num_AC == 1){
	    $conjunctions =~ s/s$//;
	}
	$guidance .= "<li><p>$num_AC adversative $conjunctions <span class\=\"advice\" data\-advice\=\"Could the highlighted words be replaced by more common ones\?\"\/><\/p>\n<ul>\n";
	my $s;
	my $sf;

	my $s;
	my $sf;
	while(($s, $sf) = each %AdversativeConjunctions){
#	    $guidance .= "$s\n";
	    if($s =~ /<([^>]+)>([^<]+)<\/([^>]+)>/){
		my $prior_context = $PREMATCH;
		my $following_context = $POSTMATCH;
		my $obstacle = $&;
		$obstacle =~ s/<([^>]+)>//g;
		while(length($prior_context) > $context_length){
		    $prior_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)//;
		}
		while(length($following_context) > $context_length){
		    $following_context =~ s/([^\s\t\n]+)((\s|\t|\n)*)$//;
		}
		
		$guidance .= "<li class\=\"example\">...".$prior_context."<span class\=\"trigger\">".$obstacle."<\/span>".$following_context."...<\/li>\n";
	    }
	}
	$guidance .= "<\/ul>\n<\/li>\n";

	while(($s, $sf) = each %AdversativeConjunctions){
	    $on++;
#	    $guidance .= "$s\n";
	}
    }



    my $num_obstacles = keys(%obstacles);
    if(keys(%obstacles) > 0){
	my $pobj = "obstacles";
	if($num_obstacles == 1){
	    $pobj =~ s/s$//;
	}
	$guidance .= "<\/ul>\n\#\#\#STARTSENTENCE\n";
# $num_obstacles potential $pobj to reading comprehension\n".$guidance;



	my $obstacles_hash_ref = \%obstacles;

	my $tag_offsets_ref = get_tag_offsets($obstacles_hash_ref);
	my @tag_offsets = @$tag_offsets_ref;

	my $tag_offset_pairs_ref = \@tag_offsets;
	my $temp_string = $original_sentence;
	my $new_sentence;
	($new_sentence) = aggregate_tags($original_sentence, $tag_offset_pairs_ref, $global_tag_number);

	$guidance .= $new_sentence."\n\n";
    }
    $guidance .= "\#\#\#ENDDIAGNOSIS\n";














    return($guidance);
}
1;

sub query_tag{
    my ($string) = @_;

    if($string =~ /[A-Za-z\'\"]/){
#	$string =~ s/(\s+)/<\\\([^>]\\\)>\\\(\\\s*\\\)<\\\([^>]\\\)>/g;
#	$string = "<\\\([^>]\\\)>".$string."<\\\([^>]\\\)>";
	$string =~ s/(\s+)/<([^>]+)>(\\\s*)<([^>]+)>/g;
	$string = "<([^>]+)>".$string."<([^>]+)>";

#	print STDERR "here 1\n$string\n";exit;sleep(100);

	return($string);
    }
}

sub strip_tags{
    my ($string) = @_;


    $string =~ s/<\/?(w|p|s)([^>]*)>//ig;

    return($string);
}

sub get_tag_offsets{
    my ($hash_ref) = @_;
    my $from;
    my $to;
    my $obstacle_type;
    my @tag_offsets = ();

    my @observations = keys % { $hash_ref };

    my $o;
    foreach $o (@observations){
	if($o =~ /<OBSERVATION ID\=\"([^\"]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/OBSERVATION>/){
	    $from = length($PREMATCH);
	    $to = $from + length($3);
	    $obstacle_type = $2;
	    my $offset_pair = $from."#".$to."#".$obstacle_type;
	    push(@tag_offsets, $offset_pair);
	}
    }
    my $tag_offsets_ref = \@tag_offsets;
}

sub aggregate_tags{
    my ($sentence, $tag_offset_pairs_ref, $global_tag_number) = @_;
    $sentence = strip_tags($sentence);
    my @offset_pairs = @$tag_offset_pairs_ref;
    my $new_sentence = "";
    my $current_offset = 0;    

    while(1){
	if($sentence =~ /^./){
	    $new_sentence .= $&;
	    $sentence = $POSTMATCH;
	    $current_offset++;

	    my $op;
	    foreach $op (@offset_pairs){
		my $tag_class;

		if($op =~ /^$current_offset\#/){
		    $global_tag_number++;
		    if($op =~ /\#([^\#]+)$/){
			$tag_class = $1;
		    }

		    $new_sentence .= "<OBSERVATION ID\=\"$global_tag_number\" CLASS\=\"$tag_class\">";
		}		
		elsif($op =~ /\#$current_offset\#/){
		    $new_sentence .= "<\/OBSERVATION>";
		}		
	    }
	}
	else{
	    last;
	}
    }


    return($new_sentence);
}
