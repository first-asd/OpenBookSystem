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
package SimplifyCIN;
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
my $nnp_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNP|NNPS)\">([^<]+)<\/w>";
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

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


################################### CIN #######################################
# # # # # # # # # # and/or
    if($potential_coordinator =~ />(and|or)</i){
# DT _ CIN _ NN _

	my $follows_coordination;
	my $nbar1;
	my $nbar2;
	my $precedes_coordination;
	my $this_determiner;
	my $subject;
	my $sentence1;
	my $sentence2;
	print STDERR "PROCESSING CIN\n\t$sentence\n";# exit;

	$this_determiner = $&;
	
	$follows_coordination;
	
	
	if($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_noun)(\s*)$/){
	    my $det = $1;
	    $nbar1 = $3.$4.$8;
	    $subject = $PREMATCH.$det;
	    


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adj1)(\s+)($any_kind_of_noun)/){
		my $follows_coordination = $POSTMATCH;
		my $nbar2 = $&;
		
		$sentence1 = $subject.$nbar1.$follows_coordination;
		$sentence2 =  $subject.$nbar2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CIN-1a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
#		print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s*)(($nnp_noun|\s)*)(\s+)($any_kind_of_noun)/){
		my $follows_coordination = $7.$8.$POSTMATCH;
		my $nbar2 = $1.$2;

		print STDERR ">>>>>>>>>>>>>>\n";
		
		$sentence1 = $subject.$nbar1.$follows_coordination;
		$sentence2 =  $subject.$nbar2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CIN-2a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
#		print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
	    }
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_number)(\s+)($plural_noun)(\s*)$/){
	    my $det = $1;
	    my $cd1 = $4;
	    my $space1 = $7;
	    my $nns1 = $8;
	    my $space2 = $10;
	    $nbar1 = $cd1.$space1.$nns1.$space2;
	    $subject = $PREMATCH.$det;


	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_number)(\s+)($plural_noun)/){
		my $space1 = $1;
		my $cd2 = $2;
		my $space2 = $5;
		my $nns2 = $6;
		my $follows_coordination = $POSTMATCH;
		my $nbar2 = $space1.$cd2.$space2.$nns2;
		
		my $sentence1 = $subject.$nbar1.$follows_coordination;
		my $sentence2 =  $subject.$nbar2.$follows_coordination;
		
		@simpler_sentences[0] = "{CIN-3a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
#		print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
	    }
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)$/){
	    my $det = $1;
	    my $space1 = $3;
	    $subject = $PREMATCH.$det.$space1;
	    $nbar1 = $4;
	    
	    
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)(\s*)($any_kind_of_sentence_boundary)/){
		my $follows_coordination = $10.$POSTMATCH;
		my $nbar2 = $1.$2;
		
		
		my $sentence1 = $subject.$nbar1.$follows_coordination;
		my $sentence2 =  $subject.$nbar2.$follows_coordination;
		
		@simpler_sentences[0] = "{CIN-4a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
#		print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
	    }
# VERB DT CD NNS CONJ CD NNS "Addressing the six men and six women"
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($vbg_verb)(\s*)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $det = $1;
	    my $shared_adj = " ".$4." ";
	    $nbar1 = $7.$12." ";
	    $subject = $PREMATCH.$det;
	    
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_noun)/){
		my $follows_coordination = $POSTMATCH;
		my $nbar2 = $&;
		
		$sentence1 = $subject.$shared_adj.$nbar1.$follows_coordination;
		$sentence2 =  $subject.$shared_adj.$nbar2.$follows_coordination;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		@simpler_sentences[0] = "{CIN-5a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
#		print STDERR "DET $det CD $cd2 NOUN $nns2\n";exit;
	    }
	}
# "using false CV and application form details"
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_verb)(\s+)($any_kind_of_adj1)(\s+)($any_kind_of_noun)(\s+)$/){
	    $nbar1 = $10;
	    $subject = $PREMATCH.$1.$4.$5.$9;
	    if($follows_rightmost_coordinator =~ /^(\s+)(($any_kind_of_noun|$any_kind_of_adj1|\s)+)/){
		$nbar2 = $&;
		$follows_coordination = $POSTMATCH;
		
		my $sentence1 = $subject.$nbar1.$follows_coordination;
		my $sentence2 = $subject.$nbar2.$follows_coordination;
		
		@simpler_sentences[0] = "{CIN-6a} ".$sentence1;
		@simpler_sentences[1] = "{CIN-6b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    
	    

#	    print STDERR "FOUND $&\nNBAR1 $nbar1\nNBAR2 $nbar2\nSUBJ $subject <<<\n";exit;
	}
	else{
	    
	    while($precedes_rightmost_coordinator =~ /$any_kind_of_adj1\s+$any_kind_of_noun/g){
		$nbar1 = $&;
		$precedes_coordination = $PREMATCH;
	    }
	    print STDERR "NBAR1 IS $nbar1\n";
		
	    print STDERR "precedes coordination $precedes_coordination\n";
	    
	    if($follows_rightmost_coordinator =~ /$any_kind_of_prep/){
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
	    
	    
	    @simpler_sentences[0] = "{CIN-7a} ".$sentence1;
	    @simpler_sentences[1] = "{CIN-7b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    print STDERR "SS REF IS $simpler_sentences_ref\n";
	    return($simpler_sentences_ref);
	}
	
    }
###############################################################################
# # # # # # # # # # anything

    elsif($potential_coordinator =~ />([^<]+)</){
# DT _ CIN _ NN _
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

	while($precedes_rightmost_coordinator =~ /$any_kind_of_determiner/g){
	    $this_determiner = $&;
	    $nbar1 = $this_determiner.$POSTMATCH;
	    $precedes_determiner = $PREMATCH;
	    $determiner_position = length($precedes_coordination);
	}
	while($precedes_rightmost_coordinator =~ /$any_kind_of_verb/g){
	    $this_verb = $&;
	    $nbar1 = $this_determiner.$POSTMATCH;
	    $precedes_verb = $PREMATCH;
	    $verb_position = length($precedes_coordination);
	}
	if($verb_position > $determiner_position){
	    if($verb_position > 0){
		$precedes_rightmost_coordinator = $precedes_verb;
	    }
	}
	else{
	    if($determiner_position > 0){
		$precedes_rightmost_coordinator = $precedes_determiner;
	    }
	}


#	print STDERR "precedes coordinator $precedes_rightmost_coordinator\n";exit;
	if($nbar1 eq ""){
	    while($precedes_rightmost_coordinator =~ /$any_kind_of_adj1((.|\s)*?)$plural_noun/g){
		$nbar1 = $&;
		$precedes_coordination = $PREMATCH;
		print STDERR "SENT $sentence\n";exit;
	    }
	}
	if($follows_rightmost_coordinator =~ /($any_kind_of_verb|$any_kind_of_subordinator)/){
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


	@simpler_sentences[0] = "{CIN-8a} ".$sentence1;
	@simpler_sentences[1] = "{CIN-8b} ".$sentence2;

	$simpler_sentences_ref = \@simpler_sentences;

	print STDERR "SS REF IS $simpler_sentences_ref\n";
	return($simpler_sentences_ref);
    }
    
    print STDERR "CIN NO RULE MATCHED\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n"; exit;
}
1;
