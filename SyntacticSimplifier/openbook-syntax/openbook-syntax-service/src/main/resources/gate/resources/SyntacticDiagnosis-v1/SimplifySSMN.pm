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
package SimplifySSMN;
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
my $any_kind_of_possPron = "<w c\=\"w\" p\=\"PRP\\\$\">([^<]+)<\/w>";
my $any_kind_of_pron = "<w c\=\"w\" p\=\"PRP\">([^<]+)<\/w>";
my $wp_pronoun = "<w c\=\"w\" p\=\"WP\">([^<]+)<\/w>";
my $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
my $proper_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNP|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
my $any_kind_of_adj1 = "<w c\=\"(w|hyw|abbr|ord)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw|abbr|ord)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_subordinator = "<PC ([^>]+)>(that|which)<\/PC>";
my $any_right_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>";
my $any_kind_of_prep = "<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>";
my $any_kind_of_rp = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>"; # used in "snap off"
my $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB)\">([^<]+)<\/w>";
my $any_kind_of_number = "<w c\=\"(w|cd)\" p\=\"CD\">([^<]+)<\/w>";
my $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
my $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $comma_that = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,(\\\s*)that<\/PC>";
my $comma_who = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,(\\\s*)who<\/PC>";
my $comma_wh = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,(\\\s*)wh([^o]+)([^<]+)<\/PC>";
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
my $hyphen = "<w c\=\"(hyph|sym)\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $conjunction = "<w c\=\"w\" p\=\"CC\">([^<]+)<\/w>";
my $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";

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
    my $subordinate_subject;

    my $sentence1;
    my $sentence2;
    print STDERR "\t[SSMN]\nPRC $precedes_leftmost_subordinator\nCONJ $potential_subordinator\nFRC $follows_leftmost_subordinator\n";

#    print STDERR "SIMPLIFYING ######### $sentence\n";

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }



################################### SSMN #######################################
##############################################################################
##### punctuation-conjunction




##############################################################################
###### punctuation
    if($potential_subordinator =~ />(\,|\;)</){
	my $subject;
	my $follows_subordination;
	my $verb1;
	my $verb2;
	my $subordinated_element;
	my $element_for_deletion;
	my $noun;
	my $terminator;
	my $punk = $1;

# Overall method checks whatever follows the potential coordinator first in
# order to determine the subordinated element.
	

	if($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"(CCV)\">([^<]+)<\/PC>/){ 
	    print STDERR "1>>>>>>>>>>>>>>>>>>\n";

	    while($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"(CCV)\">([^<]+)<\/PC>/g){ 
		$follows_subordination = $POSTMATCH;
		my $fes_class = $2;	    
#		$subordinated_element = $potential_subordinator.$PREMATCH.$&;
#		$subordinated_element = $potential_subordinator.$PREMATCH;
		$subordinated_element = $PREMATCH;
		$terminator = $&;		


###########################
		if($fes_class eq "CCV"){
		    $subject = $precedes_leftmost_subordinator;
		    my $noun;
		    $element_for_deletion = $potential_subordinator.$subordinated_element;			
		    while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			$subject = $PREMATCH;
			$subordinate_subject = $&;
		    }


		    $sentence1 = $sentence;
		    $sentence1 =~ s/\Q$element_for_deletion\E/ /;

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-1a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-1b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
	}
###########################################################	
	elsif($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/){ 
	    print STDERR "2>>>>>>>>>>>>>>>>>>\n";
	    while($follows_leftmost_subordinator =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"E([^\"]+)\">([^<]+)<\/PC>/g){ 
		$follows_subordination = $POSTMATCH;
		my $fes_class = "E".$2;	    
#		$subordinated_element = $potential_subordinator.$PREMATCH.$&;
#		$subordinated_element = $potential_subordinator.$PREMATCH;
		$subordinated_element = $PREMATCH;
		$terminator = $&;		

		print STDERR "\[$subordinated_element\]\n";

###########################
		if($fes_class eq "ESMN"){
		    $subject = $precedes_leftmost_subordinator;
		    my $noun;
		    $element_for_deletion = $potential_subordinator.$PREMATCH.$terminator;
		    if($precedes_leftmost_subordinator =~ /($vbg_verb)(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
			$subject = $PREMATCH.$1;
			my $subordinate_subject = $3.$8.$12.$13.$16.$17.$20." ";
			my $modifier = "";
			if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
			    $subordinated_element = $POSTMATCH;
			    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
			}				
			
			
			print STDERR "\[$subordinate_subject\]\n";
			
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E//;

			$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
			
			$noun = "";
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
			
			@simpler_sentences[0] = "{SSMN-2a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSMN-2b} ".$sentence2;
			
#			print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }		
		    elsif($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
			$subject = $PREMATCH;
			my $subordinate_subject = $&;

			print STDERR "2.1>>>>>>>>>>>>>>>\[$element_for_deletion\]\n";

			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E/ /;

			if($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
			    $subject = $PREMATCH;
			    my $subordinate_subject = $&;
			    
			    
			    
			    $sentence1 = $sentence;
			    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
			    
			    
			    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner|$any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_adj1|$of|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-3a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-3b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner|$any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_possessive|$any_kind_of_adverb|$any_kind_of_adj1|$of|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-4a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-4b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner|$any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_adj1|$of|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-5a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-5b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($proper_noun)(($any_kind_of_noun|$any_kind_of_possessive|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
#				print STDERR "\[$subordinate_subject\]\n";exit;


				print STDERR "SENT THEN \[$sentence1\]\n";

				$sentence1 = $sentence;
				$sentence1 =~ s/\Q$element_for_deletion\E//;

#				print STDERR "SENT NOW \[$sentence1\]\nSUB SUBJ\[$subordinate_subject\]\nDELETE \[$element_for_deletion\]\n";exit;

				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-6a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-6b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($proper_noun)(($any_kind_of_noun|$any_kind_of_possessive|\s)*)($any_kind_of_adj1)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
#				print STDERR "\[$subordinate_subject\]\n";exit;

				$sentence1 = $sentence;
				$sentence1 =~ s/\Q$element_for_deletion\E//;

				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-7a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-7b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($comma)(($any_kind_of_noun|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $4.$11;
				my $modifier = "";
				if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
				    $subordinated_element = $POSTMATCH;
				    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
				}				


				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-8a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-8b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(($any_kind_of_possessive|$any_kind_of_noun|\s)*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $1.$6.$10;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-9a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-9b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }			
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_possessive|$any_kind_of_noun|\s)*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $1.$3;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-10a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-10b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }			
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $3.$8.$12;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-11a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-11b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $3.$8.$12;
				
#				print STDERR "\[$subordinate_subject\]\n";exit;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-12a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-12b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_pc)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $5.$10.$14;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-13a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-13b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /^(\s*)($conjunction)(\s*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1.$4;
				my $subordinate_subject = $5.$10;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-14a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-14b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /^(\s*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $2.$7.$11;
				
#				print STDERR "\[$subordinate_subject\]\n";exit;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-15a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-15b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /(\s*)($any_kind_of_determiner)(\s*)($any_kind_of_adj1)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-16a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-16b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /^(\s*)($any_kind_of_number)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $2;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-17a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-17b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($comma)(($any_kind_of_noun|$any_kind_of_possessive|$hyphen|\s)*?)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH;
				my $subordinate_subject = $&;
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-18a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-18b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($any_kind_of_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $3.$8;
				
				print STDERR "\[$subordinate_subject\]\n";
				
				$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
				$noun = "";
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
				
				@simpler_sentences[0] = "{SSMN-19a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-19b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			}

			elsif($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
			    $subject = $PREMATCH;
			    my $subordinate_subject = $&;
			    
			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
			    
			    $noun = "";
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

			    @simpler_sentences[0] = "{SSMN-20a} ".$sentence1.$final_punctuation;
			    @simpler_sentences[1] = "{SSMN-20b} ".$sentence2;
			
#			    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
			    $simpler_sentences_ref = \@simpler_sentences;
			    return($simpler_sentences_ref);
			}
		    }
		}
		elsif($fes_class eq "ESMP"){
		    $subject = $precedes_leftmost_subordinator;
		    $element_for_deletion = $potential_subordinator.$PREMATCH;			
		    my $noun;

		    if($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*?)($any_kind_of_noun)/){
			my $subordinate_subject = $&;
			while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			    $subject = $PREMATCH;
			    $subordinate_subject = $&;
			}
			

			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E/ /;

			if($precedes_leftmost_subordinator =~ /($of)(\s*)($proper_noun|$plural_noun)(\s*)$/){
			    my $subordinate_subject = $2.$3.$10;

			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;

			    $noun = "";
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
			    $sentence1 =~ s/\s+($comma)/$1/g;

			    @simpler_sentences[0] = "{SSMN-21a} ".$sentence1.$final_punctuation;
			    @simpler_sentences[1] = "{SSMN-21b} ".$sentence2;
			
#			    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
			    $simpler_sentences_ref = \@simpler_sentences;
			    return($simpler_sentences_ref);
			}
			elsif($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
			    $subject = $PREMATCH;
			    my $subordinate_subject = $&;



			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

			    $noun = "";
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

			    @simpler_sentences[0] = "{SSMN-22a} ".$sentence1.$final_punctuation;
			    @simpler_sentences[1] = "{SSMN-22b} ".$sentence2;
#			    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;

			    $simpler_sentences_ref = \@simpler_sentences;
			    return($simpler_sentences_ref);
			}
		    }
		}
		elsif($fes_class eq "ESMA"){
		    $subject = $precedes_leftmost_subordinator;
		    $element_for_deletion = $potential_subordinator.$PREMATCH;			
		    my $noun;

#		    print STDERR "SE $subordinated_element\n";exit;

		    if($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*?)($proper_noun)(\s*)$/){
			my $subordinate_subject = $&;
			$subject = $PREMATCH;
		       
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E/ /;
			$sentence1 =~ s/\s+($comma)/$1/;

			
			$noun = "";
			while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
			    $noun = $1;
			}
			if($subordinated_element =~ /^(\s*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
			    if($noun =~ /S$/){
				$sentence2 =~ s/>BE</>are</;
			    }
			    else{
				$sentence2 =~ s/>BE</>is</;
			    }
			}
			else{
			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
			    if($noun =~ /S$/){
				$sentence2 =~ s/>BE</>are</;
			    }
			    else{
				$sentence2 =~ s/>BE</>is</;
			    }
			}




			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}

			@simpler_sentences[0] = "{SSMN-23a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSMN-23b} ".$sentence2;
			
#			print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		    elsif($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
			my $subordinate_subject = $1.$6;
			$subject = $PREMATCH;

			$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		       
			$sentence1 = $sentence;
			$sentence1 =~ s/\Q$element_for_deletion\E/ /;
			$sentence1 =~ s/\s+($comma)/$1/;

			
			$noun = "";
			while($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
			    $noun = $1;
			}
			if($subordinated_element =~ /^(\s*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
			    if($noun =~ /S$/){
				$sentence2 =~ s/>BE</>are</;
			    }
			    else{
				$sentence2 =~ s/>BE</>is</;
			    }
			}
			else{
			    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
			    if($noun =~ /S$/){
				$sentence2 =~ s/>BE</>were</;
			    }
			    else{
				$sentence2 =~ s/>BE</>was</;
			    }
			}




			if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
			    $final_punctuation = "";
			}

			@simpler_sentences[0] = "{SSMN-24a} ".$sentence1.$final_punctuation;
			@simpler_sentences[1] = "{SSMN-24b} ".$sentence2;
			
#			print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
			$simpler_sentences_ref = \@simpler_sentences;
			return($simpler_sentences_ref);
		    }
		}

#################################
		else{
		    $subordinated_element = $follows_leftmost_subordinator;
		    $element_for_deletion = $potential_subordinator.$subordinated_element;

		    while($precedes_leftmost_subordinator =~ /(($any_kind_of_noun|$any_kind_of_determiner|\s)*)($any_kind_of_noun)/g){
			$subject = $PREMATCH;
			$subordinate_subject = $&;
		    }


		    $sentence1 = $sentence;
		    $sentence1 =~ s/\Q$element_for_deletion\E/ /;
		    
		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		    
		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-25a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-25b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);

		}
	    }
	}
# Else the subordinated element is bounded by a sentence boundary on the right
	elsif($follows_leftmost_subordinator =~ /^(\s*)(<w c\=\"cd\" p\=\"CD\">([1-2]+)([0-9]{3})<\/w>)(\s*)($any_kind_of_pc)/){

	    $sentence1 = $precedes_leftmost_subordinator.$5.$6.$POSTMATCH;
	    $sentence2 = "<w c=\"w\" p=\"DT\">The</w> <w c=\"w\" p=\"NN\">year</w> <w c=\"w\" p=\"VBZ\">was</w> ".$2;

#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

	    @simpler_sentences[0] = "{SSMN-26a} ".$sentence1;
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}

##################################################

	elsif($follows_leftmost_subordinator =~ /(\s*)($proper_noun)(\s*)($hyphen)(\s*)($any_kind_of_pron)(\s*)($vbp_verb)/){ 
	    $subordinated_element = $1.$2.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $follows_subordination = $&.$POSTMATCH;
	    print STDERR "4>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $4." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-27a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-27b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
# Following condition seems to cause recursion
	elsif($follows_leftmost_subordinator =~ /AAAAAAAAAA(\s*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_determiner)((\s|.)*?)($any_kind_of_sentence_boundary)(\s*)$/){ 
	    $subordinated_element = $1.$2;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $follows_subordination = $&.$POSTMATCH;
	    print STDERR "12>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\nPLS $precedes_leftmost_subordinator\n";

	    if($precedes_leftmost_subordinator =~ /($of|$any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$8.$12;
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n$element_for_deletion\n";exit;
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-28a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-28b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($comma)(\s*)($vbp_verb)/){ 
	    $subordinated_element = $PREMATCH;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $&.$POSTMATCH;
	    print STDERR "16>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(\s*)($of)(\s*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3.$4;
		my $subordinate_subject = $5.$6.$10." ";
		my $modifier = "";

		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;

		print STDERR "\[$subordinate_subject\]\n";
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w>".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-29a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-29b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($hyphen)(\s*)($any_kind_of_determiner)(\s*)($of)(\s*)($wp_pronoun)(\s*)($vbp_verb)/){ 
	    $subordinated_element = $PREMATCH;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $&.$POSTMATCH;
	    print STDERR "20>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|$any_kind_of_possessive|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$4.$10.$14." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-30a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-30b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($vbp_verb)/){ 
	    $subordinated_element = $PREMATCH;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $&.$POSTMATCH;
	    print STDERR "15>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-31a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-31b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

##################################################
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_prep|\s)*)($hyphen)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|$vbn_verb|$any_kind_of_prep|$any_kind_of_possessive|$any_kind_of_determiner|\s)*)($hyphen)(\s*)($vbd_verb)/){  # (\s+) important here
	    $subordinated_element = $1.$2.$4.$10.$12.$13.$15;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $28.$31.$POSTMATCH;
	    print STDERR "14>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /^((\{([A-Za-z0-9\-]+)\} )*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $4.$9.$13." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-32a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-32b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s+)($hyphen)(\s+)/){  # (\s+) important here
	    $subordinated_element = $1.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $10.$11.$13.$POSTMATCH;
	    print STDERR "21>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$8.$12." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-33a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-33b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($subordinating_that)(($proper_noun|$any_kind_of_possessive|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $4.$11.$15." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-34a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-34b} ".$sentence2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /(\s*)($proper_noun)(\s+)($hyphen)(\s+)/){  # (\s+) important here
	    $subordinated_element = $1.$2.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $6.$7.$9.$POSTMATCH;
	    print STDERR "13>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$8.$12." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-35a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-35b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /^(($proper_noun|\s)*)($proper_noun)(\s*)($comma_wh)/){
	    $subordinated_element = $1.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $10.$11.$POSTMATCH;
	    
	    print STDERR "7>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$4.$5;
		my $subordinate_subject = $3.$4.$8." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
#		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-36a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-36b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /^(($proper_noun|\s)*)($proper_noun)(\s*)($comma_who)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){
	    $subordinated_element = $1.$6.$10.$11.$15;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $17.$POSTMATCH;
	    
	    print STDERR "6>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($comma)(\s*)($vbg_verb)(($any_kind_of_noun|$any_kind_of_possessive|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$4.$5;
		my $subordinate_subject = $7.$17.$21." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-37a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-37b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($proper_noun)(\s*)($any_kind_of_prep)(\s*)($proper_noun)(\s*)($comma)/){ 
	    $subordinated_element = $1.$5.$6.$8.$9;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $13.$14.$POSTMATCH;

	    print STDERR "9>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$4.$8." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-38a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-38b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /^(\s*)($any_kind_of_adj1)(($any_kind_of_noun|$of|\s)*)($comma)/){ 
	    $subordinated_element = $1.$2.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $11.$POSTMATCH;

	    print STDERR "10>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(($proper_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$4.$6.$11.$15." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-39a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-39b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /^(\s*)($proper_noun)(\s*)($comma)((.|\s)*)($any_kind_of_sentence_boundary)(\s*)$/){
	    $subordinated_element = $1.$2.$6.$7.$10;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $7.$POSTMATCH;
	    
	    print STDERR "22>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($conjunction)(\s*)(($any_kind_of_possPron|$any_kind_of_number|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $4.$9;
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
#		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-40a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-40b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
############################
	elsif($follows_leftmost_subordinator =~ /^(\s*)($proper_noun)(\s*)($comma)/){
	    $subordinated_element = $1.$2.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $7.$POSTMATCH;
	    
	    print STDERR "11>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($comma)(\s*)($of)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$4.$5;
		my $subordinate_subject = $6.$11.$15." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
#		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-41a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-41b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($comma)(\s*)($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$4.$5;
		my $subordinate_subject = $7.$12.$16." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-42a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-42b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$8." ";

		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-43a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-43b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

# 12>>>>> USED TO BE HERE

##################################################
	elsif($follows_leftmost_subordinator =~ /($vbd_verb)(\s*)($vbn_verb)((.|\s)*?)(($any_kind_of_sentence_boundary|\s)*)$/){ 
	    $subordinated_element = $PREMATCH.$1.$3.$4.$6;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $8.$POSTMATCH;

	    print STDERR "8>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($proper_noun)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$4.$8.$9." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-44a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-44b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$8.$12." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-45a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-45b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_determiner|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$6.$10." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $subject.$subordinate_subject.$follows_subordination;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-46a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-46b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($of)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $1.$6;
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "#######\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-47a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-47b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($vbd_verb)(\s*)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)($vbg_verb)(\s)($any_kind_of_determiner)(($any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){ 
	    $subordinated_element = $PREMATCH.$1.$3.$4.$6.$11.$13.$14.$16;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $21.$POSTMATCH;

	    print STDERR "17>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(\s*)($any_kind_of_prep)(\s*)($any_kind_of_possPron)(($any_kind_of_adj1|$any_kind_of_noun|\s)+)$/){
		$subject = $PREMATCH.$1.$2.$4;
		my $subordinate_subject = $4.$5.$7." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;				
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-48a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-48b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
#######################
	elsif($follows_leftmost_subordinator =~ /($comma_that)/){ 
	    $subordinated_element = $PREMATCH;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $&.$POSTMATCH;

#	    $subordinated_element =~ s/(\s*)<PC ID\=\"([0-9]+)\" CLASS\=\"UNKNOWN\">([^<]+)<\/PC>(\s*)$//;

	    print STDERR "19>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$8.$12." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w>".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-49a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-49b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}
##################################################
	elsif($follows_leftmost_subordinator =~ /($vbd_verb)(($any_kind_of_prep|$any_kind_of_possPron|$any_kind_of_noun|\s)*)(($any_kind_of_sentence_boundary|\s)*)$/){ 
	    $subordinated_element = $PREMATCH.$1.$3;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $10.$POSTMATCH;

#	    $subordinated_element =~ s/(\s*)<PC ID\=\"([0-9]+)\" CLASS\=\"UNKNOWN\">([^<]+)<\/PC>(\s*)$//;

	    print STDERR "18>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /($of)(($proper_noun|$any_kind_of_possessive|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $2.$12.$16." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-50a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-50b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$8.$12." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-51a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-51b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

##################################################
	elsif($follows_leftmost_subordinator =~ /($vbd_verb)/){ 
	    $subordinated_element = $PREMATCH;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
	    $subject = $precedes_leftmost_subordinator;
	    $follows_subordination = $&.$POSTMATCH;

#	    $subordinated_element =~ s/(\s*)<PC ID\=\"([0-9]+)\" CLASS\=\"UNKNOWN\">([^<]+)<\/PC>(\s*)$//;

	    print STDERR "5>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\n";

	    if($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-52a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-52b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

#		print STDERR "\[$subordinate_subject\]\n";exit;

		$sentence1 = $subordinate_subject.$follows_subordination;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-53a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-53b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_determiner)(($any_kind_of_adj1|$any_kind_of_noun|\s)*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $3.$4.$6." ";
		my $modifier = "";
		if($subordinated_element =~ /^(\s*)<w ([^>]+)>most<\/w>/){
		    $subordinated_element = $POSTMATCH;
		    $modifier = $&." <w c=\"w\" p=\"IN\">of</w> <w c=\"w\" p=\"DT\">the<\/w> ";
		}				
		

		print STDERR "\[$subordinate_subject\]\n";

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E//;
				
		$sentence2 = $modifier.$subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
				
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-54a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-54b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
	}

##################################################
	else{
	    $subordinated_element = $follows_leftmost_subordinator;
	    $subordinated_element =~ s/(($any_kind_of_sentence_boundary|\s)*)$//;
	    $element_for_deletion = $potential_subordinator.$subordinated_element;
###########################
	    $subject = $precedes_leftmost_subordinator;
	    my $noun;

	    print STDERR "3>>>>>>>>>>>>>>>>>>\[$subordinated_element\]\nPLC $precedes_leftmost_subordinator\n";

	    if($precedes_leftmost_subordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$any_kind_of_possessive|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

#		print STDERR "S1 $subordinate_subject\n";exit;
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		my $final_ss_word = "";
		while($subordinate_subject =~ />([A-Za-z])([^<]+)</g){
		    $final_ss_word = $1;
		}
		if($final_ss_word =~ /^([A-Z])/){
		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c=\"w\" p=\"IN\">in<\/w> ".$subordinated_element;
		}

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-55a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-55b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
#################################
	    elsif($precedes_leftmost_subordinator =~ /($to)(\s*)($any_kind_of_noun)(\s*)($any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$2.$3.$7;
		my $subordinate_subject = $8.$10.$18;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "S1 \[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-56a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-56b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(\s*)($proper_noun|$any_kind_of_pron)(\s*)$/){
		$subject = $PREMATCH.$1.$2;
		my $subordinate_subject = $3.$8;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

# Transforming pronouns with accusative case into nominative case forms
		$subordinate_subject =~ s/^(\s*)<([^>]+)>him<([^>]+)>(\s*)$/$1<$2>he<$3>$4/;
# her is ambiguous

		print STDERR "\[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-57a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-57b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$2;
		my $subordinate_subject = $3.$5.$6.$10." ";


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

# Transforming pronouns with accusative case into nominative case forms
		$subordinate_subject =~ s/^(\s*)<([^>]+)>him<([^>]+)>(\s*)$/$1<$2>he<$3>$4/;
# her is ambiguous

		print STDERR "\[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-58a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-58b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)($any_kind_of_possPron)(($any_kind_of_noun|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$4.$6.$14;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "\[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-59a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-59b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
###################
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)(($proper_noun|$any_kind_of_possessive|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$4.$11.$15;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

#		print STDERR "\[$subordinate_subject\]\n\[$element_for_deletion\]\n";exit;


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-60a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-60b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
##########################
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s*)(($proper_noun|$any_kind_of_possessive|\s)*)($proper_noun)(\s*)/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$4.$11.$15;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "\[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> <w c\=\"w\" p\=\"IN\">in<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-61a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-61b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
##################
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$8.$12.$13.$16.$17.$20;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "\[$subordinate_subject\]\n";


		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-62a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-62b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
###################
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(($quotes|$any_kind_of_determiner|$proper_noun|$of|\s)*)($any_kind_of_noun)(($quotes|\s)*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$13;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "\[$subordinate_subject\]\n";
		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
		if($subordinate_subject =~ / p\=\"(NN|NNS|NNPS|NNP)\"/g){
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
		
		@simpler_sentences[0] = "{SSMN-63a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-63b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
#######################
	    elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(\s*)(($any_kind_of_noun|$any_kind_of_possessive|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $4;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

#		print STDERR "S1 \[$subordinate_subject\]\n";exit;

		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-64a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-64b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(\s*)(($any_kind_of_possPron|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $3.$4.$7.$11;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "S1 \[$subordinate_subject\]\n";

		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-65a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-65b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($vbg_verb)(\s*)($any_kind_of_pron)(\s*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3.$4;
		my $subordinate_subject = $6.$7.$11;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "S1 \[$subordinate_subject\]\n";

		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-66a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-66b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
###################
	    elsif($precedes_leftmost_subordinator =~ /($vbn_verb)(\s*)(($any_kind_of_noun|$any_kind_of_possessive|$any_kind_of_adj1|\s)*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$3;
		my $subordinate_subject = $4.$13.$14.$18;


		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR "S1 \[$subordinate_subject\]\n";

		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-67a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-67b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_verb)(($proper_noun|\s)*)($proper_noun)(\s*)($comma)(\s*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $4.$9.$13.$14.$17.$18.$21;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

#		print STDERR "EFD\: $element_for_deletion\n";

		print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;


		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-68a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-68b} ".$sentence2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
#################################
	    elsif($precedes_leftmost_subordinator =~ /($any_kind_of_verb)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1;
		my $subordinate_subject = $4.$9;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

#		print STDERR "EFD\: $element_for_deletion\n";

		print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";

		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;


		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-69a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-69b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
	    }
#################################
	    elsif($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($pound)(($any_kind_of_number|$any_kind_of_sentence_boundary|\s)*)($any_kind_of_number)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		if($precedes_leftmost_subordinator =~ /($vbd_verb)(\s*)($pound)(($any_kind_of_number|$any_kind_of_sentence_boundary|\s)*)($any_kind_of_number)(\s*)$/){
		    $subject = $PREMATCH.$1;
#34
		    my $subordinate_subject = $4.$6.$10.$12;


#		    print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";exit;

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;


		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-70a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-70b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
	    }
#################################
	    elsif($precedes_leftmost_subordinator =~ /($comma_that)(\s*)($any_kind_of_possPron)(\s*)($any_kind_of_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$5;		
		my $subordinate_subject = $6.$8.$9.$13;

		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";
		
		$sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		$noun = "";
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
		
		@simpler_sentences[0] = "{SSMN-71a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-71b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
		
	    }
#################################
	    elsif($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		if($precedes_leftmost_subordinator =~ /($any_kind_of_number)(\s*)($of)(\s*)($base_np)(\s*)$/){
		    $subject = $PREMATCH;
#34
		    my $subordinate_subject = $1.$4.$5.$6.$7." ";


		    print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;


		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-72a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-72b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
#################################
	    }
	    if($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;


		if($precedes_leftmost_subordinator =~ /($of)(\s+)($base_np)(\s*)$/){
		    $subject = $PREMATCH;
		    my $preposition = $1.$2;
		    my $subordinate_subject = $3;

#		    $preposition = " <w c\=\"w\" p\=\"IN\">in<\/w> ";

#		    print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";exit;

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-73a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-73b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
		elsif($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s+)($base_np)(\s*)$/){
		    $subject = $PREMATCH;
		    my $preposition = $1.$3;
		    my $subordinate_subject = $4;

#		    $preposition = " <w c\=\"w\" p\=\"IN\">in<\/w> ";

#		    print STDERR ">>>>>>>>>>>>>>>>>>\[$subordinate_subject\]\n";exit;

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;
		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$preposition." ".$subordinated_element;

		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-73a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-73b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
		$subject = $PREMATCH;
		my $subordinate_subject = $&;
		
		$sentence1 = $sentence;
		$sentence1 =~ s/\Q$element_for_deletion\E/ /;

		if($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
		    $subject = $PREMATCH;
		    my $subordinate_subject = $&;

		    $sentence2 = $subordinate_subject." <w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

		    $noun = "";
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
		    
		    @simpler_sentences[0] = "{SSMN-74a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-74b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);
		}
#################################
	    }

	}
    }
# Different kinds of potential coordinator at this level
    
    
    open(ERROR_FILE, ">>./SSMN_errors.txt");
    print ERROR_FILE "$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n";
    close(ERROR_FILE);

    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "SSMN NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;

    if($potential_subordinator =~ />\,</){
#	print STDERR "SSMN NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
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
    $replacement_pc =~ s/ and/ <w c\=\"w\" p\=\"CC\">and<\/w>/;
    $replacement_pc =~ s/but/<w c\=\"w\" p\=\"CC\">but<\/w>/;
    $replacement_pc =~ s/or/<w c\=\"w\" p\=\"CC\">or<\/w>/;
    
    $sentence1 = $precedes_leftmost_subordinator.$replacement_pc.$follows_leftmost_subordinator;
    
#    print STDERR "$potential_subordinator\n";exit;

    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = "";
    }
	    
    @simpler_sentences[0] = "{SSMN-75a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
			
    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);
}
1;
