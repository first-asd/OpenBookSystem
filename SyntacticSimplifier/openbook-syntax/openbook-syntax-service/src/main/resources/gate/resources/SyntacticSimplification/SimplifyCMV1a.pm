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
package SimplifyCMV1a;
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
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $sentence1;
    my $sentence2;
    my $vp1;
    my $vp2;
    my $subject;

    print STDERR "\t[CMV1]\n";

    my $print_precedes_rightmost_coordinator = $precedes_rightmost_coordinator;
    my $print_follows_rightmost_coordinator = $follows_rightmost_coordinator;

    $print_follows_rightmost_coordinator =~ s/<([^>]+)>//g;
    $print_precedes_rightmost_coordinator =~ s/<([^>]+)>//g;

    open(LOGFILE, ">./logfile_cmv1.txt");
    print LOGFILE "\[$print_precedes_rightmost_coordinator\]\t\[$potential_coordinator\]\t\[$print_follows_rightmost_coordinator\]\t";
    close(LOGFILE);

#    print STDERR "$print_precedes_rightmost_coordinator\t$potential_coordinator\t$print_follows_rightmost_coordinator\n";exit;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }





################################### CMV1 #######################################
# # # # # # # # # # # # # # # semicolon-conjunction # # # # # # # # # # # # # #
    if($potential_coordinator =~ /\;(\s+)(and|but|or)/){

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMV1-1a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMV1-1b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;


	open(LOGFILE, ">>./logfile_cmv1.txt");
#	print LOGFILE "1\n";
	close(LOGFILE);
	return($simpler_sentences_ref);
    }
    

 # # # # # # # # ## # # # # comma-conjunction # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ /\,\s+(and|but)/i){
#	print STDERR "PROCESSING and-CMV1\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator"; exit;


	if($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($vbd_verb)/){
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
		    return($simpler_sentences_ref);
		}
	    }
	}
###########################
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/){
	    while($precedes_rightmost_coordinator =~ /($vbd_verb)/){
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

		    @simpler_sentences[0] = "{CMV1-10a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-10b} ".$sentence2;
	
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "3\n";
		    close(LOGFILE);
		    return($simpler_sentences_ref);
		}
	    }
	}

	
	

    }
    

 # # # # # # # # # # # # # # ## # conjunction # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />(and|but|or)</i){
	print STDERR "PROCESSING and-CMV1\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n";

	$sentence1 = $precedes_rightmost_coordinator."<w c\=\"w\" p\=\"CC\">$1<\/w> ".$follows_rightmost_coordinator;
	@simpler_sentences[0] = "{CHEAT-7a} ".$sentence1.$final_punctuation;
	
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);



	if($follows_rightmost_coordinator =~ /^((.|\s)*?)($vbz_verb|$vbd_verb|$vbn_verb)/){
	    my $intervening = $1;
	    my $verb = $3;
	    my $tail = $POSTMATCH;

	    print STDERR "3+++++++++++++++++++\n";

	    if($intervening =~ /^(\s*)($any_kind_of_adverb)(\s*)$/){
		$vp2 = $intervening.$verb.$tail;

		print STDERR "4+++++++++++++++++++\n";

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
			@simpler_sentences[0] = "{CMV1-7a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-7b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
		#	print LOGFILE "4\n";
			close(LOGFILE);
			return($simpler_sentences_ref);
		    }    
		}
	    }
	    elsif($intervening =~ /($any_kind_of_verb)/){
		print STDERR "1+++++++++++++++++++\n";
	    }
	    else{
		print STDERR "2+++++++++++++++++++\nI $intervening\n";
		$vp2 = $intervening.$verb.$tail;
		
		if($precedes_rightmost_coordinator =~ /((.|\s)*?)($vbd_verb)/g){
		    print STDERR "6+++++++++++++++++++\n";
		    if($intervening =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESMAdvP\">([^<]+)<\/PC>/){
			my $possible_adverbial = $PREMATCH.$&;
			my $possible_subject = $POSTMATCH;
			print STDERR "7+++++++++++++++++++\n";exit;
			unless($possible_adverbial =~ /($any_kind_of_verb)/){
			    my $adverbial = $possible_adverbial;
			    if($possible_subject =~ /(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
				$subject = $&;
				$vp1 = $POSTMATCH;
				print STDERR "8+++++++++++++++++++\n";exit;
			    }
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
			@simpler_sentences[0] = "{CMV1-9a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-9b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "5\n";
			close(LOGFILE);
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
			@simpler_sentences[0] = "{CMV1-7a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-7b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;
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
		    @simpler_sentences[0] = "{CMV1-8a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-8b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "6\n";
		    close(LOGFILE);
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
		    @simpler_sentences[0] = "{CMV1-7a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-7b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "7\n";
		    close(LOGFILE);
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
			@simpler_sentences[0] = "{CMV1-9a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-9b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "8\n";
			close(LOGFILE);
			return($simpler_sentences_ref);
		    }    
		}
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)/){
	    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;

		if($follows_rightmost_coordinator =~ /((.|\s)*?)($vbd_verb)/){
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
			@simpler_sentences[0] = "{CMV1-9a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{CMV1-9b} ".$sentence2;
			
			$simpler_sentences_ref = \@simpler_sentences;

			open(LOGFILE, ">>./logfile_cmv1.txt");
#			print LOGFILE "9\n";
			close(LOGFILE);
			return($simpler_sentences_ref);
		    }
		}
	    }
	}
    }

 # # # # # # # # # # # # # # # # # # semicolon # # # # #  # # # # # # # # # # #
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\;<\/PC>/i){
	my $subject_containing_part;
	my $object_containing_part;
	my $prior_to_this_instance;
	my $adverbial_phrase;

	$sentence1 = $precedes_rightmost_coordinator."<w c\=\"cm\" p\=\"\;\">\;<\/w> ".$follows_rightmost_coordinator;
	@simpler_sentences[0] = "{CHEAT-4a} ".$sentence1.$final_punctuation;
	
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);


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
	    @simpler_sentences[0] = "{CMV1-4a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMV1-4b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;

	    open(LOGFILE, ">>./logfile_cmv1.txt");
#	    print LOGFILE "10\n";
	    close(LOGFILE);
	    return($simpler_sentences_ref);
	}
    


# Idea here is to process "and" CMV1 by first identifying the left-most CMV1
# conjunction in the sentence and the subject of the verb that appears to the
# left of that left-most CMV1. This subject will be shared by the two VPs
# linked by the current CMV1

    }

 # # # # # # # # # # # # # # # # # # comma # # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMV1\">\,<\/PC>/i){
	$sentence1 = $precedes_rightmost_coordinator."<w c\=\"cm\" p\=\"\,\">\,<\/w> ".$follows_rightmost_coordinator;
	@simpler_sentences[0] = "{CHEAT-5a} ".$sentence1.$final_punctuation;
	
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);


	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb)/){
	    while($precedes_rightmost_coordinator =~ /(($any_kind_of_verb|$any_kind_of_adverb|\s)*)($any_kind_of_verb)/g){
		$subject = $PREMATCH;
		$vp1 = $&.$POSTMATCH;
	    }


	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_verb|\s)*)($any_kind_of_verb)/){
		$vp2 = $&.$POSTMATCH;

		
		$sentence1 = $subject.$vp1;
		$sentence2 = $subject." ".$vp2;
		
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;	
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMV1-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		open(LOGFILE, ">>./logfile_cmv1.txt");
#		print LOGFILE "11 \[$sentence1\]\t\[$sentence2\]\n";
		close(LOGFILE);
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
		@simpler_sentences[0] = "{CMV1-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMV1-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;

		open(LOGFILE, ">>./logfile_cmv1.txt");
#		print LOGFILE "12\n";
		close(LOGFILE);
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
		    @simpler_sentences[0] = "{CMV1-11a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMV1-11b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;

		    open(LOGFILE, ">>./logfile_cmv1.txt");
#		    print LOGFILE "13\n";
		    close(LOGFILE);
		    return($simpler_sentences_ref);
		}
	    }
	    
	}

	print STDERR ">>>>>>>> $precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n";

    }


    open(LOGFILE, ">>./logfile_cmv1.txt");
#    print LOGFILE "14\n";
    close(LOGFILE);
    print STDERR "CMV1 NO RULE MATCHED\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n"; exit;
}
1;
