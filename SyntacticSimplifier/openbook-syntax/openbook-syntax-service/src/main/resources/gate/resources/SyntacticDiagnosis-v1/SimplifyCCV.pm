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
package SimplifyCCV;
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
my $any_left_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">([^<]+)<\/PC>";
my $any_right_clause_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ESCCV\">([^<]+)<\/PC>";
my $any_left_clause_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"SSCCV\">([^<]+)<\/PC>";
my $any_kind_of_prep = "<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>";
my $any_kind_of_rp = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>"; # used in "snap off"
my $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB)\">([^<]+)<\/w>";
my $any_kind_of_number = "<w c\=\"(w|cd)\" p\=\"CD\">([^<]+)<\/w>";
my $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
my $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
my $subordinating_that = "<PC ID\=\"([0-9]+)\" CLASS\=\"(ES|SS)([^\"]+)\">that<\/PC>";
my $with = "<w c\=\"w\" p\=\"IN\">with<\/w>";
my $to = "<w c\=\"w\" p\=\"TO\">to<\/w>";
my $of = "<w c\=\"w\" p\=\"IN\">of<\/w>";
my $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
my $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
my $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
my $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
my $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
my $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
my $comma_wh = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,(\\\s+)wh([^<]+)<\/PC>";
my $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
my $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
my $hyphen = "<w c\=\"hyph\" p\=\"\:\">\-<\/w>";
my $dash = "<w c\=\"sym\" p\=\"\:\">\-<\/w>";
my $quotes = "<w c\=\"(l|r)quote\" qut\=\"s\" p\=\"(POS|\'\')\">\'<\/w>";
my $comm_verb = "<w c\=\"w\" p\=\"(VBG|VBD|VBP)\">(believe|claimed|saying)<\/w>";
my $comm_vbd = "<w c\=\"w\" p\=\"VBD\">(said|claimed)<\/w>";
my $comm_vbn = "<w c\=\"w\" p\=\"VBN\">(told)<\/w>";
my $comm_vbg = "<w c\=\"w\" p\=\"VBG\">(saying)<\/w>";
# my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(JJ|NN|VB|VBD|VBG|VBN|VBP|VBZ)\">(accept|accepted|acknowledg|acknowledge|add|added|admission|admit|admitted|admitting|agree|allegation|allege|alleging|announce|announc|answer|answered|apparent|appreciate|appreciated|argue|arguing|aware|belief|believe|believing|certain|claim|claimed|clear|complain|complained|concern|concerned|conclude|concluding|confirm|confirmed|convinced|convinc|decide|deciding|demonstrate|demonstrat|denied|deny|disappoint|disappointed|disclose|disclosing|discover|discovered|doubt|dread|emerge|emerged|emphasising|emphasise|ensur|ensure|establish|established|expect|expectation|expected|explain|explained|fear|feared|feel|felt|find|found|given|guess|guessed|illustrat|illustrate|indicate|indicated|infer|inferring|inferred|inference|insist|insisted|intimate|intimating|hear|held|hold|hope|hoping|implie|imply|know|knew|known|learn|learned|maintain|maintained|manner|mean|meant|noting|note|obvious|order|ordered|plain|possible|promising|promise|protested|protest|prov|prove|providing|provide|recording|realise|realising|recognis|recognise|recogniz|recognize|recommend|recommended|read|realis|realise|record|recorded|relate|relating|remain|report|reported|retort|retorted|reveal|revealed|rule|ruling|said|satisfie|satisfy|saw|say|scale|see|show|shown|showed|stating|suggest|suggested|suspect|suspected|tell|terrified|testify|testifie|think|thought|told|view|warn|warned|way)((s|d|ing)?)<\/w>";
my $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(JJ|NN|VB|VBD|VBG|VBN|VBP|VBZ)\">(accept|accepted|acknowledg|acknowledge|add|added|admission|admit|admitted|admitting|agree|allegation|allege|alleging|announce|announc|answer|answered|apparent|appreciate|appreciated|argue|arguing|aware|belief|believe|believing|certain|claim|clear|complain|complained|concern|concerned|conclude|concluding|confirm|confirmed|convinced|convinc|decide|deciding|demonstrate|demonstrat|denied|disappoint|disappointed|disclose|disclosing|discover|discovered|doubt|dread|emerge|emerged|emphasising|emphasise|ensur|ensure|establish|established|expect|expectation|expected|explain|explained|fear|feared|feel|felt|find|given|guess|guessed|illustrat|illustrate|indicate|indicated|infer|inferring|inferred|inference|insist|insisted|intimate|intimating|hear|held|hold|hope|hoping|implie|imply|knew|known|learn|learned|maintain|maintained|manner|mean|meant|noting|note|obvious|order|ordered|plain|possible|promising|promise|protested|protest|prov|prove|providing|provide|recording|realise|realising|recognis|recognise|recogniz|recognize|recommend|recommended|read|realis|realise|record|recorded|relate|relating|remain|report|reported|retort|retorted|reveal|revealed|rule|ruling|said|satisfie|satisfy|saw|say|scale|show|shown|showed|stating|suggest|suggested|suspect|suspected|tell|terrified|testify|testifie|think|thought|told|view|warn|warned|way)((s|d|ing)?)<\/w>";

sub simplify{
    my ($sentence, $precedes_rightmost_coordinator, $follows_rightmost_coordinator, $potential_coordinator) = @_;
    my @simpler_sentences = ();
    my $simpler_sentences_ref;

#    print STDERR "SIMPLIFYING ######### $sentence\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";exit;

    print STDERR "\t[CCV]\n";

    open(RAC, ">>RuleApplications.CCV.txt");

    my $final_punctuation = "";
    if($sentence =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = $1.$2;
    }

    my $clause1;
    my $clause2;
    my $subject;
    my $sentence1;
    my $sentence2;
################################### CCV #######################################


    if($follows_rightmost_coordinator =~ /^(\s*)($subordinating_that)/){
	$clause2 = $&.$POSTMATCH;

	if($precedes_rightmost_coordinator =~ /(\s*)($subordinating_that)/){
	    $subject = $PREMATCH;
	    $clause1 = $&.$POSTMATCH;

	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	    
	    print STDERR "S1 $sentence1\nS2 $sentence2\n";
           
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-1a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-1b} ".$sentence2;


	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-1a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-1b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    return($simpler_sentences_ref);
	   
	}
	elsif($precedes_rightmost_coordinator =~ /($vb_verb)(\s*)($wh_word)(($vbd_verb|$vbn_verb|\s)*)$/){
	    $subject = $PREMATCH.$1;
	    $clause1 = $3.$4.$8;
	    print STDERR "\[$clause1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($subordinating_that)/){
		$clause2 = $follows_rightmost_coordinator;

		$sentence1 = $subject.$clause1;
		$sentence2 = $subject.$clause2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CCV-2a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CCV-2b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CCV-2a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CCV-2b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	elsif($precedes_rightmost_coordinator =~ /($comm_verb)/){
	    $subject = $PREMATCH.$1;
	    $clause1 = $POSTMATCH;
	    print STDERR "\[$clause1\]\n";

	    if($follows_rightmost_coordinator =~ /^(\s*)($subordinating_that)/){
		$clause2 = $follows_rightmost_coordinator;

		$sentence1 = $subject.$clause1;
		$sentence2 = $subject.$clause2;

#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CCV-3a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CCV-3b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CCV-3a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CCV-3b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
	else{
	    $clause1 = $precedes_rightmost_coordinator;
	    $clause2 =~ s/^(\s*)($subordinating_that)//;

	    $sentence1 = $clause1;
	    $sentence2 = $clause2;

	    print STDERR "S1 $sentence1\nS2 $sentence2\n";
           
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-4a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-4b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-4a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-4b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}

    }
    elsif($precedes_rightmost_coordinator =~ /($vbd_verb)(\s*)($wh_word)/){
	$clause1 = $POSTMATCH;
	my $subject = $PREMATCH.$&;
	
	print STDERR "$clause1\n";

	$clause2 = $follows_rightmost_coordinator;


	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	    
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-5a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-5b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-5a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-5b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
	
    }
    elsif($precedes_rightmost_coordinator =~ /(<w c\=\"w\" p\=\"VBN\">ruled<\/w>)(($any_kind_of_determiner|$any_kind_of_noun|$any_kind_of_prep|\s)*)($subordinating_that)/){
	$subject = $PREMATCH.$&;
	$clause1 = $POSTMATCH;
	$clause2 = $follows_rightmost_coordinator;

	print STDERR "3>>>>>>>>>>>>>>>>>>\n";
	
	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;


#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-6a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-6b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-6a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-6b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
	
    }
    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$of|$any_kind_of_number|\s)*)($wh_word)/){
	while($precedes_rightmost_coordinator =~ /($any_kind_of_determiner)(($any_kind_of_noun|$of|$any_kind_of_number|\s)*)($wh_word)/g){
	    $subject = $PREMATCH.$1.$3;
	    $clause1 = $10.$POSTMATCH;
	}
	if($follows_rightmost_coordinator =~ /^(\s*)($wh_word)/){

	    $clause2 = $follows_rightmost_coordinator;
	    
	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-7a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-7b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-7a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-7b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)($subordinating_that)/){
	if($follows_rightmost_coordinator =~ /($any_kind_of_adj1)(\s*)($subordinating_that)/){
	    $clause1 = $precedes_rightmost_coordinator;
	    $clause2 = $follows_rightmost_coordinator;
	    
	    $sentence1 = $clause1;
	    $sentence2 = $clause2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-8a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-8b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-8a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-8b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
	else{

	    $subject = $PREMATCH;
	    $clause1 = $&.$POSTMATCH;
	    $clause2 = $&.$follows_rightmost_coordinator;
	    
	    print STDERR "3>>>>>>>>>>>>>>>>>>\n";
	
	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-9a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-9b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-9a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-9b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($precedes_rightmost_coordinator =~ /(\s*)($subordinating_that)/){
	$subject = $PREMATCH;
	$clause1 = $&.$POSTMATCH;
	$clause2 = $&.$follows_rightmost_coordinator;

	if($potential_coordinator =~ />but</){
	    $clause1 = $precedes_rightmost_coordinator;
	    $clause2 = $follows_rightmost_coordinator;
		
	    $sentence1 = $clause1;
	    $sentence2 = $clause2;
		
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-10a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-10b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-10a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-10b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
	else{
	    if($follows_rightmost_coordinator =~ /^(\s*)($any_kind_of_adverb)(\s*)($any_kind_of_pron)(\s*)($vbd_verb)/){
		$clause1 = $precedes_rightmost_coordinator;
		$clause2 = $follows_rightmost_coordinator;
		
		$sentence1 = $clause1;
		$sentence2 = $clause2;
		
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CCV-11a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CCV-11b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CCV-11a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CCV-11b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	
	    else{
		
		print STDERR "3>>>>>>>>>>>>>>>>>>\n";
		
		$sentence1 = $subject.$clause1;
		$sentence2 = $subject.$clause2;
	    
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
		
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CCV-12a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CCV-12b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
		
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CCV-12a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CCV-12b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
    }
    elsif($precedes_rightmost_coordinator =~ /($comma_wh)(\s*)(<w c\=\"w\" p\=\"VBD\">said<\/w>)(\s*)($any_kind_of_noun|$any_kind_of_pron|$any_kind_of_determiner)/){
	$clause1 = $precedes_rightmost_coordinator;
	$clause2 = $follows_rightmost_coordinator;
	
	$sentence1 = $clause1;
	$sentence2 = $clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-13a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-13b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-13a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-13b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }
    elsif($precedes_rightmost_coordinator =~ /(<w c\=\"w\" p\=\"VBD\">said<\/w>)(\s*)($any_kind_of_noun|$any_kind_of_pron|$any_kind_of_determiner)/){
	$clause1 = $2.$3.$POSTMATCH;
	$clause2 = $follows_rightmost_coordinator;
	$subject = $PREMATCH.$1.$2;
	
	if($follows_rightmost_coordinator =~ /($any_kind_of_noun)((.|\s)*?)($vbd_verb)((.|\s)*?)($any_kind_of_noun)/){
	    $clause1 = $precedes_rightmost_coordinator;
	    $clause2 = $follows_rightmost_coordinator;

	    $sentence1 = $clause1;
	    $sentence2 = $clause2;
	
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-14a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-14b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-14a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-14b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
	else{

	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-15a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-15b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-15a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-15b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($precedes_rightmost_coordinator =~ /(<w c\=\"w\" p\=\"VBN\">told<\/w>\s+<w c\=\"w\" p\=\"IN\">by<\/w>)((.|\s)*?)($colon)(\s*)($quotes)/){
	$clause1 = $POSTMATCH;
	$clause2 = $follows_rightmost_coordinator;
	$subject = $PREMATCH.$&;
	
	if($follows_rightmost_coordinator =~ /($quotes)/){
	    $clause2 = $PREMATCH.$&;

	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-16a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-16b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-16a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-16b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($precedes_rightmost_coordinator =~ /<w c\=\"w\" p\=\"VBN\">told<\/w>/){
	$clause1 = $POSTMATCH;
	$clause2 = $follows_rightmost_coordinator;
	$subject = $PREMATCH.$&;
	

	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-17a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-17b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-17a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-17b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }
    elsif($precedes_rightmost_coordinator =~ /($vb_verb)(\s*)($comm_vbg)/){
	$clause1 = $POSTMATCH;
	$clause2 = $follows_rightmost_coordinator;
	$subject = $PREMATCH.$&;
	
	if($follows_rightmost_coordinator =~ /($quotes)/){
	    $clause2 = $PREMATCH;

	    $sentence1 = $subject.$clause1;
	    $sentence2 = $subject.$clause2;
	
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-18a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-18b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-18a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-18b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($follows_rightmost_coordinator =~ /($quotes)((.|\s)*?)($comm_vbd)(($any_kind_of_sentence_boundary|\s)*)$/){
	$clause2 = $PREMATCH;
	my $follows_coordination = $&.$POSTMATCH;
	$clause2 =~ s/^\s+//;

	
	if($precedes_rightmost_coordinator =~ /^(\s*)($quotes)/){
	    $clause1 = $POSTMATCH;
	    $subject = $&;
	    $clause1 =~ s/\s+$//;

	    unless($clause1 =~ /($quotes)/){
		$sentence1 = $subject.$clause1.$follows_coordination;
		$sentence2 = $subject.$clause2.$follows_coordination;
	
#		print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
		if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		    $final_punctuation = "";
		}
		@simpler_sentences[0] = "{CCV-19a} ".$sentence1.$final_punctuation;
		@simpler_sentences[1] = "{CCV-19b} ".$sentence2;
		
		$simpler_sentences_ref = \@simpler_sentences;
	
		my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
		my $ras1 = $sentence1;
		my $ras2 = $sentence2;
		$ras =~ s/<([^>]*)>//g;
		$ras1 =~ s/<([^>]+)>//g;
		$ras2 =~ s/<([^>]+)>//g;
		print RAC "CCV-19a\t\[$ras\]\t\[$ras1\]\n";	    
		print RAC "CCV-19b\t\[$ras\]\t\[$ras2\]\n";	    
		close(RAC);

		return($simpler_sentences_ref);
	    }
	}
    }
    elsif($follows_rightmost_coordinator =~ /($comma)((.|\s)*?)($vbd_verb)(\s*)($comm_vbn)(($any_kind_of_sentence_boundary|\s)*)$/){
	$clause2 = $PREMATCH;
	my $follows_coordination = $&.$POSTMATCH;
	

	$clause1 = $precedes_rightmost_coordinator;
	$clause1 =~ s/\s+$//;

	$sentence1 = $clause1.$follows_coordination;
	$sentence2 = $clause2.$follows_coordination;
	
	print STDERR "S1 $sentence1\nS2 $sentence2\n";
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-20a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-20b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-20a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-20b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }
# 
#    elsif($precedes_rightmost_coordinator =~ /($ccv_comp_verb)(\s*)($base_np)(\s*)($hyphen)(\s*)($wh_word)((.|\s)*?)$/){
    elsif($precedes_rightmost_coordinator =~ /($ccv_comp_verb)(\s*)($base_np)(\s*)($hyphen|$dash)(\s*)($wh_word)/){
	$subject = $PREMATCH.$1.$7.$8.$21.$22.$23;
	$clause1 = $24.$POSTMATCH;

#	print STDERR "$subject\t\t\[$clause1\]\n";exit;
	my $tail = "";

	if($follows_rightmost_coordinator =~ /(\s*)($dash|$hyphen)/){
	    $clause2 = $PREMATCH;
	    $tail = $&.$POSTMATCH;
	}
	


	$clause1 =~ s/\s+$//;

	$sentence1 = $subject.$clause1.$tail;
	$sentence2 = $subject.$clause2.$tail;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-28a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-28b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-21a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-21b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }
# SABOTAGED THE FOLLOWING RULE AS IT MAKES A LOT OF ERRORS. DELETE THE ROW OF
# Xs TO REINSTATE
# SABOTAGE BRINGS ERROR REDUCTION > 0.03 (i.e. 3%)
    elsif($precedes_rightmost_coordinator =~ /XXXXXXX($any_right_subordination_boundary)((.|\s)*?)($any_kind_of_pron|$any_kind_of_noun)((.|\s)*?)($vbd_verb)/){
	$subject = $PREMATCH.$1;
	$clause1 = $5.$7.$13.$14.$POSTMATCH;

#	print STDERR "\[$clause1\]\n"; exit;

	$clause2 = $follows_rightmost_coordinator;
	


	$clause1 =~ s/\s+$//;

	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-21a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-21b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-21a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-21b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }

    elsif($precedes_rightmost_coordinator =~ /($any_kind_of_adverb)(\s*)($wh_word)/){
	$clause1 = $POSTMATCH;
	my $subject = $PREMATCH.$&;
	
	if($follows_rightmost_coordinator =~ /($subordinating_that)/){
	    my $follows_subordination = $&.$POSTMATCH;
	    $clause2 = $PREMATCH;
	    
	    
	    $sentence1 = $subject.$clause1.$follows_subordination;
	    $sentence2 = $subject.$clause2.$follows_subordination;
	    
#	    print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
		$final_punctuation = "";
	    }
	    @simpler_sentences[0] = "{CCV-22a} ".$sentence1.$final_punctuation;
	    @simpler_sentences[1] = "{CCV-22b} ".$sentence2;
	    
	    $simpler_sentences_ref = \@simpler_sentences;
	    
	    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	    my $ras1 = $sentence1;
	    my $ras2 = $sentence2;
	    $ras =~ s/<([^>]*)>//g;
	    $ras1 =~ s/<([^>]+)>//g;
	    $ras2 =~ s/<([^>]+)>//g;
	    print RAC "CCV-22a\t\[$ras\]\t\[$ras1\]\n";	    
	    print RAC "CCV-22b\t\[$ras\]\t\[$ras2\]\n";	    
	    close(RAC);

	    return($simpler_sentences_ref);
	}
    }
    elsif($precedes_rightmost_coordinator =~ /($ccv_comp_verb)((.|\s)*?)($colon)(\s*)($quotes|\'\')/){
	$clause1 = $POSTMATCH;
	my $subject = $PREMATCH.$&;
	
	$clause2 = $follows_rightmost_coordinator;
	$clause2 =~ s/^\s+//;

	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-26a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-26b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-23a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-23b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }
    elsif($precedes_rightmost_coordinator =~ /($ccv_comp_verb)((.|\s)*?)($quotes|\'\')/){
	$clause1 = $POSTMATCH;
	my $subject = $PREMATCH.$&;
	while($precedes_rightmost_coordinator =~ /($ccv_comp_verb)((.|\s)*?)($quotes|\'\')/g){
	    $clause1 = $POSTMATCH;
	    my $subject = $PREMATCH.$&;
	}
	
	$clause2 = $follows_rightmost_coordinator;
	$clause2 =~ s/^\s+//;

	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-27a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-27b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-23a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-23b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }


    elsif($precedes_rightmost_coordinator =~ /($colon)(\s*)($quotes)/){
	$clause1 = $POSTMATCH;
	my $subject = $PREMATCH.$&;
	
	$clause2 = $follows_rightmost_coordinator;
	$clause2 =~ s/^\s+//;

	$sentence1 = $subject.$clause1;
	$sentence2 = $subject.$clause2;
	
#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;
	
	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-23a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-23b} ".$sentence2;
	
	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-23a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-23b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }

    else{
	print STDERR "2>>>>>>>>>>>>>>>>>>\n";
	$sentence1 = $precedes_rightmost_coordinator;
	$sentence2 = $follows_rightmost_coordinator;
	$sentence1 =~ s/\s*$//;
	$sentence2 =~ s/^\s*//;
	
	$sentence2 =~ s/^(\s*)<PC ([^>]+)>(\,|\:|\;)<\/PC>(\s*)//;

	if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	    $final_punctuation = "";
	}
	@simpler_sentences[0] = "{CCV-24a} ".$sentence1.$final_punctuation;
	@simpler_sentences[1] = "{CCV-24b} ".$sentence2;

#	print STDERR "S1 $sentence1\nS2 $sentence2\n";exit;

	$simpler_sentences_ref = \@simpler_sentences;
	
	my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
	my $ras1 = $sentence1;
	my $ras2 = $sentence2;
	$ras =~ s/<([^>]*)>//g;
	$ras1 =~ s/<([^>]+)>//g;
	$ras2 =~ s/<([^>]+)>//g;
	print RAC "CCV-24a\t\[$ras\]\t\[$ras1\]\n";	    
	print RAC "CCV-24b\t\[$ras\]\t\[$ras2\]\n";	    
	close(RAC);

	return($simpler_sentences_ref);
    }


    open(ERROR_FILE, ">>./CCV_errors.txt");
    print ERROR_FILE "$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n";
    close(ERROR_FILE);
    
    `cat /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt | /home/richard/TTT2/scripts/preparetxt | /home/richard/TTT2/scripts/tokenise | /home/richard/TTT2/scripts/postag -m /home/richard/TTT2/models/pos/ >  /home/richard/FIRST/WP7_TestingAndEvaluation/corpora/annotated/pos_tagged/temp.txt.post.xml`;
#    print STDERR "CCV NO RULE MATCHED\n$precedes_rightmost_coordinator\t\t$potential_coordinator\t\t$follows_rightmost_coordinator\n"; exit;

    my $replacement_pc = $potential_coordinator;
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
    
    $sentence1 = $precedes_rightmost_coordinator.$replacement_pc.$follows_rightmost_coordinator;
    
#    print STDERR "$potential_subordinator\n";exit;

    if($sentence1 =~ /(\.|\?|\!)\s*(\'?)\s*$/){
	$final_punctuation = "";
    }
	    
    @simpler_sentences[0] = "{CCV-25a} ".$sentence1.$final_punctuation;
#    print STDERR "\tS1 $sentence1\n\n"; exit;
	
    my $ras = $precedes_rightmost_coordinator."####".$potential_coordinator."####".$follows_rightmost_coordinator;
    my $ras1 = $sentence1;
    my $ras2 = $sentence2;
    $ras =~ s/<([^>]*)>//g;
    $ras1 =~ s/<([^>]+)>//g;
    $ras2 =~ s/<([^>]+)>//g;
    print RAC "CCV-25a\t\[$ras\]\t\[$ras1\]\n";	    
    close(RAC);

    $simpler_sentences_ref = \@simpler_sentences;
    return($simpler_sentences_ref);
}
1;
