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
package SimplifyCLA;
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
my $any_kind_of_adj1 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|JJR|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|JJR|VBN)\">([^<]+)<\/w>";
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
my $ier_nn =  "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([^<]+?)ier<\/w>";
my $y_nn =  "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([^<]+?)y<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


################################### CLA #######################################
######## Conjunctions
# Note with this class and all lexical coordination, it may be more desirable to
# simply return the input sentence without the tags to indicate CLA as
# @simpler_sentences[0] and not return anything else.
#
    if($potential_coordinator =~ />(and|or|but)</){
# When enumerating these regExs, it is necessary to also count the
# parenthetical expressions defined in the variables
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adj1;
	my $adj2;




	if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1|$ier_nn)(\s+)$/){
	    $subject = $PREMATCH;
	    $adj1 = $&;
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1|$ier_nn)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		@simpler_sentences[0] = "{CLA-1a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-1b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_number)($hyphen)($vbn_verb)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $&;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		@simpler_sentences[0] = "{CLA-2a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_verb)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $&;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		@simpler_sentences[0] = "{CLA-3a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-3b} ".$sentence2;
		    
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		$simpler_sentences_ref = \@simpler_sentences;
		    
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner|$any_kind_of_possPron)(\s+)($any_kind_of_noun|$any_kind_of_verb)\s*$/){
	    $subject = $PREMATCH;
	    $adj1 = $5;

	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1|$any_kind_of_noun)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;

		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR ">>>S1 $sentence1\nS2 $sentence2\n\[$adj1\]\n";exit;

		@simpler_sentences[0] = "{CLA-4a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-4b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun|$any_kind_of_verb)\s*$/){
	    $subject = $PREMATCH;
	    $adj1 = $1;
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1|$vbg_verb)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLA-5a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-5b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	
    }
###############################################################################
####### Commas
    elsif($potential_coordinator =~ />(\,|\;)</){
	my $sentence1;
	my $sentence2;
	my $subject;
	my $follows_coordination;
	my $adj1;
	my $adj2;



	if($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)$/){
	    $subject = $PREMATCH;
	    $adj1 = $&;
	    
#	    print STDERR ">>>>>>>>>>>>>>>>>>>\n";	    exit;
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		@simpler_sentences[0] = "{CLA-6a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-6b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /^(\s+)($vbg_verb)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		@simpler_sentences[0] = "{CLA-7a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-7b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)$/){
	    $subject = $PREMATCH;
	    $adj1 = $&;
	    
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($vbn_verb)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		@simpler_sentences[0] = "{CLA-8a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-8b} ".$sentence2;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(\s+)($any_kind_of_noun|$any_kind_of_verb)(\s*)$/){
	    $subject = $PREMATCH.$1.$3;
	    $adj1 = $4;
	    
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1|$y_nn)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

		@simpler_sentences[0] = "{CLA-9a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-9b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	    elsif($follows_rightmost_coordinator =~ /(\s*)($vbg_verb)/){
		$follows_coordination = $POSTMATCH;
		
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;

		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		@simpler_sentences[0] = "{CLA-10a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-10b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_noun)$/){
	    $subject = $PREMATCH;
	    $adj1 = $1;
	    
	    
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		@simpler_sentences[0] = "{CLA-11a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($any_kind_of_number)$/){
	    $subject = $PREMATCH;
	    $adj1 = $1;
	    
	    
	    
	    if($follows_rightmost_coordinator =~ /(\s+)($any_kind_of_adj1)/){
		$follows_coordination = $POSTMATCH;
		$adj2 = $2;
		
		$sentence1 = $subject.$adj1.$follows_coordination;
		$sentence2 = $subject.$adj2.$follows_coordination;
		
		$sentence1 =~ s/\s*$//;
		$sentence2 =~ s/^\s*//;
		
		@simpler_sentences[0] = "{CLA-12a} ".$sentence1;
		@simpler_sentences[1] = "{CLA-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		print STDERR "SS REF IS $simpler_sentences_ref\n";
		return($simpler_sentences_ref);
	    }
	}
    }
    
    print STDERR "CLA NO RULE MATCHED\n$precedes_rightmost_coordinator\t$potential_coordinator\t$follows_rightmost_coordinator\n"; exit;
}
1;
