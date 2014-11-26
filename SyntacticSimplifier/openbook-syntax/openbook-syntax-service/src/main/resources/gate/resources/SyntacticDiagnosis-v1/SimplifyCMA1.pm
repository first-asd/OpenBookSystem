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
package SimplifyCMA1;
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
my $apostrophe = "<w c\=\"aposs\" p\=\"POS\">\'s<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|$apostrophe|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $hyphen = "<w c\=\"hyph\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"s\" p\=\"(POS|\'\')\">\'<\/w>";


sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

    print STDERR "\[CMA1\]\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

################################### CMA1 #######################################
###### Conjunctions
    if($potential_coordinator =~ />(and|but|or)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;

	if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
	    print STDERR "DDDDDDDDDDDDDDDDDd\n";

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_noun)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-1b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    $subject =~ s/<w ([^>]+)>both<\/w>\s*$//;
	    print STDERR ">>>>>>>AAAAAAAAAAAa\nSUBJ $subject\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/){
		my $adjp2 = $1.$2.$6.$7.$11;
		my $follows_coordination = $12.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH \[$adjp2\] JJJJJJJ $follows_coordination\n";exit;
		
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
	}
	elsif($precedes_rightmost_coordinator =~ /($vbn_verb)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    

	    print STDERR "DDDDDDDDDDDDDDDDDd\n";

	    if($follows_rightmost_coordinator =~ /^(\s+)($vbn_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)($comma)/){
		my $adjp2 = $&;
		$adjp2 =~ s/($comma)$//;
		my $rcb = $&;
		my $follows_coordination = $rcb.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-3b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
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
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($vbg_verb)(\s*)($base_np)/){
		my $adjp2 = $&;
		my $follows_coordination = $8.$POSTMATCH;
		
		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
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
	    elsif($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_word|$any_kind_of_possessive|\s)*?)($any_right_subordination_boundary)/){
		my $adjp2 = $1.$2;
		my $follows_coordination = $8.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
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
	elsif($precedes_rightmost_coordinator =~ /(($quotes|$any_kind_of_adverb|$comma|\s)*)($any_kind_of_adj1)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    $subject =~ s/<w ([^>]+)>both<\/w>\s*$//;
	    print STDERR ">>>>>>>AAAAAAAAAAAa\nSUBJ $subject\n";
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$comma|$any_kind_of_adj1|$any_kind_of_pc|\s)*)($any_kind_of_adj1)($quotes)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-6b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-7b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(\s*)($of)(\s*)($any_kind_of_noun)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-8b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-9b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_prep)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)$/){
	    $adjp1 = $3.$4.$6.$7.$8.$9.$13;
	    $subject = $PREMATCH.$1.$3;
	    
#	    print STDERR "AAAAAAAAAAA\[$adjp1\]\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(\s*)($to)(\s*)($vb_verb)(($any_kind_of_sentence_boundary|\s)*)$/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-10b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s+)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
	    $adjp1 = $5.$7.$8.$12;
	    $subject = $PREMATCH;
	    
#	    print STDERR "AAAAAAAAAAAa \[$adjp1\]\n";exit;
	    

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(\s+)($of)(\s+)($any_kind_of_pron)((.|\s)*?)($any_kind_of_sentence_boundary)((.|\s)*)$/){
		my $adjp2 = $1.$2.$6.$7.$8.$9.$12;
		my $follows_coordination = $13.$16.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH \[$adjp2\] JJJJJJJ $follows_coordination\n";exit;
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-11b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($quotes)*)($any_kind_of_adj1|$any_kind_of_noun)((\s|$quotes)*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
#	    print STDERR "AAAAAAAAAAAa\n";exit;
	    

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-31a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-31b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adverb)(\s+)($any_kind_of_adj1|$any_kind_of_prep)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(($of|$any_kind_of_noun|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;

		$subject =~ s/<w ([^>]+)>both<\/w>\s*$//;
		    

#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-13b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$comma|\s)*)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;

		$subject =~ s/<w ([^>]+)>both<\/w>\s*$//;
		    

#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-14b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$comma|$quotes|\s)*)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_prep|\s)*)($quotes)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;

		$subject =~ s/<w ([^>]+)>both<\/w>\s*$//;
		    

#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";exit;

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-15b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-16b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|$to|$any_kind_of_number|$any_kind_of_noun|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-17b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)/){
	    my $verb;
	    while($precedes_rightmost_coordinator =~ /($vbd_verb)/g){
		$adjp1 = $POSTMATCH;
		$subject = $PREMATCH;
		$verb = $&;
	    }

#	    print STDERR ">>>>>>>>>>>>>>>>\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(($to|$vb_verb|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$verb." ".$adjp1.$follows_coordination;
		$sentence2 = $subject.$verb." ".$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-18b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($quotes|\s)*)(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(($quotes)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$verb." ".$adjp1.$follows_coordination;
		$sentence2 = $subject.$verb." ".$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-19b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
#HERE
 	    elsif($follows_rightmost_coordinator =~ /^(($quotes|\s)*)(($any_kind_of_adverb|$comma|\s)*)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$verb." ".$adjp1.$follows_coordination;
		$sentence2 = $subject.$verb." ".$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-20b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_noun)(($any_kind_of_noun|\s)*)/){
		my $adjp2 = $2.$6;
		my $follows_coordination = $14.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-21a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-21b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(($any_kind_of_noun|$any_kind_of_prep|\s)*)/){
		my $adjp2 = $2.$6;
		my $follows_coordination = $14.$POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";
		
		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-22b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

    }
###############################################################################
###### Punctuation-Conjunctions
    elsif($potential_coordinator =~ />(\,|\;|\:)(\s+)(and|but|or)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;

	if($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s+)($vbn_verb)(\s*)($base_np)($any_kind_of_adverb)(\s*)$/){
	    $adjp1 = $6.$8.$9.$22.$25;
	    $subject = $PREMATCH.$1.$5;
	    my $remainder = $POSTMATCH;
	    

	    
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(\s+)($any_kind_of_prep)((.|\s)*)$/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n";

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-23a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-23b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
# To deal with age/description coordination
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	   
	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_prep)(\s+)($any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_adverb|$vbd_verb|$to|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#		print STDERR "HHHHHHHHHHHHH $adjp2 JJJJJJJ $follows_coordination\n"; exit;

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-24a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-24b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
##############################################################################
###### Punctuation
    elsif($potential_coordinator =~ />(\;|\,|\:)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adjp1;
	my $adjp2;

	
	if($precedes_rightmost_coordinator =~ /(($any_kind_of_adj1|$any_kind_of_adverb|\s)*?)($any_kind_of_adj1|$vbg_verb)(\s*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
#	    print STDERR ">>>>>>>>>>>>>>>>>";exit;

	    if($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_word)(\s*)<PC/){
		my $adjp2 = $1.$2;
		my $follows_coordination = $5."<PC".$POSTMATCH;
#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-25a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-25b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(($any_kind_of_prep|$any_kind_of_noun|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;

#		print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;
#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-26b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_adj1)(\s*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;


#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-27b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s+)($any_kind_of_adj1)(\s*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-28b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $adjp1 = $3.$4.$8;
	    $subject = $PREMATCH.$1;
	    
#	    print STDERR ">>>>>>>>>>>>>> \[$adjp1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-29b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}	
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)$/){
	    $adjp1 = $&;
	    $subject = $PREMATCH;
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(($any_kind_of_prep|\s)*)/){
		my $adjp2 = $&;
		my $follows_coordination = $POSTMATCH;
		
#

		$sentence1 = $subject.$adjp1.$follows_coordination;
		$sentence2 = $subject.$adjp2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CMA1-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMA1-30b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

    }
    

    open(ERROR_FILE, ">>./CMA1_errors.txt");
    print ERROR_FILE "$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";
    close(ERROR_FILE);

    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "CMA1 NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;

}
1;
