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
package SimplifyCMV1;
use English;
use strict;
my $any_kind_of_word = "<w c\=\"w\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $any_kind_of_possessive = "<w c\=\"aposs\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $any_kind_of_verb = "<w c\=\"w\" p\=\"(VBG|VBN|VBP|VBD|VB|VBZ)\">([^<]+)<\/w>";
my $any_kind_of_modal = "<w c\=\"w\" p\=\"MD\">([^<]+)<\/w>";
my $vb_verb = "<w c\=\"w\" p\=\"VB\">([^<]+)<\/w>";
my $vbp_verb = "<w c\=\"w\" p\=\"VBP\">([^<]+)<\/w>";
my $vbz_verb = "<w c\=\"w\" p\=\"VBZ\">([^<]+)<\/w>";
my $vbg_verb = "<w c\=\"(w|hyw)\" p\=\"VBG\">([^<]+)<\/w>";
my $vbd_verb = "<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>";
my $vbn_verb = "<w c\=\"(w|hyw)\" p\=\"VBN\">([^<]+)<\/w>";
my $any_kind_of_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([^<]+)<\/w>";
my $nnp_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNPS|NNP)\">([^<]+)<\/w>";
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
my $after = "<w c\=\"w\" p\=\"IN\">after<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $hyphen = "<w c\=\"hyph\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"(POS|\'\'|\`\`)\">([\']+)<\/w>";
my $ed_jj = "<w c\=\"(w|hyw)\" p\=\"JJ\">([^<]+?)ed<\/w>";
my $nk_jj = "<w c\=\"(w|hyw)\" p\=\"JJ\">([^<]+?)nk<\/w>";
my $nk_nn = "<w c\=\"(w|hyw)\" p\=\"NN\">([^<]+?)nk<\/w>";
my $offend_jj = "<w c\=\"(w|hyw)\" p\=\"JJ\">([^<]+?)offend<\/w>";
my $ing_nn = "<w c\=\"(w|hyw|abbr)\" p\=\"NN\">([^<]+)ing<\/w>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $because = "<w c\=\"w\" p\=\"IN\">(because|\'cause|\'coz|coz)<\/w>";
my $rp_word = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $sentence1;
    my $sentence2;
    my $vp1;
    my $vp2;
    my $subject;

    print STDERR "\t[CMV1]\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";

    my $print_precedes_rightmost_coordinator = $precedes_rightmost_coordinator;
    my $print_follows_rightmost_coordinator = $follows_rightmost_coordinator;

    $print_follows_rightmost_coordinator =~ s/<([^>]+)>//g;
    $print_precedes_rightmost_coordinator =~ s/<([^>]+)>//g;

    open(LOGFILE, ">./logfile_cmv1.txt");
    print LOGFILE "\[$print_precedes_rightmost_coordinator\]\t\[$potential_coordinator\]\t\[$print_follows_rightmost_coordinator\]\t";
    close(LOGFILE);

    print STDERR "$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    open(RAC, ">>RuleApplications.CMV1.txt");

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }





################################### CMV1 #######################################
# # # # # # # # # # # # # # # semicolon-conjunction # # # # # # # # # # # # # #
    if($potential_coordinator =~ /\;(\s+)(and|but|or)/){
#	my $return_pc = "<w c\=\"cm\" p\=\"\;\">\;<\/w>($1)<w c\=\"w\" p\=\"CC\">$2<\/w>";
#
#	unless($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj|$offend_jj|$any_kind_of_modal)/){
#	    print STDERR "1 NO VERBAL MATERIAL TO THE LEFT OF CMV1. RETURNING SENTENCE WITH ONE LESS PC\n";
#	    my $return_sentence = $precedes_rightmost_coordinator.$return_pc.$follows_rightmost_coordinator;
#
#	    @simpler_sentences[0] = "{CMV1-X1} ".$return_sentence;	
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}





	



	open(LOGFILE, ">>./logfile_cmv1.txt");
#	print LOGFILE "1\n";
	close(LOGFILE);
	return($simpler_sentences_ref);
    }
    

 # # # # # # # # ## # # # # comma-conjunction # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ /\,(\s+)(and|but)/i){
#	my $return_pc = "<w c\=\"cm\" p\=\"\,\">\,<\/w>($1)<w c\=\"w\" p\=\"CC\">$2<\/w>";
#	unless($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj|$offend_jj|$any_kind_of_modal)/){
#	    print STDERR "1 NO VERBAL MATERIAL TO THE LEFT OF CMV1. RETURNING SENTENCE WITH ONE LESS PC\n";
#	    my $return_sentence = $precedes_rightmost_coordinator.$return_pc.$follows_rightmost_coordinator;
#
#	    @simpler_sentences[0] = "{CMV1-X2} ".$return_sentence;	
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}
       
	if($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)(\s*)($base_np)(\s*)($because)/){
#	    print STDERR ">>>>>>>>>>>>>>>>\n";exit;

	    while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)(\s*)($base_np)(\s*)($because)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_verb|$any_kind_of_modal|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		    $vp2 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    


#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#		    print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
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
		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "2\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-1a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-1b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);
		    
		    return($simpler_sentences_ref);
		}
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($vbd_verb)/){
#	    print STDERR "HERE\n";exit;
	    while($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($vbd_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_verb|$any_kind_of_modal|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		    $vp2 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    


#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#		    print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
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
		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "2\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-2a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-2b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)(\s*)($vbg_verb)/){
	    $subject = $PREMATCH;
	    $vp1 = $&.$POSTMATCH;

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_prep|$any_kind_of_noun|\s)*)($vbd_verb)/){
		$vp2 = $&.$POSTMATCH;
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;


		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-63a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-63b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-63a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-63b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)/){
	    $subject = $PREMATCH;
	    $vp1 = $&.$POSTMATCH;

# following condition added 16/4/2013:
	    if($subject =~ /($any_kind_of_pc)/){
		while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb|$vbn_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
	    }

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_prep|$any_kind_of_noun|\s)*)($vbd_verb)/){
		$vp2 = $&.$POSTMATCH;
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;


		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-3a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-3b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_verb|$any_kind_of_modal|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		$vp2 = $&.$POSTMATCH;
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		    

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#		print STDERR "PTI $prior_to_this_instance\nAdvP $adverbial_phrase\nSUBJ $subject\nOCP $object_containing_part\n";exit;
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
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-4a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-4b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }

	}
###########################
	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbd_verb)/){
	    $vp2 = $&.$POSTMATCH;
	    if($precedes_rightmost_coordinator =~ /($vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    $vp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
		
		@simpler_sentences[0] = "{CMV1-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-5a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-5b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $vp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
		
		@simpler_sentences[0] = "{CMV1-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-6a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-6b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }

	}

	elsif($follows_rightmost_coordinator =~ /(\s*)($vbg_verb)/){
	    $vp2 = $&.$POSTMATCH;
	    if($precedes_rightmost_coordinator =~ /($vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}

		$sentence1 = $subject." ".$vp1;
		$sentence2 = $subject.$vp2;


		@simpler_sentences[0] = "{CMV1-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-7b} ".$sentence2;
	
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-7a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-7b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}

	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbp_verb)/){
	    $vp2 = $&.$POSTMATCH;

	    if($precedes_rightmost_coordinator =~ /($vbp_verb)/){
#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;
		while($precedes_rightmost_coordinator =~ /($vbp_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMV1-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-8a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-8b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/){
	    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		if($follows_rightmost_coordinator =~ /^(\s*)($vbd_verb)/){
		    $vp2 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }

#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    @simpler_sentences[0] = "{CMV1-9a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-9b} ".$sentence2;
	
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "3\n";
		    close(LOGFILE);
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-9a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-9b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);
		    
		    return($simpler_sentences_ref);
		}
	    }
	}	

    }
    

 # # # # # # # # # # # # # # ## # conjunction # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />(and|but|or)</i){
#	my $return_pc = "<w c\=\"w\" p\=\"CC\">$1<\/w>";
#	unless($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj|$offend_jj|$any_kind_of_modal)/){
#	    print STDERR "1 NO VERBAL MATERIAL TO THE LEFT OF CMV1. RETURNING SENTENCE WITH ONE LESS PC\n";
#	    my $return_sentence = $precedes_rightmost_coordinator.$return_pc.$follows_rightmost_coordinator;
#	    
#	    @simpler_sentences[0] = "{CMV1-X3} ".$return_sentence;	
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}

	print STDERR "PROCESSING and-CMV1\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n";

#	if($precedes_rightmost_coordinator =~ /($to)(\s*)($vb_verb)(\s*)($any_kind_of_adj1)(\s*)($base_np)/){
#	    my $vp1 = $&;
#	    print STDERR "-------------- $vp1\n";exit;
#	}

	if($follows_rightmost_coordinator =~ /^(\s*)($vbz_verb)(\s*)($vbn_verb)(\s*)($vbn_verb)/){
	    my $vp2 = $&.$POSTMATCH;

	    print STDERR ">>>>>>>>>>>>>> $vp2\n";


	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)/){

		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		
#		print STDERR "VP1: \[$vp1\]\n\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-10b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-10a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-10b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($comma|$quotes|$any_kind_of_adverb|\s)*)($vbz_verb|$nk_jj|$nk_nn|$ing_nn|$vbg_verb)/){
	    my $vp2 = $&.$POSTMATCH;

#	    print STDERR ">>>>>>>>>>>>>> $vp2\n";exit;

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_adverb|\s)*)($vbn_verb|$vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_adverb|\s)*)($vbn_verb|$vbg_verb)/g){
		    $subject = $PREMATCH.$1;
#		    $vp1 = $4.$8.$POSTMATCH;
		    $vp1 = " ".$7.$POSTMATCH;
		}
		
#		print STDERR "VP1: \[$vp1\]\n\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-11a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-11b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $subject = $PREMATCH;
#		    $vp1 = $4.$8.$POSTMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		
#		print STDERR "VP1: \[$vp1\]\n\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-12a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-12b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-13b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-13a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-13b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

#		print STDERR "S1 $sentence1\nS2 $sentence2";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-14b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-14a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-14b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_modal|$vb_verb|\s)*)($vbn_verb)(($any_kind_of_pc|\s)+)/){
	    my $vp2 = $&.$POSTMATCH;
	    my $follows_coordination;

#	    print STDERR ">>>>>>>>>>>>>>>>>>> $vp2\n";exit;


		
#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|$any_kind_of_possPron|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|$any_kind_of_possPron|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/g){
			
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		
		$sentence1 = $subject.$vp1.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-15b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-15a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-15b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }

	    
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_modal)(\s*)($vb_verb)(\s*)($rp_word)((.|\s)*)<w c\=\"cm\" p\=\"\,\">\,<\/w>/){
	    my $vp2 = $&;
	    my $follows_coordination = "<w c\=\"cm\" p\=\"\,\">\,<\/w>".$POSTMATCH;
	    $vp2 =~ s/<w c\=\"cm\" p\=\"\,\">\,<\/w>$//;

	    print STDERR "3>>>>>>>>>>>>>>>>>>> $vp2\n";


	    if($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbn_verb|$vb_verb)(\s*)($to)/){
		
		$vp1 = $&.$POSTMATCH;
		$subject = $PREMATCH;
		$sentence1 = $subject.$vp1.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-17b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-17a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-17b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$any_kind_of_modal|$to|\s)*)($vb_verb)/){
	    my $vp2 = $&.$POSTMATCH;
	    my $follows_coordination;

	    print STDERR ">>>>>>>>>>>>>>>>>>> $vp2\n";

	    if($vp2 =~ /<w c\=\"cm\" p\=\"\,\">\,<\/w>/){
		$follows_coordination = $&.$POSTMATCH;
		$vp2 = $PREMATCH;
#		print STDERR ">>>>>>>>>>>>>> $vp2\n$follows_coordination\n";exit;
	    }


	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_adj1)(\s*)($to)(\s*)($vb_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_adj1)(\s*)($to)(\s*)($vb_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}


		$sentence1 = $subject.$vp1.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-16b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-16a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-16b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		
	    }
	    elsif($precedes_rightmost_coordinator =~ /($to)(\s+)($vb_verb)/){

#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;

		if($precedes_rightmost_coordinator =~ /($to)(\s+)($vb_verb)/){
		    while($precedes_rightmost_coordinator =~ /($to)(\s+)($vb_verb)/g){

			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
			unless($vp2 =~ /^(\s*)($to)/){
			    $vp2 = "<w c=\"w\" p=\"TO\">to</w>".$vp2;
			}
		    }

		    $sentence1 = $subject.$vp1.$follows_coordination;
		    $sentence2 = $subject.$vp2.$follows_coordination;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-68a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-68b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-68a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-68b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		    		    
		}
	    }
	    elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|$to|\s)*)($vb_verb|$vbd_verb)/){

#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;

		if($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|$to|\s)*)($vbn_verb|$vb_verb)/){
		    while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|$to|\s)*)($vbn_verb|$vb_verb)/g){

			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
		    }

		    $sentence1 = $subject.$vp1.$follows_coordination;
		    $sentence2 = $subject.$vp2.$follows_coordination;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-67a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-67b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-67a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-67b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);
		    
		    return($simpler_sentences_ref);
		    		    
		}
# Modified 12/02/2013 flag "g" removed from the following regEx
		elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/){

		    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
		    }		    
				    
		    $sentence1 = $subject.$vp1.$follows_coordination;
		    $sentence2 = $subject.$vp2.$follows_coordination;


		
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-18a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-18b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		
		    open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-18a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-18b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
	    }
# CMV1-69 used to go here
	    elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/){

#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;


		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}	    
		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-19b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-19a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-19b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($nk_jj)/){

		while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($nk_jj)/g){
		    
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}	    
		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-20b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-20a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-20b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vbz_verb)/){

		while($precedes_rightmost_coordinator =~ /($vbz_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}		    
		
		$sentence1 = $subject.$vp1.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;


		
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-69a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-69b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-69a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-69b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbp_verb)/){
	    my $vp2 = $&.$POSTMATCH;

#	    print STDERR ">>>>>>>>>>>>>>\n";exit;


	    if($precedes_rightmost_coordinator =~ /($vbd_verb|$vb_verb|$vbp_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb|$vb_verb|$vbp_verb)/g){
		    
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		    
		    
		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-21a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-21b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-21a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-21b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vb_verb)/){
		while($precedes_rightmost_coordinator =~ /($vb_verb)/g){
		    
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		    
		    
		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-22a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-22b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-22a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-22b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}		    
	    }
	}

	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbd_verb)(\s*)($to)(\s*)($vb_verb)(($any_kind_of_possPron|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $vp2 = $&.$POSTMATCH;
	    if($follows_rightmost_coordinator =~ /check/){
#		print STDERR ">>>>>>>>>>>>>>\[$vp2\]\n$precedes_rightmost_coordinator\n";exit;
	    }

	    if($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbd_verb)(\s*)($any_kind_of_adverb)(\s*)($vbn_verb)(\s*)($to)(\s*)($vb_verb)/){
		$vp1 = $4.$5.$7.$8.$11.$12.$15.$16.$17.$18.$POSTMATCH;
		$subject = $PREMATCH.$1.$4;
		print STDERR ">>>>>>>>>>>>>>\[$vp1\]\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-23a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-23b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
#		print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-23a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-23b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($vbn_verb)(\s*)($any_kind_of_adj1)(\s*)$/){
		$vp1 = $8.$9.$12.$13.$17;
		$subject = $PREMATCH.$1.$5.$6;
		print STDERR ">>>>>>>>>>>>>>\[$vp1\]\n\[$vp2\]\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-24a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-24b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
#		print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-24a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-24b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    	  
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbd_verb)(\s*)($to)(\s*)($vb_verb)(($any_kind_of_possPron|$any_kind_of_noun|$any_kind_of_sentence_boundary|\s)*)$/){
	    $vp2 = $&.$POSTMATCH;
	    print STDERR ">>>>>>>>>>>>>>\[$vp2\]\n";

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_adverb|\s)*)($vbn_verb)(\s*)($to)(($vb_verb|$any_kind_of_adverb|\s)*)$/){
		$vp1 = $&;
		$subject = $PREMATCH;
		print STDERR ">>>>>>>>>>>>>>\[$vp1\]\n";
	    }
	    
	    
	    $sentence1 = $subject.$vp1;
	    $sentence2 = $subject.$vp2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMV1-25a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV1-25b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    open(LOGFILE, ">>./logfile_cmv1.txt");
#	    print LOGFILE "4\n";
	    close(LOGFILE);

	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CMV1-25a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CMV1-25b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbn_verb)(\s*)($any_kind_of_prep)/){
	    $vp2 = $&.$POSTMATCH;
	    print STDERR ">>>>>>>>>>>>>>\[$vp2\]\n";

	    if($precedes_rightmost_coordinator =~ /($vbz_verb)(\s*)($vbn_verb)(\s*)($to)(\s*)($vb_verb)/){

#		print STDERR ">>>>>>>>>>>>>>\n";exit;


		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;



		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-26b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-26a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-26b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb|$vbn_verb|$vb_verb|$offend_jj|$ed_jj)((.|\s)*?)($after)/){
	    my $vp2 = $1.$5.$15;
	    my $follows_coordination = $17.$POSTMATCH;
#	    print STDERR ">>>>>>>>>>>>>>\[$vp2\]\n";exit;

	    if($precedes_rightmost_coordinator =~ /($vbd_verb|$vbp_verb)/){

#		print STDERR ">>>>>>>>>>>>>>>>>>>\n";exit;
		while($precedes_rightmost_coordinator =~ /($vbd_verb|$vbp_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}		    
		$sentence1 = $subject.$vp1.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-27b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-27a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-27b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	}

	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb|$vbn_verb|$vb_verb|$offend_jj|$ed_jj)((.|\s)*?)($comma)(\s*)($quotes)/){
	    my $vp2 = $&;
	    my $follows_coordination = $POSTMATCH;
	    my $terminator = $vp2;
	    $terminator =~ s/^(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb|$vbn_verb|$vb_verb|$offend_jj|$ed_jj)((.|\s)*?)//;
	    print STDERR "2>>>>>>>>>>>>>>\[$vp2\]\n";

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)/){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		print STDERR ">>>>>>>>>>>>>>\[$vp1\]\n";


		$sentence1 = $subject.$vp1.$terminator.$follows_coordination;
		$sentence2 = $subject.$vp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-66a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-66b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-66a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-66b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbz_verb|$vbd_verb|$vbn_verb|$vb_verb|$offend_jj|$ed_jj)/){
	    my $vp2 = $&.$POSTMATCH;
	    print STDERR ">>>>>>>>>>>>>>\[$vp2\]\n";

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($to)(\s*)($vb_verb)/){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
		print STDERR ">>>>>>>>>>>>>>\[$vp1\]\n";


		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-28b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-28a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-28b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($vb_verb)/){

#		print STDERR ">>>>>>>>>>>>>>\n";exit;

		if($precedes_rightmost_coordinator =~ /($vbn_verb|$vb_verb)/){
		    while($precedes_rightmost_coordinator =~ /($vbn_verb|$vb_verb)/g){

			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
		    }		    
		}
		elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
		    }		    
		}


		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-29b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-29a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-29b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbz_verb)/){
		while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbz_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-30b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-30a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-30b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    
	    elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbd_verb)(\s*)($any_kind_of_determiner)(($of|$any_kind_of_noun|\s)*)($vbg_verb)(\s*)($any_kind_of_adj1)(\s*)$/){
		$subject = $PREMATCH.$1.$4;
		$vp1 = $4.$5.$7.$8.$10.$15.$18.$19.$23;

		print STDERR "\[$vp1\]\n";

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-31a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-31b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-31a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-31b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }

	    elsif($precedes_rightmost_coordinator =~ /($wh_word)((.|\s)*?)($vbd_verb)((.|\s)*)$/){
		while($precedes_rightmost_coordinator =~ /($wh_word)((.|\s)*?)($vbd_verb)((.|\s)*)$/g){
		    $subject = $PREMATCH.$1.$5;
		    $vp1 = $7.$9;
		}
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-61a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-61b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-61a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-61b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /($nnp_noun)(\s*)($vbd_verb)/){
#		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		while($precedes_rightmost_coordinator =~ /($nnp_noun)(\s*)($vbd_verb)/g){
#		    $subject = $PREMATCH;
#		    $vp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH.$1.$5;
		    $vp1 = $6.$POSTMATCH;
		}		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-62a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-62b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-62a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-62b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
		$vp1 = $&.$POSTMATCH;
		$subject = $PREMATCH;

		if($vp1 =~ /^($comma)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)((.|\s)*?)($comma)/){
		    $subject .= $&;
		    $vp1 =~ s/^($comma)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)((.|\s)*?)($comma)//;
		}

#		$vp1 = $&.$POSTMATCH;

		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-64a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-64b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-64a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-64b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }

	    elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\nPRE $precedes_rightmost_coordinator\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-65a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-65b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-65a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-65b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vbn_verb)/){
		while($precedes_rightmost_coordinator =~ /(($vbz_verb|\s)*)($vbn_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\nPRE $precedes_rightmost_coordinator\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-32b} ".$sentence2;
	       
		$simpler_sentences_ref = \@simpler_sentences;
		
		open(LOGFILE, ">>./logfile_cmv1.txt");
		    #	print LOGFILE "4\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-32a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-32b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }

	    elsif($precedes_rightmost_coordinator =~ /($vbd_verb|$vbp_verb)/){

#		print STDERR ">>>>>>>>>>>>>>>>>>>\n";exit;
		while($precedes_rightmost_coordinator =~ /($vbd_verb|$vbp_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}		    
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-33b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-33a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-33b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
		    
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbg_verb)(($any_kind_of_number|$of|$any_kind_of_pron|\s|$to|$vbg_verb|$any_kind_of_adj1|$any_kind_of_noun)*)/){

	    $vp2 = $&;
	    my $follows_coordination = $POSTMATCH;

#	    print STDERR ">>>>>>>>>>>>>>>>>>>\n";exit;
#

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)/){
		my $verb;
		my $v1_arg;
		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    $subject = $PREMATCH;
		    $verb = $1;
		    $v1_arg = $POSTMATCH;
		    $vp1 = $verb.$v1_arg;
#		    print STDERR "\[$v1_arg\]\n";exit;
		}
		$sentence1 = $subject.$verb.$v1_arg;
		$sentence2 = $subject.$verb.$vp2.$follows_coordination;
			
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-34b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-34a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-34b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($precedes_rightmost_coordinator =~ /($vbg_verb|$ing_nn|$vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb|$ing_nn|$vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2.$follows_coordination;
			
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-35a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-35b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-35a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-35b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbg_verb)/){

	    $vp2 = $&.$POSTMATCH;

	    print STDERR "~~~~~~~~~~~~~~~~~~~ $vp2\n";exit;


	    if($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		}
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject.$vp2;
			
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-36a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-36b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-36a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-36b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^((.|\s)*?)($vbz_verb|$vbd_verb|$vbn_verb)/){
	    my $intervening = $1;
	    my $verb = $3;
	    my $tail = $POSTMATCH;

#	    print STDERR "~~~~~~~~~~~~~~~~~~~\n";exit;

	    if($intervening =~ /^(\s*)($any_kind_of_adverb)(\s*)$/){
		$vp2 = $intervening.$verb.$tail;

#		print STDERR "4+++++++++++++++++++\n";exit;

		if($precedes_rightmost_coordinator =~ /($vbz_verb)/g){
		    while($precedes_rightmost_coordinator =~ /($vbz_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
			
			$sentence1 = $subject.$vp1;
			$sentence2 = $subject.$vp2;
			
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			@simpler_sentences[0] = "{CMV1-37a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-37b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
		#	print LOGFILE "4\n";
			close(LOGFILE);

			my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			my $ras1 = $sentence1;
			my $ras2 = $sentence2;
			$ras =~ s/<([^>]*)>//g;
			$ras1 =~ s/<([^>]+)>//g;
			$ras2 =~ s/<([^>]+)>//g;
			print RAC "CMV1-37a\t\[$ras\]\t\[$ras1\]\n";	    
			print RAC "CMV1-37b\t\[$ras\]\t\[$ras2\]\n";	    
			close(RAC);

			return($simpler_sentences_ref);
		    }    
		}
	    }
	    elsif($intervening =~ /($any_kind_of_verb)/){
		$vp2 = $intervening.$verb;
#		print STDERR "1+++++++++++++++++++ $vp2\n";exit;

		if($precedes_rightmost_coordinator =~ /($vbd_verb)/){
		    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
		    }

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;

#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-38a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-38b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-38a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-38b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);

		}
	    }
	    else{
		print STDERR "2+++++++++++++++++++\nI $intervening\n";
		$vp2 = $intervening.$verb.$tail;
		
		print STDERR "VP2 $vp2\n";

		if($precedes_rightmost_coordinator =~ /((.|\s)*?)($vbd_verb)/){
		    my $subject = $1;
		    $vp1 = $3.$POSTMATCH;
		    print STDERR "6+++++++++++++++++++\nINTERVENING $intervening\n";
		    if($intervening =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
			my $possible_adverbial = $PREMATCH.$&;
#			my $possible_subject = $POSTMATCH;

			print STDERR "7+++++++++++++++++++SUBJ $subject\nPA $possible_adverbial\n";
			unless($possible_adverbial =~ /($any_kind_of_verb)/){
			    my $adverbial = $possible_adverbial;

			    print STDERR "ADV $adverbial\n";

#			    if($possible_subject =~ /(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
#				$subject = $&;
#				$vp1 = $POSTMATCH;

			    $sentence1 = $subject.$vp1;
			    $sentence2 = $subject.$vp2;
#			    print STDERR "8+++++++++++++++++++ $vp1\nS1 $sentence1\nS2 $sentence2\n";exit;
			    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
				$final_punctuation = "";
			    }
			    @simpler_sentences[0] = "{CMV1-60a} ".$sentence1.$final_punctuation;
			    @simpler_sentences[1] = "{CMV1-60b} ".$sentence2;
			    
			    $simpler_sentences_ref = \@simpler_sentences;
			    
			    open(LOGFILE, ">>./logfile_cmv1.txt");
#			    print LOGFILE "5\n";
			    close(LOGFILE);

			    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			    my $ras1 = $sentence1;
			    my $ras2 = $sentence2;
			    $ras =~ s/<([^>]*)>//g;
			    $ras1 =~ s/<([^>]+)>//g;
			    $ras2 =~ s/<([^>]+)>//g;
			    print RAC "CMV1-60a\t\[$ras\]\t\[$ras1\]\n";	    
			    print RAC "CMV1-60b\t\[$ras\]\t\[$ras2\]\n";	    
			    close(RAC);
			    
			    return($simpler_sentences_ref);
#			    }
			}
		    }


		    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
			    
			$sentence1 = $subject.$vp1;
			$sentence2 = $subject.$vp2;
			
#			    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			@simpler_sentences[0] = "{CMV1-39a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-39b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "5\n";
			close(LOGFILE);

			my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			my $ras1 = $sentence1;
			my $ras2 = $sentence2;
			$ras =~ s/<([^>]*)>//g;
			$ras1 =~ s/<([^>]+)>//g;
			$ras2 =~ s/<([^>]+)>//g;
			print RAC "CMV1-39a\t\[$ras\]\t\[$ras1\]\n";	    
			print RAC "CMV1-39b\t\[$ras\]\t\[$ras2\]\n";	    
			close(RAC);
			return($simpler_sentences_ref);
		    }    
		}
		
		
	    
		if($precedes_rightmost_coordinator =~ /($vbd_verb|$vbn_verb)/){
		    print STDERR "1>>>>> >>>>>>> >>>>>$precedes_rightmost_coordinator\t$potential_coordinator\n";
		    while($precedes_rightmost_coordinator =~ /($vbd_verb|$vbn_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;
			
			
			$sentence1 = $subject.$vp1;
			$sentence2 = $subject.$vp2;
			
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			@simpler_sentences[0] = "{CMV1-40a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-40b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			my $ras1 = $sentence1;
			my $ras2 = $sentence2;
			$ras =~ s/<([^>]*)>//g;
			$ras1 =~ s/<([^>]+)>//g;
			$ras2 =~ s/<([^>]+)>//g;
			print RAC "CMV1-40a\t\[$ras\]\t\[$ras1\]\n";	    
			print RAC "CMV1-40b\t\[$ras\]\t\[$ras2\]\n";	    
			close(RAC);
			
			return($simpler_sentences_ref);
		    }
		}

	    }
	    
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)/){
	    $vp2 = $&.$POSTMATCH;

	    if($precedes_rightmost_coordinator =~ /($vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-41a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-41b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "6\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-41a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-41b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);
		    
		    return($simpler_sentences_ref);
		}
		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_verb)/){
#	    $vp2 = $&.$POSTMATCH;
	    my $verb = $&;
	    $vp2 = $verb.$POSTMATCH;


	    if($precedes_rightmost_coordinator =~ /($any_kind_of_modal)/){
		while($precedes_rightmost_coordinator =~ /($any_kind_of_modal)/g){
		    $subject = $PREMATCH.$&;
		    $vp1 = $POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-42a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-42b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "6\n";
		    close(LOGFILE);
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-42a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-42b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_modal|$any_kind_of_verb|\s)*)($vbn_verb)/){
	    $vp2 = $&.$POSTMATCH;

#	    print STDERR ">>>>>>>>>>>>>>>>> $vp2\n";exit;

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-43a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-43b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-43a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-43b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^((\s|$any_kind_of_adverb)*)($vbg_verb)/){
#	    $vp2 = $&.$POSTMATCH;
	    my $verb = $5;
	    $vp2 = $verb.$POSTMATCH;

#	    print STDERR ">>>>>>>>>>>>>>>>> $verb\n";exit;

	    if($precedes_rightmost_coordinator =~ /($vbg_verb)/){
		while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-44a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-44b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "6\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-44a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-44b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)<w c\=\"w\" p\=\"JJ\">([^<]*?)ed<\/w>/){
	    $vp2 = $&.$POSTMATCH;

#	    print STDERR "~~~~~~~~~~~~~~~~\n";

	    if($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-45a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-45b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "7\n";
		    close(LOGFILE);
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-45a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-45b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}    		
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^((.|\s)*?)($vbd_verb)/){
	    my $intervening = $1;
	    my $verb = $3;
	    my $tail = $POSTMATCH;
	    unless($intervening =~ /($any_kind_of_adverb|$any_kind_of_verb)/){
		$vp2 = $&.$POSTMATCH;

#		print STDERR "~~~~~~~~~~~~~~~~\n";

		if($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
			$subject = $PREMATCH;
			$vp1 = $&.$POSTMATCH;

			$sentence1 = $subject.$vp1;
			$sentence2 = $subject.$vp2;
		
#			print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			@simpler_sentences[0] = "{CMV1-46a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-46b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "8\n";
			close(LOGFILE);

			my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			my $ras1 = $sentence1;
			my $ras2 = $sentence2;
			$ras =~ s/<([^>]*)>//g;
			$ras1 =~ s/<([^>]+)>//g;
			$ras2 =~ s/<([^>]+)>//g;
			print RAC "CMV1-46a\t\[$ras\]\t\[$ras1\]\n";	    
			print RAC "CMV1-46b\t\[$ras\]\t\[$ras2\]\n";	    
			close(RAC);

			return($simpler_sentences_ref);
		    }    
		}
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_noun)/){
#	    print STDERR ">>>>>>>>>>>>>>>>>\n";exit;

	    my $vp2 = $&.$POSTMATCH;


	    if($precedes_rightmost_coordinator =~ /($vb_verb)/){
		while($precedes_rightmost_coordinator =~ /($vb_verb)/g){
		    $subject = $PREMATCH;
		    $vp1 = $&.$POSTMATCH;
		    
		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-47a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-47b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-47a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-47b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb|$vbg_verb)/){

	    while($precedes_rightmost_coordinator =~ /($vbd_verb|$vbg_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
		my $this_verb = $1;
		my $this_verb_query = $vbd_verb;
		if($this_verb =~ /p\=\"VBG\"/){
		    $this_verb_query = $vbg_verb;
		}

		if($follows_rightmost_coordinator =~ /^((.|\s)*?)($this_verb_query)/){
		    my $intervening = $1;
		    my $verb = $3;
		    my $tail = $POSTMATCH;

#		    print STDERR ">>>>>>>>>>>>> $intervening\n";exit;

		    unless($intervening =~ /($any_kind_of_verb|$any_kind_of_adverb)/){
			$vp2 = $verb.$tail;

			$sentence1 = $subject.$vp1;
			$sentence2 = $subject.$vp2;

#			print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			@simpler_sentences[0] = "{CMV1-48a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-48b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "9\n";
			close(LOGFILE);

			my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
			my $ras1 = $sentence1;
			my $ras2 = $sentence2;
			$ras =~ s/<([^>]*)>//g;
			$ras1 =~ s/<([^>]+)>//g;
			$ras2 =~ s/<([^>]+)>//g;
			print RAC "CMV1-48a\t\[$ras\]\t\[$ras1\]\n";	    
			print RAC "CMV1-48b\t\[$ras\]\t\[$ras2\]\n";	    
			close(RAC);

			return($simpler_sentences_ref);
		    }
		}
	    }
	}
# HERE
	elsif($precedes_rightmost_coordinator =~ /($vbg_verb)/){
	    while($precedes_rightmost_coordinator =~ /($vbg_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }
	    if($follows_rightmost_coordinator =~ /((.|\s)*?)($vbg_verb)/){
		my $intervening = $1;
		my $verb = $3;
		my $tail = $POSTMATCH;
		unless($intervening =~ /($any_kind_of_verb|$any_kind_of_adverb/){
		    $vp2 = $verb.$tail;

		    $sentence1 = $subject.$vp1;
		    $sentence2 = $subject.$vp2;
		    
		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-49a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-49b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		   
		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-49a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-49b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
	    }
	}

    }

 # # # # # # # # # # # # # # # # # # semicolon # # # # #  # # # # # # # # # # #
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;<\/PC>/i){

#	my $return_pc = "<w c\=\"cm\" p\=\"\;\">\;<\/w>";
#	unless($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj|$offend_jj|$any_kind_of_modal)/){
#	    print STDERR "1 NO VERBAL MATERIAL TO THE LEFT OF CMV1. RETURNING SENTENCE WITH ONE LESS PC\n";
#	    my $return_sentence = $precedes_rightmost_coordinator.$return_pc.$follows_rightmost_coordinator;
#	    
#	    @simpler_sentences[0] = "{CMV1-X2} ".$return_sentence;	
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}

	my $subject_containing_part;
	my $object_containing_part;
	my $prior_to_this_instance;
	my $adverbial_phrase;


	print STDERR "\tPROCESSING semicolon-CMV1\t$sentence\n";


	$subject_containing_part = $precedes_rightmost_coordinator;
	$object_containing_part = $follows_rightmost_coordinator;
	$prior_to_this_instance = $precedes_rightmost_coordinator;

	
	if($subject_containing_part =~ /<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>/){
	    $subject = $PREMATCH;
	    $vp1 = $&.$POSTMATCH;
	    $sentence1 = $subject.$vp1;
	    $sentence2 = $subject.$object_containing_part;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMV1-50a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV1-50b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;

	    open(LOGFILE, ">>./logfile_cmv1.txt");
#	    print LOGFILE "10\n";
	    close(LOGFILE);

	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CMV1-50a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CMV1-50b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    


# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

    }

 # # # # # # # # # # # # # # # # # # comma # # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,<\/PC>/i){

#	my $retrn_pc = "<w c\=\"cm\" p\=\"\,\">\,<\/w>";
#	unless($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj|$offend_jj|$any_kind_of_modal)/){
#	    print STDERR "1 NO VERBAL MATERIAL TO THE LEFT OF CMV1. RETURNING SENTENCE WITH ONE LESS PC\n";
#	    my $return_sentence = $precedes_rightmost_coordinator.$return_pc.$follows_rightmost_coordinator;

#	    @simpler_sentences[0] = "{CMV1-X4} ".$return_sentence;	
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}



	if($precedes_rightmost_coordinator =~ /($vbg_verb)(\s*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $vp1 = $&.$POSTMATCH;

	   
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($vbg_verb)/){
		$vp2 = $&.$POSTMATCH;

		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject." ".$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-51a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-51b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-51a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-51b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
# "clamped_JJ listening devices on his car CONJ ..."
	elsif($precedes_rightmost_coordinator =~ /($ed_jj|$vbn_verb|$vbd_verb)(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_possPron|\s)*)/){
	    while($precedes_rightmost_coordinator =~ /($ed_jj|$vbd_verb|$vbn_verb\s+$any_kind_of_rp)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }


#	    print STDERR ">>>>>>>>>>>>>>>>> $vp1\n";exit;

	    
	    if($follows_rightmost_coordinator =~ /^(($comma|$any_kind_of_verb|$any_kind_of_adverb|$any_kind_of_adj1|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($vbd_verb|$vbn_verb\s*$any_kind_of_rp|$vbn_verb|$ed_jj)/){
		$vp2 = $&.$POSTMATCH;

		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject." ".$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-52b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-52a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-52b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbg_verb)/){
	    while($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($vbg_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }

#	    print STDERR ">>>>>>>>>>>>>>>>> $vp1\n";exit;

	    if($follows_rightmost_coordinator =~ /^(($comma|$any_kind_of_verb|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		$vp2 = $&.$POSTMATCH;

		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject." ".$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-53b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-53a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-53b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)/){
	    while($precedes_rightmost_coordinator =~ /(($any_kind_of_verb|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }

#	    print STDERR ">>>>>>>>>>>>>>>>> $vp1\n";exit;

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_verb|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/){
		$vp2 = $&.$POSTMATCH;

		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject." ".$vp2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-54a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-54b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-54a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-54b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_verb|\s)*)<w c\=\"w\" p\=\"JJ\">([^\s]*?)ed<\/w>/){
		$vp2 = $&.$POSTMATCH;
		
		$sentence1 = $subject." ".$vp1;
		$sentence2 = $subject." ".$vp2;
		
		print STDERR "+++++++++++++++\n";
		
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-55a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-55b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		open(LOGFILE, ">>./logfile_cmv1.txt");
#		print LOGFILE "12\n";
		close(LOGFILE);

		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CMV1-55a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CMV1-55b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^((.|\s)*?)($vbd_verb)/){
		my $intervening = $1;
		my $verb = $3;
		my $tail = $POSTMATCH;
		
		unless($intervening =~ /($any_kind_of_verb|$any_kind_of_adverb)/){
		    $vp2 = $verb.$intervening.$tail;
		    
		    $sentence1 = $subject." ".$vp1;
		    $sentence2 = $subject." ".$vp2;
		    
		    print STDERR "+++++++++++++++\n";
		    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    @simpler_sentences[0] = "{CMV1-56a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-56b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "13\n";
		    close(LOGFILE);

		    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		    my $ras1 = $sentence1;
		    my $ras2 = $sentence2;
		    $ras =~ s/<([^>]*)>//g;
		    $ras1 =~ s/<([^>]+)>//g;
		    $ras2 =~ s/<([^>]+)>//g;
		    print RAC "CMV1-56a\t\[$ras\]\t\[$ras1\]\n";	    
		    print RAC "CMV1-56b\t\[$ras\]\t\[$ras2\]\n";	    
		    close(RAC);

		    return($simpler_sentences_ref);
		}
	    }
	    
	}

	print STDERR ">>>>>>>> $precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n";

    }


    open(LOGFILE, ">>./logfile_cmv1.txt");
#    print LOGFILE "14\n";
    close(LOGFILE);

####################### HERE ARE THE ERROR CASES THAT SHOULD BE SOLVED "LATER"


    open(ERROR_FILE, ">>./CMV1_errors.txt");
    print ERROR_FILE "$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";
    close(ERROR_FILE);
    
    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "CCV NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;

    my $replacement_pc = $potential_coordinator;
    $replacement_pc =~ s/<([^>]+)>//g;
    $replacement_pc =~ s/\,/<w c\=\"cm\" p\=\"\,\">\,<\/w>/;
    $replacement_pc =~ s/which/<w c\=\"w\" p\=\"WDT\">which<\/w>/;
    $replacement_pc =~ s/what/<w c\=\"w\" p\=\"WP\">what<\/w>/;
    $replacement_pc =~ s/when/<w c\=\"w\" p\=\"WRB\">when<\/w>/;
    $replacement_pc =~ s/where/<w c\=\"w\" p\=\"WRB\">where<\/w>/;
    $replacement_pc =~ s/while/<w c\=\"w\" p\=\"IN\">while<\/w>/;
    $replacement_pc =~ s/who/<w c\=\"w\" p\=\"WP\">who<\/w>/;
    $replacement_pc =~ s/and/<w c\=\"w\" p\=\"CC\">and<\/w>/;
    $replacement_pc =~ s/but/<w c\=\"w\" p\=\"CC\">but<\/w>/;
    $replacement_pc =~ s/or/<w c\=\"w\" p\=\"CC\">or<\/w>/;
    
    $sentence1 = $precedes_rightmost_coordinator.$replacement_pc.$follows_rightmost_coordinator;
    

    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = "";
    }
	    
    @simpler_sentences[0] = "{CMV1-57a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    
    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
    my $ras1 = $sentence1;
    $ras =~ s/<([^>]*)>//g;
    $ras1 =~ s/<([^>]+)>//g;
    print RAC "CMV1-57a\t\[$ras\]\t\[$ras1\]\n";	    
    close(RAC);
    
    return($simpler_sentences_ref);


    if($precedes_rightmost_coordinator =~ /CLASS\=\"UNKNOWN\"/ && $follows_rightmost_coordinator =~ /CLASS\=\"UNKNOWN\"/){
	my $substitute_pc = $potential_coordinator;
	$substitute_pc =~ s/<PC([^>]+)>//;
	$substitute_pc =~ s/<\/PC>//;

	$sentence1 = $precedes_rightmost_coordinator.$substitute_pc.$follows_rightmost_coordinator;

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-58a} ".$sentence1.$final_punctuation;
	
	$simpler_sentences_ref = \@simpler_sentences;
       
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CMV1-58\t\[$ras\]\t\[$ras1\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }

    else{
	my $substitute_pc = $potential_coordinator;
	$substitute_pc =~ s/<PC([^>]+)>//;
	$substitute_pc =~ s/<\/PC>//;

	$sentence1 = $precedes_rightmost_coordinator.$substitute_pc.$follows_rightmost_coordinator;

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-59a} ".$sentence1;
	
	$simpler_sentences_ref = \@simpler_sentences;
       
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CMV1-59a\t\[$ras\]\t\[$ras1\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);

	print STDERR "CMV1 NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
    }
}
1;
