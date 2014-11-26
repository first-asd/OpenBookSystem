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
package SimplifyCLV;
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
my $escaped_ing_jj = "<w c\\\=\\\"([^\\\"]+)\\\" p\\\=\\\"JJ\\\">([^\\\s]*?)ing<\\\/w>";
my $ing_jj = "<w c\=\"([^\"]+)\" p\=\"JJ\">([^\s]*?)ing<\/w>";
my $ed_jj = "<w c\=\"([^\"]+)\" p\=\"JJ\">([^\s]*?)ed<\/w>";
my $nd_jj = "<w c\=\"([^\"]+)\" p\=\"JJ\">([^\s]*?)nd<\/w>";


sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

    print STDERR "\t[CLV]\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

################################### CLV #######################################
###### Conjunctions
# Note that all rules must be ordered, more specific and detailed prior to more
# general or they will not have chance to be activated
    if($potential_coordinator =~ />(and|but|or)</){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";


	if($precedes_rightmost_coordinator =~ /($ing_jj|$vbg_verb|$escaped_ing_jj)(\s*)$/){
	    my $precedes_coordination = $PREMATCH;
	    my $verb1 = $&;


#	    print STDERR ">>>>>>>>>>>>>>>>>>\n\[$follows_rightmost_coordinator\]\n$ing_jj\n";exit;

#	    if($follows_rightmost_coordinator =~ /^(\s*)<w c\=\"(w|hyw)\" p\=\"\JJ">([^\s]*?)ing<\/w>/){
	    if($follows_rightmost_coordinator =~ /^((\s|$any_kind_of_adverb)*)($vbg_verb|$ing_jj|$escaped_ing_jj)/){
		$follows_coordination = $POSTMATCH;
		my $verb2 = $&;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n\[$verb2\]";exit;

		$sentence1 = $precedes_coordination.$verb1.$follows_coordination;
		$sentence2 = $precedes_coordination.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CLV-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)/){
#	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb|$ing_jj)/){
		$follows_coordination = $POSTMATCH;
		my $verb2 = $&;

		$sentence1 = $precedes_coordination.$verb1.$follows_coordination;
		$sentence2 = $precedes_coordination.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CLV-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_modal)(\s*)($any_kind_of_adverb)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    
	    print STDERR "GGGV1 $verb1\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_modal)(\s*)($any_kind_of_adverb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
	       
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
	
		print STDERR "HHHHHHHHHHSUBJ is $subject\nV2 $verb2\nFC is $follows_coordination\n";
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
	
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "9a S1 $sentence1\n9b S2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLV-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)$/){
	    my $verb1 = $&;
	    my $subject = $PREMATCH;
	    
	    print STDERR "GGGV1 $verb1\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adverb|\s)*)($any_kind_of_verb|$ed_jj|$nd_jj)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		print STDERR "HHHHHHHHHHSUBJ is $subject\nV2 $verb2\nFC is $follows_coordination\n";

		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "9a S1 $sentence1\n9b S2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLV-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-4b} ".$sentence2;
		
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
		
		
		@simpler_sentences[0] = "{CLV-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-5b} ".$sentence2;
		
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
		
		
		@simpler_sentences[0] = "{CLV-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-6b} ".$sentence2;
		
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
#	    print STDERR ">>>>>>>>>>V1 \[$verb1\]\n";exit;
		
	    print STDERR "123456123456";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_word)(\s*)/){ 
		my $verb2 = $&;
		$follows_coordination = $POSTMATCH;
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
		
		@simpler_sentences[0] = "{CLV-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-9b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-10b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-11b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-12b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-13b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-14b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-15b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
    }
##############################################################################
##### punctuation-conjunction
    elsif($potential_coordinator =~ />(\,|\;|\:)(\s*)(and|but|or)</){
	my $sentence1 = "";
	my $sentence2 = "";
	my $subject = "";
	my $follows_coordination = "";

	print STDERR "1GGGGGGGGGGGG\n";


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
		
		@simpler_sentences[0] = "{CLV-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-16b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($of)(\s*)($any_kind_of_noun)(\s*)$/){
	    my $verb1 = $3;
	    my $subject = $PREMATCH.$1.$2;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_adverb|$any_kind_of_verb|\s)*)($any_kind_of_verb)/){
		my $verb2 = $&;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-17b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
##############################################################################
###### punctuation
    elsif($potential_coordinator =~ />(\,|\;)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $verb1;
	my $verb2;

	if($precedes_rightmost_coordinator =~ /($any_kind_of_verb|$ed_jj)(\s*)$/){
	    $verb1 = $&;
#	    $subject = $PREMATCH."<PC ID\=\"".$1."\" CLASS\=\"CLV\">\,</PC>";
	    $subject = $PREMATCH;

	    print STDERR ">>>>>>>>>>>>>>>>\n";
		

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_verb|$vbn_verb|$ed_jj)(($quotes|\s)*)/){ 
		$verb2 = $1.$2;
		$follows_coordination = $9.$POSTMATCH;
		
#		print STDERR ">>>>>>>>>> $verb1\t$verb2\n";exit;

		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{CLV-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-18b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{CLV-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-19b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
		
	    }
	}

# Most dangerous, general pattern so far
	elsif($precedes_rightmost_coordinator =~ /(\s+)($to)(\s+)($any_kind_of_word)$/){
	    $verb1 = $4;
	    $subject = $PREMATCH.$1.$2.$3;
	    
	    print STDERR "JJJJJJJJJJJJJJ\n";

	    if($follows_rightmost_coordinator =~ /($any_kind_of_word)(\s+)($any_kind_of_prep)/){
		$verb2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLV-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-20b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /($any_kind_of_word)(\s+)(<PC ID\=\"([0-9]+)\" CLASS\=\"CLV\">)/){
		$verb2 = $1;
		$follows_coordination = $4.$5.$POSTMATCH;
		
		$sentence1 = $subject.$verb1.$follows_coordination;
		$sentence2 = $subject.$verb2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CLV-21a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-21b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($ing_jj)(\s*)$/){
	    my $precedes_coordination = $PREMATCH;
	    my $verb1 = $&;



	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb|$ing_jj|$escaped_ing_jj)/){
		$follows_coordination = $POSTMATCH;
		my $verb2 = $&;

		$sentence1 = $precedes_coordination.$verb1.$follows_coordination;
		$sentence2 = $precedes_coordination.$verb2.$follows_coordination;

		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CLV-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLV-22b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }


    print STDERR "CLV NO RULE MATCHED $precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
