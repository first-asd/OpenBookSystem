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
package SimplifySSMV;
# use lib '/home/richard/Lingua-EN-Inflect-1.893/lib/';
# use Lingua::EN::Inflect;
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
my $special_adverb = "<w ([^>]+)>day<\/w>(\\\s+)<w ([^>]+)>after<\/w>(\\\s+)<w ([^>]+)>day<\/w>";
my $any_kind_of_number = "<w c\=\"(w|cd|abbr)\" p\=\"CD\">([^<]+)<\/w>";
my $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
my $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
my $subordinating_that = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">that<\/PC>";
my $rp_word = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>";
my $with = "<w c\=\"w\" p\=\"IN\">with<\/w>";
my $to = "<w c\=\"w\" p\=\"TO\">to<\/w>";
my $of = "<w c\=\"w\" p\=\"IN\">of<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $whose = "<w c\=\"w\" p\=\"WP\\\$\">wh([^<]+)<\/w>";
my $unclassified_which = "<w c\=\"w\" p\=\"WDT\">wh([^<]+)<\/w>";
my $which = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">which<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $hyphen = "<w c\=\"([^\"]+)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";
my $unclassified_comma = "<w c\=\"cm\" p\=\"\,\">\,<\/w>";
my $unclassified_and = "<w c\=\"w\" p\=\"CC\">and<\/w>";
my $er_noun = "<w c\=\"(w)\" p\=\"(NN)\">([^<]+)er<\/w>";
my $bound_jj = "<w c\=\"(w)\" p\=\"(JJ)\">bound<\/w>";
my $ing_jj = "<w c\=\"(w)\" p\=\"(JJ)\">([^\s]*?)ing<\/w>";
my $ES_this_class = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESMV\">([^<]+)<\/PC>";
my $SS_this_class = "<PC ID\=\"([0-9]+)\" CLASS\=\"SSMV\">([^<]+)<\/PC>";
my $ESMN = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESMN\">([^<]+)<\/PC>";
my $ESMA = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESMA\">([^<]+)<\/PC>";
my $SSMA = "<PC ID\=\"([0-9]+)\" CLASS\=\"SSMA\">([^<]+)<\/PC>";
my $ESCCV = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESCCV\">([^<]+)<\/PC>";
my $SSCCV = "<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">([^<]+)<\/PC>";
my $COMBINATORY = "<PC ID\=\"([0-9]+)\" CLASS\=\"COMBINATORY\">([^<]+)<\/PC>";
my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(VB|VBD|VBG|VBN|VBZ)\">(accept|accepted|admit|admitted|admitting|agree|allege|alleging|believe|believing|conclude|concluding|fear|feared|find|found|intimate|intimating|hope|hoping|know|knew|known|mean|meant|realise|realising|relate|relating|reveal|revealed|rule|ruling|said|say|show|shown|showed|tell|terrified|think|thought|told)((s|d|ing)?)<\/w>";
my $be = "<w c\=\"w\" p\=\"(VBG|VBN|VBP|VBD|VB|VBZ)\">(is|are|was|were)<\/w>";
my $uc_but = "<w c\=\"w\" p\=\"CC\">But<\/w>";
my $wrb_word = "<w c\=\"w\" p\=\"WRB\">why<\/w>";
my $uc_ing = "<w c\=\"w\" p\=\"VBG\">([A-Z])([a-z]*?)ing<\/w>";
my $ing_word =  "<w c\=\"w\" p\=\"([^\"]+)\">([a-z]*?)ing<\/w>";

my ($verb_file) = `pwd`;
chomp($verb_file);
$verb_file .= "/verb_forms.txt";


my %ing = ();
open(VERBS, $verb_file);
while(<VERBS>){
    my $vline = $_;
    chomp($vline);

    if($vline =~ /\t([^\t]+)\t([^\t]+)$/){
	$ing{$2} = $1;
    }
}
close(VERBS);


sub simplify{
    my ($sentence, $precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;
    my $ed_verb;

    my $sentence1;
    my $sentence2;
    my $subject;
    my $element_for_deletion;
    my $subordinate_subject;
    my $subordinated_element;
    my $follows_subordination;
    my $noun;

    print STDERR "\t[SSMV]\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }



################################### SSMV #######################################
##############################################################################
##### punctuation-conjunction




##############################################################################
###### punctuation
    if($potential_subordinator =~ />(\,|\;)</){
	my $verb;


	if($follows_leftmost_subordinator =~ /^(\s*)($vbg_verb|$vbn_verb)((.|\s)*?)($ES_this_class)/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/($ES_this_class)$//;

	    print STDERR "1>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$6;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-23a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-23b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($quotes|$vbd_verb|$rp_word|$any_kind_of_prep|\s)*)($any_kind_of_noun)(($quotes|\s)*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/(($quotes|$vbd_verb|$rp_word|$any_kind_of_prep|\s)*)($any_kind_of_noun)(($quotes|\s)*)$//;
		$subordinate_subject =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>the<\/w>/i;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-28b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|$any_kind_of_possessive|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $1.$8;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-24a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-24b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbp_verb)(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(\s*)$/){
		$sentence2 = "<w c=\"w\" p=\"DT\">this</w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>are</;
		}
		else{
		    $sentence2 =~ s/>BE</>is</;
		}
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-18b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($verb =~ />according</){
		$sentence2 = "<w c=\"w\" p=\"DT\">this</w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-13b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_prep|$quotes|\s)*)($vbg_verb|$vbn_verb)((.|\s)*?)($ES_this_class)/){
	    $verb = $8;
	    my $terminator = $13;
	    $subordinated_element = $&;

	    $subordinated_element =~ s/($ES_this_class)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/^(($any_kind_of_prep|\s)*)//;

	    print STDERR "7>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_prep|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-26b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
		$subordinate_subject = "<w c=\"w\" p=\"DT\">the</w> ".$subordinate_subject;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(($quotes|\s)*)($vbg_verb)/$1$ed_verb/;
		$sentence2 = $subordinate_subject." ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-26b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbg_verb)(\s*)($to)(\s*)($nnp_noun|$any_kind_of_determiner|$any_kind_of_possPron)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes))(\s*)$/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "11>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\nPLS $precedes_leftmost_subordinator\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;
	    	    
	    $subordinate_subject = $1.$6;

	    $sentence2 = "<w c=\"w\" p=\"DT\">this</w> <w c=\"w\" p=\"VBD\">was</w> ".$subordinated_element;

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSMV-1a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMV-1b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($vbg_verb)(\s*)($nnp_noun|$any_kind_of_determiner|$any_kind_of_possPron)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $verb = $6;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "10>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\nPLS $precedes_leftmost_subordinator\nverb is $verb\n";
	    

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;
	    	    

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|$any_kind_of_adj1|\s)*)($nnp_noun)(\s*)($vbd_verb)/){
		$subordinate_subject = $1.$9;
		
		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($any_kind_of_adverb)(\s*)($verb)/$1$2$5$ed_verb/;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSMV-37a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-37b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($vbg_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $verb = $5;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;


	    print STDERR "2>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\nPLS $precedes_leftmost_subordinator\nverb is $verb\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    if($verb =~ />according</){
		$sentence2 = "<w c=\"w\" p=\"DT\">this</w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-13b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbd_verb)(($vbn_verb|\s)*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
		$subordinate_subject = $1.$6;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-34b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(($any_kind_of_adverb|\s)*)($vbd_verb)(($any_kind_of_prep|\s)*)(($left_quote|$any_kind_of_noun|\s)*)$/){
		$subordinate_subject = $1.$6;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-35a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-35b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_pron)(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)$/){
		$subordinate_subject = $1;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-5b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_pron)(($any_kind_of_adverb|\s)*)($vbd_verb)((.|\s)*?)$/){
		$subordinate_subject = $1;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-12b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_pron)(\s*)($vbd_verb|$vbn_verb)(($any_kind_of_determiner|\s)*?)(($any_kind_of_noun|\s)*?)$/){
		$subordinate_subject = $1;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbn_verb)((.|\s)*?)($to)(\s*)($vb_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$6;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-25a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-25b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$6;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;



		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-4b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(($any_kind_of_adverb|\s)*)($vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$6;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-38a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-38b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$6;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-29b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($vbn_verb|$vbg_verb|vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$3.$11;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-19b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($to)//;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-20b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($nnp_noun|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$3.$4;
		$subordinate_subject =~ s/($vbd_verb)((.|\s)*)$//;
		$subordinate_subject =~ s/>a<\/w>/>the<\/w>/i;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-20b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_pron)(\s*)($vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $1;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-21a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-21b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($nnp_noun)(\s*)($vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $1;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-7b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_number)(($any_kind_of_adj1|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)((.|\s)*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/(\s*)($vbd_verb)((.|\s)*)$//;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-27b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)($to)((.|\s)*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/(\s*)($to)((.|\s)*)$//;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-8b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbg_verb)((.|\s)*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/(\s*)($vbg_verb)((.|\s)*)$//;
		$subordinate_subject =~ s/^($vbn_verb)(\s*)//;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-9b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$of|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/>a<\/w>/>the<\/w>/i;

		my ($ed_verb) = change_ing($verb);
		print STDERR " v is $verb\n ed is $ed_verb\n";

		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-3b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_prep)(($any_kind_of_noun|$nnp_noun|$any_kind_of_number|\s)*)$/){
		$subordinate_subject = $&;
		my $accusative_pronoun = $4;
		my ($nominative_pronoun) = change_pron($accusative_pronoun);

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $nominative_pronoun." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-30b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vb_verb)(\s*)($any_kind_of_determiner)(($left_quote|$plural_noun|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)((.|\s)*)$/){
		$subordinate_subject = $4.$6.$16;
		$subordinate_subject =~ s/>a<\/w>/>the<\/w>/i;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-22b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun|$uc_ing)(($any_kind_of_adverb|\s)*)($vbd_verb)(($vbn_verb|\s)*)(($any_kind_of_prep|$any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
		$subordinate_subject = $1.$6;

		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;

		$sentence2 = $subordinate_subject." ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-36a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-36b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /<w ([^>]+)>making<\/w>(\s*)<w ([^>]+)>it<\/w>(\s*)<w ([^>]+)>the<\/w>/i){
		my ($ed_verb) = change_ing($verb);
		$subordinated_element =~ s/^(\s*)($vbg_verb)/$1$ed_verb/;
		$sentence2 = "<w c=\"w\" p\=\"DT\">this</w> ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-16b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb|$vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "3>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|$any_kind_of_determiner|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$7;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-31a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-31b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/>a<\/w>/>the<\/w>/i;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-32b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_adverb|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)((.|\s)*?)$/){
		$subordinate_subject = $1.$3.$10;
		$subordinate_subject =~ s/>a<\/w>/>the<\/w>/i;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-14b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($verb =~ />said</){
		$subordinated_element =~ s/^(\s*)($verb)(\s*)//;

		$sentence2 = $subordinated_element." ".$verb." <w c=\"w\" p=\"DT\">this</w>";


		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-33b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adj1|\s)*)($vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "6>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|$any_kind_of_determiner|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$7;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-17b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($to)(\s*)($vb_verb)((.|\s)*?)($ES_this_class)/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    my $terminator = $8;
	    $subordinated_element =~ s/($ES_this_class)$//;

	    print STDERR "3>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;
	    print STDERR "\[$sentence1\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|$of|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>the<\/w>/i;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>are</;
		}
		else{
		    $sentence2 =~ s/>BE</>is</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-10b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">was<\/w> ".$subordinated_element;

	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSMV-11a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMV-11b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

	elsif($follows_leftmost_subordinator =~ /^(\s*)($to)(\s*)($vb_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "4>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;


	    if($precedes_leftmost_subordinator =~ /($to)(\s*)($vb_verb)(\s*)($plural_noun)(\s*)($of)(($any_kind_of_number|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($to)(\s*)($vb_verb)(\s*)//;
		$subordinate_subject = "<w c\=\"w\" p\=\"DT\">the<\/w> ".$subordinate_subject;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>are</;
		}
		else{
		    $sentence2 =~ s/>BE</>is</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-10b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($vbz_verb)(\s*)($vbn_verb)(\s*)($to)(\s*)($vb_verb)((.|\s)*)$/){
		$subordinate_subject = $1.$4.$11;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-15b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($ing_word)(\s*)($SSCCV)/){
	    $verb = $2;
	    $subordinated_element = $&;
	    $subordinated_element =~ s/($SSCCV)$//;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "5>>>>>>>>>>>>>>>\[$subordinated_element\]\n$element_for_deletion\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;


	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>were</;
		}
		else{
		    $sentence2 =~ s/>BE</>was</;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSMV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMV-10b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
# Following conditions handles some types of verbless clause introduced by SSMV rather than SPECIAL or SCCCV
# Maybe ask Emma Franklin about reasoning behind these annotations [,_SSMV] police established[,_ESMV]
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)($vbg_verb|$vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$/){
	    $verb = $10;
	    my $terminator = $13;
	    $subordinated_element = $&;

	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/^(($any_kind_of_prep|\s)*)//;

	    print STDERR "8>>>>>>>>>>>>>>>\[$subordinated_element\]\nverb is $verb\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    my ($ed_verb) = change_ing($verb);
	    $sentence2 = $subordinated_element;
	    $sentence2 =~ s/\Q$verb\E/$ed_verb/;



	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSMV-26a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMV-26b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($vbd_verb)((.|\s)*?)($ES_this_class)/){
	    $verb = $10;
	    my $terminator = $13;
	    $subordinated_element = $&;

	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes)*)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/($ES_this_class)$//;

	    print STDERR "9>>>>>>>>>>>>>>>\[$subordinated_element\]\nverb is $verb\n";

	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    my ($ed_verb) = change_ing($verb);
	    $sentence2 = $subordinated_element." <w c=\"w\" p=\"DT\">this</w>";
	    $sentence2 =~ s/\Q$verb\E/$ed_verb/;



	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSMV-26a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMV-26b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

# All other PCs are de-tagged and the sentence is returned, unsimplified
	my $replacement_pc = $potential_subordinator;
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
	
	$sentence1 = $precedes_leftmost_subordinator.$replacement_pc.$follows_leftmost_subordinator;

#	print STDERR "$potential_subordinator\n";exit;

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	    
	@simpler_sentences[0] = "{SSMV-77a} ".$sentence1.$final_punctuation;
#	print STDERR "\tS1 $sentence1\n\n"; exit;
			
	$simpler_sentences_ref = \@simpler_sentences;

	open(ERROR_FILE, ">>./SSMV_errors.txt");
	print ERROR_FILE "$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";
	close(ERROR_FILE);
	
	`cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
	

#	unless($potential_subordinator =~ />\,/ && ($precedes_leftmost_subordinator =~ /(found)<\/w>(\s*)$/) && $follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>by<\/w>/){
#	    unless($potential_subordinator =~ />\,/ && $follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>in<\/w>(\s*)<w ([^>]+)>particular<\/w>(\s*)($ES_this_class)/){
		
#	print STDERR "SSMV NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
#	    }
#	}
	
	return($simpler_sentences_ref);
    }		
    
    
        



}
1;

sub change_ing{
    my ($verb) = @_;
    $verb =~ s/p\=\"VBG\"/p\=\"VBD\"/;
    $verb =~ s/coming</came</;
    $verb =~ s/keeping</kept</;
    $verb =~ s/leaving</left</;
    $verb =~ s/making</made</;
    $verb =~ s/paying</paid</;
    $verb =~ s/shooting</shot</;
    $verb =~ s/sweeping</swept</;
    $verb =~ s/>([A-Za-z]+)ing</>$1ed</;
    return ($verb);
}

sub change_pron{
    my ($acc_pron) = @_;
    my $pron = $acc_pron;

    $pron =~ s/>her</>she</i;
    $pron =~ s/>him</>he</i;

    return ($pron);
}
