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
package SimplifyCMP;
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
my $by = "<w c\=\"w\" p\=\"IN\">by<\/w>";
my $as = "<w c\=\"w\" p\=\"IN\">as<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $hyphen = "<w c\=\"(hyph|sym)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"s\" p\=\"(POS|\'\')\">\'<\/w>";
my $because = "<w c\=\"w\" p\=\"IN\">because<\/w>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $sentence1;
    my $sentence2;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }



################################### CMP #######################################
###### punctuation-conjunction
    if($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(\,)(\s+)(and|but|or)<\/PC>/){
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;

	if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)(($any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_pron|$any_kind_of_prep|\s)*)/){
	    $pp2 = $&;
	    $follows_coordination = $POSTMATCH;	    


	    
	    if($precedes_rightmost_coordinator =~ /(\s*)($any_kind_of_prep)/){
		while($precedes_rightmost_coordinator =~ /(\s*)($any_kind_of_prep)/g){
		    $pp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		    
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMP-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)/){
	    $pp2 = $&.$POSTMATCH;
	    my $this_preposition = $&;
	    
	    print STDERR "FFFFFFFFFFFF\n";
	    
	    if($precedes_rightmost_coordinator =~ /(\s*)\Q$this_preposition\E/){
		while($precedes_rightmost_coordinator =~ /(\s*)\Q$this_preposition\E/g){
		    $pp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		    
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(\s*)($to)/){
	    $pp2 = $&.$POSTMATCH;
	    my $this_preposition = $&;
	    
	    print STDERR "FFFFFFFFFFFF\n";
	    
	    if($precedes_rightmost_coordinator =~ /(\s*)($to)/){
		while($precedes_rightmost_coordinator =~ /(\s*)($to)/g){
		    $pp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		    
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMP-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_prep)((.|\s)*?)($comma)/){
	    $pp2 = $&;
	    $follows_coordination = $POSTMATCH;
	    my $this_preposition = $&;
	    
	    
	    if($precedes_rightmost_coordinator =~ /(\s*)($any_kind_of_prep)/){
		while($precedes_rightmost_coordinator =~ /(\s*)($any_kind_of_prep)/g){
		    $pp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}
		    
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMP-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }

###################### Conjunctions #################################

    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;



	if($precedes_rightmost_coordinator =~ /($to)((\s|$any_kind_of_determiner|$any_kind_of_adj1)*)($any_kind_of_word)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR ">>>>>>>>>>>>>>>>>\n";exit;
#	    print STDERR "FFFFFFFFFFFF\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adverb)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		    $sentence1 = $subject.$pp1.$follows_coordination;
		    $sentence2 = $subject.$pp2.$follows_coordination;

#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		    @simpler_sentences[0] = "{CMP-5a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-5b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($as)((\s|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_prep)*)($any_kind_of_noun)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR "FFFFFFFFFFFF\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_adverb|\s)*)($as)(($any_kind_of_noun|$any_kind_of_prep)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}


		@simpler_sentences[0] = "{CMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($to)((\s|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_prep|$any_kind_of_noun)*)($any_kind_of_noun)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR "FFFFFFFFFFFF\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($to)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_subordinator|\s)*)(($any_kind_of_word|\s)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;

		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }


		@simpler_sentences[0] = "{CMP-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($because)(($any_kind_of_word|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR "FFFFFFFFFFFF\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($because)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}


		@simpler_sentences[0] = "{CMP-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun)*?)($any_kind_of_noun)(\s*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;

       	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_noun|$any_kind_of_adj1)*?)($subordinating_that)((.|\s)*?)($any_kind_of_sentence_boundary)/){ # ((^$subordinating_that)*?)($any_kind_of_sentence_boundary)/){
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
		    
		    
		    @simpler_sentences[0] = "{CMP-9a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-9b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }	    
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adverb|\s)*)($any_kind_of_prep)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun)*?)($any_kind_of_noun)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

#		print STDERR ">>>>>>>>>>>>>>>";exit;

		my $follows_that = $16;

		if($follows_that =~ /($any_kind_of_subordinator)/){
		}
		else{
		    print STDERR "PPPPPPPPPPP $follows_that\n";
		    
		    print STDERR "FFFFFFFFFFFF $pp1\n2GGGGGGGGGGG$pp2\n";
		    
		    $sentence1 = $subject.$pp1.$follows_coordination;
		    $sentence2 = $subject.$pp2.$follows_coordination;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    
		    @simpler_sentences[0] = "{CMP-10a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-10b} ".$sentence2;
		    
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
		
		
		@simpler_sentences[0] = "{CMP-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($any_kind_of_prep)((\s|$any_kind_of_determiner|$vbg_verb|$any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun)*?)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;


       	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_prep|$to)((\s|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_noun|$any_kind_of_adj1)*?)/){ # ((^$subordinating_that)*?)($any_kind_of_sentence_boundary)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;



		my $follows_that = $16;

		if($follows_that =~ /($any_kind_of_subordinator)/){
		}
		else{
		    print STDERR "PPPPPPPPPPP $follows_that\n";
		    
		    print STDERR "FFFFFFFFFFFF $pp1\n2GGGGGGGGGGG$pp2\n";
		    
		    $sentence1 = $subject.$pp1;
		    $sentence2 = $subject.$pp2.$follows_coordination;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    
		    @simpler_sentences[0] = "{CMP-12a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{CMP-12b} ".$sentence2;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }	    
	}

	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|\s)*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(($hyphen|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    my $this_preposition = $5;

#	    print STDERR ">>>>>>>>>>>>>>>>> $pp1\n$follows_rightmost_coordinator\n\[$this_preposition\]\n";exit;	    

       	    if($follows_rightmost_coordinator =~ /^((.|\s)*?)\Q$this_preposition\E/){ # ((^$subordinating_that)*?)($any_kind_of_sentence_boundary)/){
# NPs can be so complex that there is no easily defineable limit on the
# material that may serves as the argument of a preposition can be (e.g. "CMP,
# most alarmingly, PREP the prison service entrusted with locking him up when
# he was caught for other crimes")
		$pp2 = $&.$POSTMATCH;
#		$follows_coordination = $POSTMATCH;

		my $follows_that = $16;

   
		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMP-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-13b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }	    
	}

    }
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(\,|\;)(\s+)(and|but|or)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;


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
		

		@simpler_sentences[0] = "{CMP-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-14b} ".$sentence2;
		
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
		

		@simpler_sentences[0] = "{CMP-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-15b} ".$sentence2;
		
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
		

		@simpler_sentences[0] = "{CMP-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-16b} ".$sentence2;
		
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
		

		@simpler_sentences[0] = "{CMP-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-17b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
############# punctuation
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMP\">(\,|\;)<\/PC>/){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $pp1;
	my $pp2;


	if($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(($to|$any_kind_of_possPron|$any_kind_of_noun|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	    
#	    print STDERR ">>>>>>>>>>>>>>\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(($to|$any_kind_of_possPron|$any_kind_of_noun|\s)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		@simpler_sentences[0] = "{CMP-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-18b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $pp1 = $&;
	    $subject = $PREMATCH;
	    	

    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)/){
		$pp2 = $&;
		$follows_coordination = $POSTMATCH;

		
		$sentence1 = $subject.$pp1.$follows_coordination;
		$sentence2 = $subject.$pp2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		@simpler_sentences[0] = "{CMP-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-19b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)/){
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)/){
		$pp2 = $&.$POSTMATCH;

		my $this_preposition = $2;

		while($precedes_rightmost_coordinator =~ /($this_preposition)/g){
		    $pp1 = $&.$POSTMATCH;
		    $subject = $PREMATCH;
		}

		$sentence1 = $subject.$pp1;
		$sentence2 = $subject.$pp2;
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		@simpler_sentences[0] = "{CMP-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMP-20b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    while($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)/g){
		$pp1 = $&.$POSTMATCH;
		$subject = $PREMATCH;
	    }


	    	    


#	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)(($to|$any_kind_of_possPron|$any_kind_of_noun|\s)*)/){
#		$pp2 = $&;
#		$follows_coordination = $POSTMATCH;
		
#		$sentence1 = $subject.$pp1.$follows_coordination;
#		$sentence2 = $subject.$pp2.$follows_coordination;
		
		
#		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
#		    $final_punctuation = "";
#		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
#
#		@simpler_sentences[0] = "{CMP-7a} ".$sentence1.$final_punctuation#;
#		@simpler_sentences[1] = "{CMP-7b} ".$sentence2;
#		
#		$simpler_sentences_ref = \@simpler_sentences;
#		return($simpler_sentences_ref);
#	    }

	}
    }

    open(ERROR_FILE, ">>./CMP_errors.txt");
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
	    
    @simpler_sentences[0] = "{CMP-21a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);

    print STDERR "CMP NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
