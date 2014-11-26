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
package SimplifySSMA;
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
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $hyphen = "<w c\=\"([^\"]+)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";
my $unclassified_comma = "<w c\=\"cm\" p\=\"\,\">\,<\/w>";
my $er_noun = "<w c\=\"(w)\" p\=\"(NN)\">([^<]+)er<\/w>";
my $bound_jj = "<w c\=\"(w)\" p\=\"(JJ)\">bound<\/w>";
my $ES_this_class = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESMA\">([^<]+)<\/PC>";
my $SSCCV = "<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">([^<]+)<\/PC>";
my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(VB|VBD|VBG|VBN|VBZ)\">(accept|accepted|admit|admitted|admitting|agree|allege|alleging|believe|believing|conclude|concluding|fear|feared|find|found|intimate|intimating|hope|hoping|know|knew|known|mean|meant|realise|realising|relate|relating|reveal|revealed|rule|ruling|said|say|show|shown|showed|tell|terrified|think|thought|told)((s|d|ing)?)<\/w>";

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
    my $noun;

    print STDERR "PROCESSING\n\t[SSMA]\n$precedes_leftmost_subordinator\t$potential_subordinator\t$follows_leftmost_subordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

    my $sentence1;
    my $sentence2;
    my $subject;
    my $follows_subordination;
    my $verb1;
    my $verb2;
    my $subordinated_element;
    my $subordinate_subject;
    my $element_for_deletion;
    my $main_clause;

################################### SSMA #####################################
##############################################################################
##### punctuation-conjunction


    if($potential_subordinator =~ />\,\s+(but)</){
	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){
	    my $terminator = $&;
	    $element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
	    $subordinated_element = $PREMATCH;
	    my $class = "E".$2;

	    print STDERR "9>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";
	}
	else{
	    $subordinated_element = $POSTMATCH;
	    if($subordinated_element =~ /^<w ([^>]+)>because<\/w>/){
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSMA-7a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-7a} ".$sentence2.$final_punctuation;
		
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
    }

##############################################################################
##### conjunction alone

##############################################################################
###### punctuation, comma, colon, semicolon
    elsif($potential_subordinator =~ />(\,|\;|\:)</){
	my $subordinator = $1;

	if($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)<PC ID\=\"([^\"]+)\" CLASS\=\"(SSMP)\">([^<]+)<\/PC>(\s*)($of)((.|\s)*?)($vbd_verb)/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/($vbd_verb)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;

	    print STDERR "10>>>>>>>>>>>>SE \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-2b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
# Following  two conditions are special cases for ADJPs that are verbless clauses
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_prep)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinate_subject = $1.$2;
	    $element_for_deletion = $potential_subordinator.$&;
	    $subordinated_element = $4.$5.$8.$9.$13.$14.$16;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "26>>>>>>>>>>>>SE \[$subordinated_element\]\n\[$subordinate_subject\]\n";
		
	    $sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;


	    if($subordinate_subject =~ /^(\s*)<w ((.|\s)*?)p\=\"CD\">([^<]+)<\/w>/){
		my $cd_word = $4;
		if($cd_word ne "(one|1)"){
		    $sentence2 =~ s/>BE</>were</;
		}
	    }		
	    elsif($subordinate_subject =~ /^(\s*)<w ((.|\s)*?)p\=\"DT\">some<\/w>/){
		$sentence2 =~ s/>BE</>were</;
	    }
		
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
	    
	    @simpler_sentences[0] = "{SSMA-3a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMA-3b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($of)(\s*)($any_kind_of_pron)(\s*)($vbn_verb)((.|\s)*?)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>/){
	    $subordinated_element = $11.$13;
	    $element_for_deletion = $potential_subordinator.$&;
	    $subordinate_subject = $1.$2.$5.$6.$7.$8.$10;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "20>>>>>>>>>>>>SE \[$subordinated_element\]\n\[$subordinate_subject\]\n";
		
	    $sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;


	    if($subordinate_subject =~ /^(\s*)<w ((.|\s)*?)p\=\"CD\">([^<]+)<\/w>/){
		my $cd_word = $4;
		if($cd_word ne "(one|1)"){
		    $sentence2 =~ s/>BE</>were</;
		}
	    }		
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
	    
	    @simpler_sentences[0] = "{SSMA-3a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMA-3b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($of)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_adj1)(\s*)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>/){
	    $subordinated_element = $11.$15.$19;
	    $element_for_deletion = $potential_subordinator.$&;
	    $subordinate_subject = $1.$2.$5.$6.$7.$8;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "21>>>>>>>>>>>>SE \[$subordinated_element\]\n\[$subordinate_subject\]\n";
		
	    $sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
	    
	    @simpler_sentences[0] = "{SSMA-3a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{SSMA-3b} ".$sentence2.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($follows_leftmost_subordinator =~ /^((.|\s)*?)($any_kind_of_number)(\s*)($comma)(\s*)($any_kind_of_prep)((.|\s)*)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>/){
	    $subordinated_element = $&;
	    $element_for_deletion = $potential_subordinator.$&;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "17>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-3b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($of)(\s*)($nnp_noun)(\s*)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>(\s*)($vbd_verb)/){
	    $subordinated_element = $1.$2.$3.$4;
	    $element_for_deletion = $potential_subordinator.$&;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "23>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-79a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-79b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_number|\s)*)($nnp_noun)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>(\s*)($vbd_verb)/){
	    $subordinated_element = $1.$5;
	    $element_for_deletion = $potential_subordinator.$&;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "11>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-79a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-79b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_number|\s)*)($plural_noun)(\s*)($any_kind_of_adj1)(\s*)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>(\s*)($vbz_verb)/){
	    $subordinated_element = $1.$5.$9.$10;
	    $element_for_deletion = $potential_subordinator.$&;
	    $element_for_deletion =~ s/(\s*)($vbz_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "12>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-80a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-80b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|$any_kind_of_number|\s)*)($any_kind_of_number)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>(\s*)($vbd_verb)/){
	    $subordinated_element = $1.$7;
	    $element_for_deletion = $potential_subordinator.$&;
	    $element_for_deletion =~ s/(\s*)($vbd_verb)$//;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "5>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-81a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-81b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-82a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-82b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)<PC ID\=\"([^\"]+)\" CLASS\=\"(ESMA)\">([^<]+)<\/PC>/){
	    $subordinated_element = $1.$2.$5;
	    $element_for_deletion = $potential_subordinator.$&; # n.b. if the pattern above
                                                               # includes spaces at the
                                                              # start and end, these spaces
                                                             # will be deleted from the
                                                            # sentence
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//; 
	    
	    print STDERR "19>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-83a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-83b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_prep)/){
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "22>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-84a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-84b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($vbd_verb)/){
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$1.$2;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "7>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-84a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-84b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($plural_noun)(\s*)$/){
	    $subordinated_element = $1.$2.$5.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
	    
	    print STDERR "18>>>>>>>>>>>>SE \[$subordinated_element\]\n";
	    
	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		
		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">BE<\/w> ".$subordinated_element;
		
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
		
		@simpler_sentences[0] = "{SSMA-84a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-84b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##############################	
# WARNING THE FOLLOWING PATTERN MAY BE UNSAFE DUE TO INCLUSION OF
# $any_kind_of_noun
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($any_kind_of_pc|$any_kind_of_noun)/){
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "2>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-1b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)($hyphen)(\s*)($any_kind_of_prep|$vbd_verb)/){
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "28>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-1a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-1b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
# Below, use ($vbn_verb|$vbd_verb) instead of ($vbn_verb). $4 then needs to be $5? $6 needs to become $7?
#	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbn_verb)((.|\s)*?)($ES_this_class)/){
#	    $subordinated_element = $1.$2.$4;
#	    $element_for_deletion = $potential_subordinator.$subordinated_element.$6;
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbn_verb|$vbd_verb)((.|\s)*?)($ES_this_class)/){
	    $subordinated_element = $1.$2.$5;
	    $element_for_deletion = $potential_subordinator.$subordinated_element.$7;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "13>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($of)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;
		$subordinate_subject = "<w c\=\"w\" p\=\"DT\">the<\/w> ".$subordinate_subject;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-4b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-9b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_adverb|\s)*)($any_kind_of_adj1)(\s*)($any_kind_of_number)(\s*)($vbd_verb)(\s*)/){
	    $subordinated_element = $1.$5.$9.$10.$13;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "16>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-10b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_number)(\s*)($any_kind_of_pc)(\s*)($any_kind_of_number)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $1.$2.$6.$7.$10.$11.$15.$16;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "25>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_possPron)(($any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $1.$3.$7.$11;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-11b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_number)(\s*)($any_kind_of_pc)/){
	    $subordinated_element = $1.$2.$6.$7;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "24>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)$/){
		$subordinate_subject = $1.$6;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-12b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_adverb|\s)*)($any_kind_of_adj1)((.|\s)*?)($colon)/){
	    $subordinated_element = $1.$2.$7.$11;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "27>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-13b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_determiner|$any_kind_of_adverb|\s)*)($any_kind_of_adj1)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $1.$2.$7.$11;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "15>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($of)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;
		$subordinate_subject = "<w c\=\"w\" p\=\"DT\">the<\/w> ".$subordinate_subject;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-20b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($quotes|\s)*)(($any_kind_of_adj1|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($any_kind_of_prep)//;
		$subordinate_subject = "<w c\=\"w\" p\=\"DT\">the<\/w> ".$subordinate_subject;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-14b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	    elsif($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbd_verb)(\s*)($rp_word)(\s*)$/){
		$subordinate_subject = $1.$6;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-15b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)($vbd_verb)(\s*)($rp_word)(\s*)$/){
		$subordinate_subject = $1.$3.$8.$12;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-16b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_possPron)(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;
		$subordinate_subject =~ s/^($of)//;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-17b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

#	    print STDERR "3>>>>>>>>>>>> \[$subordinated_element\]\n";exit;

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-18b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbn_verb)(\s*)(($any_kind_of_number|$any_kind_of_pc|\s)*)($any_kind_of_number)(\s*)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $&;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "8>>>>>>>>>>>> \[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($any_kind_of_possPron|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

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

		@simpler_sentences[0] = "{SSMA-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-19b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbn_verb)((.|\s)*?)<PC ID\=\"([0-9]+)\" CLASS\=\"ESMA\">([^<]+)<\/PC>/){
	    $subordinated_element = $1.$2.$4;
	    $element_for_deletion = $potential_subordinator.$&;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "4>>>>>>>>>>>> \[$subordinated_element\]\n";
#	    print STDERR "SE \[$subordinated_element\]\n";exit;

	    if($precedes_leftmost_subordinator =~ /(($nnp_noun|\s)*)($nnp_noun)$/){
		$subordinate_subject = $&;

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBZ\">HAVE<\/w> <w c=\"w\" p=\"VBN\">been<\/w> ".$subordinated_element;

		while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
		    $noun = $1;
		}
		if($noun =~ /S$/){
		    $sentence2 =~ s/>HAVE</>have</;
		}
		else{
		    $sentence2 =~ s/>HAVE</>has</;
		}
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}

		@simpler_sentences[0] = "{SSMA-5a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-5b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)<PC ID\=\"([0-9]+)\" CLASS\=\"ESMA\">\,(\s*)which<\/PC>/){
	    $subordinated_element = $1.$2.$4;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$element_for_deletion\E//;

	    print STDERR "6>>>>>>>>>>>> \[$subordinated_element\]\n";
#	    print STDERR "SE \[$subordinated_element\]\n";exit;

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|$quotes|\s)*)($any_kind_of_noun)((\s|$quotes)*)$/){
		$subordinate_subject = $&;
		my $replacement_np = $subordinate_subject;
		$replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
		$replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
		print STDERR "14>>>>>>>>>>>>> \[$replacement_np\]\n";


		$sentence2 = $replacement_np." <w c=\"w\" p=\"VBD\">BE<\/w> ".$subordinated_element;

		while($replacement_np =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
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

		@simpler_sentences[0] = "{SSMA-6a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMA-6b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}

    }
##################################

##################################
    else{
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
	    
	@simpler_sentences[0] = "{SSMA-77a} ".$sentence1.$final_punctuation;
#	print STDERR "\tS1 $sentence1\n\n"; exit;
			
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

    open(ERROR_FILE, ">>./SSMA_errors.txt");
    print ERROR_FILE "$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";
    close(ERROR_FILE);
    
    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;

    unless($precedes_leftmost_subordinator =~ /(believe|hoping)/){
	unless($potential_subordinator =~ />that/ && ($precedes_leftmost_subordinator =~ /(later|apparent|pleased)/ | $precedes_leftmost_subordinator =~ /($ccv_comp_verb)/ | $precedes_leftmost_subordinator =~ />it<\/w>(\s*)<w ([^>]+)>(is|was|\'s)<\/w>(\s*)($any_kind_of_adj1)(\s*)/i)){
	    unless($potential_subordinator =~ /who</ && ($precedes_leftmost_subordinator =~ /($ccv_comp_verb)(\s*)$/ | $precedes_leftmost_subordinator =~ /($ccv_comp_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|\s)*)$/ | $precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"DT\">those<\/w>(\s*)($plural_noun)(\s*)$/ | $precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)<w ([^>]+)>staff<\/w>(\s*)$/ | ($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"DT\">those<\/w>(\s*)$/ && $follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)/) | ($follows_leftmost_subordinator =~ /(($vbd_verb|\s)*)(($any_kind_of_number|$any_kind_of_noun|$any_kind_of_prep|$any_kind_of_determiner|$of|\s)*)/))){
		unless($potential_subordinator =~ /but/ && $follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>only<\/w>(\s*)<w ([^>]+)>if<\/w>/){
		    unless($potential_subordinator =~ /which/ && (($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)/ && $precedes_leftmost_subordinator =~ /<w([^>]+)>events<\/w>(\s*)$/)|($precedes_leftmost_subordinator =~ /<w ([^>]+)>in<\/w>(\s*)$/))){
			unless($potential_subordinator =~ /which/ && (  ($follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>beset<\/w>/)  && ($precedes_leftmost_subordinator =~ /<w ([^>]+)>those<\/w>(\s*)$/) ) ){
			    unless($potential_subordinator =~ /which/ && (  ($follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>the<\/w>/)  && ($precedes_leftmost_subordinator =~ /<w ([^>]+)>under<\/w>(\s*)$/) ) ){
				unless($potential_subordinator =~ /which/ && ($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)$/) ){
#				    print STDERR "SSMA NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
				}
			    }
			}
		    }
		}
	    }
	}
    }

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
    $replacement_pc =~ s/that/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
    
    $sentence1 = $precedes_leftmost_subordinator.$replacement_pc.$follows_leftmost_subordinator;
    
#    print STDERR "$potential_subordinator\n";exit;

    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = "";
    }
	    
    @simpler_sentences[0] = "{SSMA-78a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);
    
}
1;
