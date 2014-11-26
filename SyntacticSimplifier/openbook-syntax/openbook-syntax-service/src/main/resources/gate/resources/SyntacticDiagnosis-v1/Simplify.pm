# Package adjusted to handle all classes present in the physical examinations
# key file. These are:
#
# and 
# ADJP, CLAUSE, CONJOINED_HEAD_NOUNS, CONJOINED_HEAD_ADJS,
# CONJOINED_HEAD_VERBS, CONJOINED_NBAR, NP, CONJOINED_NP_PP, VP,
# CONJOINED_ADJP_PPS, NP_CONJOINED_TO_SPECIFY_COMPOUND
#
# but
# ADJP, NP, VP
#
# or
# CONJOINED_HEAD_NOUNS, NP_CONJOINED_TO_SPECIFY_COMPOUND
#
# comma
# ADJP, ADVP_SEPARATOR, CLAUSE, CONJOINED_ADJP_PPS, CONJOINED_HEAD_ADJS,
# CONJOINED_HEAD_NOUNS, CONJOINED_NBAR, END_OF_PARENTHETICAL, NP,
# START_OF_PARENTHETICAL, 
#
# commaAnd
# ADJP, CLAUSE, CONJOINED_ADJP_PP, CONJOINED_HEAD_ADJS, CONJOINED_HEAD_NOUNS,
# CONJOINED_NBAR, NP, VP, 
#
# ", or" and is not used in physical examinations. 
#
# Note on current annotation: "to the moon and back" should be COMBINATORY
#
# Modifications begun: 19/7/2010
package Simplify;
use English;
use strict;
my $any_kind_of_word = "<w c\=\"w\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $any_kind_of_possessive = "<w c\=\"aposs\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $any_kind_of_verb = "<w c\=\"w\" p\=\"(VBG|VBN|VBP|VBD|VB|VBZ)\">([^<]+)<\/w>";
my $any_kind_of_modal = "<w c\=\"w\" p\=\"MD\">([^<]+)<\/w>";
my $vb_verb = "<w c\=\"w\" p\=\"VB\">([^<]+)<\/w>";
my $vbp_verb = "<w c\=\"w\" p\=\"VBP\">([^<]+)<\/w>";
my $vbz_verb = "<w c\=\"w\" p\=\"VBZ\">([^<]+)<\/w>";
my $vbg_verb = "<w c\=\"w\" p\=\"VBG\">([^<]+)<\/w>";
my $vbd_verb = "<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>";
my $vbn_verb = "<w c\=\"w\" p\=\"VBN\">([^<]+)<\/w>";
my $any_kind_of_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([^<]+)<\/w>";
my $any_kind_of_possPron = "<w c\=\"w\" p\=\"PRP\\\$\">([^<]+)<\/w>";
my $any_kind_of_pron = "<w c\=\"w\" p\=\"PRP\">([^<]+)<\/w>";
my $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
my $any_kind_of_adj1 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_subordinator = "<PC ([^>]+)>(that|which)<\/PC>";
my $any_right_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>";
my $any_kind_of_prep = "<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>";
my $any_kind_of_rp = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>"; # used in "snap off"
my $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB)\">([^<]+)<\/w>";
my $any_kind_of_number = "<w c\=\"(w|cd)\" p\=\"CD\">([^<]+)<\/w>";
my $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
my $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
my $subordinating_that = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">that<\/PC>";
my $with = "<w c\=\"w\" p\=\"IN\">with<\/w>";
my $to = "<w c\=\"w\" p\=\"TO\">to<\/w>";
my $of = "<w c\=\"w\" p\=\"IN\">of<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $hyphen = "<w c\=\"hyph\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"s\" p\=\"(POS|\'\')\">\'<\/w>";

sub simplify{
    my ($sentence) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

################################### CCV #######################################
    if($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CCV\">([^<]+)<\/PC>/){
	my $sentence1 = $PREMATCH;
	my $sentence2 = $POSTMATCH;
	$sentence1 =~ s/\s*$//;
	$sentence2 =~ s/^\s*//;

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-1a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-1b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

################################### CMV1 #######################################
# # # # # # # # # # # # # # # semicolon-conjunction # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;\s+(and|but)<\/PC>/i){
	print STDERR "PROCESSING semicolon-conjunction-CMV1\t$sentence\n";# exit;

	my $subject_containing_part;
	my $prior_to_this_instance;
	my $subject;
	my $adverbial_phrase;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;\s+(and|but)<\/PC>/gi){
	    $subject_containing_part = $PREMATCH;
	    my $vp2 = $POSTMATCH;
	    $prior_to_this_instance = $PREMATCH;

	    $subject;
	    $adverbial_phrase;
	    my $vp1;


	    if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">/){
		$subject_containing_part = $PREMATCH;
		if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
		    my $adverb_comma = $&;
		    $adverbial_phrase = $PREMATCH;
		    $subject_containing_part = $POSTMATCH;
		    $adverbial_phrase =~ s/\s+/ /g;
		    $adverbial_phrase .= $adverb_comma;

		}
	    }


	    my $vp1;
	    print STDERR "NOW $subject_containing_part\n";
	    while($subject_containing_part =~ /$vbd_verb/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }
	    print STDERR "SCP $subject_containing_part\nSUBJ $subject\nVP1 $vp1\n";


	    
	    my $sentence1 = $prior_to_this_instance;
	    my $sentence2 = $adverbial_phrase.$subject.$vp2;
	    
#	print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMV1-1a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV1-1b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
    }

 # # # # # # # # ## # # # # comma-conjunction # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,\s+(and|but)<\/PC>/i){
	print STDERR "PROCESSING and-CMV1\t$sentence\n";# exit;

	my $subject_containing_part;
	my $prior_to_this_instance;
	my $subject;
	my $adverbial_phrase;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,\s+(and|but)<\/PC>/gi){
	    $subject_containing_part = $PREMATCH;
	    my $vp2 = $POSTMATCH;
	    $prior_to_this_instance = $PREMATCH;

	    $subject;
	    $adverbial_phrase;
	    my $vp1;


	    if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">/){
		$subject_containing_part = $PREMATCH;
		if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
		    my $adverb_comma = $&;
		    $adverbial_phrase = $PREMATCH;
		    $subject_containing_part = $POSTMATCH;
		    $adverbial_phrase =~ s/\s+/ /g;
		    $adverbial_phrase .= $adverb_comma;

		}
	    }


	    my $vp1;
	    print STDERR "NOW $subject_containing_part\n";
	    while($subject_containing_part =~ /$vbd_verb/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }
	    print STDERR "SCP $subject_containing_part\nSUBJ $subject\nVP1 $vp1\n";


	    
	    my $sentence1 = $prior_to_this_instance;
	    my $sentence2 = $adverbial_phrase.$subject.$vp2;
	    
#	print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMV1-2a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV1-2b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
    }

 # # # # # # # # # # # # # # ## # conjunction # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">(and|but|or)<\/PC>/i){
#	print STDERR "PROCESSING and-CMV1\t$sentence\n";exit;

	my $subject_containing_part = $PREMATCH;
	my $object_containing_part = $POSTMATCH;
	my $prior_to_this_instance = $PREMATCH;
	my $subject;
	my $adverbial_phrase;



	if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">/){
	    $subject_containing_part = $PREMATCH;

	    if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
		my $adverb_comma = $&;
		$adverbial_phrase = $PREMATCH;
		$subject_containing_part = $POSTMATCH;
		$adverbial_phrase =~ s/\s+/ /g;
		$adverbial_phrase .= $adverb_comma;

	    }
	}


	if($subject_containing_part =~ /<w c\=\"w\" p\=\"(VBG|VBD)\">([^<]+)<\/w>/){
	    $subject = $PREMATCH;
	}

	my $sentence1 = $prior_to_this_instance;
	my $sentence2 = $adverbial_phrase.$subject.$object_containing_part;

#	print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-3a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMV1-3b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

 # # # # # # # # # # # # # # # # # # semicolon # # # # #  # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;<\/PC>/i){
	my $subject_containing_part;
	my $object_containing_part;
	my $prior_to_this_instance;
	my $subject;
	my $adverbial_phrase;
	my $sentence1;
	my $sentence2;
	my $vp1;
	my $vp2;
	print STDERR "\tPROCESSING semicolon-CMV1\t$sentence\n";

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;<\/PC>/gi){
	    $subject_containing_part = $PREMATCH;
	    $object_containing_part = $POSTMATCH;
	    $prior_to_this_instance = $PREMATCH;
	    $subject;
	    $adverbial_phrase;
	    $sentence1;
	    $sentence2;
	}
#	print STDERR "OCP $object_containing_part\n";exit;
	if($object_containing_part =~ //){

	}
	
	if($subject_containing_part =~ /<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>/){
	    $subject = $PREMATCH;
	    $vp1 = $&.$POSTMATCH;
	    $sentence1 = $subject.$vp1;
	    $sentence2 = $subject.$object_containing_part;
	}
    


# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-4a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMV1-4b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

 # # # # # # # # # # # # # # # # # # comma # # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,<\/PC>/i){
	my $subject_containing_part;
	my $object_containing_part;
	my $prior_to_this_instance;
	my $subject;
	my $adverbial_phrase;
	my $sentence1;
	my $sentence2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,<\/PC>/gi){

	    print STDERR "PROCESSING comma-CMV1\t$sentence\n";

	    $subject_containing_part = $PREMATCH;
	    $object_containing_part = $POSTMATCH;
	    $prior_to_this_instance = $PREMATCH;
	    $subject;
	    $adverbial_phrase;
	    $sentence1;
	    $sentence2;
	}

#	print STDERR "SCP IS NOW $subject_containing_part\n";
	
	if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">/){
	    $subject_containing_part = $PREMATCH;
	    if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
		$subject_containing_part = $POSTMATCH;
		$adverbial_phrase = $PREMATCH.", ";
	    }
	}
	else{
# This is the first occurrence of CMV1 in the sentence 
	    if($subject_containing_part =~ /<w c\=\"w\" p\=\"(VBG|VBD|VBN)\">([^<]+)<\/w>/){
#		print STDERR "PTTI IS NOW $prior_to_this_instance\n";
		
		if($subject_containing_part =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
		    $subject_containing_part = $POSTMATCH;
		    $adverbial_phrase = $PREMATCH.", ";
		}
		
	    }
	}
	
	if($subject_containing_part =~ /<w c\=\"w\" p\=\"(VBG|VBD|VBN)\">([^<]+)<\/w>/){
	    $subject = $PREMATCH;
	    $sentence1 = $prior_to_this_instance;
	    $sentence2 = $adverbial_phrase.$subject.$object_containing_part;
	}
    


# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-5a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMV1-5b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

###################################### CMV2 ###################################
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(and|but|or)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	}
	if($precedes_rightmost_coordinator =~ /(($any_kind_of_verb|$any_kind_of_adverb|$any_kind_of_modal|\s)*)(\s*)($any_kind_of_adj1)(\s*)$/){
	    my $verb1 = $1.$8;
	    my $v1_object = $9.$13;
	    my $subject = $PREMATCH;
	    

	    if($follows_rightmost_coordinator =~ /^((\s|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_noun)*)/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object.$follows_coordination;
		$sentence2 = $subject.$verb1.$v2_object.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
#	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(($of|\s)*?)((\s|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun)*)$/){
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(($of|\s)*?)($base_np)$/){
	    my $verb1 = $1;
	    my $v1_object = $4.$6;
	    my $subject = $PREMATCH;
	    

# Following pattern to catch -ing words mistagged as NN
	    if($follows_rightmost_coordinator =~ /^((\s|$vbg_verb|$any_kind_of_noun)*?)($of)($base_np)/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object.$follows_coordination;
		$sentence2 = $subject.$verb1.$v2_object.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMV2-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	}

	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(($any_kind_of_number|$any_kind_of_noun|\s)*)($to)(\s+)(($any_kind_of_verb)+)((.|\s)*?)$/){
	    my $verb1 = $1;
	    my $v1_object = $4.$10.$12.$13.$17;
	    my $subject = $PREMATCH;

	    if($follows_rightmost_coordinator =~ /^((\s|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_noun)*)/){
		my $v2_object = $&.$POSTMATCH;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object;
		$sentence2 = $subject.$verb1.$v2_object;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
################## commas
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	}


	if($precedes_rightmost_coordinator =~ /($vbd_verb)(($base_np|\s)*)($colon)((\s|.)*)$/){
	    my $verb1 = $1.$3.$15;
	    my $v1_object = $18;# .$10.$11.$12.$16;
	    my $subject = $PREMATCH;

#	    print STDERR "AAAAAAAAAAAAAAAAAAV1 $verb1\nFRC $follows_rightmost_coordinator\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s+)($to)(\s+)($base_np)/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object.$follows_coordination;
		$sentence2 = $subject.$verb1.$v2_object.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
}
################################### CMN1 #######################################

    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">(and|or)<\/PC>/){
	print STDERR "PROCESSING $2\-CMN1\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;
	my $this_verb;
	my $objects_of_verb;
	my $follows_rightmost_coordinator;
	my $precedes_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">(and|or)<\/PC>/g){
	    $follows_rightmost_coordinator = $POSTMATCH;
	    $precedes_rightmost_coordinator = $PREMATCH;
	}


#	    print STDERR "PRC $precedes_rightmost_coordinator\n";
# need to handle cases of "...VERB NNS with NP1 and NP2 VERB..."


	if($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)+)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;


	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)+)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /$any_kind_of_verb\s+$any_kind_of_noun\s+$with\s+/){
	    while($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s+)($any_kind_of_noun)(\s+)($with)(\s+)/g){
		$np1 = $POSTMATCH;
		$subject = $PREMATCH.$&;
	    }
	    if($follows_rightmost_coordinator =~ /$any_kind_of_verb/){
		$follows_coordination = $&.$POSTMATCH;
		$np2 = $PREMATCH;
	    }
	    
	    $sentence1 = $subject.$np1.$follows_coordination;
	    $sentence2 = $subject.$np2.$follows_coordination;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
		}
	    @simpler_sentences[0] = "{CMN1-1a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-1b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

	elsif($precedes_rightmost_coordinator =~ /($wh_word)((\s|.)*?)($vbp_verb)(\s*)$/){
	    $np1 = $1.$5.$7;
	    $subject = $PREMATCH;


	    if($follows_rightmost_coordinator =~ /^(\s*)($wh_word)((.|\s)*?)($vbp_verb)(\s*)/){
		$np2 = $1.$2.$6.$8."[".$10."]";
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}	
	
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_clncin_pc|\s)+)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    print STDERR "GOTCHA $np1\n";
	    
	    
	    if($follows_rightmost_coordinator =~ /(($any_kind_of_adverb|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		$np2 = $PREMATCH.$&;
		$follows_coordination = $POSTMATCH;
		
		if($sentence =~ /secret/){
		    print STDERR "NP1 $np1\nNP2 $np2\nSUBJECT $subject\n";
		}
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

# Causes error processing "Occasionally I ate [[pasty] and [chips]] CONJ [jumbo
# sausage with chips]."
# V NN and NN CONJ ... [IN, JJ, NN] NN.$


	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_clncin_pc|\s)+)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    print STDERR "GOTCHA $np1\n";
	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_prep|$any_kind_of_adj1|$any_kind_of_noun|\s)*)$any_kind_of_noun/){# \s*$/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_noun)*)(\s*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    
	    if($follows_rightmost_coordinator =~ /$any_kind_of_noun(\s*)(($any_kind_of_noun)*)/){
		$np2 = $PREMATCH.$&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence1 = $subject.$np2.$follows_coordination;
	    }
	    
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-6a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-6b} ".$sentence2;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	
###############  [1] V [2] CONJ [3 V [4]] ->
#                                            [1] V [2] [4], 
#                                            [1] V [3]
# works well ONLY  for "Occasionally I ate pasty and chips [or] jumbo sausage
# with chips - but mainly it was just chips,' he said."
	elsif($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    
#		print STDERR "SUBJ $subject\n";exit;
	    
	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
		$follows_coordination = " ".$&.$POSTMATCH;
	    }
	    
	    
	    print STDERR "FC $follows_coordination\n";
	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-2a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-2b} ".$sentence2;
	    
	    unless($sentence =~ /pasty/){
#		    print STDERR ">>> $sentence1\n>>> $sentence2\n";exit;
	    }
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

    }
    
    
# ... NOT ONLY with ... CONJ [BOTH] NP and NP
# Going to rewrite to just
# ... with ... <PC CLASS="original">and</PC> NP and NP
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">but<\/PC>/){
	print STDERR "PROCESSING $2\-CMN1\t$sentence\n";

	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">but<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $this_verb;
	    my $objects_of_verb;





	    if($precedes_rightmost_coordinator =~ /($not)(\s+)($only)(\s+)($any_kind_of_prep)(\s*)((.|\s)+)$/){
		$subject = $PREMATCH;
		my $prep = $5;
		$np1 = $8;

		$sentence1 = $subject." ".$prep." ".$np1."<PC ID=\"000\" CLASS=\"CMN1\">and</PC>".$follows_rightmost_coordinator;

#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}


		@simpler_sentences[0] = "{CMN1-8a} ".$sentence1.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
# # # # # # # # # # # # # # # # comma-and # # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">\,\s+and<\/PC>/){
	print STDERR "PROCESSING ,_and-CMN1\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">\,\s+and<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $this_verb;
	    my $objects_of_verb;

	    if($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
		$subject = $PREMATCH;
		$objects_of_verb = $POSTMATCH;
		$this_verb = $&;

		print STDERR "SUBJ $subject\n";

	    }
	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
		$follows_coordination = " ".$&.$POSTMATCH;
	    }


	    print STDERR "FC $follows_coordination\n";
	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	}

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMN1-3a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMN1-3b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

# # # # # # # # # # # # # # ## semicolon-and # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">\;\s+and<\/PC>/){
	print STDERR "PROCESSING ,_and-CMN1\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">\;\s+and<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $this_verb;
	    my $objects_of_verb;

	    if($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
		$subject = $PREMATCH;
		$objects_of_verb = $POSTMATCH;
		$this_verb = $&;

		print STDERR "SUBJ $subject\n";

	    }
	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
		$follows_coordination = " ".$&.$POSTMATCH;
	    }


	    print STDERR "FC $follows_coordination\n";
	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	}

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMN1-4a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMN1-4b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }



# # # # # # # # # # # # # # # # # commas # # # # # # # # # # # # # # # # # # #
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">(\,|\;)<\/PC>/){
	print STDERR "PROCESSING ,_and-CMN1\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">(\,|\;)<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_coordination;
	    my $this_verb;
	    my $objects_of_verb;

	    if($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
		$subject = $PREMATCH;
		$objects_of_verb = $POSTMATCH;
		$this_verb = $&;

		print STDERR "SUBJ $subject\n";
	    }

	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
		$follows_coordination = " ".$&.$POSTMATCH;
	    }
	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	}

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMN1-5a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMN1-5b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

################################### CMN4 #######################################

    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN4\">(and|or)<\/PC>/){
#	print STDERR "PROCESSING or-CMN4\t$sentence\n"; exit;
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN4\">(and|or)<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $this_verb;
	    my $objects_of_verb;

	    if($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_adj1)(\s*)$/){
		$subject = $PREMATCH;
		my $this_determiner = $1;
		my $space1 = $3;
		my $adj1 = $4;
		my $space2 = $8;
		my $np1 = $this_determiner.$space1.$adj1.$space2;

		if($follows_rightmost_coordinator =~ /\Q$this_determiner\E(\s+)($any_kind_of_adj1)(\s+)($any_kind_of_noun)/){
		    $follows_coordination = $POSTMATCH;
		    my $space1 = $1;
		    my $adj2 = $2;
		    my $space2 = $6;
		    my $head_noun = $7;

		    $np1 .= $head_noun;
		    $np2 = $this_determiner.$space1.$adj2.$space2.$head_noun;

		    my $sentence1 = $subject.$np1.$follows_coordination;
		    my $sentence2 = $subject.$np2.$follows_coordination;

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMN4-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMN4-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $determiner1 = $3.$4.$7;
		print STDERR "FRC $follows_rightmost_coordinator\n";


		if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
#		if($follows_rightmost_coordinator =~ /^(\s*)(any_kind_of_determiner)(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		    $follows_coordination = $POSTMATCH;
		    my $determiner2 = $1.$2;
		    my $adj2 = $2;
		    my $space2 = $6;
		    my $noun_modifiers = $5.$6;
		    my $head_noun = $10;

#		    print STDERR ">>>>>>>>>>>>>>> $determiner1 $determiner2 $noun_modifiers $head_noun\n";

		    $np1 = $determiner1.$head_noun;
		    $np2 = $determiner2.$noun_modifiers.$head_noun;


		    my $sentence1 = $subject.$np1.$follows_coordination;
		    my $sentence2 = $subject.$np2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMN4-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMN4-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	}
    }
 # # # # # # # # comma-conjunction
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN4\">\,\s+and<\/PC>/){
#	print STDERR "PROCESSING or-CMN4\t$sentence\n"; exit;
# "...not guilty of [[six charges of making racial remarks to or about Pte Roy Carr, 26], and [two of ill treatment]]." 
# ...CD NN1 of ... CONJ CD of ... NN2 
# rewrites as ...CD NN1 of ... . ...CD NN1 of ... NN2  
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;
	
	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN4\">\,\s+and<\/PC>/g){
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $this_verb;
	    my $objects_of_verb;


#	    if($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s+)($any_kind_of_noun)(\s+)($of)(($any_kind_of_word|$any_kind_of_pc|\s)+)/){ # $/){
	    if($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s+)($any_kind_of_noun)(\s+)($of)((.|\s)*)$/){
		my $cd1 = $1;
		my $repeated_noun = $5;
		my $prep_of1 = $9;
		my $of_arg1 = $10;
		$subject = $PREMATCH;


		if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_number)(\s+)($of)(\s+)(($any_kind_of_noun|$any_kind_of_adj1|\s)+)/){
		    $follows_coordination = $POSTMATCH;
		    my $cd2 = $2;		    
		    my $prep_of2 = $6;
		    my $of_arg2 = $8;

		    $sentence1 = $subject.$cd1." ".$repeated_noun." ".$prep_of1.$of_arg1.$follows_coordination;
		    $sentence2 = $subject." ".$repeated_noun." ".$prep_of2." ".$of_arg2.$follows_coordination;
		    		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMN4-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMN4-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	}
    }

################################### CMP #######################################
###### Conjunctions
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP">(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}

	if($precedes_rightmost_coordinator =~ /($to)((\s|$any_kind_of_determiner|$any_kind_of_adj1)*)($any_kind_of_noun)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    
	    print STDERR "FFFFFFFFFFFF\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adverb)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		    $sentence1 = $subject.$pp1.$follows_coordination;
		    $sentence2 = $subject.$pp2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMP-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun)*?)($any_kind_of_noun)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

       	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_noun|$any_kind_of_adj1)*?)($subordinating_that)((.|\s)*?)($any_kind_of_sentence_boundary)/){ # ((^$subordinating_that)*?)($any_kind_of_sentence_boundary)/){
		$pp2 = $&;
		$follows_coordination = $18.$POSTMATCH;

		my $follows_that = $16;

		if($follows_that =~ /($any_kind_of_subordinator)/){
		}
		else{
		    print STDERR "PPPPPPPPPPP $follows_that\n";
		    
		    print STDERR "FFFFFFFFFFFF $pp1\n2GGGGGGGGGGG$pp2\n";
		    
		    $sentence1 = $subject.$pp1.$follows_coordination;
		    $sentence2 = $subject.$pp2.$follows_coordination;
		    
		    print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    
		    @simpler_sentences[0] = "{CMP-3a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-3b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }	    
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		print STDERR "FFFFFFFFFFFF $pp1\nJJJJJJJJJJJJ $pp2\n";

		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		print STDERR "TTTS1 $sentence1\nTTTS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}



    }
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(\,|\;)(\s+)(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP">(\,|\;)(\s+)(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}

	if($precedes_rightmost_coordinator =~ /($with)(\s*)($vbg_verb)((.|\s)+)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($of)(\s*)($vbg_verb)((.|\s)+)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($vbg_verb)((.|\s)+)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	    
	    print STDERR "TTTTTTTTTTTTTTT\n";

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(\s*)($base_np)(\s+)($any_kind_of_prep)(\s+)($base_np)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($vb_verb)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_pc|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	
	    if($follows_rightmost_coordinator =~ /^(\s+)($to)(\s*)($vb_verb)(($any_kind_of_noun|$any_kind_of_prep|\s)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;
		

		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	


	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_adverb|\s)*?)($any_kind_of_prep)(($any_kind_of_number|$any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s|$of)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;


		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
############# punctuation
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(\,|\;)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP">(\,|\;)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}

	if($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(($to|$any_kind_of_possPron|$any_kind_of_noun|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	    


	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(($to|$any_kind_of_possPron|$any_kind_of_noun|\s)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
################################### CMA1 #######################################
###### Conjunctions
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(and|but|or)<\/PC>/g){
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;

	    if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)$/){
		$adjp1 = $&;
		$subject = $PREMATCH;


		if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)/){
		    my $adjp2 = $&;
		    my $follows_coordination = $POSTMATCH;

#		    print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		    $sentence1 = $subject.$adjp1.$follows_coordination;
		    $sentence2 = $subject.$adjp2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMA1-2a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMA1-2b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
		elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adverb)(\s+)($any_kind_of_adj1|$any_kind_of_prep)/){
		    my $adjp2 = $&;
		    my $follows_coordination = $POSTMATCH;

#		    print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		    $sentence1 = $subject.$adjp1.$follows_coordination;
		    $sentence2 = $subject.$adjp2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMA1-3a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMA1-3b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }

	    if($precedes_rightmost_coordinator =~ /($vbn_verb)(\s*)$/){
		$adjp1 = $&;
		$subject = $PREMATCH;


		if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_word|$any_kind_of_possessive|\s)*?)($any_right_subordination_boundary)/){
		    my $adjp2 = $1.$2;
		    my $follows_coordination = $8.$POSTMATCH;

#		    print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		    $sentence1 = $subject.$adjp1.$follows_coordination;
		    $sentence2 = $subject.$adjp2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMA1-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMA1-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }

	}
    }
###### Punctuation-Conjunctions
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}

	if($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s+)($vbn_verb)(\s*)($base_np)($any_kind_of_adverb)(\s*)$/){
	    $adjp1 = $6.$8.$9.$22.$25;
	    $subject = $PREMATCH.$1.$5;
	    my $remainder = $POSTMATCH;
	    

	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(\s+)($any_kind_of_prep)((.|\s)*)$/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		    print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }

###### Punctuation
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(\;|\,|\:)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMA1\">(\;|\,|\:)<\/PC>/g){
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;


	    if($precedes_rightmost_coordinator =~ /(($any_kind_of_adj1|$any_kind_of_adverb|\s)*?)($any_kind_of_adj1)(\s*)$/){
		$adjp1 = $&;
		$subject = $PREMATCH;




		if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_word)(\s*)<PC/){
		    my $adjp2 = $1.$2;
		    my $follows_coordination = $5."<PC".$POSTMATCH;

#

		    $sentence1 = $subject.$adjp1.$follows_coordination;
		    $sentence2 = $subject.$adjp2.$follows_coordination;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMA1-5a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMA1-5b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	}
    }
################################### CMAdv #######################################
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMAdv\">(and|or)<\/PC>/i){
	print STDERR "PROCESSING and-CMAdv\t$sentence\n";
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;
	my $adverbial1;
	my $adverbial2;
	my $follows_coordination;
	my $subject;
	my $sentence1;
	my $sentence2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMAdv\">(and|or)<\/PC>/ig){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}

	if($precedes_rightmost_coordinator =~ /($to)(($any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)/){
		print STDERR "IIIIIIIIIIIIIII\n";

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;


		print STDERR "ADVP2 $adverbial2\n";

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		
		@simpler_sentences[0] = "{CMAdv-4a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


	    print STDERR "SUBJ $subject\n";exit;
	}
	if($precedes_rightmost_coordinator =~ /($any_kind_of_prep)((.|\s)*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;
	    my $this_prepostion = $1;
	    my $advp_tag_sequence = "";
	    while($adverbial1 =~ /p\=\"([^\"]+)\"/g){
		$advp_tag_sequence .= $1."#";
	    }




	    if($follows_rightmost_coordinator =~ /^(\s*)$this_prepostion((.|\s)*)/){
#		print STDERR "IIIIIIIIIIIIIII PW $this_prepostion\nADVP1 $adverbial1\nADVP TS $advp_tag_sequence\n";
		my $match = $&;
		my $advp2_tag_sequence = "";
		my $current_adverbial2 = "";
		$follows_coordination = $POSTMATCH;
		while($match =~ /<w((.|\s)*?)p\=\"([^\"]+)\">([^<]+)<\/w>/g){
		    $advp2_tag_sequence .= $3."#";
		    $current_adverbial2 .= $&." ";
		    my $fc = $POSTMATCH;
		    if($advp2_tag_sequence eq $advp_tag_sequence){
			$adverbial2 = $current_adverbial2;
			$follows_coordination = $fc;
			last;
		    }
		}

		print STDERR "ADVP2 $adverbial2\n";

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		
		@simpler_sentences[0] = "{CMAdv-3a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($to)(($any_kind_of_noun|$any_kind_of_determiner|\s)*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;



	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)/){

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;


             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		
		@simpler_sentences[0] = "{CMAdv-1a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_pron)(\s*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;
	
	    if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_prep)(($any_kind_of_adj1|$any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)/){       
		$adverbial2 = $&;
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		@simpler_sentences[0] = "{CMAdv-2a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
    }
################################### CIN #######################################
# # # # # # # # # # and/or
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CIN\">(and|or)<\/PC>/i){
# DT _ CIN _ NN _
	my $precedes_coordinator;
	my $follows_coordinator;
	my $follows_coordination;
	my $nbar1;
	my $nbar2;
	my $precedes_coordination;
	my $this_determiner;
	my $subject;
	my $sentence1;
	my $sentence2;
	print STDERR "PROCESSING CIN\n\t$sentence\n";# exit;
	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CIN\">(and|or)<\/PC>/gi){
	    $this_determiner = $&;
	    $precedes_coordinator = $PREMATCH;
	    $follows_coordinator = $POSTMATCH;
	    $follows_coordination;


	    if($precedes_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_noun)(\s*)$/){
		my $det = $1;
		$nbar1 = $3.$4.$8;
		$subject = $PREMATCH.$det;



		if($follows_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s+)($any_kind_of_noun)/){
		    my $follows_coordination = $POSTMATCH;
		    my $nbar2 = $&;

		    $sentence1 = $subject.$nbar1.$follows_coordination;
		    $sentence2 =  $subject.$nbar2.$follows_coordination;

#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    @simpler_sentences[0] = "{CIN-6a} ".$sentence1;
		    @simpler_sentences[1] = "{CIN-6b} ".$sentence2;

		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
#		    print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
		}
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	    }
	    elsif($precedes_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_number)(\s+)($plural_noun)(\s*)$/){
		my $det = $1;
		my $cd1 = $4;
		my $space1 = $7;
		my $nns1 = $8;
		my $space2 = $10;
		$nbar1 = $cd1.$space1.$nns1.$space2;
		$subject = $PREMATCH.$det;


		if($follows_coordinator =~ /^(\s*)($any_kind_of_number)(\s+)($plural_noun)/){
		    my $space1 = $1;
		    my $cd2 = $2;
		    my $space2 = $5;
		    my $nns2 = $6;
		    my $follows_coordination = $POSTMATCH;
		    my $nbar2 = $space1.$cd2.$space2.$nns2;

		    my $sentence1 = $subject.$nbar1.$follows_coordination;
		    my $sentence2 =  $subject.$nbar2.$follows_coordination;

		    @simpler_sentences[0] = "{CIN-4a} ".$sentence1;
		    @simpler_sentences[1] = "{CIN-4b} ".$sentence2;

		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
#		    print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
		}
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	    }
	    elsif($precedes_coordinator =~ /($any_kind_of_determiner)(\s+)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)$/){
		my $det = $1;
		my $space1 = $3;
		$subject = $PREMATCH.$det.$space1;
		$nbar1 = $4;



		if($follows_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)(\s*)($any_kind_of_sentence_boundary)/){
		    my $follows_coordination = $10.$POSTMATCH;
		    my $nbar2 = $1.$2;


		    my $sentence1 = $subject.$nbar1.$follows_coordination;
		    my $sentence2 =  $subject.$nbar2.$follows_coordination;

		    @simpler_sentences[0] = "{CIN-5a} ".$sentence1;
		    @simpler_sentences[1] = "{CIN-5b} ".$sentence2;

		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
#		    print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
		}
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	    }
# "using false CV and application form details"
	    elsif($precedes_coordinator =~ /($any_kind_of_verb)(\s+)($any_kind_of_adj1)(\s+)($any_kind_of_noun)(\s+)$/){
		$nbar1 = $10;
		$subject = $PREMATCH.$1.$4.$5.$9;
		if($follows_coordinator =~ /^(\s+)(($any_kind_of_noun|$any_kind_of_adj1|\s)+)/){
		    $nbar2 = $&;
		    $follows_coordination = $POSTMATCH;

		    my $sentence1 = $subject.$nbar1.$follows_coordination;
		    my $sentence2 = $subject.$nbar2.$follows_coordination;

		    @simpler_sentences[0] = "{CIN-3a} ".$sentence1;
		    @simpler_sentences[1] = "{CIN-3b} ".$sentence2;

		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}



#		print STDERR "FOUND $&\nNBAR1 $nbar1\nNBAR2 $nbar2\nSUBJ $subject <<<\n";exit;
	    }
	    else{

		while($precedes_coordinator =~ /$any_kind_of_adj1\s+$any_kind_of_noun/g){
		    $nbar1 = $&;
		    $precedes_coordination = $PREMATCH;
		}
		print STDERR "NBAR1 IS $nbar1\n";
		
		print STDERR "precedes coordination $precedes_coordination\n";
		
		if($follows_coordinator =~ /$any_kind_of_prep/){
		    $follows_coordination = $&.$POSTMATCH;
		    $nbar2 = $PREMATCH;
		}
		
		
		
		
		my $sentence1 = $precedes_coordination.$nbar1." ".$follows_coordination;
		my $sentence2 = $precedes_coordination.$nbar2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		if($sentence1 !~ /([A-Za-z]+)/){
		    print STDERR "SENT $sentence produces EMPTY S1\n";exit;
		}
		
		
		@simpler_sentences[0] = "{CIN-1a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
    }
# # # # # # # # # # anything

    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CIN\">([^<]+)<\/PC>/){
# DT _ CIN _ NN _
	my $precedes_coordinator = $PREMATCH;
	my $follows_coordinator = $POSTMATCH;
	my $follows_coordination;
	my $nbar1;
	my $nbar2;
	my $precedes_coordination;
	my $this_determiner;
	my $this_verb;

	my $determiner_position = 0;
	my $verb_position = 0;
	my $precedes_determiner;
	my $precedes_verb;

	while($precedes_coordinator =~ /$any_kind_of_determiner/g){
	    $this_determiner = $&;
	    $nbar1 = $this_determiner.$POSTMATCH;
	    $precedes_determiner = $PREMATCH;
	    $determiner_position = length($precedes_coordination);
	}
	while($precedes_coordinator =~ /$any_kind_of_verb/g){
	    $this_verb = $&;
	    $nbar1 = $this_determiner.$POSTMATCH;
	    $precedes_verb = $PREMATCH;
	    $verb_position = length($precedes_coordination);
	}
	if($verb_position > $determiner_position){
	    if($verb_position > 0){
		$precedes_coordinator = $precedes_verb;
	    }
	}
	else{
	    if($determiner_position > 0){
		$precedes_coordinator = $precedes_determiner;
	    }
	}


#	print STDERR "precedes coordinator $precedes_coordinator\n";exit;
	if($nbar1 eq ""){
	    while($precedes_coordinator =~ /$any_kind_of_adj1((.|\s)*?)$plural_noun/g){
		$nbar1 = $&;
		$precedes_coordination = $PREMATCH;
		print STDERR "SENT $sentence\n";exit;
	    }
	}
	if($follows_coordinator =~ /($any_kind_of_verb|$any_kind_of_subordinator)/){
	    $follows_coordination = $&.$POSTMATCH;
	    $nbar2 = $PREMATCH;
	}

	print STDERR "NBAR1 $nbar1\nNBAR2 $nbar2\n";
	print STDERR "PROCESSING CIN\n\t$sentence\n";# exit;


	my $sentence1 = $precedes_coordination.$nbar1.$follows_coordination;
	my $sentence2 = $precedes_coordination.$this_determiner.$nbar2.$follows_coordination;

	$sentence1 =~ s/\s*$//;
	$sentence2 =~ s/^\s*//;

	if($sentence1 !~ /([A-Za-z]+)/){
	    print STDERR "SENT $sentence produces EMPTY S1\n";exit;
	}


	@simpler_sentences[0] = "{CIN-2a} ".$sentence1;
	@simpler_sentences[1] = "{CIN-2b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;

	print STDERR "SS REF IS $simpler_sentences_ref\n";
	return($simpler_sentences_ref);
    }


################################### CLV #######################################
###### Conjunctions
# Note that all rules must be ordered, more specific and detailed prior to more
# general or they will not have chance to be activated
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(and|but|or)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";

	print STDERR "3GGGGGGGGGGGG\n";

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	    print STDERR "\t>>> PRMC $precedes_rightmost_coordinator <<<\nFRC $follows_rightmost_coordinator\n";
	}
	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    
	    print STDERR "GGGV1 $verb1\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		print STDERR "HHHHHHHHHHSUBJ is $subject\nV2 $verb2\nFC is $follows_coordination\n";

		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "9a S1 $sentence1\n9b S2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLV-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)(($any_kind_of_rp|\s)*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    print STDERR "4GGGGGGGGGGGGGG\n";    		
	    
	    if($follows_rightmost_coordinator =~ /^((\s|$any_kind_of_adverb)*)($any_kind_of_verb)(($any_kind_of_rp|\s)*)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)(($any_kind_of_adverb|\s)*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    print STDERR "12341234";
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$any_kind_of_verb|$any_kind_of_modal|\s)*?)(\s*)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)(($any_kind_of_prep|\s)*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    print STDERR "1234512345";
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_verb|$any_kind_of_modal|\s)*?)(\s*)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		print STDERR ":::::::::::::\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
# Patterns used to handle mis-tagged verbs
	
	
	elsif($precedes_rightmost_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">\,<\/PC>(\s+)($any_kind_of_word)(\s*)$/){
	    my $verb1 = $2.$3.$6;
	    $subject = $PREMATCH."<PC ID\=\"".$1."\" CLASS\=\"CLV\">\,</PC>";
#		print STDERR "V1 \[$verb1\]";
		
	    print STDERR "123456123456";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_word)(\s*)/){ 
		my $verb2 = $&;
		$follows_coordination = $POSTMATCH;
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($any_kind_of_noun)(\s*)$/){
	    my $verb1 = $3;
	    my $subject = $PREMATCH.$1.$2;
		
	    print STDERR "12345671234567";

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adverb)(\s+)($any_kind_of_noun)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-10b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_noun)(\s+)($any_kind_of_determiner)/){
		my $verb2 = $2;
		my $follows_coordination = $6.$POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		

		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($quotes)($any_kind_of_noun)($quotes)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    
	    print STDERR "12345678a12345678a\n";		
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($quotes)($any_kind_of_word)($quotes)(\s*)($any_kind_of_sentence_boundary)/){
		my $verb2 = $1.$2.$5.$8.$11;
		my $follows_coordination = $12.$POSTMATCH;


		
		$sentence1 = $subject."[".$verb1."]".$follows_coordination;
		$sentence2 = $subject."[".$verb2."]".$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($left_quote)(\s*)($any_kind_of_word)/){
	    my $verb1 = $5;
	    my $subject = $PREMATCH;
	    
	    print STDERR "1234567812345678";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_word)($left_quote)/){
		my $verb2 = $2;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$any_kind_of_noun)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
		
	    print STDERR "123456789123456789";

	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_adverb|$any_kind_of_verb|$any_kind_of_modal|\s)*?)(\s*)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		    
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /./){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
		
	    print STDERR "DDDDDDDDDDDDDDDDDDDDDDDD\n";

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
		
	    print STDERR "123456789123456789";

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
    }
##### comma and
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(\,|\;|\:)(\s*)(and|but|or)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";

	print STDERR "1GGGGGGGGGGGG\n";

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(\,|\;|\:)(\s*)(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	    print STDERR "\t>>> PRMC $precedes_rightmost_coordinator <<<\nFRC $follows_rightmost_coordinator\n";
	}
	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)(($any_kind_of_verb|\s)*)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		


		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "9a S1 $sentence1\n9b S2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLV-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
    
###### Commas
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(\,|\;)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $verb1;
	my $verb2;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">(\,|\;)<\/PC>/g){

	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}
	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)$/){
	    my $verb1 = $&;
#	    $subject = $PREMATCH."<PC ID\=\"".$1."\" CLASS\=\"CLV\">\,</PC>";
	    $subject = $PREMATCH;
		
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_verb)(\s*)/){ 
		my $verb2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
		
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_verb)(\s*)/){ 
		my $verb2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
		
	    }
	}
	
# Most dangerous, general pattern so far
	if($precedes_rightmost_coordinator =~ /(\s+)($to)(\s+)($any_kind_of_word)$/){
	    $verb1 = $4;
	    $subject = $PREMATCH.$1.$2.$3;
	    
	    if($follows_rightmost_coordinator =~ /($any_kind_of_word)(\s+)($any_kind_of_prep)/){
		$verb2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
################################### CLN #######################################

    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}
	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		my $noun2 = " ".$7;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLN-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-1b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
############ Punctuation-Conjunction
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}
	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		my $noun2 = " ".$7;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLN-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-2b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
############ Punctuation
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(\,|\;|\:)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $precedes_rightmost_coordinator;
	my $follows_rightmost_coordinator;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLN\">(\,|\;|\:)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;
	}
	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    

	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		my $noun2 = $1.$7;
		my $follows_coordination = $POSTMATCH;

		print STDERR "FFFFFFFFFFFFF \n";
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLN-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-3b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }


################################### CLA #######################################
######## Conjunctions
# Note with this class and all lexical coordination, it may be more desirable to
# simply return the input sentence without the tags to indicate CLA as
# @simpler_sentences[0] and not return anything else.
#
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLA\">(and|or|but)<\/PC>/){
# When enumerating these regExs, it is necessary to also count the
# parenthetical expressions defined in the variables
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adj1;
	my $adj2;


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLA\">(and|or|but)<\/PC>/g){
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;

	    if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s+)$/){
		$subject = $PREMATCH;
		$adj1 = $&;

		if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-1a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
		elsif($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_number)($hyphen)($vbn_verb)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $&;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-5a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-5b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
		elsif($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_verb)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $&;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-6a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-6b} ".$sentence2;
		    
		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
	    }
	    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_noun|$any_kind_of_verb)\s*$/){
		$subject = $PREMATCH;
		$adj1 = $4;

		if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-2a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-2b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
	    }
	    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun|$any_kind_of_verb)\s*$/){
		$subject = $PREMATCH;
		$adj1 = $1;

		if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1|$vbg_verb)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    @simpler_sentences[0] = "{CLA-3a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-3b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
	    }
	}
    }
####### Commas
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLA\">(\,|\;)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adj1;
	my $adj2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLA\">(\,|\;)<\/PC>/g){
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;

	    if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)$/){
		$subject = $PREMATCH;
		$adj1 = $&;



		if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-4a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-4b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
	    }
	    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_noun|$any_kind_of_verb)$/){
		$subject = $PREMATCH.$1.$3;
		$adj1 = $4;



		if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		    $follows_coordination = $POSTMATCH;
		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    @simpler_sentences[0] = "{CLA-3a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-3b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
		elsif($follows_rightmost_coordinator =~ /(\s*)($vbg_verb)/){
		    $follows_coordination = $POSTMATCH;

		    $adj2 = $2;

		    $sentence1 = $subject.$adj1.$follows_coordination;
		    $sentence2 = $subject.$adj2.$follows_coordination;

		    $sentence1 =~ s/\s*$//;
		    $sentence2 =~ s/^\s*//;

		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    @simpler_sentences[0] = "{CLA-7a} ".$sentence1;
		    @simpler_sentences[1] = "{CLA-7b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    print STDERR "SS REF IS $simpler_sentences_ref\n";
		    return($simpler_sentences_ref);
		}
	    }
	}
    }

################################### CLP #######################################
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLP\">(or|and)<\/PC>/){
# When enumerating these regExs, it is necessary to also count the
# parenthetical expressions defined in the variables
	print STDERR "PROCESSING and-CLP\n\t$sentence\n";

	my $sentence1;
	my $sentence2;

	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLP\">(or|and)<\/PC>/g){
	    my $conjunction = $2;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;
	    my $subject;
	    my $follows_coordination;
	    my $prep1;
	    my $prep2;

	    if($precedes_rightmost_coordinator =~ /($to|$any_kind_of_prep)(\s*)$/){
		$prep1 = $&;
		$subject = $PREMATCH;


		if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep|$to)/){
		    $prep2 = $&;
		    $follows_coordination = $POSTMATCH;

		    $sentence1 = $subject.$prep1.$follows_coordination;
		    $sentence2 = $subject.$prep2.$follows_coordination;

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CLP-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CLP-1b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }

	}

    }

################################### CLQ #######################################
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLQ\">(or|and)<\/PC>/){
# When enumerating these regExs, it is necessary to also count the
# parenthetical expressions defined in the variables
	print STDERR "PROCESSING and-CLQ\n\t$sentence\n";

	my $sentence1;


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CLQ\">(or|and)<\/PC>/g){
	    my $conjunction = $2;
	    my $precedes_rightmost_coordinator = $PREMATCH;
	    my $follows_rightmost_coordinator = $POSTMATCH;

	    $sentence1 = $precedes_rightmost_coordinator.$conjunction.$follows_rightmost_coordinator;
	    $sentence1 =~ s/\s*$//;
	    @simpler_sentences[0] = "{CLQ-1} ".$sentence1;

	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    print STDERR "SS REF IS $simpler_sentences_ref\n";
	    return($simpler_sentences_ref);
	}

    }
################################## CPA ########################################
    elsif($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CPA\">(and|but|or)<\/PC>/){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";
	my $precedes_rightmost_coordinator = "";
	my $follows_rightmost_coordinator = "";


	while($sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CPA\">(and|but|or)<\/PC>/g){
	    $precedes_rightmost_coordinator = $PREMATCH;
	    $follows_rightmost_coordinator = $POSTMATCH;

	    print STDERR "\t>>> PRMC $precedes_rightmost_coordinator <<<\nFRC $follows_rightmost_coordinator\n";
	}

	if($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s*)$/){
	    my $prefix1 = $&;
	    my $subject = $PREMATCH;

	    if($prefix1 =~ />([^<]+)</){
		$prefix1 = $1;
		$prefix1 =~ s/\-$//;
	    }	    


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)/){
		my $follows_coordination = $POSTMATCH;
		my $adjective2 = $&;
		my $adjective1 = $adjective2;
		$adjective1 =~ s/>([^\-]+)\-/>$prefix1\-/;


		

		$sentence1 = $subject.$adjective1.$follows_coordination;
		$sentence2 = $subject.$adjective2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "9a S1 $sentence1\n9b S2 $sentence2\n";
		
		@simpler_sentences[0] = "{CPA-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CPA-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }

    print STDERR "NO RULE MATCHED $sentence\n"; exit;
}
1;
