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
package SimplifyCMAdv;
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
my $reflexive = "<w c\=\"w\" p\=\"PRP\">([^<]+?)(self|selves)<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

    my $adverbial1;
    my $adverbial2;
    my $follows_coordination;
    my $subject;
    my $sentence1;
    my $sentence2;

################################### CMAdv ################################################################# Punctuation-conjunctions
    if($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMAdv\">(\,)(\s+)(and|or)<\/PC>/i){
	print STDERR "PROCESSING and-CMAdv\t$sentence\n";


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
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMAdv-1a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)/){
		print STDERR "IIIIIIIIIIIIIII\n";

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;


		print STDERR "ADVP2 $adverbial2\n";

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMAdv-2a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}
    }

############################# Conjunctions
    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMAdv\">(and|or)<\/PC>/i){
	print STDERR "PROCESSING and-CMAdv\t$sentence\n";
	my $adverbial1;
	my $adverbial2;
	my $follows_coordination;
	my $subject;
	my $sentence1;
	my $sentence2;

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
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMAdv-3a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}
	elsif($precedes_rightmost_coordinator =~ /(\s*)($reflexive)(\s*)$/){
	    $adverbial1 = $&;
	    $subject = $PREMATCH;
	    print STDERR "AAAAAAAAAAAAAAAAAAAAa\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_prep)(($base_np|$any_kind_of_prep|\s)*)($any_kind_of_sentence_boundary)/){
		$follows_coordination = $19.$POSTMATCH;
		$adverbial2 = $1.$2.$4;

		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CMAdv-4a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($any_kind_of_prep)(\s*)($base_np)(\s*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)(\s*)($base_np)(\s*)/){
		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;

#		print STDERR ">>>>>>>>>>>>>>>\n";exit;

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		@simpler_sentences[0] = "{CMAdv-5a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($base_np)/){
		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		@simpler_sentences[0] = "{CMAdv-6a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($base_np)(\s*)$/){
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

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		}
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		
		@simpler_sentences[0] = "{CMAdv-7a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}

	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)((.|\s)*)$/){
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
		
		
		@simpler_sentences[0] = "{CMAdv-8a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-8b} ".$sentence2;
		
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
		
		
		@simpler_sentences[0] = "{CMAdv-9a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-9b} ".$sentence2;
		
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

		@simpler_sentences[0] = "{CMAdv-10a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-10b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
    }
######################### Punctuation

    elsif($potential_coordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMAdv\">(\,)<\/PC>/i){

	if($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $subject = $PREMATCH;
	    $adverbial1 = $&;

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)/){
		print STDERR "IIIIIIIIIIIIIII\n";

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;


		print STDERR "ADVP2 $adverbial2\n";

             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMAdv-11a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)/){
		print STDERR "IIIIIIIIIIIIIII\n";

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;

#		print STDERR "ADVP2 $adverbial2\n";
             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMAdv-12a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }


#	    print STDERR "SUBJ $subject\n";exit;
	}
	elsif($precedes_rightmost_coordinator =~ /(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
#	    print STDERR ">>>>>>>>>>>>>>>>>>\n";exit;
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adverb|$any_kind_of_number|\s)+)(\s)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)/){
		print STDERR "IIIIIIIIIIIIIII\n";

		$adverbial2 = $&;
		$follows_coordination = $POSTMATCH;

#		print STDERR "ADVP2 $adverbial2\n";
             
		$sentence1 = $subject.$adverbial1.$follows_coordination;
		$sentence2 = $subject.$adverbial2.$follows_coordination;
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CMAdv-13a} ".$sentence1;
		@simpler_sentences[1] = "{CMAdv-13b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }

	}
    }



    print STDERR "CMAdv NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
