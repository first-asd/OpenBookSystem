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
package SimplifyCLN;
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
my $another = "<w c\=\"w\" p\=\"DT\">(A|a)nother<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


################################### CLN #######################################

    if($potential_coordinator =~ />(and|but|or)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($quotes)*)($any_kind_of_noun|$any_kind_of_pron|$any_kind_of_adj1|$vb_verb|$vbz_verb)(($quotes|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    	    


	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)(($quotes)*)($any_kind_of_noun|$any_kind_of_pron|$another)(($quotes)*)/){
		my $noun2 = " ".$7.$11.$16;
		my $follows_coordination = $POSTMATCH;

#		print STDERR ">>>>>>>>>>>>>>> $noun1\t$noun2\n";exit;
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLN-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-1b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
    }
############ Punctuation-Conjunction
    elsif($potential_coordinator =~ />(\,|\;|\:)(\s+)(and|but|or)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    
	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		my $noun2 = " ".$7;
		my $follows_coordination = $POSTMATCH;
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		
		@simpler_sentences[0] = "{CLN-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-2b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
###############################################################################
############ Punctuation
    elsif($potential_coordinator =~ />(\,|\;|\:)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;

	print STDERR "\t>>> PRMC $precedes_rightmost_coordinator\n";

	if($precedes_rightmost_coordinator =~ /(($any_kind_of_noun|\s)*)$/){
	    my $noun1 = $&;
	    my $subject = $PREMATCH;
	    

	    
	    if($follows_rightmost_coordinator =~ /^(($any_kind_of_prep|$any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		my $noun2 = $1.$7;
		my $follows_coordination = $POSTMATCH;

		print STDERR "FFFFFFFFFFFFF \n";
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLN-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-3b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(($any_kind_of_adverb|$any_kind_of_prep|\s)*)($any_kind_of_noun)/){
		my $noun2 = $6;
		my $follows_coordination = $POSTMATCH;

#		print STDERR "FFFFFFFFFFFFF \[$noun2\]\n";exit;
		
		$sentence1 = $subject.$noun1.$follows_coordination;
		$sentence2 = $subject.$noun2.$follows_coordination;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLN-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CLN-4b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }




    print STDERR "CLN NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;
}
1;
