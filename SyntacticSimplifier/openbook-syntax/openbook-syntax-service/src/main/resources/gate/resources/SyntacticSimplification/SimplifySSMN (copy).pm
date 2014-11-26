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
my $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
my $proper_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNP|NNPS)\">([^<]+)<\/w>";
my $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
my $any_kind_of_adj1 = "<w c\=\"(w|hyw|abbr)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_adj2 = "<w c\=\"(w|hyw|abbr)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
my $any_kind_of_subordinator = "<PC ([^>]+)>(that|which)<\/PC>";
my $any_right_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>";
my $any_kind_of_prep = "<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>";
my $any_kind_of_rp = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>"; # used in "snap off"
my $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB)\">([^<]+)<\/w>";
my $any_kind_of_number = "<w c\=\"(w|cd)\" p\=\"CD\">([^<]+)<\/w>";
my $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
my $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
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
my $conjunction = "<w c\=\"w\" p\=\"CC\">([^<]+)<\/w>";

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
	my $sentence1;
	my $sentence2;
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
		    if($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
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
				
				@simpler_sentences[0] = "{SSMN-2a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-2b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-3a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-3b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-4a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-4b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-20a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-20b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-21a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-21b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-5a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-5b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-5a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-5b} ".$sentence2;
				
#				print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit
				
				$simpler_sentences_ref = \@simpler_sentences;
				return($simpler_sentences_ref);
			    }
			    elsif($precedes_leftmost_subordinator =~ /^(\s*)(($proper_noun|\s)*)($proper_noun)(\s*)$/){
				$subject = $PREMATCH.$1;
				my $subordinate_subject = $2.$7.$11;
				
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
				
				@simpler_sentences[0] = "{SSMN-6a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-6b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-2a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-2b} ".$sentence2;
				
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
				
				@simpler_sentences[0] = "{SSMN-7a} ".$sentence1.$final_punctuation;
				@simpler_sentences[1] = "{SSMN-7b} ".$sentence2;
				
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

			    @simpler_sentences[0] = "{SSMN-8a} ".$sentence1.$final_punctuation;
			    @simpler_sentences[1] = "{SSMN-8b} ".$sentence2;
			
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


			if($precedes_leftmost_subordinator =~ /($base_np)(\s*)$/){
			    $subject = $PREMATCH;
			    my $subordinate_subject = $&;

			    $sentence2 = $subordinate_subject."<w c\=\"w\" p\=\"VBD\">BE<\/w> ".$subordinated_element;

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
			
#			    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
			    $simpler_sentences_ref = \@simpler_sentences;
			    return($simpler_sentences_ref);
			}
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
		    
		    @simpler_sentences[0] = "{SSMN-10a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-10b} ".$sentence2;
		    
#		    print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		    
		    $simpler_sentences_ref = \@simpler_sentences;
		    return($simpler_sentences_ref);

		}
	    }
	}
	elsif($follows_leftmost_subordinator =~ /^(\s*)(<w c\=\"cd\" p\=\"CD\">([1-2]+)([0-9]{3})<\/w>)(\s*)($any_kind_of_pc)/){

	    $sentence1 = $precedes_leftmost_subordinator.$5.$6.$POSTMATCH;
	    $sentence2 = "<w c=\"w\" p=\"DT\">The</w> <w c=\"w\" p=\"NN\">year</w> <w c=\"w\" p=\"VBZ\">was</w> ".$2;

#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

	    @simpler_sentences[0] = "{SSMN-19a} ".$sentence1;
	    $simpler_sentences_ref = \@simpler_sentences;
	    return($simpler_sentences_ref);
	}
##################################################
	else{
	    $subordinated_element = $follows_leftmost_subordinator;
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
		
		@simpler_sentences[0] = "{SSMN-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-11b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n"; exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
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
		
		@simpler_sentences[0] = "{SSMN-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-12b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
	    elsif($precedes_leftmost_subordinator =~ /($to)(\s*)($proper_noun)(\s*)$/){
		$subject = $PREMATCH.$1.$2;
		my $subordinate_subject = $3.$7;


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
		
		@simpler_sentences[0] = "{SSMN-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-12b} ".$sentence2;
		
		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		$simpler_sentences_ref = \@simpler_sentences;
		return($simpler_sentences_ref);
#################################
	    }
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
		
		@simpler_sentences[0] = "{SSMN-13a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-13b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{SSMN-14a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-14b} ".$sentence2;
		
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
		
		@simpler_sentences[0] = "{SSMN-15a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{SSMN-15b} ".$sentence2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		    
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
		    
		    @simpler_sentences[0] = "{SSMN-16a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-16b} ".$sentence2;
		    
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

		if($precedes_leftmost_subordinator =~ /($any_kind_of_prep)(\s+)($base_np)(\s*)$/){
		    $subject = $PREMATCH;
		    my $preposition = $1.$3;
		    my $subordinate_subject = $4;

		    $preposition = " <w c\=\"w\" p\=\"IN\">in<\/w> ";

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
		    
		    @simpler_sentences[0] = "{SSMN-17a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-17b} ".$sentence2;
		    
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
		    
		    @simpler_sentences[0] = "{SSMN-18a} ".$sentence1.$final_punctuation;
		    @simpler_sentences[1] = "{SSMN-18b} ".$sentence2;
		    
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

my $ttt2_dir = "../TTT2/scripts";
my $ttt2_models_dir = "../TTT2/models";
`cat temp.txt | $ttt2_dir/preparetxt | $ttt2_dir/tokenise | $ttt2_dir/postag -m $ttt2_models_dir/pos >  temp.txt.post.xml`;
####    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "SSMN NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;

    if($potential_subordinator =~ />\,</){
	print STDERR "SSMN NO RULE MATCHED\n$precedes_leftmost_subordinator\t\t$potential_subordinator\t\t$follows_leftmost_subordinator\n"; exit;
    }
}
1;
