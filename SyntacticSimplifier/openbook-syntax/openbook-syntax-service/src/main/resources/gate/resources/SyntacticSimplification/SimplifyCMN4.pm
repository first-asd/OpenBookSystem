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
package SimplifyCMN4;
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
my $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB|RBS)\">([^<]+)<\/w>";
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

#    print STDERR "SIMPLIFYING ######### $sentence\n";
    print STDERR "\[CMN4\]\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";


    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


################################### CMN4 #######################################
# Conjunctions
    if($potential_coordinator =~ />(and|or)</){
#	print STDERR "PROCESSING or-CMN4\t$sentence\n"; exit;
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;


	my $this_verb;
	my $objects_of_verb;

	if($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_adj1)(\s*)$/){
	    $subject = $PREMATCH;
	    my $this_determiner = $1;
	    my $space1 = $3;
	    my $adj1 = $4;
	    my $space2 = $8;
	    my $np1 = $this_determiner.$space1.$adj1.$space2;
	    


	    if($follows_rightmost_coordinator =~ /\Q$this_determiner\E(\s+)(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(\s+)($any_kind_of_noun)/){
		$follows_coordination = $POSTMATCH;
		my $space1 = $1;
		my $adj2 = $2." ".$6." ".$10;
		my $space2 = $10;
		my $head_noun = $11;
		


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
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)(($any_kind_of_noun|\s)*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_prep|$any_kind_of_possPron|\s)*)$/){
	    $subject = $PREMATCH;
	    my $this_determiner = $1;
	    my $space1 = $3;
	    my $nbar1 = $4;
	    my $preposition = $9;
	    my $pp1_arg = $11;

	    $np1 = $&;
	    
#	    print STDERR "\[$this_determiner\] \[$space1\] \[$nbar1\] \[$preposition\] \[$pp1_arg\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_prep|$any_kind_of_possPron|\s)*)/){
		$follows_coordination = $POSTMATCH;
		my $space1 = $1;
		my $number1 = $2;
		my $space2 = $5;
		my $preposition2 = $6;
		my $space3 = $8;
		my $pp2_arg = $9;

		$np2 = $space1.$number1.$space2.$nbar1.$space2.$preposition2.$space3.$pp2_arg;

#		print STDERR "\[$space1\] \[$number1\] \[$space2\] \[$preposition2\] \[$space3\] \[$pp2_arg\]\n";

		my $adj2 = $2." ".$6." ".$10;
		my $space2 = $10;
		my $head_noun = $11;
		
		
		my $sentence1 = $subject.$np1.$follows_coordination;
		my $sentence2 = $subject.$np2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN4-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)/){
	    print STDERR "888888888888888\n";
	    $subject = $PREMATCH;
	    my $number1 = $1;
	    my $space1 = $4;
	    my $noun1 = $5;
	    my $space2 = $9;
	    my $of1 = $10;
	    my $space3 = $11;
	    my $argument1 = $POSTMATCH;

	    $sentence1 = $subject.$&.$argument1;

#	    print STDERR "\[$number1\] \[$space1\] \[$noun1\] \[$space2\] \[$of1\] \[$space3\] \[$argument1\]\n";exit;

	    if($follows_rightmost_coordinator =~ /(\s*)($any_kind_of_number)(\s*)($of)/){
		my $space4 = $1;
		my $number2 = $2;
		my $space5 = $5;


		$sentence2 = $subject.$space4.$number2.$space5.$noun1.$space5.$of1." ".$POSTMATCH;

#		print STDERR "\[$number1\] \[$space1\] \[$noun1\] \[$space2\] \[$of1\] \[$space3\] \[$argument1\]\n\[$space4\] \[$number2\] \[$space5\]\nS1 $sentence1\nS2 $sentence2\n";exit;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN4-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }

	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
	    $subject = $PREMATCH.$1;
	    my $determiner1 = $3.$4.$8;
	    my $preposition = $1;

	    if($preposition =~ /between/){
		my $substitute_potential_coordinator = $potential_coordinator;
		$substitute_potential_coordinator =~ s/<([^>]+)>//g;
		$sentence1 = $precedes_rightmost_coordinator.$substitute_potential_coordinator.$follows_rightmost_coordinator;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN4-4a} ".$sentence1.$final_punctuation;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

#	    print STDERR "FRC $follows_rightmost_coordinator\n\[$determiner1\]\n";exit;
	    
	    
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
		@simpler_sentences[0] = "{CMN4-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)/){
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
		@simpler_sentences[0] = "{CMN4-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-6b} ".$sentence2;
		
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
		@simpler_sentences[0] = "{CMN4-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-7b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
    }
###############################################################################
 # # # # # # # # comma-conjunction
    elsif($potential_coordinator =~ />\,\s+and</i){
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
	

	my $this_verb;
	my $objects_of_verb;


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
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN4-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-8b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	
    }
############################
# Punctuation
    elsif($potential_coordinator =~ />(\,)</){
#	print STDERR "PROCESSING or-CMN4\t$sentence\n"; exit;
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $np1;
	my $np2;


	my $this_verb;
	my $objects_of_verb;

	if($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_adj1)(\s*)$/){
	    $subject = $PREMATCH;
	    my $this_determiner = $1;
	    my $space1 = $3;
	    my $adj1 = $4;
	    my $space2 = " ";
	    my $np1 = $this_determiner.$space1.$adj1.$space2;



	    if($follows_rightmost_coordinator =~ /\Q$this_determiner\E(\s+)(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(\s+)($any_kind_of_noun)/){
		$follows_coordination = $POSTMATCH;
		my $space1 = $1;
		my $adj2 = $2.$6.$10;
		my $space2 = $10;
		my $head_noun = $11;
		


		$np1 .= $head_noun;
		$np2 = $this_determiner.$space1.$adj2.$space2.$head_noun;


		
		my $sentence1 = $subject.$np1.$follows_coordination;
		my $sentence2 = $subject.$np2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CMN4-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CMN4-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
    
    
    print STDERR "CMN4 NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
