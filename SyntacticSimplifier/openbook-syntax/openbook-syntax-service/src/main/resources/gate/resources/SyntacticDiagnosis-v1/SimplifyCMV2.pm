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
package SimplifyCMV2;
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
my $pound = "<w c\=\"what\" p\=\"(CD|VBD)\">\£<\/w>";
my $told = "<w c\=\"w\" p\=\"VBD\">told<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $sentence1;
    my $sentence2;
    my $subject;
    my $follows_coordination;

    print STDERR "SIMPLIFYING ######### $sentence\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }



###################################### CMV2 ###################################
    if($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(and|but|or)<\/PC>/){


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
	elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_number)/){
	    my $clause_subject = $2.$7;
	    my $clause_adverb = $12;

	    $sentence1 = $precedes_rightmost_coordinator;
	    $sentence2 = $sentence1;

	    print STDERR "$sentence1 +++++++++\n";

	    $sentence1 =~ s/($any_kind_of_noun)/$clause_subject/;
	    $sentence1 =~ s/($any_kind_of_number|<w c\=\"w\" p\=\"JJ\">ten<\/w>)/$clause_adverb/;
#	    print STDERR ">>>>>>>>>>>>>>$clause_subject\n$clause_adverb\n";exit;

	    print STDERR "S1 $sentence1\nS2 $sentence2\n";
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
		
	    @simpler_sentences[0] = "{CMV2-2a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV2-2b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($told)($base_np)((.|\s)*)$/){
	    my $verb1 = $1;
	    my $v1_object1 = $2;
	    my $v1_object2 = $15;
	    my $subject = $PREMATCH;

#	    print STDERR ">>>>>>>>>>>>> \[$verb1\] \[$v1_object1\] \[$v1_object2\]\n";exit;

# Following pattern to catch -ing words mistagged as NN
	    if($follows_rightmost_coordinator =~ /^(\s*)<([^>]+)>that<([^>]+)>((\s|.)*)$/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object1.$v1_object2.$follows_coordination;
		$sentence2 = $subject.$verb1.$v1_object1.$v2_object.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMV2-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
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
		
		@simpler_sentences[0] = "{CMV2-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(($any_kind_of_verb|\s)*)/){
	    my $verb1 = $1;
	    my $v1_object = $4.$6;
	    my $subject1 = $PREMATCH;
	    my $subject2;
	    while($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(($any_kind_of_verb|\s)*)/g){
		$verb1 = $&;
		$v1_object = $POSTMATCH;
		$subject1 = $PREMATCH;
	    }

# Following pattern to catch -ing words mistagged as NN
	    if($follows_rightmost_coordinator =~ /^(\s*)($base_np)(($pound|$any_kind_of_number|\s)+)/){
		$subject2 = $2;
		my $v2_object = $15;

		my $follows_coordination = $POSTMATCH;
		

		$sentence1 = $subject1.$verb1.$v1_object.$follows_coordination;
		$sentence2 = $subject2.$verb1.$v2_object.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMV2-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)(\s+)(and|but|or)<\/PC>/){

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
		
		
		@simpler_sentences[0] = "{CMV2-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
################## commas
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV2\">(\,|\;|\:)<\/PC>/){

#	print STDERR ">>>>>>>>>>>>>>>>>\n$precedes_rightmost_coordinator\n";exit;


	if($precedes_rightmost_coordinator =~ /($vbd_verb)(($base_np|\s)*)($colon)((\s|.)*)$/){
	    my $verb1 = $1.$3.$15;
	    my $v1_object = $18;# .$10.$11.$12.$16;
	    my $subject = $PREMATCH;

	    print STDERR "AAAAAAAAAAAAAAAAAAV1 $verb1\nFRC $follows_rightmost_coordinator\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s+)($to)(\s+)($base_np)/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$v1_object.$follows_coordination;
		$sentence2 = $subject.$verb1.$v2_object.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($to)(\s*)($base_np)(\s*)$/){
	    my $verb1 = $1;
	    my $v1_arg = $3.$4.$5.$6.$17;
	    my $subject = $PREMATCH;

#	    print STDERR "\[$v1_arg\]\n"; exit;

	    print STDERR "";
#	    print STDERR "AAAAAAAAAAAAAAAAAAV1 $verb1\nFRC $follows_rightmost_coordinator\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s+)($to)(\s+)($base_np)/){
		my $v2_object = $&;
		my $follows_coordination = $POSTMATCH;
		
#		$sentence1 = $subject.$verb1.$v1_object.$follows_coordination;
#		$sentence2 = $subject.$verb1.$v2_object.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($base_np)(\s+)($to)(\s+)($base_np)/){
		my $v2_subject = $2;
		my $v2_arg = $15.$16.$17.$18;
		my $follows_coordination = $POSTMATCH;
		


		$sentence1 = $subject.$verb1.$v1_arg.$follows_coordination;
		$sentence2 = $v2_subject.$verb1.$v2_arg.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMV2-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV2-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }


    print STDERR "CMV2 NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
