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
package SimplifySSCCV;
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
my $html_pound = "<w c\=\"amp\" p\=\"CC\">\&amp\;<\/w><w c\=\"sym\" p\=\"\#\">\#<\/w><w c\=\"cd\" p\=\"CD\">163<\/w><w c\=\"cm\" p\=\"\:\">\;<\/w>";
my $uc_pron = "<w c\=\"w\" p\=\"PRP\">([A-Z])([^<]*)<\/w>";
my $lc_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([a-z])([^<]+)<\/w>";

my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(JJ|NN|VB|VBD|VBG|VBN|VBP|VBZ)\">(accept|accepted|admit|admitted|admitting|agree|allege|alleging|aware|belief|believe|believing|certain|claim|conclude|concluding|convinced|convinc|doubt|fear|feared|find|found|intimate|intimating|hope|hoping|know|knew|known|mean|meant|realise|realising|relate|relating|reveal|revealed|rule|ruling|said|say|scale|show|shown|showed|tell|terrified|think|thought|told)((s|d|ing)?)<\/w>";

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

    print STDERR "PROCESSING\n\t[SSCCV]\n$precedes_leftmost_subordinator\t$potential_subordinator\t$follows_leftmost_subordinator\n";

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

################################### SSCCV #####################################
##############################################################################
##### punctuation-conjunction

    if($potential_subordinator =~ />\,\s+(who)</){
	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){
	    my $terminator = $&;
	    $element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
	    $subordinated_element = $PREMATCH;
	    my $class = "E".$2;

	    print STDERR "1>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";exit;

	    if($potential_subordinator =~ /wh/){

		if($class eq "ESCCV"){
		    if($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
			$subordinate_subject = $&;
			while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			    $subject = $PREMATCH;
			    $subordinate_subject = $&;
			}
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-1a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-1b} ".$sentence2.$final_punctuation;
			
		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
		elsif($class eq "ESMN"){

		    if($precedes_leftmost_subordinator =~ /($any_kind_of_verb)(\s*)/){
			$subordinate_subject;
			while($precedes_leftmost_subordinator =~ /($any_kind_of_verb)(\s*)/g){
			    $subject = $PREMATCH.$&;
			    $subordinate_subject = $POSTMATCH;
			}

			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-2a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-2b} ".$sentence2.$final_punctuation;
			
		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
####################
		elsif($class eq "ESMA"){

		    if($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
			$subordinate_subject = $&;
			while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			    $subject = $PREMATCH;
			    $subordinate_subject = $&;
			}
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-3a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-3b} ".$sentence2.$final_punctuation;
			
		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	}
	else{
	    $subordinated_element = $follows_leftmost_subordinator;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;

	    print STDERR "2>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
		$subordinate_subject = $&;
		while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
		    $subject = $PREMATCH;
		    $subordinate_subject = $&;
		}
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-4a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-4a} ".$sentence2.$final_punctuation;
		
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }	
	}
    }
    elsif($potential_subordinator =~ />\,\s+(which)</){
	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){
	    my $terminator = $&;
	    $element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
	    $subordinated_element = $PREMATCH;
	    my $class = "E".$2;

# Following while loop needed because there are cases when the subordinated CCV contains
# subordinated elements such as NPs (ESMN) and the first encountered ES class is not ESCCV
	    while($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/g){
		$terminator = $&;
		$class = "E".$2;
		$element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
		$subordinated_element = $PREMATCH;
	    

		print STDERR "9>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n\[$precedes_leftmost_subordinator\]\n$class\n";



		if($class eq "ESCCV"){
		    if($precedes_leftmost_subordinator =~ /($vbn_verb)((\s|$comma)*)(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)/){
			$subordinate_subject = $7.$13;
			
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-5a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-5b} ".$sentence2.$final_punctuation;
			
			
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		    elsif($precedes_leftmost_subordinator =~ /($of)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
			$subordinate_subject = $2;
			while($precedes_leftmost_subordinator =~ /($of)(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			    $subject = $PREMATCH;
			    $subordinate_subject = $&;
			}
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-6a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-6b} ".$sentence2.$final_punctuation;
			
		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		    elsif($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
			$subordinate_subject = $&;
			while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			    $subject = $PREMATCH;
			    $subordinate_subject = $&;
			}
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = $subordinate_subject.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-7a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-7b} ".$sentence2.$final_punctuation;
			
		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}

	    }
	} # NO ES SUBORDINATOR FOLLOWS THE INSTANCE IN THE SENTENCE
	else{
	    if($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|\s)*)($any_kind_of_noun)(\s*)($comma)(\s*)($vbn_verb)((.|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3.$12;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-8a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-8b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(\s*)($vb_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$nnp_noun|$any_kind_of_number|$any_kind_of_adj1|$hyphen|$html_pound|\s)*)($any_kind_of_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $&;
		$subordinate_subject =~ s/($to)(\s*)($vb_verb)(\s*)//;

		if($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(\s*)($vbd_verb)(\s*)($any_kind_of_prep)((.|\s)*?)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		    $subordinated_element = $&;
		    my $sub_subj = $2;
		    my $sub_verb = $5;
		    my $sub_prep = $8.$10;

		    $sentence2 = $sub_subj." ".$sub_verb." ".$subordinate_subject." ".$sub_prep;

		    print STDERR "SS $sub_subj\nSV $sub_verb\nSP $sub_prep\n";

		    $sentence1 = $sentence;
#		    $subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		    $element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		    $sentence1 =~ s/\Q$element_for_deletion\E//;

		
		    print STDERR "30>>>>>>>>>>>>>>>\[$subordinated_element\]\n\[$subordinate_subject\]\n";
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-9a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSCCV-9b} ".$sentence2.$final_punctuation;
		
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($to)(($any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|$any_kind_of_adj1|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $5;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-9a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-9b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $7.$9.$10;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-10a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-10b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|$any_kind_of_adj1|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-11b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_possPron|$any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|$any_kind_of_adj1|$of|$to|$quotes|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-12b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possessive|$unclassified_comma|$nnp_noun|$any_kind_of_number|$any_kind_of_noun|$hyphen|\s)*)($any_kind_of_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $6.$19;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-13b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vb_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possessive|$any_kind_of_noun|$of|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $9;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-14b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vb_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|$pound|$hyphen|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3.$15;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-15b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possessive|$any_kind_of_possPron|$any_kind_of_adj1|$any_kind_of_noun|$of|\s)*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $14;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-16a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-16b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|$pound|$hyphen|$any_kind_of_possPron|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3.$16;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator; # safe because we know there
                                                                        # is no ES PC following the
                                                                        # subordinator
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-17a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-17b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(($any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|$any_kind_of_number|$any_kind_of_adj1|$any_kind_of_prep|$any_kind_of_pc|$of|\s)*)($any_kind_of_noun|$nnp_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $2.$20;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator;
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-18a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-18b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($of)(($any_kind_of_determiner|$any_kind_of_noun|$nnp_noun|$any_kind_of_possPron|\s)*)($any_kind_of_noun|$nnp_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $2.$12;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator;
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-19b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun|$nnp_noun)(\s*)$/){ # The case where the end of the sentence ends the subordinated constituent
		$subordinate_subject = $3.$11;
		$sentence1 = $sentence;
		$subordinated_element = $follows_leftmost_subordinator;
		$subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
		$element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-20a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-20b} ".$sentence2.$final_punctuation;
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)/){ # The case where there is no explicit rightmost boundary for the subordinated constituent and it is being guessed on the basis of following verbal elements
		while($follows_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbn_verb)(\s*)($to)/g){
		    $subordinated_element = $PREMATCH;
		}
		print STDERR ">>>>> \[$subordinated_element\] <<<<<<\n";

		$sentence1 = $sentence;
		$element_for_deletion = $potential_subordinator.$subordinated_element;

		if($precedes_leftmost_subordinator =~ /(($any_kind_of_determiner|$any_kind_of_noun|$of|$any_kind_of_number|\s)*)($any_kind_of_noun)$/){
		    $subordinate_subject = $&;


		    $sentence1 =~ s/\Q$element_for_deletion\E//;
		    $sentence2 = $subordinate_subject.$subordinated_element;
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-21a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSCCV-21b} ".$sentence2.$final_punctuation;
		    
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	}
    }
    elsif($potential_subordinator =~ />\,\s+(but)</){
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
		
		@simpler_sentences[0] = "{SSCCV-22a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-22a} ".$sentence2.$final_punctuation;
		
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";  exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);

	    }
	}
    }

##############################################################################
##### conjunction alone
    elsif($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">when<\/PC>/){

	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){
	    while($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/g){
		my $terminator = $&;
		$element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
		$subordinated_element = $PREMATCH;
		my $class = "E".$2;
		my $tail = $POSTMATCH;      	
		
		print STDERR "3>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

		if($class eq "ESCCV"){
		    my $subordinate_subject;
		    
		    $subordinate_subject = $&;
		    
		    
		    $sentence1 = $sentence;
		    $sentence1 =~ s/\Q$element_for_deletion\E//;
		    $sentence2 = "<w c=\"w\" p=\"PRP\">It</w> <w c=\"w\" p=\"VBD\">was</w> <w =\"w\" p=\"WRB\">when</w> ".$subordinated_element;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-23a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSCCV-23b} ".$sentence2.$final_punctuation;
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		    
		}
		elsif($class eq "ESCM"){
		    my $subordinate_subject;
		    if($precedes_leftmost_subordinator =~ /<w c\=\"cd\" p\=\"CD\">(1|2)([0-9]{3})<\/w>(\s*)$/){
			$subordinate_subject = $&;
			
			
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = "<w c\=\"w\" p\=\"IN\">In<\/w> ".$subordinate_subject." ".$subordinated_element.$terminator.$tail;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-24a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-24b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
		elsif($class eq "ESCMN"){
		    my $subordinate_subject;
		    if($precedes_leftmost_subordinator =~ /<w c\=\"cd\" p\=\"CD\">(1|2)([0-9]{3})<\/w>(\s*)$/){
			$subordinate_subject = $&;
			
			
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			$sentence2 = "<w c\=\"w\" p\=\"IN\">In<\/w> ".$subordinate_subject." ".$subordinated_element.$terminator.$tail;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-25a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-25b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	}
	else{
	    while($follows_leftmost_subordinator =~ /<w c\=\"w\" p\=\"IN\">as<\/w>/g){

		my $terminator = $&;
		$element_for_deletion = $potential_subordinator.$PREMATCH;
		$subordinated_element = $PREMATCH;
		my $class = "E".$2;
		my $tail = $POSTMATCH;      	
		    
		    
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = "<w c=\"w\" p=\"PRP\">It</w> <w c=\"w\" p=\"VBD\">was</w> <w =\"w\" p=\"WRB\">when</w> ".$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		    
		@simpler_sentences[0] = "{SSCCV-26a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-26b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
		    
	    }
	    unless($follows_leftmost_subordinator =~ /<PC /){
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WRB\">when<\/w>/g;
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-27a} ".$sentence1.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
    }
############################################
    elsif($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">that<\/PC>/){

# The following conditions enable simplification of certain constructions to be ignored/filtered


	if($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>(($rp_word|\s)*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-28a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"VB\">(say|intimate)<\/w>(\s*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-29a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /^(\s*)<w c\=\"w\" p\=\"VBG\">([A-Z]+)([^<]+)ing<\/w>(\s*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-30a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /($vbz_verb)(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_adj1)(\s*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-31a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($any_kind_of_determiner)(($quotes|\s)*)((.|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $&;
	    $matrix_np =~ s/^($vbd_verb)(\s*)($any_kind_of_noun)(\s*)($of)//;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>an<\/w>/$1<w $2>that<\/w>/;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>that<\/w>/;

	    print STDERR "38>>>>>>>>>>>>>\[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($vbz_verb)(\s*)($any_kind_of_determiner)((.|\s)*)(($quotes|\s)*)($any_kind_of_sentence_boundary)(\s*)/){
		$subordinated_element = $&;
		$subordinated_element =~ s/(($quotes|\s)*)($any_kind_of_sentence_boundary)(\s*)$//;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-32b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"DT\">(an|a)<\/w>(\s*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $&;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($vbd_verb)(\s*)($vbd_verb)/){
		$subordinated_element = $1.$2.$5.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-32b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC $subordinated_element\n";
		
		@simpler_sentences[0] = "{SSCCV-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-33b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /SABOTAGE(($any_kind_of_sentence_boundary|\s)*)$/){
		$subordinated_element = $PREMATCH;
		$element_for_deletion = $potential_subordinator.$subordinated_element;

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;


		$sentence2 = $subordinated_element.$replacement_np;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-34b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"VBN\">ruled<\/w>(($any_kind_of_prep|\s))(($any_kind_of_noun|$any_kind_of_determiner|$any_kind_of_prep|\s)*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-35a} ".$sentence1.$final_punctuation;

#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"(VBD|VBN)\">told<\/w>(($any_kind_of_noun|$any_kind_of_pron|$any_kind_of_determiner|$any_kind_of_prep|\s)*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-36a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"(VBD|VBN)\">said<\/w>(($any_kind_of_noun|$any_kind_of_adj1|$any_kind_of_determiner|$any_kind_of_prep|\s)*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-37a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
	elsif($precedes_leftmost_subordinator =~ /($of)(\s*)($any_kind_of_determiner)(\s*)(($any_kind_of_noun|$of|\s)*)($any_kind_of_noun)(\s*)$/){
	    $sentence1 = $sentence;
	    $subordinate_subject = $&;
	    $subordinate_subject =~ s/^($of)(\s*)//;

	    if($follows_leftmost_subordinator =~ /($lc_noun)(\s*)($uc_pron)/){
		$subordinated_element = $PREMATCH.$1;

		$element_for_deletion = $potential_subordinator.$subordinated_element;		
		$sentence1 =~ s/$element_for_deletion//;

		$sentence2 = $subordinate_subject.$subordinated_element;

		$sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-38a} ".$sentence1.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"VBD\">was<\/w>(\s*)<w c\=\"w\" p\=\"VBN\">realised<\/w>(\s*)$/){
	    $sentence1 = $sentence;
	    $sentence1 =~ s/\Q$potential_subordinator\E/<w c\=\"w\" p\=\"WDT\">that<\/w>/;
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-38a} ".$sentence1.$final_punctuation;
#	    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}


	else{
	    $subordinated_element = $follows_leftmost_subordinator;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    print STDERR "4>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";
	    my $head_noun;
	    if($precedes_leftmost_subordinator =~ /(($any_kind_of_determiner|\s)*)($any_kind_of_noun)/){
# recently added $any_kind_of_possPron below 21/06/2012
		while($precedes_leftmost_subordinator =~ /(($any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)/g){
		    $subordinate_subject = $&;
#		    $head_noun = $4;# before addition of $any_kind_of_possPron
		    $head_noun = $5;

#		    print STDERR "\[$head_noun\]\n$precedes_leftmost_subordinator\n";#exit;

# recently added "worry" below 21/06/2012
		    if($head_noun =~ />(possibility|likelihood|fact|probablity|worry)</){
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
    
#			print STDERR "$potential_subordinator\n";exit;

			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
	    
			@simpler_sentences[0] = "{SSCCV-39a} ".$sentence1.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
		if($precedes_leftmost_subordinator =~ /($any_kind_of_pron)(\s*)($vbd_verb)(\s*)<w ([^>]+)>only<\/w>(\s*)<PC ([^>]+)>when<\/PC>/){
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
		    
#		    print STDERR "$potential_subordinator\n";exit;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-105a} ".$sentence1.$final_punctuation;
#		    print STDERR "\tS1 $sentence1\n\n"; exit;
			
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject.$subordinated_element;

		if($sentence1 =~ /<([^>]+)>underestimate<([^>]+)> <([^>]+)>the<([^>]+)> <([^>]+)>effects<([^>]+)>/){
#		    exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		@simpler_sentences[0] = "{SSCCV-40a} ".$sentence1.$final_punctuation;
#		@simpler_sentences[1] = "{SSCCV-40b} ".$sentence2.$final_punctuation;
		
		if($sentence1 =~ /seriously/){
#		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n";exit;
		}
		
#		$simpler_sentences_ref = \@simpler_sentences;
#		return($simpler_sentences_ref);		
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_noun)/){
		while($precedes_leftmost_subordinator =~ /($any_kind_of_noun)/g){
		    $subordinate_subject = $&;
		}
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = "<w c\=\"w\" p\=\"DT\">The<\/w> ".$subordinate_subject.$subordinated_element;

		if($sentence1 =~ /<([^>]+)>underestimate<([^>]+)> <([^>]+)>the<([^>]+)> <([^>]+)>effects<([^>]+)>/){
#		    exit;
		}

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		@simpler_sentences[0] = "{SSCCV-41a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-41b} ".$sentence2.$final_punctuation;
		
		
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; # exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);		
	    }
	    else{
		if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){
		
		}
	    }
	}

    }
##############################################################################
    elsif($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">which<\/PC>/){
	if($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbg_verb)(\s*)($any_kind_of_determiner)((.|\s)*)$/){
	    my $matrix_np = $7.$9;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    print STDERR "14>>>>>>>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_adverb|\s)*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$6.$8;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-42a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-42b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vb_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($of)(\s*)($subordinating_that)(\s*)$/){
	    my $matrix_np = $7.$9.$17.$18.$19.$22;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    print STDERR "19>>>>>>>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($er_noun)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_adj1)(\s*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$6.$7.$9.$10.$12.$13;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-80a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-80b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vb_verb)(\s*)($any_kind_of_adj1)(\s*)($plural_noun)(\s*)$/){
	    my $matrix_np = $4.$8.$9;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;

	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>(the)<\/w>/){
		$replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$replacement_np;
	    }
	    print STDERR "36>>>>>>>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_modal)(\s*)($vb_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-80a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-80b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /<w c\=\"w\" p\=\"DT\">(an|a)<\/w>(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $&;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    print STDERR "18>>>>>>>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($vbd_verb)(\s*)($vbd_verb)/){
		$subordinated_element = $1.$2.$5.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-42a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-42b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(($any_kind_of_modal|$vb_verb|$vbn_verb|\s)*)($vbn_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$6.$8;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		print STDERR "$sentence1\n";
		$sentence1 =~ s/\Q$element_for_deletion\E//;

#		print STDERR "EFD $element_for_deletion\n$sentence1\n";exit;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-79a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-79b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($nnp_noun)(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$6.$7.$9;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = "<w c=\"w\" p=\"PRP\">It</w> <w c=\"w\" p=\"VBD\">was</w> ".$replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-43a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-43b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(($any_kind_of_adverb|\s)*)($vbp_verb)((.|\s)*?)$/){
		$subordinated_element = $1.$2.$4.$8.$10;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $subordinated_element.$replacement_np;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-44a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-44b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($colon)((.|\s)*?)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4.$5.$8;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-45a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-45b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-86a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-86b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_possPron|$plural_noun)((.|\s)*?)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4.$5.$13;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-86a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-86b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($of)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($any_kind_of_prep)(\s*)($nnp_noun)(\s*)$/){
	    my $matrix_np = $6.$8.$16.$18.$19.$23;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;

	    print STDERR "10>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_determiner)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-46a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-46b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_determiner|$any_kind_of_number)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)($plural_noun)(\s*)$/){
	    my $matrix_np = $4.$8.$16;
	    my $replacement_np = $matrix_np;
	    if($replacement_np !~ /(\s*)($any_kind_of_determiner)/){
		$replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$replacement_np;
	    }
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;


	    print STDERR "15>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbp_verb)(($any_kind_of_determiner|$any_kind_of_noun|$of|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-47a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-47b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_prep)(($any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $6.$9.$13;
	    my $replacement_np = $matrix_np;
	    if($replacement_np !~ /(\s*)($any_kind_of_determiner|$any_kind_of_possPron)/){
		$replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$replacement_np;
	    }
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;


	    print STDERR "25>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-84a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-84b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$nnp_noun|\s)*)($nnp_noun)(\s*)$/){
	    my $matrix_np = $4.$7.$14;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;

	    print STDERR "3>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($vbd_verb)(\s*)($vbd_verb)/){
		$subordinated_element = $1.$2.$5.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-48a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-48b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-49a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-49b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^SABOTAGE(\s*)($vbd_verb)((.|\s)*?)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-50a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-50b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($plural_noun)(($any_kind_of_prep|$any_kind_of_possPron|\s)*)($plural_noun)(\s*)$/){
	    my $matrix_np = $4;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
#	    unless($replacement_np =~ /^(\s*)($plural_noun)/){
	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;
#	    }


	    print STDERR "34>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_pron)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC \[$subordinated_element\]\n";# exit;
		
		@simpler_sentences[0] = "{SSCCV-51a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-51b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$nnp_noun|\s)*)($of)(\s*)($plural_noun)(\s*)$/){
	    my $matrix_np = $16;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;


	    print STDERR "1>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|\s)*)($vbn_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$8.$10;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-51a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-51b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$nnp_noun|\s)*)($of)(\s*)($any_kind_of_number)(\s*)$/){
	    my $matrix_np = $9.$10.$12.$20.$21.$22.$25;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;

	    print STDERR "22>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbz_verb)(\s*)($to)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$6;
		$sentence2 = $replacement_np.$subordinated_element;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

#		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-81a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-81b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbn_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$nnp_noun|\s)*)($of)(\s*)($plural_noun)(\s*)$/){
	    my $matrix_np = $7.$9.$17.$18.$19;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;

	    print STDERR "20>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(($any_kind_of_modal|$vb_verb|\s)*)($any_kind_of_prep)(\s*)($any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$8.$10.$11.$14.$15;
		$sentence2 = $1.$2.$4.$replacement_np.$5.$8.$10.$11.$14.$15;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

#		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-81a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-81b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_adj1|$any_kind_of_noun|$hyphen|\s)*)($plural_noun)(\s*)$/){
	    my $matrix_np = $3.$12;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;


	    print STDERR "11>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|\s)*)($vbn_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$8.$10;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-52b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(\s*)($vbp_verb)(\s*)($vbn_verb)(\s*)($any_kind_of_prep)/){
		$subordinated_element = $1.$2.$4.$5.$7.$8.$10;

		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $subordinated_element.$replacement_np;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-88a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-88b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_adverb|$any_kind_of_noun|$hyphen|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $3.$15;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;



#	    print STDERR "17>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_modal|\s)*)($vb_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-52b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-52b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$of|$any_kind_of_adj1|\s)*)($plural_noun)(\s*)$/){
	    my $matrix_np = $7.$9.$17;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
#	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;


	    print STDERR "12>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_possPron)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-53b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbz_verb)(($any_kind_of_determiner|$any_kind_of_number|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(($any_kind_of_prep|$any_kind_of_number|\s)*)$/){
	    my $matrix_np = $3.$11.$15;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/^(\s*)($any_kind_of_number)/$1<w c\=\"w\" p\=\"DT\">the<\/w> $2/;
#	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;


	    print STDERR "16>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_prep)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC \[$subordinated_element\]\n";
		
		@simpler_sentences[0] = "{SSCCV-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-53b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbz_verb)(($any_kind_of_adverb|\s)*)($vb_verb)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $9.$12;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>the<\/w>/;
	    $replacement_np =~ s/^(\s*)($any_kind_of_number)/$1<w c\=\"w\" p\=\"DT\">the<\/w> $2/;
#	    $replacement_np = "<w c=\"w\" p=\"DT\">the</w> ".$matrix_np;


	    print STDERR "21>>>>>>>>> \[$replacement_np\]\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(($vbz_verb|\s)*)($vbn_verb)(\s*)($any_kind_of_pron)(\s*)($to)(\s*)($any_kind_of_prep)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$7.$9.$10.$12.$13.$14.$15.$17;
		$sentence2 = $1.$2.$4.$7.$9.$10.$12.$13.$14.$replacement_np.$14.$15.$17;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

#		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC \[$subordinated_element\]\n";
		
		@simpler_sentences[0] = "{SSCCV-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-53b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($nnp_noun|$any_kind_of_number)(\s*)($any_kind_of_noun)(\s*)($of)(\s*)($plural_noun)(\s*)$/){
	    my $matrix_np = $4.$10.$11.$15.$16.$17.$18.$22;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

	    print STDERR "24>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /^(($nnp_noun|\s)*)($nnp_noun)(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$6.$10.$11.$13;
		my $subordinated_subject = $1.$6;
		my $subordinated_vp = $10.$11.$13;
		$sentence2 = $subordinated_subject.$subordinated_vp." ".$replacement_np;


		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
						
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-60a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-60b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }


	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($plural_noun)(\s*)($of)(($any_kind_of_noun|$nnp_noun|\s)*?)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $3.$4.$8.$9.$10.$18.$22;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    $replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;

	    print STDERR "26>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-82a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-82b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)($quotes)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-85a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-85b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    

	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|$nnp_noun|\s)*)($any_kind_of_noun)((\s|$hyphen)*)$/){
	    my $matrix_np = $3.$4.$15;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>(that|the)<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }
#provision of accommodation

	    print STDERR "35>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-82a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-82b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_modal|\s)*)($vb_verb)((.|\s)*?)($hyphen)/){
		$subordinated_element = $1.$2.$5.$7;
# DELETING THE FOLLOWING HYPHEN
		$element_for_deletion = $potential_subordinator.$subordinated_element.$9;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-85a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-85b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(($any_kind_of_adverb|\s)*)($vbd_verb)(\s*)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$4.$8;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		


		$sentence2 = $subordinated_element." ".$replacement_np;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-102a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-102b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)((.|\s)*?)($vb_verb)(($quotes|\s)*)($any_kind_of_pc)/){
		$subordinated_element = $1.$2.$4.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		

		$sentence2 = $subordinated_element.$replacement_np;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-103a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-103b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }	    

# Following condition causes an error in "Although the events which led to Francis's arrest occurred..."
	    elsif($follows_leftmost_subordinator =~ /^SABOTAGE((\s|$any_kind_of_adverb)*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		


		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC \[$subordinated_element\]\n";
		
		@simpler_sentences[0] = "{SSCCV-104a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-104b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_adj1|$nnp_noun|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(\s*)($vbg_verb)(\s*)($any_kind_of_noun)((\s|$hyphen)*)$/){
	    my $matrix_np = $3.$4.$15.$19.$20.$22.$23.$25.$26;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>(that|the)<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }
#provision of accommodation

	    print STDERR "37>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-82a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-82b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$4;
# DELETING THE FOLLOWING HYPHEN
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-85a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-85b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_noun)(\s*)($quotes)(($any_kind_of_pc|$quotes|$of|$any_kind_of_determiner|$any_kind_of_noun|\s)*)($quotes)(\s*)$/){
	    my $matrix_np = $1;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

	    print STDERR "30>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-91a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-91b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)((.|\s)*?)($vb_verb)(\s*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		

		$sentence2 = $subordinated_element." ".$replacement_np;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-98a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-98b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_noun)(\s*)($of)(($any_kind_of_noun|$nnp_noun|\s)*?)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $7.$15.$19;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

	    print STDERR "23>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-90a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-90b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)((.|\s)*?)($vb_verb)(($quotes|\s)*)($any_kind_of_pc)/){
		$subordinated_element = $1.$2.$4.$6;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		

		$sentence2 = $subordinated_element.$replacement_np;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-92a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-92b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }

	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_number|\s)*)($plural_noun)(\s*)$/){
	    my $matrix_np = $3.$7.$11;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    $replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;

	    print STDERR "27>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-93a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-93b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}

	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_pron)(\s*)(($any_kind_of_adverb|\s)*)($vbd_verb)(\s*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$9.$11;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $subordinated_element." ".$replacement_np;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-94a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-94b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		    
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-95a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-95b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }		    
	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_determiner)(\s*)($quotes)((.|\s)*?)($quotes)(\s*)$/){
	    my $matrix_np = $3.$4.$6.$7.$12.$14.$19;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>an<\/w>/$1<w $2>that<\/w>/;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>the<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }

	    print STDERR "29>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-96a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-96b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_prep)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
			
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-89a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-89b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($of)(\s*)($any_kind_of_determiner|$any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_pc|$any_kind_of_adj1|$nnp_noun|\s)*)($any_kind_of_noun)(\s*)($hyphen)(\s*)$/){
	    my $matrix_np = $2.$3.$6.$20.$24;# .$25.$27;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>that<\/w>/|$replacement_np =~ /^(\s*)($any_kind_of_possPron)/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }

	    print STDERR "31>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-97a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-97b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbz_verb)(\s*)($vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-97a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-97b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($colon)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$comma|$any_kind_of_adj1|$any_kind_of_pc|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $4.$5.$7.$20;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>that<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }

	    print STDERR "28>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-97a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-97b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbz_verb)(\s*)($vbn_verb)((.|\s)*)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$4.$5.$7;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
			
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-87a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-87b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vb_verb)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $3.$6.$10;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>an<\/w>/$1<w $2>that<\/w>/;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>(the|this)<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }

	    print STDERR "33>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-96a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-96b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(\s*)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-100a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-100b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($bound_jj)((.|\s)*?)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$5;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-101a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-101b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /(<w ([^>]+)>had<\/w>)(\s*)(<w ([^>]+)>this<\/w>)(\s*)(<w ([^>]+)>thrust<\/w>)(\s*)(<w ([^>]+)>upon<\/w>)(\s*)($any_kind_of_pron)(\s*)$/){
	    my $matrix_np = $4;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>an<\/w>/$1<w $2>that<\/w>/;
	    $replacement_np =~ s/^(\s*)<w ([^>]+)>a<\/w>/$1<w $2>that<\/w>/;
	    unless($replacement_np =~ /^(\s*)<w ([^>]+)>(the|this)<\/w>/){
		$replacement_np = "<w c=\"p\" p=\"DT\">the</w> ".$replacement_np;
	    }

	    print STDERR "32>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>/){
		my $fes_class = "ES".$2;
		if($fes_class eq "ESMN"){
		    if($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*?)($comma)(\s*)($vbd_verb)/){
			$subordinated_element = $1.$2.$4;
			$element_for_deletion = $potential_subordinator.$subordinated_element;
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;
			
			$sentence2 = $replacement_np.$subordinated_element;
			
			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
#			print STDERR "SC $subordinated_element\n";exit;
		
			@simpler_sentences[0] = "{SSCCV-96a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-96b} ".$sentence2.$final_punctuation;
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_modal)(\s*)($vb_verb)(\s*)($vbn_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(($quotes|\s)*)$/){
		$subordinated_element = $1.$2.$4.$5.$7.$8.$10;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		
		$sentence2 = $replacement_np.$subordinated_element;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC \[$subordinated_element\]\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-99a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-99b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
##############################################################################
    elsif($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">who<\/PC>/){
#	if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_adverb|$special_adverb)(\s*)($any_kind_of_prep)((\s|\.)*)$/){
	if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_adverb|$special_adverb)(\s*)($any_kind_of_prep)((\s|.)*)$/){
	    my $determiner = $4;
	    my $matrix_noun = $6;

	    if($determiner !~ /([A-Za-z0-9]+)/){
		if($matrix_noun =~ /p\=\"(NNS|NNPS)\"/){
		    $determiner = "<w c\=\"w\" p\=\"DT\">these<\/w> ";
		}
	    }

	    my $matrix_np = $determiner.$matrix_noun;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

#	    print STDERR "######## $matrix_np\n";exit;

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbp_verb)((.|\s)*)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-54a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-54b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($nnp_noun)((\s|$hyphen)*)$/){
	    my $matrix_np = $4;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

#	    print STDERR "######## $matrix_np\n";exit;

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbp_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-55a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-55b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence1 =~ s/($hyphen)(($any_kind_of_sentence_boundary|\s)*)$/$3/;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-56a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-56b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_noun|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $3.$8;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;
	    $replacement_np  = "<w c=\"w\" p=\"p\">the<\/w> ".$replacement_np;

	    print STDERR "2######## \[$matrix_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)(($any_kind_of_number|$any_kind_of_prep|\s)*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$7.$9;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-57a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-57b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_prep)(\s*)($nnp_noun)(\s*)$/){
	    my $matrix_np = $7;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/i;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/i;

#	    print STDERR "######## $matrix_np\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|$vbn_verb|\s)*)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$5.$6.$9;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
		print STDERR "SC \[$subordinated_element\]\n";
		
		@simpler_sentences[0] = "{SSCCV-58a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-58b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|$vbn_verb|\s)*)((.|\s)*)$/){
		$subordinated_element = $&;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-59a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-59b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(($of|$any_kind_of_noun|\s)*)$/){
	    my $determiner = $3;
	    my $matrix_noun = $6.$10;
	    my $matrix_np = $3.$6.$10;

	    if($determiner !~ /([A-Za-z0-9]+)/){
		if($matrix_noun =~ /p\=\"(NNS|NNPS)\"/){
		    $determiner = "<w c\=\"w\" p\=\"DT\">these<\/w> ";
		}
	    }

	    my $matrix_np = $determiner.$matrix_noun;
	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

	    print STDERR ">>> $replacement_np\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbp_verb)((.|\s)*)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-83a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-83b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-61a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-61b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|$vbn_verb|\s)*)((.|\s)*)$/){
		$subordinated_element = $&;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-62a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-62b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbz_verb)(($any_kind_of_adverb|$vbn_verb|\s)*)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)($any_kind_of_prep)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)/){
		$subordinated_element = $&;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-63a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-63b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|$any_kind_of_possPron|\s)*)($any_kind_of_noun)(($any_kind_of_pc|$any_kind_of_noun|\s)*)$/){
	    my $determiner = $3;
	    my $matrix_noun = $6.$10;
	    my $matrix_np = $3.$7.$11;

	    if($determiner !~ /([A-Za-z0-9]+)/){
		if($matrix_noun =~ /p\=\"(NNS|NNPS)\"/){
		    $determiner = "<w c\=\"w\" p\=\"DT\">these<\/w> ";
		}
	    }

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/;

	    print STDERR "13>>>>>>>>> \[$replacement_np\]\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)((\s|$quotes)*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-64a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-64b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

	elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)($any_kind_of_prep)(\s*)($plural_noun)(\s*)$/){
	    my $matrix_np = $7;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/i;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/i;
	    $replacement_np = "<w c=\"w\" p=\"DT\">those<\/w> ".$replacement_np;

	    print STDERR "######## $matrix_np\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($any_kind_of_adverb|$vbn_verb|\s)*)((.|\s)*)$/){
		$subordinated_element = $&;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-65a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-65b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /($quotes)(\s*)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $7.$10.$14;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w $1>that<\/w>/i;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w $1>that<\/w>/i;

	    print STDERR "######## $matrix_np\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($vbn_verb|$any_kind_of_prep|$any_kind_of_noun|$to|$vb_verb|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-66a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-66b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_leftmost_subordinator =~ /^(($any_kind_of_determiner|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
	    my $matrix_np = $&;

	    my $replacement_np = $matrix_np;
	    $replacement_np =~ s/<w ([^>]+)>an<\/w>/ <w c\=\"w\" p\=\"DT\">that<\/w>/i;
	    $replacement_np =~ s/<w ([^>]+)>a<\/w>/ <w c\=\"w\" p\=\"DT\">that<\/w>/i;
	    $replacement_np =~ s/<w ([^>]+)>one<\/w>/ <w c\=\"w\" p\=\"DT\">that<\/w>/i;

	    print STDERR "######## $replacement_np\n";

	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\"><\/PC>/){
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($vbn_verb|$any_kind_of_prep|$any_kind_of_noun|$to|$vb_verb|$any_kind_of_adj1|$any_kind_of_determiner|\s)*)($vbd_verb)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-67a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-67b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /^(\s*)($vbd_verb)(($vbd_verb|\s)*)($vbn_verb)(\s*)($any_kind_of_prep)/){
		$subordinated_element = $1.$2.$4;
		$element_for_deletion = $potential_subordinator.$subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $replacement_np.$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		
#		print STDERR "SC $subordinated_element\n";exit;
		
		@simpler_sentences[0] = "{SSCCV-68a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-68b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; exit;
			
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

    }
##############################################################################
###### punctuation
    elsif($potential_subordinator =~ />(\,|\;|\:)</){
	my $subordinator = $1;

	
	if($precedes_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">/){
	    print STDERR "\n\n1\n\n";
	    if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"CMN1\">([^<]+)<\/PC>/){
		my $possible_subordinated_element = $PREMATCH;
		my $possible_terminator = $&;



		if($possible_subordinated_element =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"(E|S)([^\"]+)\">/){
#		    print STDERR "HERE\n";exit;
		}
		else{
		    $subordinated_element = $possible_subordinated_element;
		    my $terminator = $possible_terminator;
		    $element_for_deletion = $potential_subordinator.$possible_subordinated_element;
		    $main_clause = $precedes_leftmost_subordinator;

		    $sentence1 = $sentence;
		    $sentence1 =~ s/\Q$element_for_deletion\E//;

		    print STDERR "5>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

		    print STDERR "\n\nBranch1\n\n";

		    if($possible_subordinated_element =~ /^(\s*)($whose)/){
#			print STDERR "\tSE $subordinated_element\n\tMC $main_clause\n";
			my $this_whose = $&;
			my $replacement_for_whose;



			while($main_clause =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)/g){
			    $replacement_for_whose = $&."<w c=\"aposs\" p\=\"POS\">\'s</w> ";
			}
			$sentence2 = $subordinated_element;
			$sentence2 =~ s/\Q$this_whose\E/$replacement_for_whose/;

			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}
			
			@simpler_sentences[0] = "{SSCCV-69a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSCCV-69b} ".$sentence2.$final_punctuation;

		    
#			print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; # exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);



#			print STDERR "\tS2 $sentence2\n";exit;

# Now need to replace whose by a preceding NP in the subordiate clause
		    }


		}
	    }
# looking for another terminator of the subordinated element
# First, the last verb in the remaining sentence
	    elsif($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"ESCCV\">([^<]+)<\/PC>/){
		my $subordinated_element = $PREMATCH;
		my $terminator = $&;
		my $noun;
		$element_for_deletion = $potential_subordinator.$subordinated_element.$terminator;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		print STDERR "6>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

		while($precedes_leftmost_subordinator =~ /($any_kind_of_verb)/g){
		    $subordinate_subject = $POSTMATCH;
		}

		$sentence2 = $subordinate_subject." <w c=\"w\" p=\"VBD\">BE</w>  ".$subordinated_element;

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
		
		@simpler_sentences[0] = "{SSCCV-70a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-70b} ".$sentence2.$final_punctuation;
#		print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; # exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($follows_leftmost_subordinator =~ /($any_kind_of_verb)/){
		my $possible_subordinated_element;
		while($follows_leftmost_subordinator =~ /($any_kind_of_verb)/g){
		    $possible_subordinated_element = $PREMATCH;
		}
		$element_for_deletion  = $potential_subordinator.$possible_subordinated_element;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;
		
		$sentence2 = $element_for_deletion;
		$main_clause = $precedes_leftmost_subordinator;
		
		    
		if($possible_subordinated_element =~ /^(\s*)($whose)/){
#			    print STDERR "\tSE $subordinated_element\n\tMC $main_clause\n";
		    my $this_whose = $&;
		    my $replacement_for_whose;
		    
		    
		    
		    while($main_clause =~ /(($any_kind_of_noun|\s)*)($any_kind_of_noun)/g){
			$replacement_for_whose = $&."<w c=\"aposs\" p\=\"POS\">\'s</w> ";
		    }
		    $sentence2 = $subordinated_element;
		    $sentence2 =~ s/\Q$this_whose\E/$replacement_for_whose/;
		    
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-71a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSCCV-71b} ".$sentence2.$final_punctuation;
		    
		    
		    print STDERR "\tS1 $sentence1\n\tS2 $sentence2\n"; # exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
		else{
		    $subordinated_element = $follows_leftmost_subordinator;
		    $element_for_deletion = $potential_subordinator.$follows_leftmost_subordinator;
		    $main_clause = $precedes_leftmost_subordinator; 
		    
#		    $sentence1 = $main_clause."<w c\=\"cm\" p\=\"\,\">".$subordinator."</w> <I>".$subordinated_element."</I>";
		    $sentence1 = $main_clause."<w c\=\"cm\" p\=\"\,\">".$subordinator."</w> ".$subordinated_element;
		    $sentence1 =~ s/(\s+)/ /g;

		    print STDERR "7>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";
		
		    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			$final_punctuation = "";
		    }
		    
		    @simpler_sentences[0] = "{SSCCV-72a} ".$sentence1.$final_punctuation;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
# Preven "return" here to stop redundant sentences being added to the output
		    return($simpler_sentences_ref);
		}
		
	    }

	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_prep)((.|\s)*?)<PC ID\=\"([0-9]+)\" CLASS\=\"ESCCV\">([^<]+)<\/PC>/){
	    my $prep = $2;
	    my $follows_prep = $4;
	    $subject = $PREMATCH.$1;
	    my $space1 = $1;
	    my $right_boundary = "<PC ID=\"".$6."\" CLASS=\"ESCCV\">".$7."</PC>";

	    $subordinated_element = $4;


#	    print STDERR ">>> $follows_prep\n";exit;

	    if($prep =~ /because/i){
		$subordinated_element = $follows_prep;
		$element_for_deletion = $potential_subordinator.$space1.$prep.$subordinated_element.$right_boundary;

		print STDERR "\[$element_for_deletion\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = "<w c\=\"w\" p\=\"DT\">This<\/w> <w c\=\"w\" p\=\"VBZ\">is<\/w> $prep ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
	    
		@simpler_sentences[0] = "{SSCCV-73a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-73b} ".$sentence2.$final_punctuation;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
	    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($prep =~ />as</i){
		$subordinated_element = $follows_prep;
		$element_for_deletion = $potential_subordinator.$space1.$prep.$subordinated_element.$right_boundary;

		print STDERR "\[$element_for_deletion\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = "<w c\=\"w\" p\=\"DT\">This<\/w> <w c\=\"w\" p\=\"VBZ\">is<\/w> $prep ".$subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
	    
		@simpler_sentences[0] = "{SSCCV-74a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-74b} ".$sentence2.$final_punctuation;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
	    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    else{
		$subordinated_element = $follows_prep;
		$element_for_deletion = $potential_subordinator.$space1.$prep.$subordinated_element.$right_boundary;

		print STDERR "\[$element_for_deletion\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		$sentence2 = $subordinated_element;

		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
	    
		@simpler_sentences[0] = "{SSCCV-75a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSCCV-75b} ".$sentence2.$final_punctuation;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
	    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
################################################
	else{
#	    print STDERR "HERE2";exit;
	    $subordinated_element = $precedes_leftmost_subordinator;
	    $element_for_deletion = $precedes_leftmost_subordinator.$potential_subordinator;
	    $main_clause = $follows_leftmost_subordinator; 

	    print STDERR "8>>>>>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";
	    
	    $sentence1 = $subordinated_element."<w c\=\"cm\" p\=\"\,\">".$subordinator."</w> ".$main_clause;
	    
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    
	    @simpler_sentences[0] = "{SSCCV-76a} ".$sentence1.$final_punctuation;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
# Not returning this duplicate sentence
	    return($simpler_sentences_ref);
	
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
	    
	@simpler_sentences[0] = "{SSCCV-77a} ".$sentence1.$final_punctuation;
#	print STDERR "\tS1 $sentence1\n\n"; exit;
			
	$simpler_sentences_ref = \@simpler_sentences;
	return($simpler_sentences_ref);
    }

    open(ERROR_FILE, ">>./SSCCV_errors.txt");
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
#				    print STDERR "SSCCV NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
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
	    
    @simpler_sentences[0] = "{SSCCV-78a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);
    
}
1;
