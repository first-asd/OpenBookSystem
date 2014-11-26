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
#
# 21/06/2012: Note "This is/was..." constructions are generated when the algorithm cannot determine a nominal phrase
# that the identified PP is modifying
# In light of the dependence of the "This is/was..." sentence on the matrix clause, there may be an argument for
# returning a single string consisting of 2 sentences, rather than each sentence individually.
# In many cases, we can either have a subordinated PP or discourse anaphora.
package SimplifySSMP;
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
my $right_parenthesis = "<w c\=\"([^\"]+)\" p\=\"\\\)\">\\\)<\/w>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $hyphen = "<w c\=\"([^\"]+)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";
my $unclassified_comma = "<w c\=\"cm\" p\=\"\,\">\,<\/w>";
my $unclassified_and = "<w c\=\"w\" p\=\"CC\">and<\/w>";
my $er_noun = "<w c\=\"(w)\" p\=\"(NN)\">([^<]+)er<\/w>";
my $bound_jj = "<w c\=\"(w)\" p\=\"(JJ)\">bound<\/w>";
my $ing_jj = "<w c\=\"(w)\" p\=\"(JJ)\">([^\s]*?)ing<\/w>";
my $ES_this_class = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESMP\">([^<]+)<\/PC>";
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
my $such = "<w c\=\"w\" p\=\"JJ\">such<\/w>";
my $as = "<w c\=\"w\" p\=\"IN\">as<\/w>";

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

    print STDERR "\t[SSMP]\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }



################################### SSMP #######################################
##############################################################################
##### punctuation-conjunction




##############################################################################
###### punctuation
# Need to decide on a strategy for writing sentences containing SSMP.
# Currently "The item, in 1997, referred to a forthcoming memorial concert.
# Becomes
# "In 1997, the item referred to a forthcoming memorial concert"

    if($potential_subordinator =~ />(\,|\;)</){

	my $verb1;
	my $verb2;

	if($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)((.|\s)*?)($ES_this_class)/){
	    $subordinated_element = $&;
	    my $this_ESMA = $6;
	    my $adverb = $2;
	    my $preposition = $6;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/($ES_this_class)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "16>>>>>>>>>>>\[$subordinated_element\]\n$adverb\t$preposition\n";

	    if($precedes_leftmost_subordinator =~ /($vbg_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_number)(\s*)($any_kind_of_prep)(($any_kind_of_number|$any_kind_of_pc|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
		$sentence2 = "<w c\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;


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

		@simpler_sentences[0] = "{SSMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_number|$any_kind_of_pc|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

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

		@simpler_sentences[0] = "{SSMP-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-33b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_number|$any_kind_of_pc|$any_kind_of_noun|$of|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

# HERE, WE ARE IN A GENRE-SPECIFIC CONDITION

		$subordinated_element =~ s/($adverb)//;
#		$subordinate_subject =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>the<\/w>/i;
		$sentence2 = $subordinate_subject." ".$adverb." <w c=\"w\" p=\"VBZ\">occurs<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-34b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_prep)((.|\s)*?)($vbd_verb)/){
	    $subordinated_element = $1.$2.$5.$6.$8;
	    my $this_ESMA = $6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "6>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		print STDERR "\[$subordinate_subject\]\n";

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

		@simpler_sentences[0] = "{SSMP-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-9b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($such)(\s*)($as)((.|\s)*?)($ES_this_class)/){
	    $subordinated_element = $&;
	    my $this_ESMA = $6;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/($ES_this_class)$//;
	    $subordinated_element =~ s/^(\s*)($such)(\s*)($as)//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "16>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinated_element." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinate_subject;


		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>are</;
		}
		elsif($subordinate_subject =~ /($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)/){
		    $sentence2 =~ s/>BE</>are</;
		}
		else{
		    $sentence2 =~ s/>BE</>is</;
		}
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

		@simpler_sentences[0] = "{SSMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($such)(\s*)($as)((.|\s)*?)(($right_parenthesis|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
	    $subordinated_element = $&;
	    my $this_ESMA = $6;


	    $subordinated_element =~ s/(($right_parenthesis|\s)*)($any_kind_of_sentence_boundary)(\s*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subordinated_element =~ s/^(\s*)($such)(\s*)($as)//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "16>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbz_verb)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)($wh_word)((.|\s)*?)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($vbz_verb)//;

		$sentence2 = $subordinated_element." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinate_subject;


		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>BE</>are</;
		}
		elsif($subordinate_subject =~ /($any_kind_of_noun)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_noun)/){
		    $sentence2 =~ s/>BE</>are</;
		}
		else{
		    $sentence2 =~ s/>BE</>is</;
		}
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

		@simpler_sentences[0] = "{SSMP-35a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-35b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(($nnp_noun|\s)*)($nnp_noun)($unclassified_comma)(($unclassified_comma|\s)*)($nnp_noun)(\s*)($unclassified_comma)/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(\s*)($unclassified_comma)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "13>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($of)(\s*)(($any_kind_of_number|$hyphen|$any_kind_of_adj1|$nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		print STDERR "\[$subordinate_subject\]\n";

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

		@simpler_sentences[0] = "{SSMP-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-8b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($quotes|\s)*)($any_kind_of_prep)((.|\s)*?)($ES_this_class)/){
	    $subordinated_element = $1.$7.$9;
	    my $this_ESMA = $11;
	    $element_for_deletion = $potential_subordinator.$subordinated_element.$this_ESMA;
	    $sentence1 = $sentence;
	    my $prep = $7;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

#	    print STDERR "4>>>>>>>>>>>\[$subordinated_element\]\nprep $prep\n";exit;

	    if($precedes_leftmost_subordinator =~ /($comma)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)($any_kind_of_number)(\s*)$/){
		$subordinate_subject = $4.$5.$10.$14.$15;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		print STDERR "\[$subordinate_subject\]\n";

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

		@simpler_sentences[0] = "{SSMP-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-8b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
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

		@simpler_sentences[0] = "{SSMP-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-13b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(\s*)($any_kind_of_noun)(($of|$any_kind_of_number|\s)*)$/){
		$subordinate_subject = $&;
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

		@simpler_sentences[0] = "{SSMP-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-16b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
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

		@simpler_sentences[0] = "{SSMP-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-19b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$6.$10;

		if($prep =~ />as</){
		    $subordinated_element =~ s/(($quotes|\s)*)($prep)/$1/;
		}
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

		@simpler_sentences[0] = "{SSMP-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-4b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbz_verb)(\s*)($vbn_verb)(\s*)($ing_jj)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
		$sentence2 = "<w c\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
		$sentence2 = "<w c\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-18b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_adverb)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-7b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /^(\s*)($uc_but)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
		$sentence2 = "<w c\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    else{
		$sentence2 = "<w c\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-32b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)((.|\s)*?)($ESMA)/){
	    $subordinated_element = $1.$2.$4;
	    my $this_ESMA = $6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element.$this_ESMA;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "1>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_number)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-17b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_number)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-1b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_prep)((.|\s)*?)($ESMN)/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/($ESMN)$//;
	    my $this_ESMA = $6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element.$this_ESMA;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "14>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($wrb_word)(\s*)($any_kind_of_determiner)(($any_kind_of_number|$of|$any_kind_of_pron|$unclassified_comma|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$COMBINATORY|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($wrb_word)//;
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

		@simpler_sentences[0] = "{SSMP-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-17b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)((.|\s)*?)($ESCCV)/){
	    $subordinated_element = $1.$2.$4;
	    my $this_ESMA = $6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element.$this_ESMA;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "11>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$9;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

#		print STDERR "\[$subordinate_subject\]\n";exit;

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

		@simpler_sentences[0] = "{SSMP-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-8b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)((.|\s)*?)($hyphen)(($any_kind_of_noun|\s)*)($any_kind_of_noun)/){
	    $subordinated_element = $&;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "15>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-21a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-21b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)((.|\s)*?)($hyphen)/){
	    $subordinated_element = $1.$2.$4;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "2>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_number)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(\s*)$//g;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "3>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-3b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_number)(\s*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$of|$any_kind_of_number|\s)*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($be)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)$/){
		$subordinate_subject = $1.$6.$10;
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

		@simpler_sentences[0] = "{SSMP-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbd_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)$/){
		$subordinate_subject = $1.$6;
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

		@simpler_sentences[0] = "{SSMP-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-30b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
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

		@simpler_sentences[0] = "{SSMP-36a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-36b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(($nnp_noun|\s)*)($nnp_noun)(\s*)($any_kind_of_modal)/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(\s*)($any_kind_of_modal)$//g;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "22>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($ESCCV)(\s*)($uc_ing)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($ESCCV)//;
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

		@simpler_sentences[0] = "{SSMP-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-27b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)$/){
	    $subordinated_element = $1.$2.$4;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "5>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
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

		@simpler_sentences[0] = "{SSMP-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-5b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possPron|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-11b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($which|$unclassified_which)((.|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $sentence2 = $subordinated_element;
	    $sentence2 =~ s/^(\s*)($any_kind_of_prep)(\s*)($which|$unclassified_which)//;

	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "27>>>>>>>>>>>\[$subordinated_element\]\n";

	    @simpler_sentences[0] = "{SSMP-10a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-10b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($nnp_noun|$of|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $1.$2.$4.$5.$7;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "7>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($of)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
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

		@simpler_sentences[0] = "{SSMP-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-10b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($vbd_verb)(\s*)//;
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

		@simpler_sentences[0] = "{SSMP-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-12b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}

	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_adverb|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "8>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-11b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_prep|\s)*)($any_kind_of_prep)(\s*)($any_kind_of_determiner|$any_kind_of_number)(($any_kind_of_adverb|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "12>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($of)(\s*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-20b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(($nnp_noun|\s)*)($nnp_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "9>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
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

		@simpler_sentences[0] = "{SSMP-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-11b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
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

		@simpler_sentences[0] = "{SSMP-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-14b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		print STDERR "\[$subordinate_subject\]\n";

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

		@simpler_sentences[0] = "{SSMP-23a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-23b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($vbg_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "10>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_adverb)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-15b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_prep)(\s*)(($any_kind_of_determiner|$any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $3.$4.$8;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-22b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    else{
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-37a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-37b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)((.|\s)*?)(($any_kind_of_sentence_boundary|quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_prep = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "17>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($this_prep =~ /(because)/){
		
		if($precedes_leftmost_subordinator =~ /($any_kind_of_modal)(\s*)($vb_verb)(\s*)($any_kind_of_adj1)(\s*)$/){
		    $subordinate_subject = $&;
		    $subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
		    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		    
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
		    
		    @simpler_sentences[0] = "{SSMP-15a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMP-15b} ".$sentence2.$final_punctuation;
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	    else{
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
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
		
		@simpler_sentences[0] = "{SSMP-24a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-24b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($any_kind_of_adverb)((.|\s)*?)(($any_kind_of_sentence_boundary|quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_prep = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "19>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
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
		
	    @simpler_sentences[0] = "{SSMP-25a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-25b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($any_kind_of_adj1)((.|\s)*?)(($any_kind_of_sentence_boundary|quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_prep = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "24>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($comma)(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbz_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($unclassified_comma)(\s*)$/){
		$subordinate_subject = $4.$9;
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

		@simpler_sentences[0] = "{SSMP-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-30b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    else{
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-29b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)(\s*)($vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_prep = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "21>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
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
		
	    @simpler_sentences[0] = "{SSMP-26a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-26b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($to)(\s*)($any_kind_of_noun)((.|\s)*?)(($any_kind_of_sentence_boundary|quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_prep = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;

	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "20>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
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
		
	    @simpler_sentences[0] = "{SSMP-25a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-25b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_prep)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(($any_kind_of_adverb|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $element_for_deletion =~ s/^\s*//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "23>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($unclassified_comma|$comma)(\s*)(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($vbd_verb)//;
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

		@simpler_sentences[0] = "{SSMP-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-28b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    else{
		$sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMP-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMP-29b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_prep)(\s*)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)((.|\s)*)(($any_kind_of_sentence_boundary|$quotes|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $element_for_deletion =~ s/^\s*//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "25>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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
	    
	    @simpler_sentences[0] = "{SSMP-31a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-31b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_prep)(\s*)(($any_kind_of_possPron|\s)*)($any_kind_of_noun)((.|\s)*)(($any_kind_of_sentence_boundary|$quotes|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $element_for_deletion =~ s/^\s*//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "26>>>>>>>>>>>\[$subordinated_element\]\n";

	    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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
	    
	    @simpler_sentences[0] = "{SSMP-31a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMP-31b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_noun)(\s*)($to)(\s*)($SSCCV)((.|\s)*?)(($any_kind_of_sentence_boundary|$quotes|\s)*)$/){
	    $subordinated_element = $&;
	    my $this_noun = $2;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|$quotes|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "18>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($this_noun =~ /(contrary)/){

		if($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)$/){
		    $subordinate_subject = $&;
		    $subordinate_subject =~ s/^($any_kind_of_prep)(\s*)//;
		    $sentence2 = "<w c\=\"w\" p\=\"DT\">this<\/w> <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		    
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
		    
		    @simpler_sentences[0] = "{SSMP-15a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMP-15b} ".$sentence2.$final_punctuation;
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
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
	    
	@simpler_sentences[0] = "{SSMP-77a} ".$sentence1.$final_punctuation;
#	print STDERR "\tS1 $sentence1\n\n"; exit;
			
	$simpler_sentences_ref = \@simpler_sentences;

	open(ERROR_FILE, ">>./SSMP_errors.txt");
	print ERROR_FILE "$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";
	close(ERROR_FILE);
	
my $ttt2_dir = "../TTT2/scripts";
my $ttt2_models_dir = "../TTT2/models";
`cat temp.txt | $ttt2_dir/preparetxt | $ttt2_dir/tokenise | $ttt2_dir/postag -m $ttt2_models_dir/pos >  temp.txt.post.xml`;
####	`cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
	

	unless($potential_subordinator =~ />\,/ && ($precedes_leftmost_subordinator =~ /(found)<\/w>(\s*)$/) && $follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>by<\/w>/){
	    unless($potential_subordinator =~ />\,/ && $follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>in<\/w>(\s*)<w ([^>]+)>particular<\/w>(\s*)($ES_this_class)/){
		
#		print STDERR "SSMP NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
	    }
	}
	
	return($simpler_sentences_ref);
    }


}
1;



