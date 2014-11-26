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
# Note that when following pleonastic "it", the word "that" should not be 
# simplified. The preceding verb "to be" has a clause complement and the 
# sentence is describing/evaluating the following clause.
package TagNounModifiers;
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
my $singular_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NN|NNP)\">([^<]+)<\/w>";
my $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
my $any_kind_of_adj1 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_subordinator = "<PC ([^>]+)>(that|which)<\/PC>";
my $any_right_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>";
my $any_left_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">([^<]+)<\/PC>";
my $any_phrasal_coordinator = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CC|CM)([^\"]+)\">([^<]+)<\/PC>";
my $any_coordinator = "<PC ID\=\"([0-9]+)\" CLASS\=\"C([^\"]+)\">([^<]+)<\/PC>";
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

# Possibly, the phrase "worked out" should be included as a $ccv_comp_verb
my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(JJ|NN|VB|VBD|VBG|VBN|VBP|VBZ)\">(accept|accepted|acknowledg|acknowledge|add|added|admission|admit|admitted|admitting|agree|allegation|allege|alleging|announce|announc|answer|answered|apparent|appreciate|appreciated|argue|arguing|aware|belief|believe|believing|certain|claim|claimed|clear|complain|complained|concern|concerned|conclude|concluding|confirm|confirmed|convinced|convinc|decide|deciding|demonstrate|demonstrat|denied|deny|disappoint|disappointed|disclose|disclosing|discover|discovered|doubt|dread|emerge|emerged|emphasising|emphasise|ensur|ensure|establish|established|expect|expectation|expected|explain|explained|fear|feared|feel|felt|find|found|given|guess|guessed|illustrat|illustrate|indicate|indicated|infer|inferring|inferred|inference|insist|insisted|intimate|intimating|hear|held|hold|hope|hoping|implie|imply|is|know|knew|known|learn|learned|maintain|maintained|manner|mean|meant|noting|note|obvious|order|ordered|plain|possible|promising|promise|protested|protest|prov|prove|providing|provide|recording|realise|realising|recognis|recognise|recogniz|recognize|recommend|recommended|read|realis|realise|record|recorded|relate|relating|remain|report|reported|retort|retorted|reveal|revealed|rule|ruling|said|satisfie|satisfy|saw|say|scale|see|show|shown|showed|state|stating|suggest|suggested|suspect|suspected|tell|terrified|testify|testifie|think|thought|told|view|warn|warned|was|way)((s|d|ing)?)<\/w>";

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

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }


    my $left_boundary_class;
    my $right_boundary_class;
    my $alternate_right_boundary_class = "GGGGG";
    if($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"S([^\"]+)\">([^<]+)<\/PC>/){
	$left_boundary_class = "S".$2;
	$right_boundary_class = "E".$2;

	my $class = $2;
	my $sign = $3;

	if($left_boundary_class =~ /SSMN/){
	    $alternate_right_boundary_class = "(CMN1|ESMP)";
	}
	elsif($left_boundary_class =~ /SSMA/){
	    $alternate_right_boundary_class = "(CMN1)";
	}

	print STDERR "PROCESSING\n\t[$left_boundary_class]\n$precedes_leftmost_subordinator\t$potential_subordinator\t$follows_leftmost_subordinator\n";

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



    if($potential_subordinator =~ />\,\s+([^<]+)</){
#	print STDERR ">>>>>> $potential_subordinator\n";exit;

	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"$right_boundary_class\">([^<]+)<\/PC>/){
	    my $follows_subordination = $POSTMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    my $boundary = $&;
	    my $modifier = $PREMATCH;
	    $boundary =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;
#	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier.$boundary."[/MODIFIER]".$follows_subordination;
#	    $sentence1 = $precedes_leftmost_subordinator." ".$POSTMATCH;
	    
	    @simpler_sentences[0] = "{RNM-1} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS1 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}


	elsif($follows_leftmost_subordinator =~ /($any_kind_of_sentence_boundary)/){
	    my $boundary = $&;
	    my $follows_subordination = $POSTMATCH;
	    my $modifier = $PREMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-2} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS3 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}
    }

##############################################################################
##### conjunction alone
    elsif($potential_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">([^\,\;\:]+)<\/PC>/i){


	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"$right_boundary_class\">([^<]+)<\/PC>/){
	    my $boundary = $&;
	    my $follows_subordination = $POSTMATCH;
	    my $modifier = $PREMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-3} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS4 $sentence1\n"; exit;
	    
	    if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
	elsif($follows_leftmost_subordinator =~ /($any_kind_of_sentence_boundary)/){
	    my $modifier = $PREMATCH;
	    my $boundary = $&;
	    my $follows_subordination = $POSTMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;

# A rule that looks to see whether there are any verbs in the sentence prior to the sign
# If not, it expects that the final verb chunk in the sentence is the right boundary

	    if($follows_leftmost_subordinator =~ /($vbd_verb)(\s+)($vbd_verb)/){
		$boundary = $4;
		$follows_subordination = $POSTMATCH;
		$modifier = $PREMATCH.$1;
		
		$sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER] ".$boundary.$follows_subordination;
		@simpler_sentences[0] = "{RNM-4} ".$sentence1;
	    
#		print STDERR "HERE $sentence1\n";exit;

		if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }

	    if($precedes_leftmost_subordinator !~ /($any_kind_of_verb)/){
		if($follows_leftmost_subordinator =~ /($vbd_verb|$vbz_verb)/){
		    if($follows_leftmost_subordinator =~ /($plural_noun)(\s*)($singular_noun)(\s*)($vbd_verb|$vbz_verb)/){
			while($follows_leftmost_subordinator =~ /($plural_noun)(\s*)($singular_noun)(\s*)($vbd_verb|$vbz_verb)/g){
			    $boundary = $&;
			    $follows_subordination = $POSTMATCH;
			    $modifier = $PREMATCH.$1.$5;
			    $boundary =~ s/($plural_noun)//;			    

			    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER] ".$boundary.$follows_subordination;
#			    print STDERR "$sentence1\n";exit;
			    @simpler_sentences[0] = "{RNM-5} ".$sentence1;
			}
		    }

		    else{
			while($follows_leftmost_subordinator =~ /($vbd_verb|$vbz_verb)/g){
			    $boundary = $&;
			    $follows_subordination = $POSTMATCH;
			    $modifier = $PREMATCH;
		    
# A BATTLE for compensation by an English couple [who claimed they were victims
# of racial discrimination while living in a Scottish village] ended yesterday
# when lawyers reached an out-of-court settlement. 

			    unless($modifier =~ />(when|after|before)</){
				$sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER] ".$boundary.$follows_subordination;
			    }

#			    print STDERR "$sentence1\n";exit;
			    @simpler_sentences[0] = "{RNM-6} ".$sentence1;
			}
		    }

		    if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}
#		print STDERR "\tS6 $sentence1\n"; exit;
	    }

	

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-7} ".$sentence1;
#	    print STDERR "\tS6 $sentence1\n"; exit;
	    
#	    unless($precedes_leftmost_subordinator =~ /($ccv_comp_verb)((\s+<w ([^>]+)>([^<]+)<\/w>){0,8})(\s+)$/ && $potential_subordinator =~ />that</){

	    if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
	elsif($follows_leftmost_subordinator =~ /(\.|\?|\!)(\s*)$/){
	    my $boundary = $&;
	    my $modifier = $PREMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary;
	    
	    @simpler_sentences[0] = "{RNM-8} ".$sentence1;	    
#	    print STDERR "\tS6 $sentence1\n"; exit;
	    
	    if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
	else{
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$follows_leftmost_subordinator."[/MODIFIER]";

	    @simpler_sentences[0] = "{RNM-9} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS11 $sentence1\n"; exit;
	    
	    if(return_flag($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) == 1){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
    }
##############################################################################
###### punctuation
    elsif($potential_subordinator =~ />(\,|\;|\:)</){
	my $subordinator = $1;
	
	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"($right_boundary_class)\">([^<]+)<\/PC>/){
	    my $follows_subordination = $POSTMATCH;
	    my $modifier = $PREMATCH.$&;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-10} ".$sentence1;   
#	    print STDERR "\tS7 $sentence1\n"; exit;
	    
#	    print STDERR "\[$precedes_leftmost_subordinator\]\n";exit;
	    unless($potential_subordinator =~ />\:</ && $precedes_leftmost_subordinator =~ /^(\s*)<w([^>]+)>([^<]+)<\/w>(\s*)$/){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
	elsif($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"($alternate_right_boundary_class)\">([^<]+)<\/PC>/){
	    my $follows_subordination = $&.$POSTMATCH;
	    my $modifier = $PREMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-11} ".$sentence1;   
#	    print STDERR "\tS7 $sentence1\n"; exit;
	    
#	    print STDERR "\[$precedes_leftmost_subordinator\]\n";exit;
	    unless($potential_subordinator =~ />\:</ && $precedes_leftmost_subordinator =~ /^(\s*)<w([^>]+)>([^<]+)<\/w>(\s*)$/){
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)<w ([^>]+)>including<\/w>((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
	    my $boundary = $5;
	    my $modifier = $&;
	    $modifier =~ s/($any_kind_of_sentence_boundary)(\s*)$//;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary;

	    
	    @simpler_sentences[0] = "{RNM-12} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS7 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}

	elsif($follows_leftmost_subordinator =~ /($ccv_comp_verb)((.|\s)*?)($any_kind_of_sentence_boundary)(\s*)$/){
#	    my $boundary = $7.$8;
	    my $follows_subordination = $POSTMATCH;
	    my $boundary = $9;
	    my $modifier = $PREMATCH.$&;
	    $modifier =~ s/($any_kind_of_sentence_boundary)(\s*)$//;

	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    

	    @simpler_sentences[0] = "{RNM-12} ".$sentence1;
#	    print STDERR "\tS9 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}


	elsif($follows_leftmost_subordinator =~ /($any_kind_of_sentence_boundary)/){
	    my $boundary = $&;
	    my $modifier = $PREMATCH;
	    my $follows_subordination = $POSTMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier."[/MODIFIER]".$boundary.$follows_subordination;
	    
	    unless($potential_subordinator =~ />\,</ && $follows_leftmost_subordinator =~ /heard/){
		@simpler_sentences[0] = "{RNM-14} ".$sentence1.$final_punctuation;	    
#		print STDERR "\tS9 $sentence1\n"; exit;
	    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
	elsif($follows_leftmost_subordinator =~ /(\.|\?|\?)(\s*)$/){
	    my $boundary = $&;
	    my $modifier = $PREMATCH;
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier.$boundary."[/MODIFIER]";
	    
	    @simpler_sentences[0] = "{RNM-15} ".$sentence1;	    
#	    print STDERR "\tS9 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}
	elsif($follows_leftmost_subordinator =~ /($quotes)(\s*)$/){
	    my $print_potential_subordinator = $potential_subordinator;
	    my $boundary = $&;
	    my $follows_subordination = $POSTMATCH;
	    my $modifier = $PREMATCH;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    

	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$modifier.$boundary."[/MODIFIER]".$follows_subordination;
	    
	    @simpler_sentences[0] = "{RNM-16} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS9 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}
# When there is nothing to indicate the end of the sentence
	else{
	    my $print_potential_subordinator = $potential_subordinator;
	    $print_potential_subordinator =~ s/<PC([^>]+)>([^<]+)<\/PC>/$2/;	    
	    $sentence1 = $precedes_leftmost_subordinator."[MODIFIER]".$print_potential_subordinator.$follows_leftmost_subordinator."[/MODIFIER]";

	    @simpler_sentences[0] = "{RNM-17} ".$sentence1.$final_punctuation;	    
#	    print STDERR "\tS11 $sentence1\n"; exit;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	    
	}
    }

##################################

##################################
    
    open(ERROR_FILE, ">>./SSCCV_errors.txt");
    print ERROR_FILE "$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";
    close(ERROR_FILE);
    
    #FIXME: iustin -> hardcpded pathrs and filename inside library :(
    #`cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
    

#    print STDERR "TNM NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;

    
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
    
    @simpler_sentences[0] = "{XNM-000} ".$sentence1.$final_punctuation;
#    @simpler_sentences[0] = "{RNM-000} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
    
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);
    
}
1;

sub return_flag{
    my ($precedes_leftmost_subordinator, $follows_leftmost_subordinator, $potential_subordinator) = @_;
    my $return_flag = 0;
 	    
    unless($precedes_leftmost_subordinator =~ /($any_kind_of_adj1)(\s*)$/ && $potential_subordinator =~ />that</){
	unless($precedes_leftmost_subordinator =~ /($ccv_comp_verb)((\s+<w ([^>]+)>([^<]+)<\/w>){0,8})(\s*)$/ && $potential_subordinator =~ />that</){
	    unless($precedes_leftmost_subordinator =~ /($any_coordinator)(\s*)$/ && $potential_subordinator =~ />that</){
		unless($precedes_leftmost_subordinator =~ /($any_kind_of_prep|$of)(\s*)$/i && $potential_subordinator =~ />(which|that)</){
		    $return_flag = 1
		}
	    }
	}
    }
    return($return_flag);
}
