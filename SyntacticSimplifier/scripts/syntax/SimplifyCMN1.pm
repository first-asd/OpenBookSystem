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
package SimplifyCMN1;
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
my $any_kind_of_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NNPS|NN)\">([^<]+)<\/w>";
my $nnp_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNP|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_possPron = "<w c\=\"w\" p\=\"PRP\\\$\">([^<]+)<\/w>";
my $any_kind_of_pron = "<w c\=\"w\" p\=\"PRP\">([^<]+)<\/w>";
my $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
my $any_kind_of_adj1 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_subordinator = "<PC ([^>]+)>(that|which|\, who)<\/PC>";
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
my $in = "<w c\=\"w\" p\=\"IN\">in<\/w>";
my $between = "<w c\=\"w\" p\=\"IN\">between<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $semicolon = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\;<\/PC>";
my $hyphen = "<w c\=\"(hyph|sym)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"s\" p\=\"(POS|\'\')\">\'<\/w>";
my $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";
my $ing_jj = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+?)ing<\/w>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $both = "<w c\=\"w\" p\=\"DT\">both<\/w>";
my $pdt = "<w c\=\"w\" p\=\"PDT\">([^<]+)<\/w>";
my $whose = "<w c\=\"w\" p\=\"WP\\\$\">whose<\/w>";
my $all = "<w c\=\"w\" p\=\"DT\">all<\/w>";
my $including = "<w c\=\"w\" p\=\"VBG\">including<\/w>";
my $involving = "<w c\=\"w\" p\=\"VBG\">involving<\/w>";
my $parentheses = "<w c\=\"br\" p\=\"(\\\(|\\\))\">(\\\(|\\\))<\/w>";
my $wrb_word = "<w c\=\"w\" p\=\"WRB\">([^<]+)<\/w>";
my $uc_ing = "<w c\=\"w\" p\=\"([^\"]+)\">([A-Z])([A-Za-z]*?)ing<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $np1;
    my $np2;
    my $follows_coordination;
    my $np1;
    my $np2;
    my $sentence1;
    my $sentence2;
    my $subject;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


################################### CMN1 #######################################

    if($potential_coordinator =~ />(and|or)</i){
#	print STDERR "PROCESSING $1\-CMN1\t$sentence\n";
# First identify verb,


	my $this_verb;
	my $objects_of_verb;




	if($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($quotes)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $3.$4.$7.$15.$19;
	    $subject = $PREMATCH.$1.$3;

	    print STDERR "47>>>>>>>>>>>>>>>>\n\[$np1\]\n\[$subject\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$vbd_verb|\s)*)($any_kind_of_noun)($quotes)(\s*)($whose)/g){
		$np2 = $1.$2.$6.$8.$12.$15;
		$follows_coordination = $15.$16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($nnp_noun)(\s*)($comma)(($any_kind_of_number|\s)*)($plural_noun)(\s*)$/){
	    $np1 = $4.$5.$9.$10.$13.$17.$21;
	    $subject = $PREMATCH.$1.$4;

	    print STDERR "106>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($nnp_noun)(\s*)($any_kind_of_pc)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$7.$11." ";
		$follows_coordination = $13.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
#	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(($to|$vb_verb|$any_kind_of_noun|\s)*)$/){
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$5.$7.$8.$10.$11.$15.$16.$18.$19.$21.$22.$26;
	    $subject = $PREMATCH.$1.$4;

	    print STDERR "106>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(($any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$7.$11.$12.$13." ";
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)+)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "1>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)($comma)((.|\s)*?)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$9.$12.$14;
		$follows_coordination = $17.$18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_number|$any_kind_of_noun|\s)+)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($comma|$any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_determiner)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|$quotes|\s)*)$/){
		$np2 = $&;
		$follows_coordination = $20;
		$np2 =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;


#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_pron)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "2>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_number|$hyphen|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$9.$13;
		$follows_coordination = $14.$POSTMATCH;
		
		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vb_verb)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_modal)(\s*)($vb_verb)/){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$12.$13.$POSTMATCH;
		
		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_number|\s)*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "3>>>>>>>>>>>>>>>>\n";
#	    print STDERR ">>>>>>>>>>>>>>>>> $np1\n";exit;

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($nnp_noun)(\s*)$/){
	    $np1 = $4.$5.$7.$8.$12.$13.$14.$15.$19;
	    $subject = $PREMATCH.$1.$4;
#	    print STDERR ">>>>>>>>>>>>>>>> $np1\n";exit;

	    print STDERR "107>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$7." ";
		$follows_coordination = $11.$12.$POSTMATCH;
		
#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
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
	elsif($precedes_rightmost_coordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
#	    print STDERR ">>>>>>>>>>>>>>>> $np1\n";exit;

	    print STDERR "5>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|\s)*)($nnp_noun)(($nnp_noun|\s)*)/){
		$np2 = $&;
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
		@simpler_sentences[0] = "{CMN1-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-10b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($of)(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)(($any_kind_of_noun|$any_kind_of_adj1|\s)*?)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)($any_kind_of_noun)(\s*)($comma)(($nnp_noun|\s)*)($comma)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$6.$10.$11.$14.$19." ";
		$follows_coordination = $22.$23.$POSTMATCH;

		print STDERR "\[$np2\]\n";
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)(($any_kind_of_noun|$any_kind_of_adj1|\s)*?)($any_kind_of_noun)(($of|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)/){
		$np2 = $1.$2.$6.$14.$18." ";
		$follows_coordination = $24.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-13b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)(($any_kind_of_noun|$any_kind_of_adj1|\s)*?)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-14b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_number|$hyphen|\s)*?)($any_kind_of_noun)/){
		$np2 = $&;
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
		@simpler_sentences[0] = "{CMN1-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-15b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|\s)+)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_number|$hyphen|$quotes|\s)*?)($any_kind_of_noun)/){
		$np2 = $&;
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
		@simpler_sentences[0] = "{CMN1-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-16b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}	

	elsif($precedes_rightmost_coordinator =~ /($between)(\s*)($pound)($any_kind_of_number)(\s*)$/){

#	    $np1 = $3.$4.$5;
	    $np1 = $3.$5;
	    $subject = $PREMATCH;

	    print STDERR "6>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /(\s*)($pound)($any_kind_of_number)/){
		$follows_coordination = $POSTMATCH;
		$np2 = $&;
	    }
	    
	    $sentence1 = $subject.$np1.$follows_coordination;
	    $sentence2 = $subject.$np2.$follows_coordination;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-17a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-17b} ".$sentence2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($between)(\s*)($any_kind_of_number)(\s*)$/){

	    $np1 = $3;
	    $subject = $PREMATCH;

	    print STDERR "7>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_number)/){
		$follows_coordination = $POSTMATCH;
		$np2 = $&;
	    }
	    
	    $sentence1 = $subject.$np1.$follows_coordination;
	    $sentence2 = $subject.$np2.$follows_coordination;
	 
# BUT SINCE THIS IS LIKELY TO BE COMBINATORY...

	    my $substitute_coordinator = $potential_coordinator;
	    $substitute_coordinator =~ s/<\/PC>/<\/w>/;
	    $substitute_coordinator =~ s/<PC([^>]+)>/<w c\=\"w\" p\=\"CC\">/;

	    $sentence1 = $precedes_rightmost_coordinator.$substitute_coordinator.$follows_rightmost_coordinator;
   
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-18a} ".$sentence1.$final_punctuation;
#	    @simpler_sentences[1] = "{CMN1-10b} ".$sentence2;
	    
#	    print STDERR ">>>>>>>>>>>>S1 $sentence1\nS2 $sentence2\n";exit;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)$/){

	    $np1 = $3.$6.$7.$11;
	    $subject = $PREMATCH.$1;

	    print STDERR "44>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$follows_coordination = $10.$POSTMATCH;
		$np2 = $1.$2.$5.$6;
	    }
	    
#	    print STDERR "\[$np2\]";exit;

	    $sentence1 = $subject.$np1.$follows_coordination;
	    $sentence2 = $subject.$np2.$follows_coordination;
	 
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

# BUT SINCE THIS IS LIKELY TO BE COMBINATORY...

	    my $substitute_coordinator = $potential_coordinator;
	    $substitute_coordinator =~ s/<\/PC>/<\/w>/;
	    $substitute_coordinator =~ s/<PC([^>]+)>/<w c\=\"w\" p\=\"CC\">/;

	    $sentence1 = $precedes_rightmost_coordinator.$substitute_coordinator.$follows_rightmost_coordinator;
   
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-19a} ".$sentence1.$final_punctuation;
#	    @simpler_sentences[1] = "{CMN1-10b} ".$sentence2;
	    
#	    print STDERR ">>>>>>>>>>>>S1 $sentence1\nS2 $sentence2\n";exit;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

	elsif($precedes_rightmost_coordinator =~ /(\s*)($pound)($any_kind_of_number)(\s*)$/){

	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "8>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /(\s*)($pound)($any_kind_of_number)/){
		$follows_coordination = $POSTMATCH;
		$np2 = $&;
	    }
	    
	    $sentence1 = $subject.$np1.$follows_coordination;
	    $sentence2 = $subject.$np2.$follows_coordination;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-20a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-20b} ".$sentence2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

	elsif($precedes_rightmost_coordinator =~ /$any_kind_of_verb\s+$any_kind_of_noun\s+$with\s+/){
	    print STDERR "9>>>>>>>>>>>>>>>>\n";

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
	    @simpler_sentences[0] = "{CMN1-21a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-21b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

	elsif($precedes_rightmost_coordinator =~ /($wh_word)((\s|.)*?)($vbp_verb)(\s*)$/){
	    $np1 = $1.$5.$7;
	    $subject = $PREMATCH;

	    print STDERR "10>>>>>>>>>>>>>>>>\n";

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
		@simpler_sentences[0] = "{CMN1-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-22b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_adj1)(\s*)($plural_noun)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "39>>>>>>>>>>>>>>>>\[$np1\]\n";
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($pound)($nnp_noun)\,($nnp_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-23a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-23b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    

	}	

	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($including)(($any_kind_of_determiner|$any_kind_of_number|$hyphen|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $6.$18.$22;
	    $subject = $PREMATCH.$1.$4.$5;

	    print STDERR "100>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $6.$7.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-24a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-24b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbg_verb)(($any_kind_of_determiner|$any_kind_of_number|$hyphen|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$5.$7.$19.$23;
	    $subject = $PREMATCH.$1;

	    print STDERR "99>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_sentence_boundary|\s)*)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-25a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-25b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_rp)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$13.$14." ";
		$follows_coordination = $18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-26b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbg_verb)(($any_kind_of_determiner|$any_kind_of_number|$hyphen|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $3.$15.$19;
	    $subject = $PREMATCH.$1;

	    print STDERR "49>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$5.$6.$10;
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-27b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$15.$16.$17.$18.$22;
		$follows_coordination = $23.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-28b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$15.$16.$17.$18.$22;
		$follows_coordination = $23.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-29b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$6." ";
		$follows_coordination = $7.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-30b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|$any_kind_of_possessive|\s)*)($any_kind_of_noun)(($parentheses|$any_kind_of_noun|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$8.$12." ";
		$follows_coordination = $19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-31a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-31b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$8.$9.$10.$11.$14.$15.$19." ";
	    
	    print STDERR "51>>>>>>>>>>>>>>>>\[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$5.$6.$7.$8.$11.$12." ";
		$follows_coordination = $16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-32b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_pc)(\s*)($any_kind_of_number|$vbn_verb)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $5.$6.$10.$11." ";
	    
	    print STDERR "62>>>>>>>>>>>>>>>>\[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)((\s|$comma)*)($vbd_verb)/){
		$np2 = $1.$2.$5.$6;
		$follows_coordination = $10.$14.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-33b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$6.$8.$12.$16;
		$follows_coordination = $20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-34b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_adverb|$any_kind_of_adj1|\s)*)(\s*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $3.$4.$6.$7.$14.$15.$19;
	    $subject = $PREMATCH.$1;

	    print STDERR "58>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)((.|\s)*?)($wh_word)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$13.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-35a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-35b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$6.$10.$11.$15.$17.$19;
		$follows_coordination = $21.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-36a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-36b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_subordinator)((.|\s)*?)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$6.$10.$11.$14.$16.$18;
		$follows_coordination = $20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-37a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-37b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($vb_verb|$any_kind_of_adj1|\s)*)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$8.$9;
		$follows_coordination = $13.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-38a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-38b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "59>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)((.|\s)*?)($wh_word)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$13.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-39a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-39b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(\s+)(($any_kind_of_noun|$any_kind_of_adj1|\s)+?)(\s+)($any_kind_of_noun)(\s*)($to)(\s*)($vb_verb)((.|\s)*)$/){
	    $np1 = $3.$4.$6.$7.$15.$16.$20.$21.$22.$23.$25;
	    $subject = $PREMATCH.$1.$3;

	    print STDERR "11>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_pron)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$7.$12.$16.$17.$20.$21;
		$follows_coordination = $20.$21.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-40a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-40b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($quotes)*)($any_kind_of_determiner)(\s+)(($any_kind_of_noun|$any_kind_of_adj1|\s)+?)(\s+)($any_kind_of_noun)(\s*)($to)(\s*)($vb_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){

		$np2 = $1.$2.$5.$6.$8.$9.$17.$18.$22.$23.$24.$25.$27;
		$follows_coordination = $29.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-41a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-41b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_number|\s)($comma)((.|\s)*)$/){
	    $np1 = $4.$5.$10.$14.$15.$18.$21;
	    $subject = $PREMATCH.$1.$4;

	    print STDERR "69>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_pron)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$7.$12.$16.$17.$20.$21;
		$follows_coordination = $20.$21.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-42a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-42b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_adj1|$hyphen|\s|$any_kind_of_noun)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$17.$21;
	    $subject = $PREMATCH.$1;

	    print STDERR "71>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$7.$8;
		$follows_coordination = $12.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-43a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-43b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|$hyphen|$any_kind_of_adj1|$vbd_verb|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$13;
		$follows_coordination = $17.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-44a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-44b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)($any_kind_of_determiner)(\s*)($vbd_verb)/g){
		$np2 = $1.$7.$11.$12.$16.$17.$19.$20.$22.$26." ";
		$follows_coordination = $26.$27.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-45a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-45b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|$hyphen|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_adverb|\s)*)($vbd_verb)/g){
		$np2 = $1.$2.$12;
		$follows_coordination = $16.$20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence2 =~ /hamnever/){
		    print STDERR "insert whitespace here\n";exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-46a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-46b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|$hyphen|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($comma|\s)*)/g){
		$np2 = $1.$2.$15;
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-47a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-47b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$9." ";
		$follows_coordination = $13.$14.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-48a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-48b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$11." ";
		$follows_coordination = $15.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-49a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-49b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $np1 = $4.$5.$9.$10.$13.$14.$17;
	    $subject = $PREMATCH.$1;

	    print STDERR "88>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($comma)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$6.$7.$10.$11.$14." ";
		$follows_coordination = $15.$18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-50a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-50b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbn_verb)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_number|$any_kind_of_possPron|$hyphen|\s)*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$6.$7.$13.$18.$22;
	    $subject = $PREMATCH.$1.$3;

	    print STDERR "97>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-51a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-51b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($to)(($any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $2.$9.$13;
	    $subject = $PREMATCH.$1;

	    print STDERR "102>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)(($vbn_verb|\s)*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_possPron|\s)*)($any_kind_of_noun)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$5.$8.$19;
		$follows_coordination = $23.$26.$27.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-52b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($subordinating_that)(\s)($any_kind_of_modal)(\s*)($vb_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|$to|$vbg_verb|$any_kind_of_possPron|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$6.$7.$10.$11.$13.$14.$16.$17.$19." ";
		$follows_coordination = $29.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-53b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$6;
		$follows_coordination = $10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-54a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-54b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /^(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_adj1|$any_kind_of_possessive|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){

	    $np1 = $&;
	    $subject = $PREMATCH;

	    print STDERR "111>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($vbd_verb)(($any_kind_of_prep|$any_kind_of_noun|$to|$vb_verb|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$7.$11.$12.$16.$17.$19." ";
		$follows_coordination = $26.$29.$30.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-55a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-55b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$8.$12." ";
		$follows_coordination = $12.$13.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-56a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-56b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_possessive|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){

		$np2 = $1.$11.$18." ";
		$follows_coordination = $15.$16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-57a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-57b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_possessive|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbp_verb)(\s*)($vbn_verb)/){

		$np2 = $1.$11.$15." ";
		$follows_coordination = $15.$16.$19.$22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-58a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-58b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(($any_kind_of_adverb|\s)*)($vbp_verb)/){

		$np2 = $1.$2.$6.$7." ";
		$follows_coordination = $11.$15.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-59a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-59b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/){

		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-60a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-60b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)($any_kind_of_adj1)(\s*)($vbd_verb)/){
		$np2 = $1.$4.$8." ";
		$follows_coordination = $8.$9.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-61a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-61b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($precedes_rightmost_coordinator =~ /($vb_verb)(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $3.$4.$9.$13;
	    $subject = $PREMATCH.$1;

	    print STDERR "117>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)($quotes)(\s*)$/g){
		$np2 = $5.$6." ";
		$follows_coordination = $10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-62a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-62b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$10." ";
		$follows_coordination = $14.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-63a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-63b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun|$any_kind_of_determiner)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$7.$8." ";
		$follows_coordination = $12.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-64a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-64b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)($quotes)(\s*)$/g){
		$np2 = $1.$2." ";
		$follows_coordination = $6.$10.$13.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-65a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-65b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
#	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){ # MAY NEED TO REPLACE THIS
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_adj1)(\s*)($nnp_noun)(\s*)($plural_noun)(\s*)$/){ # MAY NEED TO REPLACE THIS
	    $np1 = $&;
	    $subject = $PREMATCH.$1.$4.$5.$7.$8;
	    $np1 =~ s/^($comma)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_adj1)//;


	    print STDERR "121>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($plural_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2;
		$follows_coordination = $6.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-66a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-66b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){ # MAY NEED TO REPLACE THIS
	    $np1 = $&;
	    $subject = $PREMATCH;

#	    print STDERR "70>>>>>>>>>>>>>>>>\[$np1\]\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$7.$8;
		$follows_coordination = $12.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-66a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-66b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$15.$16.$17.$18.$22;
		$follows_coordination = $23.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-67a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-67b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $&;
		$follows_coordination = $13.$14.$POSTMATCH;
		$np2 =~ s/($any_kind_of_prep)$//;



#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\]\nS2 $sentence2\]\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-279a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-279b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$9.$13;
		$follows_coordination = $13.$14.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-68a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-68b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$15.$16.$17.$18.$22;
		$follows_coordination = $23.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-69a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-69b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($pdt)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$7.$8.$12.$13.$14.$15;
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-70a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-70b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$6.$7.$11.$12.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-71a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-71b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-72a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-72b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($pound)($nnp_noun)\,($nnp_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject."[".$np2."]".$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-73a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-73b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }	

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)($comma)((.|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$9.$12.$14;
		$follows_coordination = $17.$18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-74a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-74b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)($comma)((.|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$9.$12.$14;
		$follows_coordination = $17.$18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-75a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-75b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-76a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-76b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($vbg_verb)/g){
		$np2 = $1.$2.$4.$5.$9." ";
		$follows_coordination = $10.$14.$15.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-77a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-77b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$5.$6.$10;
		$follows_coordination = $10.$11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-78a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-78b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-79a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-79b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }	
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)($any_kind_of_noun|$any_kind_of_adj1)/){
		$np2 = $PREMATCH.$&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-80a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-80b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_number|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$7;
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-81a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-81b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_modal)(\s*)($vb_verb)/g){
		$np2 = $1.$2.$9.$13;
		$follows_coordination = $13.$14.$16.$17.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-82a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-82b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)(\s*)($comma)/g){
		$np2 = $1.$2.$5.$6.$8.$9.$13.$14.$15.$21." ";
		$follows_coordination = $21.$22.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-83a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-83b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}	

#	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_clncin_pc|\s)+)(\s*)$/){
#	    $np1 = $&;
#	    $subject = $PREMATCH;
#	    print STDERR "GOTCHA $np1\n";
#
#
# This pattern will match anything containing a space...	    
#	    if($follows_rightmost_coordinator =~ /(($any_kind_of_adverb|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
#		$np2 = $PREMATCH.$&;
#		$follows_coordination = $POSTMATCH;
		
#		if($sentence =~ /secret/){
#		    print STDERR "NP1 $np1\nNP2 $np2\nSUBJECT $subject\n";
#		}
		
#		$sentence1 = $subject.$np1.$follows_coordination;
#		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";
#
#		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
#		    $final_punctuation = "";
#		}
#		@simpler_sentences[0] = "{CMN1-a} ".$sentence1.$final_punctuation;
#		@simpler_sentences[1] = "{CMN1-7b} ".$sentence2;
#		
#		$simpler_sentences_ref = \@simpler_sentences;
#		return($simpler_sentences_ref);
#	    }
#	}

# Causes error processing "Occasionally I ate [[pasty] and [chips]] CONJ [jumbo
# sausage with chips]."
# V NN and NN CONJ ... [IN, JJ, NN] NN.$

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron|$any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)(\s*)($vbn_verb)(\s*)$/){
	    $np1 = $3.$4.$7.$8.$12.$13.$17.$18.$22.$23.$25;
	    $subject = $PREMATCH.$1;
	    print STDERR "GOTCHA $np1\n";
	    
	    print STDERR "27>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)((.|\s)*?)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){# \s*$/){
		$np2 = $1.$2.$7.$11.$12.$14.$16;
		$follows_coordination = $20.$POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

		print STDERR "\[$np2\]\n";	
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		

#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-84a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-84b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_possPron|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    print STDERR "GOTCHA $np1\n";
	    
	    print STDERR "27>>>>>>>>>>>>>>>>$np1\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_possPron|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_adverb)((\s|$any_kind_of_sentence_boundary)*)$/){# \s*$/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-85a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-85b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($vbg_verb)((.|\s)*?)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)((.|\s)*)$/){
	    $np1 = $3.$4.$6.$8.$12.$13.$17.$18.$22;
	    $subject = $PREMATCH.$1.$3;
	    print STDERR "GOTCHA $np1\n";
	    
	    print STDERR "72>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_prep|$any_kind_of_adj1|$any_kind_of_noun|\s)*)$any_kind_of_noun/){# \s*$/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-86a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-86b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_prep|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($any_kind_of_number|\s)*)($any_kind_of_prep)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/){# \s*$/){
		$np2 = $1.$11.$15.$19.$21;
		$follows_coordination = $23.$POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
		print STDERR "\[$np2\]\n";
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-87a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-87b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}


	elsif($precedes_rightmost_coordinator =~ /($of)(\s*)(($vbg_verb|$any_kind_of_noun))(\s*)($any_kind_of_pc)(\s*)($vbg_verb)((.|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)((.|\s)*?)$/){
	    $np1 = $2.$3.$9.$10.$13.$15.$17.$19.$23.$24.$26;
	    $subject = $PREMATCH.$1.$2;
	    
	    print STDERR "73>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)((.|\s)*?)($vbd_verb)/){# \s*$/){
		$np2 = $1.$2.$4;
		$follows_coordination = $6.$POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "\[$np2\]\n";
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		

#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-88a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-88b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /AAAA(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_clncin_pc|\s)+)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    print STDERR "GOTCHA $np1\n";
	    
	    print STDERR "12>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_prep|$any_kind_of_adj1|$any_kind_of_noun|\s)*)$any_kind_of_noun/){# \s*$/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-89a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-89b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_noun)*)(\s*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    
	    print STDERR "13>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /$any_kind_of_noun(\s*)(($any_kind_of_noun)*)/){
		$np2 = $PREMATCH.$&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence1 = $subject.$np2.$follows_coordination;
	    }
	    
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-90a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-90b} ".$sentence2;

	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	
###############  [1] V [2] CONJ [3 V [4]] ->
#                                            [1] V [2] [4], 
#                                            [1] V [3]
# works well ONLY  for "Occasionally I ate pasty and chips [or] jumbo sausage
# with chips - but mainly it was just chips,' he said."
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($wrb_word)(\s*)($uc_ing)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $15.$16.$20;
	    $this_verb = $&;
	    $this_verb =~ s/($uc_ing)(\s*)$//;

	    print STDERR "120>>>>>>>>>>>>>>>>\[$np1\]\n";

#		print STDERR "SUBJ $subject\n";exit;
	    
	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
		$follows_coordination = " ".$&.$POSTMATCH;
	    }
	    
	    
	    print STDERR "FC $follows_coordination\n";
	    $sentence1 = $subject.$this_verb.$np1.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-91a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-91b} ".$sentence2;
	    
	    unless($sentence =~ /pasty/){
#		    print STDERR ">>> $sentence1\n>>> $sentence2\n";exit;
	    }
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    
	    print STDERR "14>>>>>>>>>>>>>>>>\n";

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
	    @simpler_sentences[0] = "{CMN1-91a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-91b} ".$sentence2;
	    
	    unless($sentence =~ /pasty/){
#		    print STDERR ">>> $sentence1\n>>> $sentence2\n";exit;
	    }
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s+)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    my $objects_of_prep = $POSTMATCH;
	    my $this_prep = $1;
	    
	    print STDERR "15>>>>>>>>>>>>>>>>\n";

	    print STDERR "~~~~~~~~~~~~~~\n";

#		print STDERR "SUBJ $subject\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_sentence_boundary)/g){
		$follows_coordination = " ".$6.$POSTMATCH;
	    }
	    
	    
	    print STDERR "FC $follows_coordination\n";exit;
	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CMN1-92a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CMN1-92b} ".$sentence2;
	    
	    unless($sentence =~ /pasty/){
#		    print STDERR ">>> $sentence1\n>>> $sentence2\n";exit;
	    }
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($of)(\s+)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1.$2;
	    $np1 = $2.$3.$9.$13.$14.$17;
	    
	    print STDERR "115>>>>>>>>>>>>>>>>\[$np1\]\n";

	 
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_number|$any_kind_of_noun|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$14.$18;
		$follows_coordination = $18.$19.$POSTMATCH;
		
		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-93a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-93b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
    
# ... NOT ONLY with ... CONJ [BOTH] NP and NP
# Going to rewrite to just
# ... with ... <PC CLASS="original">and</PC> NP and NP
    elsif($potential_coordinator =~ />but</){
	print STDERR "PROCESSING $&\-CMN1\t$sentence\n";

	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;


	my $this_verb;
	my $objects_of_verb;

	if($precedes_rightmost_coordinator =~ /($not)(\s+)($only)(\s+)($any_kind_of_prep)(\s*)((.|\s)+)$/){
	    $subject = $PREMATCH;
	    my $prep = $5;
	    $np1 = $8;
	    
	    print STDERR "16>>>>>>>>>>>>>>>>\n";

	    $sentence1 = $subject." ".$prep." ".$np1."<PC ID=\"000\" CLASS=\"CMN1\">and</PC>".$follows_rightmost_coordinator;
	    
#	    print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }

	    
	    @simpler_sentences[0] = "{CMN1-94a} ".$sentence1.$final_punctuation;
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_rightmost_coordinator =~ /($not)(\s+)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;
	    
	    print STDERR "17>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun|$any_kind_of_number)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n";exit;


	    
#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

	    
		@simpler_sentences[0] = "{CMN1-95a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-95a} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($not)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    my $modifier1 = $1.$3.$5;
	    my $modifier2 = $3.$5;
	    $np1 = " ".$6.$8.$15;

	    print STDERR "18>>>>>>>>>>>>>>>>\n";

#	    print STDERR "\[$modifier1\] \[$modifier2\] \[$np1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_prep|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n";exit;


	    
#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		$sentence1 = $subject.$modifier1.$np1;
		$sentence2 = $subject.$modifier2.$np2.$follows_coordination;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
		@simpler_sentences[0] = "{CMN1-96a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-96a} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	} 
	elsif($precedes_rightmost_coordinator =~ /($not)(\s+)(($any_kind_of_adj1|\s)*?)($nnp_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;
	    
	    print STDERR "19>>>>>>>>>>>>>>>>\n";
	    
	    print STDERR "HHHHHHH $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }

	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_adj1|$any_kind_of_noun|$nnp_noun|$any_kind_of_determiner|\s)*)($nnp_noun)/){
		$follows_coordination = $POSTMATCH;	    
		$np2 = $&;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		@simpler_sentences[0] = "{CMN1-97a} ".$sentence1.$follows_coordination;
		@simpler_sentences[0] = "{CMN1-97b} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(($any_kind_of_noun|$any_kind_of_prep|\s)*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;
	    	    
	    print STDERR "20>>>>>>>>>>>>>>>>\n";
#	    print STDERR "HHHHHHH $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";exit;


	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_noun|$nnp_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/){
		$follows_coordination = $POSTMATCH;	    
		$np2 = $&;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

		@simpler_sentences[0] = "{CMN1-98a} ".$sentence1.$follows_coordination;
		@simpler_sentences[0] = "{CMN1-98b} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
# # # # # # # # # # # # # # # # comma-and # # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />\,\s+and</i){
#	print STDERR "PROCESSING ,_and-CMN1\t$sentence\n\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";exit;
# First identify verb,


	my $this_verb;
	my $objects_of_verb;

	if($precedes_rightmost_coordinator =~ /($comma)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)((.|\s)*)($comma)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($of)(($any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH;
	    $this_verb = $&;
	    $np1 = $4.$5.$9.$14.$17.$19.$22.$23.$24.$31.$32;	    

	    print STDERR "60>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_adverb|\s)*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$10.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-99a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-99b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_modal)(\s*)($vb_verb)/g){
		$np2 = $1.$5.$9;
		$follows_coordination = $9.$10.$12.$13.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-100a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-100b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($precedes_rightmost_coordinator =~ /^((\{([^\}]+)\} |\s)*)($nnp_noun)(\s*)($comma)((.|\s)*)($vbn_verb)(\s*)($any_kind_of_number)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;	    
	    $np1 =~ s/^((\{([^\}]+)\} |\s)*)/ /;
#	    print STDERR "119>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$4;
		$follows_coordination = $8.$9.$11.$13;

#		print STDERR "\[$np2\]\n$follows_coordination\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-277a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-277b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(($of|$any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&." ";	    

	    print STDERR "114>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$9.$13;
		$follows_coordination = $13.$14.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-101a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-101b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)($hyphen)(\s*)($wh_word)(\s*)($vbd_verb)((.|\s)*?)($hyphen)(\s*)($any_kind_of_determiner)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$10.$11.$15.$16.$17.$18.$22.$23.$25.$26.$30.$31.$33.$35.$37;
# $38 is "both": omit this
		$follows_coordination = $37.$40.$41.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-102a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-102b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($vbg_verb)((.|\s)*)$/){
	    $subject = $PREMATCH;
	    $this_verb = $&;
	    $np1 = $4.$5.$9.$10.$12.$13.$15;	    

	    print STDERR "43>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_adverb|\s)*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$10.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-103a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-103b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun)(\s*)($wh_word)(\s*)($vbz_verb)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$5;
	    $this_verb = $&;
	    $np1 = $5.$6.$10.$11.$13.$23.$27;	    

	    print STDERR "113>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6." ";
		$follows_coordination = $8.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-104a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-104b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($vb_verb)(($any_kind_of_noun|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$2.$3.$5;
	    $np1 = $5.$13.$17;
	    
	    print STDERR "81>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)(\s*)($any_kind_of_noun)($comma)(\s*)($any_kind_of_number)((.|\s)*?)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$13.$14.$18.$21.$22.$25.$27.$30;
		$follows_coordination = $31.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-105a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-105b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$10;
		$follows_coordination = $14.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-106a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-106b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_adverb)(\s*)($vbn_verb)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $1.$2.$7.$11.$12.$15.$16.$19.$20.$22.$23.$26;
	    
	    print STDERR "94>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$13.$14.$18;
		$follows_coordination = $18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-107a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-107b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(($any_kind_of_noun|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$11.$15.$16.$19.$20.$23;
	    
	    print STDERR "80>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)(\s*)($any_kind_of_noun)($comma)(\s*)($any_kind_of_number)((.|\s)*?)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$13.$14.$18.$21.$22.$25.$27.$30;
		$follows_coordination = $31.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-108a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-108b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($wh_word)(\s*)($vbz_verb)((.|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$4.$9.$13.$14.$18.$19.$21.$23." ";
		$follows_coordination = $27.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-109a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-109b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($subordinating_that)(($any_kind_of_determiner|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($wh_word)(($any_kind_of_modal|$vb_verb|$any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)$/){
	    $subject = $PREMATCH.$1.$3.$4;
	    $np1 = $7.$12.$16.$17.$21;
	    
	    print STDERR "84>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)*)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_modal)(\s*)($vb_verb)/g){
		$np2 = $1.$10.$11.$15;
		$follows_coordination = $16.$19.$20.$22.$23.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-110a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-110b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_possessive)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$of|\s)*)$/){
	    $subject = $PREMATCH.$1;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $3.$4.$9.$12.$13.$17.$18.$20.$21;	    

	    print STDERR "93>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_subordinator)(\s)($any_kind_of_noun)(\s*)($vbz_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$9.$10.$13.$14.$18.$19.$21;
		$follows_coordination = $23.$POSTMATCH;

		print STDERR "NP2 \[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-111a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-111b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /AAAA($any_kind_of_prep)(\s*)(($any_kind_of_noun|\s)*)($vbg_verb)(\s*)($any_kind_of_noun)(($any_kind_of_noun|\s)*)($any_kind_of_pc)((.|\s)*)$/){
	    $subject = $PREMATCH.$1;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $3.$4.$5.$9.$11.$12.$16.$21.$25." ";	    

	    print STDERR "116>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_pc)(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_pc)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$9.$10.$12.$14.$18.$19.$21;
		$follows_coordination = $23.$POSTMATCH;

		print STDERR "NP2 \[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
#    		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-112a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-112b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
# REMOVE THE FOLLOWING ELSIF
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $3.$4.$6.$7.$11.$12.$15.$16.$21.$25.$26.$29.$30.$33;	    

	    print STDERR "53>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_noun|\s)*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)/g){
		$np2 = $1.$2.$4.$5.$9.$10.$15.$18.$19;
		$follows_coordination = $22.$23.$POSTMATCH;

#		print STDERR "NP2 \[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-113a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-113b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-114a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-114b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($nnp_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $np1 = $&;
	    $subject = $PREMATCH;
	    if($np1 =~ /^($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)/){
		$subject .= $&;
		$np1 =~ s/^($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)//;
	    }

	    print STDERR "122>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($nnp_noun)(\s*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $14;
		$np2 =~ s/((\s|$any_kind_of_sentence_boundary)*)$//;

#		print STDERR "NP2 \[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-278a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-278b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($comma)((.|\s)*?)($comma)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $3.$4.$6.$7.$11.$12.$15.$17.$20.$21.$23.$24.$28;	    

	    print STDERR "42>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_noun|\s)*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)/g){
		$np2 = $1.$2.$4.$5.$9.$10.$15.$18.$19;
		$follows_coordination = $22.$23.$POSTMATCH;

#		print STDERR "NP2 \[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-115a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-115b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$5.$9.$10.$13.$14.$18.$22.$23.$26;
		$follows_coordination = $27.$POSTMATCH;

#		print STDERR "NP2 \[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-116a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-116b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
################

	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
#	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $1.$9.$13.$14.$17.$18.$21;
	    
	    print STDERR "55>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(($any_kind_of_noun|\s)*)($comma)(\s*)($any_kind_of_number)(\s*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$10.$14.$15.$18.$23.$26.$27.$30.$31.$34;
		$follows_coordination = $34.$35.$POSTMATCH;

		print STDERR "\[$np2\]\n";


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-117a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-117b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($any_kind_of_number)(\s*)($any_kind_of_subordinator)/g){
		$np2 = $1.$2.$10.$14.$17.$18;
		$follows_coordination = $21.$22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-118a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-118b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($any_kind_of_subordinator)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$11.$15.$16.$19.$20.$23;
		$follows_coordination = $23.$24.$27.$28.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-119a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-119b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($any_kind_of_subordinator)(\s*)($vbd_verb)/g){
		$np2 = $1.$2;
		$follows_coordination = $27.$28.$31.$32.$POSTMATCH;

		print STDERR ">>>\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-120a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-120b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)((\,|$comma|\s)*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$11.$15.$16.$19.$20;
		$follows_coordination = $23.$27.$POSTMATCH;

#		print STDERR ">>>\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-121a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-121b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_number|$hyphen|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$14;
		$follows_coordination = $18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-122a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-122b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($any_kind_of_number)(($any_kind_of_sentence_boundary|\s)*)/g){
		$np2 = $1.$2.$10.$14.$17.$18;
		$follows_coordination = $21.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-123a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-123b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($comma)(($any_kind_of_noun|\s)*)($comma)(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)(($any_kind_of_possPron|$any_kind_of_noun|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$5.$9.$10.$13.$18.$21.$22.$25.$26.$28." ";
		$follows_coordination = $34.$37.$38.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-124a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-124b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
#	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $1.$6.$10.$11.$14.$15.$18;
	    
	    print STDERR "83>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($any_kind_of_number)(\s*)($any_kind_of_subordinator)/g){
		$np2 = $1.$2.$10.$14.$17.$18;
		$follows_coordination = $21.$22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-125a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-125b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $4.$5.$9;	    

	    print STDERR "33>>>>>>>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-126a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-126b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
# REPLACE HERE

	elsif($precedes_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)(($any_kind_of_noun|\s)*)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $1.$2.$6.$7.$12.$13.$16.$17.$20;	    

	    print STDERR "54>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_noun|\s)*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)/g){
		$np2 = $1.$2.$4.$5.$9.$10.$15.$18.$19;
		$follows_coordination = $22.$23.$POSTMATCH;

#		print STDERR "NP2 \[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-127a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-127b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1.$4;
	    $np1 = $4.$5.$10.$14.$15.$18.$19.$22." ";
	    
	    print STDERR "67>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$6.$10.$11.$14.$15;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-128a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-128b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)((.|\s)*?)($comma)(($any_kind_of_adverb|$any_kind_of_prep|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $1.$2.$7.$11.$14.$16.$19.$24.$28.$29.$31.$32.$36;	    

	    print STDERR "40>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_number)(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$4.$5.$8.$9.$13.$14.$18;

		print STDERR "\[$np2\]\n";
		$follows_coordination = $19.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-129a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-129b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-130a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-130b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($whose)((.|\s)*)$/){
	    $subject = $PREMATCH.$1;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $4.$5.$7.$8.$13.$17.$20.$21.$22;	    

	    print STDERR "34>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n$follows_rightmost_coordinator\n";

	    if($follows_rightmost_coordinator =~ /($hyphen)(\s*)($all)(\s*)($vbd_verb)/g){
		$np2 = $PREMATCH;
		$follows_coordination = " ".$POSTMATCH;
		my $verb = $5.$6;

#		print STDERR "\[$verb\]\n";exit;

		$sentence1 = $subject.$np1.$verb.$follows_coordination;
		$sentence2 = $subject.$np2.$verb.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-131a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-131b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($subordinating_that)(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($comma)((.|\s)*?)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$10.$14.$24.$27;	    

	    print STDERR "82>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)(($any_kind_of_adverb|$any_kind_of_prep|$any_kind_of_noun|\s)*)($vbd_verb)/g){
		$np2 = $1.$7.$11.$12.$14;
		$follows_coordination = $22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-132a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-132b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)((.|\s)*?)($comma)((.|\s)*)$/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $np1 = $&;	    

	    print STDERR "92>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($comma)(\s*)(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$10.$14.$15.$18.$19.$22.$23.$26.$27.$36.$40;
		$follows_coordination = $41.$44.$45.$POSTMATCH;

		print STDERR "\[$np2\]\n";


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-133a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-133b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-134a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-134b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(($comma|$any_kind_of_prep|$any_kind_of_noun|\s)+)($comma)(\s*)($any_kind_of_determiner)(\s*)($vbp_verb)/){
		$np2 = $1.$2.$6." ";

#		print STDERR "\[$np2\]\n";exit;
		$follows_coordination = $14.$20.$21.$POSTMATCH;
# $17 and $18 map to "all ". This "all" is being deleted in the rewritten
# version
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-135a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-135b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(($any_kind_of_noun|$of|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $1.$6.$10.$11.$14.$20;
		$follows_coordination = $24.$POSTMATCH;
# $17 and $18 map to "all ". This "all" is being deleted in the rewritten
# version
		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-136a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-136b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$4;
	    $np1 = $4.$5.$9.$10.$14.$15.$19;	    

	    print STDERR "110>>>>>>>>>>>>>>>>>>>>>>\n\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
 
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
   
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-137a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-137b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbz_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    $np1 = $3.$4.$6.$7.$11." ";	    

	    print STDERR "118>>>>>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($vbg_verb)(($any_kind_of_determiner|\s)*?)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|$to|$vb_verb|\s)*)($any_kind_of_pc)(\s*)($vbz_verb)(\s*)($vbn_verb)/g){
		$np2 = $1.$2.$4.$5.$9.$10.$11.$12.$14.$17.$21.$22.$26.$27.$31." ";
		$follows_coordination = $38.$42.$43.$45.$46.$POSTMATCH;

		print STDERR "\[$np2\]\n";


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-138a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-138b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

    }

# # # # # # # # # # # # # # # # comma-but # # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />\,\s+but</i){
	print STDERR "PROCESSING ,_but-CMN1\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	my $this_verb;
	my $objects_of_verb;

	if($precedes_rightmost_coordinator =~ /($not)(\s+)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;
	    
	    print STDERR "22>>>>>>>>>>>>>>>>\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun|$any_kind_of_number)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n";exit;


	    
#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

	    
		@simpler_sentences[0] = "{CMN1-139a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-139a} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($not)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    my $modifier1 = $1.$3.$5;
	    my $modifier2 = $3.$5;
	    $np1 = " ".$6.$8.$15;
	    
	    print STDERR "23>>>>>>>>>>>>>>>>\n";

#	    print STDERR "\[$modifier\] \[$np1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_prep|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n";exit;


	    
#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		$sentence1 = $subject.$modifier1.$np1;
		$sentence2 = $subject.$modifier2.$np2.$follows_coordination;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
		@simpler_sentences[0] = "{CMN1-140a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-140a} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	} 
	elsif($precedes_rightmost_coordinator =~ /(($any_kind_of_adverb|$comma|\s)*)(($any_kind_of_noun|$any_kind_of_possessive|$comma|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = " ".$7.$16.$20;
	    
	    print STDERR "24>>>>>>>>>>>>>>>>\n";

	    print STDERR "\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$comma|$any_kind_of_determiner|$any_kind_of_prep|\s)*)($any_kind_of_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
#		print STDERR ">>>>>>>>>>>>>>>>>>>>\n";exit;


	    
#		print STDERR "HHHHHHHHHHHHH $prep ### $np1\n\t>>> $follows_rightmost_coordinator\n\tS1 $sentence1\n";

		$sentence1 = $subject.$np1;
		$sentence2 = $subject.$np2.$follows_coordination;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	    
		@simpler_sentences[0] = "{CMN1-141a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-141a} ".$sentence2.$final_punctuation;
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }





# # # # # # # # # # # # # # ## semicolon-and # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />\;\s+and</i){
	print STDERR "PROCESSING $&\t$sentence\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	
	
	my $this_verb;
	my $objects_of_verb;
	
	if($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
	    $subject = $PREMATCH;
	    $objects_of_verb = $POSTMATCH;
	    $this_verb = $&;
	    
	    print STDERR "SUBJ $subject\n";

	    print STDERR "25>>>>>>>>>>>>>>>>\n";
	    
	}
	while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
	    $follows_coordination = " ".$&.$POSTMATCH;
	}


	print STDERR "FC $follows_coordination\n";
	$sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
	$sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
    
    
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CMN1-142a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CMN1-142b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }



# # # # # # # # # # # # # # # # # commas # # # # # # # # # # # # # # # # # # #
    elsif($potential_coordinator =~ />(\,|\;)</){
	print STDERR "PROCESSING $&\t$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";
# First identify verb,
	my $sentence1;
	my $sentence2;
	my $subject;

	my $follows_coordination;
	my $this_verb;
	my $objects_of_verb;
	

	if($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_modal)(($vb_verb|$any_kind_of_adverb|\s)*)$/){
	    $subject = $PREMATCH.$1.$4;
	    $np1 = $4.$5.$7.$8.$12.$13.$15.$16.$18;
	    
	    print STDERR "95>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_pc|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$12." ";
		$follows_coordination = $16.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-143a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-143b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_number)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($to)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$7.$8.$13.$17.$18.$19.$20.$23.$24.$28." ";
	    
	    print STDERR "52>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$5.$6.$7.$8.$11.$12;
		$follows_coordination = $16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-144a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-144b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(($any_kind_of_possPron|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)(\s*)$/){
	    $np1 = $3.$6.$7.$11.$12." ";
	    $subject = $PREMATCH.$1;
#	    print STDERR "GOTCHA $np1\n";
	    
	    print STDERR "56>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_possPron|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_adverb)((\s|$any_kind_of_sentence_boundary)*)$/){# \s*$/){
		$np2 = $1.$2.$5.$6.$10.$11.$13.$14;
		$follows_coordination = $17.$POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "\[$np2\]\n";exit;		

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-145a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-145b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_possPron|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)((\s|$any_kind_of_sentence_boundary)*)$/){# \s*$/){
		$np2 = $1.$2.$5.$6.$10.$11;
		$follows_coordination = $13.$POSTMATCH;
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "\[$np2\]\n";exit;		

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-146a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-146b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_number)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($to)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$7.$8.$13.$17.$18.$19.$20.$22.$23.$27." ";
	    
	    print STDERR "52>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)((.|\s)*?)($wh_word)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$13.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-147a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-147b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$13.$17.$18.$22;
		$follows_coordination = $24.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-148a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-148b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$7.$8.$10.$11." ";
		$follows_coordination = $15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-149a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-149b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_possPron|$any_kind_of_adj1|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$8.$9.$15." ";
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-150a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-150b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($any_kind_of_number)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $2.$3.$6.$7.$12.$16;
	    
	    print STDERR "75>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$10.$11.$13;
		$follows_coordination = $15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-151a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-151b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$11;
		$follows_coordination = $15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-152a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-152b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$10.$14.$15.$17;
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-153a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-153b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($to)(\s*)($nnp_noun)(\s*)$/){
	    $np1 = $2.$3.$7." ";
	    $subject = $PREMATCH.$1.$2;
#	    print STDERR ">>>>>>>>>>>>>>>> $np1\n";exit;

	    print STDERR "108>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$7." ";
		$follows_coordination = $11.$12.$POSTMATCH;
		
#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
# Note error caused by lack of pronoun resolution in: 
# {CMA-1b} {CMN1-9b} A FORMER double glazing salesman described as 'evil beyond
# belief' was jailed for life yesterday for the double murders of her mother.
	    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-154a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-154b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($nnp_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$4.$5.$9.$10.$11.$12.$16;
		$follows_coordination = $16.$17.$POSTMATCH;


		print STDERR "\[$np2\]\n";


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
			    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-155a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-155b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_subordinator)(\s*)($any_kind_of_pron)(\s*)$/){
	    $np1 = $4.$5.$7." ";
	    $subject = $PREMATCH.$1;

	    print STDERR "91>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$8.$12;
		$follows_coordination = $13.$15.$16.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-156a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-156b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$8.$12;
		$follows_coordination = $13.$15.$16.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-157a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-157b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$8.$9.$10.$11.$13.$14.$18." ";
	    
	    print STDERR "51>>>>>>>>>>>>>>>>\[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$13.$17.$18.$22;
		$follows_coordination = $24.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-158a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-158b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)((.|\s)*?)($wh_word)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$13.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-159a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-159b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_possPron|$any_kind_of_adj1|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$8.$9.$15." ";
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-160a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-160b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($of)(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)(($to|$vb_verb|$any_kind_of_noun|\s)*)$/){
	    $np1 = $2.$3.$5.$6.$8.$9.$13.$14.$16.$17.$21.$22." ";
	    $subject = $PREMATCH.$1.$2;

	    print STDERR "109>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(($any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$7.$11.$12.$13." ";
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-161a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-161b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $1.$2.$4.$5.$7.$8.$12.$13.$15.$16;
		$follows_coordination = $22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-162a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-162b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($of)(\s*)($vbg_verb)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($to)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$2;
	    $np1 = $2.$3.$5.$6.$14.$18.$19.$20.$21.$25." ";
	    
	    print STDERR "45>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($to)(\s*)($vb_verb)((.|\s)*?)($any_kind_of_pc)(\s*)($vbg_verb)/g){
		$np2 = $1.$2.$4.$5.$6.$7.$9;
		$follows_coordination = $11.$15.$16.$POSTMATCH;

#		print STDERR " \[$np2\]\n\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-163a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-163b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}


	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|\s)*)(\s*)$/){
	    $subject = $PREMATCH.$1." ";
	    $np1 = $3.$4.$6.$7.$12.$15.$19." ";
	    
	    print STDERR "57>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($to)/g){
		$np2 = $1.$2.$10.$14;
		$follows_coordination = $15.$POSTMATCH;

#		print STDERR " \[$np2\]\n\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-164a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-164b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(($any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$11.$15.$16.$17;
		$follows_coordination = $22.$POSTMATCH;

#		print STDERR "NP2 \[$np2\]\n\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-165a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-165b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbn_verb)/g){
		$np2 = $1.$2.$11.$15;
		$follows_coordination = $15.$16.$19.$20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-166a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-166b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $np1 = $3.$4.$7.$8.$16.$20." ";
	    
	    print STDERR "46>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($to)/g){
		$np2 = $1.$2.$12;
		$follows_coordination = $16.$17.$POSTMATCH;

		print STDERR " \[$np2\]\nF\[$follows_coordination\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-167a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-167b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

#	elsif($precedes_rightmost_coordinator =~ /($vbg_verb)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	elsif($precedes_rightmost_coordinator =~ /($including|$involving)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $2.$3.$12." ";
	    my $inIng_word = $1; 	    

	    print STDERR "31>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-168a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-168b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($whose)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($vbd_verb)(($any_kind_of_number|$any_kind_of_possessive|$any_kind_of_prep|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$10.$14.$17.$18.$19.$20.$28.$30.$31.$40.$44." ";
		$follows_coordination = $45.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-169a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-169b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)/g){
		$np2 = $1.$8.$12;
		$follows_coordination = $13." ".$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-170a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-170b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)/g){
		$np2 = $1.$8;
		$follows_coordination = $12." ".$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-171a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-171b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)/g){
		$np2 = $1.$2.$7.$11.$12.$13.$14;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-172a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-172b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;


		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;


#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-173a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-173b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2;
		$follows_coordination = $6.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-174a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-174b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)/g){
		$np2 = $1.$2;
		$follows_coordination = $6.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-175a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-175b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_prep|$any_kind_of_noun|\s)*)($comma)/g){
		$np2 = $1.$2.$4.$5.$9.$10;
		$follows_coordination = $16.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-176a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-176b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_adverb|\s)*)($vbg_verb)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$4;
	    $np1 = $4.$5.$9.$11.$12.$14.$21.$25;
	    
	    print STDERR "76>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$10.$14;
		$follows_coordination = $15.$POSTMATCH;
		
#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-177a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-177b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($quotes|\s)*)($comma)/){
		$np2 = $1.$10.$14;
		$follows_coordination = $15.$POSTMATCH;
		
#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-178a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-178b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    
	}

	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)($vbg_verb)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun|$vbg_verb)(\s*)$/){
	    $subject = $PREMATCH.$1.$4.$6;
	    $np1 = $8.$10.$19.$25;

	    print STDERR "74>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(($vbg_verb|$any_kind_of_pc|$to|\s)*)((.|\s)*?)($to)((.|\s)*?)($comma)(\s*)($vbg_verb)/g){
		$np2 = $1.$2.$4.$10.$12.$13;
		$follows_coordination = $15.$18.$19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-179a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-179b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($precedes_rightmost_coordinator =~ /($vbg_verb)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$13." ";
	    
	    print STDERR "77>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$10.$14;
		$follows_coordination = $14.$15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-180a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-180b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$vbd_verb|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$11.$15;
		$follows_coordination = $15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-181a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-181b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}



	elsif($precedes_rightmost_coordinator =~ /($subordinating_that)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*?)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$5.$7.$8.$16.$20;
	    $subject = $PREMATCH.$1;

	    print STDERR "96>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|\s)*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($pound)($nnp_noun)\,($nnp_noun)/){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-182a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-182b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/){
		$np2 = $1.$2.$6.$7;
		$follows_coordination = $11.$12.$POSTMATCH;
		
		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-183a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-183b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    

	}	
	elsif($precedes_rightmost_coordinator =~ /($subordinating_that)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*?)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$13.$17." ";
	    $subject = $PREMATCH.$1;

	    print STDERR "61>>>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/){
		$np2 = $1.$10.$14;
		$follows_coordination = $15.$POSTMATCH;
		
#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
#
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-184a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-184b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    
	}


	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_number)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$10.$11.$19.$23." ";
	    
	    print STDERR "48>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$13.$17.$18.$22;
		$follows_coordination = $24.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-185a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-185b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$10.$14.$15;
		$follows_coordination = $22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-186a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-186b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$13;
		$follows_coordination = $17.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-187a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-187b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$10.$14.$15.$17;
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-188a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-188b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_pc|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$12." ";
		$follows_coordination = $16.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-189a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-189b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)/g){
		$np2 = $1.$2.$7.$11;
		$follows_coordination = $12.$14.$15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence2 =~ /hamnever/){
		    print STDERR "insert whitespace here\n";exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-190a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-190b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$6.$7.$11." ";
		$follows_coordination = $12.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-191a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-191b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$6." ";
		$follows_coordination = $6.$7.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-192a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-192b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^((.|\s)*?)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$3.$7;
		$follows_coordination = $8.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-193a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-193b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /\}(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH."}".$1;
	    $np1 = $1.$2.$4.$12.$16." ";
	    
	    print STDERR "85>>>>>>>>>>>>>>>>\[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|\s)*)($vbp_verb)/g){
		$np2 = $1.$7.$11;
		$follows_coordination = $17.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-194a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-194b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(($pound|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH;
	    $np1 = $&;
	    
	    print STDERR "26>>>>>>>>>>>>>>>>\[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$13.$17.$18.$22;
		$follows_coordination = $24.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-195a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-195b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-196a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-196b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)((.|\s)*?)($wh_word)(\s*)($vbd_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9.$13.$14.$16;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-197a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-197b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$5.$6.$7.$8.$11.$18;
		$follows_coordination = $22.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-198a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-198b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($vbg_verb)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4;
		$follows_coordination = $22.$POSTMATCH;

		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-199a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-199b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pron)/g){
		$np2 = $1.$2.$4.$11.$12.$16;
		$follows_coordination = $16.$17.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-200a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-200b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_adj1)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$9.$10.$15." ";
	    
	    print STDERR "28>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $10.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence2 =~ /hamnever/){
		    print STDERR "insert whitespace here\n";exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-201a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-201b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
       
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)($comma)(\s*)($whose)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($vbd_verb)(($any_kind_of_number|$any_kind_of_possessive|$any_kind_of_prep|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$10.$14.$17.$18.$19.$20.$28.$30.$31.$40.$44;
		$follows_coordination = $45.$POSTMATCH;

#		print STDERR "\[$np2\]";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-202a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-202b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-203a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-203b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)/g){
		$np2 = $1.$8.$12;
		$follows_coordination = $13." ".$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-204a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-204b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|\s)*)($vbp_verb)/g){
		$np2 = $1.$7.$11;
		$follows_coordination = $17.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-205a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-205b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $7.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-206a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-206b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($plural_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2;
		$follows_coordination = $6.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-207a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-207b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun\s+)+?)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$10.$12.$13." ";
	    
	    print STDERR "30>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $12.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /hamnever/){
		    print STDERR "insert whitespace here\n";exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-208a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-208b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1\s+|$any_kind_of_noun\s+)+?)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$10.$11." ";
		$follows_coordination = $16.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-209a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-209b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $7.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-210a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-210b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$7.$8.$15.$16.$20." ";
	    
	    print STDERR "65>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$8.$12.$13;
		$follows_coordination = $20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-211a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-211b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun\s+)+?)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5.$10.$15." ";
	    
	    print STDERR "29>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $10.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence2 =~ /hamnever/){
		    print STDERR "insert whitespace here\n";exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-212a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-212b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$7.$11;
		$follows_coordination = $12.$15.$16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-213a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-213b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)($comma)((.|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$4.$5.$9.$12.$14;
		$follows_coordination = $17.$18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-214a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-214b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $10.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-215a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-215b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^((.|\s)*)($vbd_verb)/g){
		$np2 = $1;
		$follows_coordination = $3.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

		print STDERR "S1 $sentence1\nS2 $sentence2\n";		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-216a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-216b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbp_verb)(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $np1 = $3.$4.$10.$18.$22." ";
	    
	    print STDERR "66>>>>>>>>>>>>>>>>\[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$5.$6.$10;
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]\n"; exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-217a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-217b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$6.$8.$12.$16;
		$follows_coordination = $20.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-218a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-218b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($any_kind_of_number|$vbn_verb)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$4;
	    $np1 = $4.$5.$9.$10.$14." ";
	    
#	    print STDERR "63>>>>>>>>>>>>>>>>\[$np1\]\n";exit;


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbd_verb)/){
		$np2 = $1.$2.$5.$6.$10;
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-219a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-219b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_possPron|$any_kind_of_determiner|\s)*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$6.$8.$12.$16;
		$follows_coordination = $20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-220a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-220b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
#	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
#	    $subject = $PREMATCH.$1.$4;
#	    $np1 = $4.$5.$10.$14.$15.$18.$19.$22." ";
	    
#	    print STDERR "69>>>>>>>>>>>>>>>> \[$np1\]\n";

#	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)((\s|$any_kind_of_sentence_boundary)*)$/){
#		$np2 = $1.$6.$10.$11.$14.$15;
#		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

#		$sentence1 = $subject.$np1.$follows_coordination;
#		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
#		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
#		    $final_punctuation = "";
#		}
#		@simpler_sentences[0] = "{CMN1-53a} ".$sentence1.$final_punctuation;
#		@simpler_sentences[1] = "{CMN1-53b} ".$sentence2;
		
#		$simpler_sentences_ref = \@simpler_sentences;
#		return($simpler_sentences_ref);
#	    }
#	}
	elsif($precedes_rightmost_coordinator =~ /($comma|$semicolon)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $6.$7.$11." ";
	    
	    print STDERR "37>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $10.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-221a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-221b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1|$any_kind_of_noun)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_sentence_boundary)/g){
		$np2 = $1.$2.$10.$14." ";
		$follows_coordination = $14.$15.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-222a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-222b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$6.$7." ";
		$follows_coordination = $12.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-223a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-223b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_noun)/g){
		$np2 = $1.$2.$7.$11.$12.$13.$14;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-224a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-224b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $7.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-225a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-225b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$7.$11;
		$follows_coordination = $12.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-226a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-226b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2;
		$follows_coordination = $6.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-227a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-227b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $6.$7.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-228a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-228b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_noun)(\s*)(($any_kind_of_sentence_boundary|\s)*)/g){
		$np2 = $1.$2.$4.$5.$9;
		$follows_coordination = $9.$10.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-229a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-229b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(($vbn_verb|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)/g){
		$np2 = $1.$2.$4.$7." ";
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-230a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-230b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$6.$7.$11." ";
		$follows_coordination = $12.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-231a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-231b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($vbp_verb)/g){
		$np2 = $1.$2.$6." ";
		$follows_coordination = $6.$7.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-232a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-232b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)(($pound|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$6.$7.$11.$12." ";
	    
	    print STDERR "32>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_prep|$any_kind_of_adverb)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-233a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-233b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($pound)/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-234a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-234b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(\s*)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
#	    $np1 = $3.$4.$6.$7.$15.$16." ";
	    $np1 = $3.$4.$6.$7.$15.$16;
	    
	    print STDERR "35>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$6;
		$follows_coordination = $10.$11.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-235a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-235b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$6;
		$follows_coordination = $10.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-236a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-236b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$10.$14;
		$follows_coordination = $14.$15.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-237a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-237b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron|$vbn_verb)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$7.$8." ";
	    
#	    print STDERR "38>>>>>>>>>>>>>>>> \[$np1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_prep|$any_kind_of_adverb)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-238a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-238b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }       
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbn_verb)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$4.$5.$9.$10.$12;
		$follows_coordination = $13.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-239a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-239b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$6;
		$follows_coordination = $7.$POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-240a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-240b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)($to)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$8.$9.$10.$11.$13.$14.$18.$19.$21.$26." ";
	    
	    print STDERR "41>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_prep|$any_kind_of_adverb)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-241a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-241b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)((.|\s)*?)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $1.$2.$6.$7.$9;
		$follows_coordination = $11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-242a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-242b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($of)(\s*)($quotes)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$2.$3;
	    $np1 = $6.$15.$19;
	    
	    print STDERR "104>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)(($of|$any_kind_of_noun|\s)*)($quotes)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$11.$15.$16;
		$follows_coordination = $21.$24.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-243a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-243b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($hyphen)(\s*)($quotes)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3.$4;
	    $np1 = $7.$16.$20." ";
	    
	    print STDERR "101>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)(($of|$any_kind_of_noun|\s)*)($quotes)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$11.$15.$16;
		$follows_coordination = $21.$24.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-244a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-244b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)(($of|$any_kind_of_noun|\s)*)($any_kind_of_sentence_boundary)(\s*)($quotes)(\s*)$/g){
		$np2 = $1.$2.$11.$15.$16;
		$follows_coordination = $21.$24.$25.$28.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-245a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-245b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($hyphen)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $np1 = $3.$4.$13.$17." ";
	    
	    print STDERR "64>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($of|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)(($quotes|\s)*)$/g){
		$np2 = $1.$2.$8.$12;
		$follows_coordination = $18.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-246a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-246b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$8.$12.$13;
		$follows_coordination = $20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-247a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-247b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$4.$5.$10;
		$follows_coordination = $14.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-248a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-248b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$5.$6;
		$follows_coordination = $10.$11.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-249a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-249b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$13." ";
	    
	    print STDERR "50>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_number|$hyphen|$any_kind_of_possPron|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$14;
		$follows_coordination = $25.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-250a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-250b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adverb|\s)*)(($any_kind_of_noun|$vbg_verb|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($quotes|\s|$comma)+)/g){
		$np2 = $1.$2.$6.$15;
		$follows_coordination = $19.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-251a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-251b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(($of|$any_kind_of_determiner|$any_kind_of_noun|\s)*)($comma)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$8.$12;
		$follows_coordination = $18.$21.$22.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-252a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-252b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$2.$7.$11." ";
		$follows_coordination = $11.$12.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-253a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-253b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$7.$11." ";
		$follows_coordination = $11.$12.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-254a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-254b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_prep)(\s*)(($any_kind_of_prep|$any_kind_of_noun|$any_kind_of_determiner|\s)*)($of)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_pc)/g){
		$np2 = $1.$2.$4.$5.$10.$12.$13.$20.$21.$22.$24.$25.$29." ";
		$follows_coordination = $30.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-255a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-255b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_rp)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$13.$14." ";
		$follows_coordination = $18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-256a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-256b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/g){
		$np2 = $1.$2.$8." ";
		$follows_coordination = $12.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-257a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-257b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

#	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)(\s*)$/){
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
#	    $np1 = $3.$4.$8.$9." ";
	    $np1 = $3.$4.$13.$14." ";
	    
	    print STDERR "87>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($in)/g){
		$np2 = $1.$2.$12.$16.$17.$19;
		$follows_coordination = $25.$POSTMATCH;

		print STDERR " \[$np2\]\nF\[$follows_coordination\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-258a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-258b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($to)/g){
		$np2 = $1.$2.$12;
		$follows_coordination = $16.$17.$POSTMATCH;

#		print STDERR " \[$np2\]\nF\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-259a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-259b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $2.$7.$11.$12.$15.$16;
		$follows_coordination = $19.$20.$POSTMATCH;

#		print STDERR "NP2\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-260a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-260b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $2.$7.$11.$12.$15.$16;
		$follows_coordination = $19.$20.$POSTMATCH;

#		print STDERR "NP2\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-261a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-261b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
# THE FOLLOWING CONDITION CAUSES RECURSION BETWEEN PATTERNS 87>>> AND 68>>> 
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $1.$2." ";
		$follows_coordination = $6.$POSTMATCH;

#		print STDERR "NP2\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-262a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-262b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)((\s|$any_kind_of_adj1)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $1.$2.$5.$10;
		$follows_coordination = $14.$POSTMATCH;

#		print STDERR "NP2\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-263a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-263b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $np1 = $3.$4.$8.$9." ";
	    
	    print STDERR "90>>>>>>>>>>>>>>>> \[$np1\]\n";


	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($to)/g){
		$np2 = $1.$2.$12.$16;
		$follows_coordination = $16.$17.$POSTMATCH;

#		print STDERR " \[$np2\]\nF\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-264a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-264b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_rightmost_coordinator =~ /($vbn_verb)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$8.$12." ";

	    print STDERR "103>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($in)/g){
		$np2 = $1.$2.$12.$16.$17.$19;
		$follows_coordination = $25.$POSTMATCH;

#		print STDERR " \[$np2\]\nF\[$follows_coordination\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-265a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-265b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

#	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)(($any_kind_of_noun|\s|$comma|$any_kind_of_number|$any_kind_of_adj1)+)($any_kind_of_noun)(($comma|\s*|$any_kind_of_number)*)((\s|$any_kind_of_sentence_boundary)*)$/){

#HERE


	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $4.$5;
	    
	    print STDERR "68>>>>>>>>>>>>>>>> \[$np1\]\n";

# SUBJ $subject\nFOLLOWS $follows_rightmost_coordinator\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $2.$7.$11.$12.$15.$16;
		$follows_coordination = $19.$20.$POSTMATCH;

		print STDERR "NP2\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-266a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-266b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($to)(\s*)($vb_verb)/){
		$np2 = $1.$2.$7.$11;
		$follows_coordination = $11.$12.$13.$14.$POSTMATCH;

#		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-267a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-267b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
		$np2 = $1.$2.$12;
		$follows_coordination = $16.$POSTMATCH;

		print STDERR "HHHHH\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-268a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-268b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /^\{((.|\s)*)\}(\s*)($any_kind_of_noun)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH."\{".$1."\}".$3;
	    $np1 = $3.$4.$8.$9.$13." ";
	    
	    print STDERR "112>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)($any_kind_of_determiner)(\s*)($vbd_verb)/g){
		$np2 = $1.$7.$11.$12.$16.$17.$19.$20.$22.$26." ";
		$follows_coordination = $26.$27.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-269a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-269b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)($vbd_verb)/g){
		$np2 = $1.$7.$11.$12.$16.$17.$19.$20.$22;
		$follows_coordination = $24.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-270a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-270b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$10.$14;
		$follows_coordination = $14.$15.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-271a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-271b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

# COMPLEX NP COORDINATION
	elsif($precedes_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($comma)(($any_kind_of_pc|$any_kind_of_noun|\s)*)(\s*)($comma)(($any_kind_of_determiner|$any_kind_of_prep|$any_kind_of_noun|$comma|\s)*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4.$7.$8.$13.$17.$18.$19.$20.$23.$24.$28." ";
	    
	    print STDERR "78>>>>>>>>>>>>>>>>\[$np1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($to)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(\s*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/){
		$np2 = $1.$2.$5.$6.$7.$8.$11.$12;
		$follows_coordination = $16.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-272a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-272b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($whose)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $2.$3.$7." ";
	    
	    print STDERR "98>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)/g){
		$np2 = $1.$6.$10;
		$follows_coordination = $10.$11.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-273a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-273b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_pron)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    $np1 = $3.$4." ";
	    
	    print STDERR "86>>>>>>>>>>>>>>>> \[$np1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_possPron)(($any_kind_of_number|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)((\s|$any_kind_of_sentence_boundary)*)$/g){
		$np2 = $&;
		$follows_coordination = $POSTMATCH;

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-274a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-274b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comma)(\s*)($vbg_verb)(($any_kind_of_determiner|$any_kind_of_number|$hyphen|$any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    $np1 = $4.$5.$7.$19.$23;
	    $subject = $PREMATCH.$1;

	    print STDERR "105>>>>>>>>>>>>>>>>\[$np1\]\n";
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($vbg_verb)(\s*)($any_kind_of_rp)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($comma)/g){
		$np2 = $1.$2.$4.$5.$7.$8.$10.$11.$13.$14." ";
		$follows_coordination = $18.$19.$POSTMATCH;

		print STDERR "\[$np2\]\n";

		$sentence1 = $subject.$np1.$follows_coordination;
		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN1-275a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN1-275b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}


#	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
#	    $subject = $PREMATCH.$1.$3;
#	    $np1 = $3.$4.$9.$13." ";
	    
#	    print STDERR "67>>>>>>>>>>>>>>>> \[$np1\]\n SUBJ $subject\nFOLLOWS $follows_rightmost_coordinator\n";exit;

#	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)($comma|$any_kind_of_sentence_boundary)/){
#		$np2 = $2.$7.$11.$12.$15.$16.$19;
#		$follows_coordination = $19.$20.$POSTMATCH;

#		print STDERR "\[$np2\]\n";exit;

#		$sentence1 = $subject.$np1.$follows_coordination;
#		$sentence2 = $subject.$np2.$follows_coordination;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;		
		
#		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
#		    $final_punctuation = "";
#		}
#		@simpler_sentences[0] = "{CMN1-53a} ".$sentence1.$final_punctuation;
#		@simpler_sentences[1] = "{CMN1-53b} ".$sentence2;
		
#		$simpler_sentences_ref = \@simpler_sentences;
#		return($simpler_sentences_ref);
#	    }
#	}


#	if($precedes_rightmost_coordinator =~ /$any_kind_of_verb/){
#	    $subject = $PREMATCH;
#	    $objects_of_verb = $POSTMATCH;
#	    $this_verb = $&;
#	    
#	    print STDERR "26>>>>>>>>>>>>>>>>\n";

#	    print STDERR "SUBJ $subject\n";
#
#	    while($follows_rightmost_coordinator =~ /$any_kind_of_verb/g){
#		$follows_coordination = " ".$&.$POSTMATCH;
#	    }
#	    $sentence1 = $subject.$this_verb.$objects_of_verb.$follows_coordination;
#	    $sentence2 = $subject.$this_verb.$follows_rightmost_coordinator;
#	    
#	    
#	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
#		$final_punctuation = "";
#	    }
#	    @simpler_sentences[0] = "{CMN1-5a} ".$sentence1.$final_punctuation;
#	    @simpler_sentences[1] = "{CMN1-5b} ".$sentence2;
#	    
#	    $simpler_sentences_ref = \@simpler_sentences;
#	    return($simpler_sentences_ref);
#	}
	

    }



    open(ERROR_FILE, ">>./CMN1_errors.txt");
    print ERROR_FILE "$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";
    close(ERROR_FILE);

    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "CMN1 NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
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
    
#    print STDERR "$potential_subordinator\n";exit;
    
    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = "";
    }
    
    @simpler_sentences[0] = "{CMN1-276a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);

}
1;
