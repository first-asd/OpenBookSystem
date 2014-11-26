# Program us a modified version of
# "conjunction_classifier_diagnosis_sentences.pl"
# Program is designed to take plain text, identify a subset of conjuntions, and
# create a feature vector for each conjuntion that will enable it to be
# classified in the appropriate way by TiMBL.
#
# In order to run the tagger, it is necessary to type:
# PATH=$PATH:/home/richard/Brill_tagger/RULE_BASED_TAGGER_V1.14/Bin_and_Data/; export PATH
# in the shell from which this program is to run.
# ###ID workaround: modify the tagger.c file and rebuild the brill tagger 
# i.e. change "start-state-tagger" to "./start-state-tagger" 
#             "final-state-tagger" to "./final-state-tagger"
#
# Classification Using TiMBL (correct 27/02/2008):
# "and" with semantic tags only: -k 5 -mM:I6-17 -w3 (semantic training data,
#                                                    ignoring PoS features)
# "and" with semantic tags and PoS tags: -k 2 -mM -L1
# "and" without semantic tags: -k 8 -mM -d IL
# "comma" with semantic tags only: -k 2 -mM:I6-17   (semantic training data,
#                                                    ignoring PoS features)
# "comma" with semantic tags and PoS tags: -k 1
# "comma" without semantic tags: -k 2 -mM -w0 -L 4
# "or" with semantic tags only: -k 9                (semantic training data,
#                                                    ignoring PoS features)
# "or" with semantic tags and PoS tags: -k 6        (too little training data)
# "or" without semantic tags: -k 8                  (too little training data)
#
# ", and" with semantic tags and PoS tags: -k 1 -mM -w 4 -L 4
#
# Call using:
# TiMBL -t leave_one_out -f ./(and|comma|or).training.(semantics).txt <OPTIONS>
# Note that current training data does not contain any instances of ", nor", 
# only instances of "nor".
#
# FEATURES: 
#  (1) $conjunction_string 
#  (2-4) $sent_pos 
#  (5) $sentence_length 
#  (6) PT: 
# (7-11)   $prev_tags 
# (12) FT: 
# (13-17) $rest_tags 
# (18) PW: 
# (19-23) $preceding_words 
# (24) FW: 
# (25-29) $following_words 
# (30) $vbp 
# (31) $vbz 
# (32) $vbn 
# (33) $det 
# (34) $cd 
# (35) $jj 
# (36) $nn 
# (37) $prior_adverb 
# (38) PS: 
# (39-40) $preceding_semantic_tags 
# (41) FS: 
# (42-43) $following_semantic_tags 
# (44) ADJ_ST: 
# (45) $adjacent_semantic_tags 
# (46) $conj_adj 
# (47) $conj_n 
# (48-50) $pre_n 
# (51) $num_preceding_determiners 
# (52) $num_following_determiners 
# (53) $prior_determiner_fd_distance 
# (54) $conj_det 
# (55) $conj_cd 
# (56-57) $prior_rb 
# (58) $sentence_class;
#
# Next need to implement an alternate program that exploits FDG/Charniak
# dependencies ALONE when classifying conjunctions. May not be possible for, as
# this is not a lexical item and syntactic analysis tends not to include
# punctuation (though instances could be based on adjacency to other
# constituents and also the classification of adjacent conjunctions.
#
# Need to add IE rules that exploit annotation of different classes of
# conjunction in a sensible way

# Program expects to receive an input $string that is a sentence to process,
# together with the conjunction string and the position of the conjunction.
# That information will all be sent by the program calling this function
package PotentialCoordinatorVectors;
use English;
use strict;
binmode STDIN, ':encoding(UTF-8)'; 
binmode STDOUT, ':encoding(UTF-8)';

# If semantic tagging is to be used to derive features, this process should be
# called  within the current package. First call a function for domain
# detection and then call a function to tag sentences using the appropriate
# ontology for that domain.


my $wp3_dir = "/home/idornescu/sync/FIRST/wp3/perl/";
my $tagger_logfile = $wp3_dir."brill_tagger_logfile.txt";
my $tagger_folder = "/home/idornescu/sync/FIRST/wp3/perl/RULE_BASED_TAGGER_V1.14/Bin_and_Data/";

sub clean_sentence{
	my ($c_for_tagging) = @_;
	return $c_for_tagging;
}
sub postag_sentence{
	my ($c_for_tagging) = @_;

    my $temp_sent_file = rand;
    $temp_sent_file =~ s/^0\.//;
    $temp_sent_file = $wp3_dir."other_output/".$temp_sent_file;
    
    open(TEMP_SENT, ">$temp_sent_file");
    print TEMP_SENT "$c_for_tagging\n";
    close(TEMP_SENT);

    #Brill POS tagger
    #my @tagged_sentence = `PATH=\$PATH:$tagger_folder; export PATH; cd $tagger_folder; ./tagger LEXICON $temp_sent_file BIGRAMS LEXICALRULEFILE CONTEXTUALRULEFILE.WSJ 2>$tagger_logfile`;

    #ID TTT2 postagging
    my @tagged_sentence =`cd ../perl/TTT2/scripts ; cat $temp_sent_file | ./preparetxt | ./tokenise | ./postag -m ../models/pos/ 2>/dev/null | egrep '<p><s' |sed -r 's%<p><s[^>]+>%%g' | sed -r 's%</s></p>%\\n%' |sed -r 's%<w[^>]+p="([^>]+)">([^<]+)</w>%\\2/\\1%g'`;
    ###print $tagged_sentence[0];
 
    my $wp3_programs_dir = $wp3_dir."programs/";
    `cd $wp3_programs_dir`;
    `rm $temp_sent_file`;

    my $tagged_sent_ref = \@tagged_sentence;
    #return($tagged_sent_ref);
    return $tagged_sentence[0];
}


sub potential_coordinator_vector{
    my ($c) = @_;

######### POS TAGGING THE SENTENCE AND CONTEXT IN WHICH #####################
############### THE POTENTIAL COORDINATOR OCCURES ###########################
    my $potential_coordinator;
    
    my %numeric_features = ();
    my %symbolic_features = ();

    my $total_numeric_features = 4;
    my $total_symbolic_features = 46;
# initialising features
    my $i;
    for($i=1; $i < $total_numeric_features; $i++){
	$numeric_features{$i} = 0;
    }
    for($i=1; $i < $total_symbolic_features; $i++){
	$symbolic_features{$i} = 0;
    }

    my $preceding_material = "";
    my $following_material = "";
    my $this_pc = "";

    my $c2=clean_sentence($c);

    #if($c =~ /\[([\,\;\: abcdehilnortuwABCDEHILNORTUW\']+)\]/){
    if($c2 =~ /\[([^\]]+)\]/){
	$this_pc = $&;
	$preceding_material = $PREMATCH;
	$following_material = $POSTMATCH;
    }
    my $c_for_tagging = $c;
    $c_for_tagging =~ s/\[([^\]]+)\]/$1/;
    $c_for_tagging =~ s/([A-Za-z0-9]+)([^A-Za-z0-9\s\t])/$1 $2/g;
    $c_for_tagging =~ s/([^A-Za-z0-9\s\t])([A-Za-z0-9]+)/$1 $2/g;
    $c_for_tagging =~ s/([^A-Za-z0-9\s\t])([^A-Za-z0-9\s\t\1])/$1 $2/g;
    $c_for_tagging =~ s/([^A-Za-z0-9\s\t])\s+\1/$1$1/g;
    $c_for_tagging =~ s/\'\s+s /\'s /g;
    $c_for_tagging =~ s/\'\s+s$/\'s/g;
    $c_for_tagging =~ s/\s+\'\s+(t|d|ll|re)/\'$1/g;
    $c_for_tagging =~ s/\s*\'\s+(cept)/ \'$1/g;
    $c_for_tagging =~ s/\'\'(\.|\?|\!)/\'\' $1/g;
    $c_for_tagging =~ s/\'d/ \'d/g;
    $c_for_tagging =~ s/\'ve/ \'ve/g;
    $c_for_tagging =~ s/\'ll/ \'ll/g;
    $c_for_tagging =~ s/\'re/ \'re/g;
    $c_for_tagging =~ s/n\'t/ n\'t/g;
    $c_for_tagging =~ s/\s+o\'/ o\' /g;
    $c_for_tagging =~ s/\s+o\'\s+clock/ o\'clock/g;


    ###ID I couldn't get the array parameters to work :(
    ### just return a one-line string for the sentence;
    my $tagged_sentence = postag_sentence($c_for_tagging);

    my $ts;
    #$ts = $tagged_sentence[0];
    $ts = $tagged_sentence;

    #print STDERR "===sent:\n$c_for_tagging\n===tags:\n$ts\n$c2\n$c\n";

#    print STDERR "$ts\n";
# Now the sentence is tagged, we want to match the tagged tokens with
# $preceding material and $following_material to identify the location of the
# potential coordinator within the tagged sentence.
# First strip the tags from $ts
# remove spaces in $ts caused by the tokenisation process
# and search for $preceding_material in $ts
    my $match_ts = $ts;
    $match_ts =~ s/\/([^\s\/]+)(\s+)/$2/g;
    $match_ts =~ s/\/([^\s\/]+)$//g;
    $match_ts =~ s/\/(``|''|POS)//g;


    my $ots = $ts;
    my @tags_this_sentence = ();
    while(1){
	if($ots =~ /^\/([^\s]+)$/){
	    my $tag = $&;
	    $ots = $POSTMATCH;
	    push(@tags_this_sentence, $tag);
	}
	if($ots =~ /^\/([^\s]+)(\s+)/){
	    my $tag = $&;
	    $ots = $POSTMATCH;
	    push(@tags_this_sentence, $tag);
	}
	elsif($ots =~ /^./){
	    $ots = $POSTMATCH;
	}
	else{
	    last;
	}
    }
    my $mts = $match_ts;
    my $constructed_preceding_material = "";
    my $constructed_following_material = "";
    my $word_position = 0;
    
##ID:normalisation sequence -> function?
    $preceding_material =~ s/([^A-Za-z0-9\s\t])([A-Za-z0-9]+)/$1 $2/g;
    $preceding_material =~ s/([A-Za-z0-9]+)([^A-Za-z0-9\s\t])/$1 $2/g;
    $preceding_material =~ s/([^A-Za-z0-9\s\t])([^A-Za-z0-9\s\t\1])/$1 $2/g;
    $preceding_material =~ s/([^A-Za-z0-9\s\t])\s+\1/$1$1/g;
    $preceding_material =~ s/\'\s+s /\'s /g;
    $preceding_material =~ s/\'\s+s$/\'s/g;
    $preceding_material =~ s/\s+\'\s+(ll|t|d|re)/\'$1/g;
    $preceding_material =~ s/\s*\'\s+(cept)/ \'$1/g;
    $preceding_material =~ s/\'\'(\.|\?|\!)/\'\' $1/g;
    $preceding_material =~ s/\'d/ \'d/g;
    $preceding_material =~ s/\'ve/ \'ve/g;
    $preceding_material =~ s/\'ll/ \'ll/g;
    $preceding_material =~ s/\'re/ \'re/g;
    $preceding_material =~ s/n\'t/ n\'t/g;
    $preceding_material =~ s/\s+o\'/ o\' /g;
##ID:the following rules seem very specific
    $preceding_material =~ s/\s+o\'\s+clock/ o\'clock/g;
    $preceding_material =~ s/evidence \' /evidence\'/g;
    $preceding_material =~ s/God \' /God\'/g;
    $preceding_material =~ s/speculation \' /speculatio n\'/g;
    $preceding_material =~ s/robbery \' /robbery\'/g;
    $preceding_material =~ s/tariff \' /tariff\'/g;
    $preceding_material =~ s/Committee \' /Committee\'/g;
    $preceding_material =~ s/excuse \' /excuse\'/g;
    $preceding_material =~ s/believe \' /believe\'/g;
    $preceding_material =~ s/likely \' /likely\'/g;
#    $preceding_material =~ s/sad \' /sad\'/g;
    $preceding_material =~ s/word \, \' /word \,\'/g;
    $preceding_material =~ s/sad\'/sad\(\s\*\)\'\(\s\*\)/g;
    $preceding_material =~ s/he was \' sad \' /he was \' sad\'/g;
    $preceding_material =~ s/tariff\'\-/tariff \' \-/g;
    $preceding_material =~ s/excuse\'([a-z]+)/excuse \' $1/g;

    print "====preceding_material\n$preceding_material\n";


    $following_material =~ s/([^A-Za-z0-9\s\t])([A-Za-z0-9]+)/$1 $2/g;
    $following_material =~ s/([A-Za-z0-9]+)([^A-Za-z0-9\s\t])/$1 $2/g;
    $following_material =~ s/([^A-Za-z0-9\s\t])([^A-Za-z0-9\s\t\1])/$1 $2/g;
    $following_material =~ s/([^A-Za-z0-9\s\t])\s+\1/$1$1/g;
#    $following_material =~ s/\'\s+(s|t) /\'$1 /g;
#    $following_material =~ s/\'\s+(s|t)$/\'$1/g;
    $following_material =~ s/\'\s+s /\'s /g;
    $following_material =~ s/\'\s+s$/\'s/g;
    $following_material =~ s/\s+\'\s+(t|d|ll|re)/\'$1/g;
    $following_material =~ s/\s*\'\s+(cept)/ \'$1/g;
    $following_material =~ s/\'\'(\.|\?|\!)/\'\' $1/g;
    $following_material =~ s/\'d/ \'d/g;
    $following_material =~ s/\'ve/ \'ve/g;
    $following_material =~ s/\'ll/ \'ll/g;
    $following_material =~ s/\'re/ \'re/g;
    $following_material =~ s/n\'t/ n\'t/g;
    $following_material =~ s/\s+o\'/ o\' /g;
    $following_material =~ s/\s+o\'\s+clock/ o\'clock/g;
    
    my $tpm = $preceding_material;
    my $tfm = $following_material;
    
    print STDERR "\nCURRENT POTENTIAL COORDINATOR IS $this_pc\nSENTENCE SENT TO BE TAGGED WAS $c_for_tagging\nTAGGED SENTENCE: $ts\n";
    
    if($match_ts =~ /^\s*\Q$preceding_material\E\s*/){
#	print STDERR "PRECEDING MATERIAL $preceding_material\n";
#	print STDERR "FOLLOWING MATERIAL $following_material\n";
    }
    else{
	print STDERR "Could not find prior text \[$preceding_material\] in\n\[$match_ts\]\noriginally tagged as\n\[$ts\]\n";exit;
    }
    
    
    while(1){
	if($tpm =~ /([^\s]+)/){
	    $tpm = $POSTMATCH;
	    $constructed_preceding_material .= $1.@tags_this_sentence[$word_position];
	    $word_position++;
	}
	elsif($tpm =~ /^./){
	    $tpm = $POSTMATCH;
	    $constructed_preceding_material .= $&;
	}
	else{
	    last;
	}
    }
#    print STDERR "CONSTRUCTED PRECEDING MATERIAL\:\n$constructed_preceding_material\n";
    
    my $word_position_increment = 1;
    my $tpc = $this_pc;
    while(1){
	if($tpc =~ /\s+/){
	    $tpc = $POSTMATCH;
	    $word_position_increment++;
	}
	else{
	    last;
	    }
    }
    $word_position += $word_position_increment;
    
#    print STDERR "FOLLOWING MATERIAL IS NOW $tfm\n";
    while(1){
	if($tfm =~ /([^\s]+)/){
	    $tfm = $POSTMATCH;
	    $constructed_following_material .= $1.@tags_this_sentence[$word_position];
	    $word_position++;
	}
	elsif($tfm =~ /^./){
	    $tfm = $POSTMATCH;
	    $constructed_following_material .= $&;
	}
	else{
	    last;
	}
    }
#    print STDERR "CONSTRUCTED FOLLOWING MATERIAL\:\n$constructed_following_material\n";

##################################### BUILDING THE VECTOR ###########

    my $sentence = $potential_coordinator;
    my $prior = $constructed_preceding_material;
    my $following = $constructed_following_material;


    chomp($sentence);
    my $vector = "";



######### Words and PoS tags to the left of the instance
    my $tp = $prior;
    my $num_words_added = 0;
    my $num_preceding_words = 0;
    $symbolic_features{21} = "no";
    $symbolic_features{22} = "no";
    $symbolic_features{23} = "no";
    $symbolic_features{24} = "no";
    $symbolic_features{25} = "no";
    $symbolic_features{26} = "no";
    $symbolic_features{27} = "no";
    $symbolic_features{28} = "no";
    $symbolic_features{29} = "no";
    $symbolic_features{30} = "no";
    $symbolic_features{31} = "no";
    $symbolic_features{32} = "no";
    $symbolic_features{33} = "no";
    $symbolic_features{34} = "no";
    $symbolic_features{35} = "no";
    $symbolic_features{36} = "no";
    $symbolic_features{37} = "no"; # value is "X" or numeric
    $symbolic_features{38} = "no";
    $symbolic_features{39} = "no";
    $symbolic_features{40} = "no";
    $symbolic_features{41} = "no";
    $symbolic_features{42} = "no";
    $symbolic_features{43} = "no";
    $symbolic_features{44} = "no";
    $symbolic_features{45} = "no";


    my $preceding_vbp = 0;
    my $preceding_vbz = 0;
    my $preceding_vbd = 0;
    my $preceding_vbn = 0;
    my $preceding_nn = 0;
    my $preceding_nns = 0;
    my $preceding_prp = 0;
    my $preceding_cd = 0;
    my $preceding_det = 0;
    my $preceding_jj = 0;
    my $preceding_rb = 0;
    my $preceding_no = 0;
    my $preceding_not = 0;
    my $preceding_either = 0;
    my $preceding_neither = 0;
    my $preceding_adverbs = 0;
    my $preceding_prepositions = 0;
    my $immediately_preceding_adjective = 0;
    my $immediately_following_adjective = 0;
    my $immediately_preceding_noun = 0;
    my $immediately_following_noun = 0;
    my $immediately_preceding_det = 0;
    my $immediately_following_det = 0;
    my $immediately_preceding_cd = 0;
    my $immediately_following_cd = 0;
    while(1){
	if($tp =~ /([^\s]+)\/([^\/\s]+)$/){
	    $tp = $PREMATCH;
	    my $this_word = $1;
	    my $this_post = $2;
	    $num_words_added++;
	    $num_preceding_words++;
	    if($this_post eq "VBP"){
		$preceding_vbp = 1;
	    }
	    if($this_post eq "VBZ"){
		$preceding_vbz = 1;
	    }
	    if($this_post eq "VBD"){
		$preceding_vbd = 1;
	    }
	    if($this_post eq "VBN"){
		$preceding_vbn = 1;
	    }
	    if($this_post eq "NN"){
		$preceding_nn = 1;
	    }
	    if($this_post eq "NNS"){
		$preceding_nns = 1;
	    }
	    if($this_post =~ /^PRP/){
		$preceding_prp = 1;
	    }
	    if($this_post eq "CD"){
		$preceding_cd = 1;
	    }
	    if($this_post eq "DT"){
		$preceding_det = 1;
		$numeric_features{2}++; # NUM PRECEDING DETERMINERS
	    }
	    if($this_post =~ /^JJ/){
		$preceding_jj = 1;
	    }
	    if($this_post =~ /^RB/){
		$preceding_rb = 1;
		$preceding_adverbs = 1;
	    }
	    if($this_post =~ /^IN/){
		$preceding_prepositions = 1;
	    }
	    if($this_word =~ /^no$/i){
		$preceding_no = 1;
	    }
	    if($this_word =~ /^not$/i){
		$preceding_not = 1;
	    }
	    if($this_word =~ /^either$/i){
		$preceding_either = 1;
	    }
	    if($this_word =~ /^neither$/i){
		$preceding_neither = 1;
	    }
	    if($num_words_added == 1){
		$symbolic_features{5} = $this_word;
		$symbolic_features{15} = $this_post;
		if($this_post eq "VBN" | $this_post eq "JJ"){
		    $immediately_preceding_adjective = 1;
		}
		elsif($this_post =~ /^(NN|NNS|NNP|NNPS)/){
		    $immediately_preceding_noun = 1;
		}
		elsif($this_post =~ /^DT/){
		    $immediately_preceding_det = 1;
		}
		elsif($this_post eq "CD"){
		    $immediately_preceding_cd = 1;
		}
	    }
	    elsif($num_words_added == 2){
		$symbolic_features{4} = $this_word;
		$symbolic_features{14} = $this_post;
	    }
	    elsif($num_words_added == 3){
		$symbolic_features{3} = $this_word;
		$symbolic_features{13} = $this_post;
	    }
	    elsif($num_words_added == 4){
		$symbolic_features{2} = $this_word;
		$symbolic_features{12} = $this_post;
	    }
	    elsif($num_words_added == 5){
		$symbolic_features{1} = $this_word;
		$symbolic_features{11} = $this_post;
	    }
	}
	elsif($tp =~ /.$/){
	    $tp = $PREMATCH;
	}
	else{
	    last;
	}
    }

####### What type of coordinations are there before the current potential #####
############################# coordinator? ####################################
    my $mp = $prior;
    my $preceding_conjuncts = "";
    while($mp =~ /\/(DT|IN|JJ|IN|NNS|NNP|NN|PRP\$|RB|VBP|VBN|VBZ)((.|\s)*?)\s+(an\'|and|but|nor|or|\&|that|what|when|where|which|while|who)\/CC((.|\s)*?)\/\1(\s|\]|\)|\.|\,|\;)/){
	$mp = $POSTMATCH;
	my $tag = $1;
	unless($preceding_conjuncts =~ /\#\Q$tag\E\#/ | $preceding_conjuncts =~ /\#\Q$tag\E$/){
	    $preceding_conjuncts .= "#".$tag;
	}
    }
    if($preceding_conjuncts eq ""){
	$preceding_conjuncts = "X";
    }
    $preceding_conjuncts =~ s/\#$//;
    $preceding_conjuncts =~ s/^\#//;
    $symbolic_features{35} = $preceding_conjuncts;

######### Words and PoS tags to the right of the instance
    my $tf = $following;
    my $num_words_added = 0;
    my $num_following_words = 0;
    my $following_vbp = 0;
    my $following_vbz = 0;
    my $following_vbd = 0;
    my $following_vbn = 0;
    my $following_nn = 0;
    my $following_nns = 0;
    my $following_prp = 0;
    my $following_cd = 0;
    my $following_det = 0;
    my $following_jj = 0;
    while(1){
	if($tf =~ /^([^\s]+)\/([^\/\s]+)/){
	    $tf = $POSTMATCH;
	    my $this_word = $1;
	    my $this_post = $2;
	    $num_words_added++;
	    $num_following_words++;
	    if($this_post eq "VBP"){
		$following_vbp = 1;
	    }
	    if($this_post eq "VBZ"){
		$following_vbz = 1;
	    }
	    if($this_post eq "VBD"){
		$following_vbd = 1;
	    }
	    if($this_post eq "VBN"){
		$following_vbn = 1;
	    }
	    if($this_post eq "NN"){
		$following_nn = 1;
	    }
	    if($this_post eq "NNS"){
		$following_nns = 1;
	    }
	    if($this_post =~ /^PRP/){
		$following_prp = 1;
	    }
	    if($this_post eq "CD"){
		$following_cd = 1;
	    }
	    if($this_post eq "DT"){
		$following_det = 1;
		$numeric_features{3}++; # NUM OF FOLLOWING DETERMINERS
	    }
	    if($this_post =~ /^JJ/){
		$following_jj = 1;
	    }
	    if($num_words_added == 1){
		$symbolic_features{6} = $this_word;
		$symbolic_features{16} = $this_post;
		if($this_post =~ /^VBN/ | $this_post =~ /^JJ/){
		    $immediately_following_adjective = 1;
		}
		elsif($this_post =~ /^(NN|NNS|NNP|NNPS)/){
		    $immediately_following_noun = 1;
		}
		elsif($this_post =~ /^DT/){
		    $immediately_following_det = 1;
		}
		elsif($this_post =~ /^CD/){
		    $immediately_following_cd = 1;
		}
	    }
	    elsif($num_words_added == 2){
		$symbolic_features{7} = $this_word;
		$symbolic_features{17} = $this_post;
	    }
	    elsif($num_words_added == 3){
		$symbolic_features{8} = $this_word;
		$symbolic_features{18} = $this_post;
	    }
	    elsif($num_words_added == 4){
		$symbolic_features{9} = $this_word;
		$symbolic_features{19} = $this_post;
	    }
	    elsif($num_words_added == 5){
		$symbolic_features{10} = $this_word;
		$symbolic_features{20} = $this_post;
	    }
	}
	elsif($tf =~ /^./){
	    $tf = $POSTMATCH;
	}
	else{
	    last;
	}
    }
####### What type of coordination is there after the current potential ######
############################# coordinator? ####################################
    my $mf = $following;
    my $following_conjuncts = "";
    while($mf =~ /\/(DT|IN|JJ|IN|NNS|NNP|NN|PRP\$|RB|VBP|VBN|VBZ)((.|\s)*?)\s+(\&|an\'|and|but|nor|or|that|what|when|where|which|while|who)\/CC((.|\s)*?)\/\1(\s|\]|\)|\.|\,|\;)/){
	$mf = $POSTMATCH;
	my $tag = $1;
	unless($following_conjuncts =~ /\#\Q$tag\E\#/ | $following_conjuncts =~ /\#\Q$tag\E$/){
	    $following_conjuncts .= "#".$tag;
	}
    }
    if($following_conjuncts eq ""){
	$following_conjuncts = "X";
    }
    $following_conjuncts =~ s/\#$//;
    $following_conjuncts =~ s/^\#//;
    $symbolic_features{36} = $following_conjuncts;

###############################################################################
######### If there is a prior determiner, how close is the next determiner? ###
    if($preceding_det == 1 && $following_det == 0){
	$symbolic_features{37} = "X";
    }
    elsif($preceding_det == 1 && $following_det == 1){
	if($following =~ /([^\s]+)\/DT/){
	    my $intervening = $PREMATCH;
	    my $distance = 0;
	    my $si = $intervening;
	    while($si =~ /([^\s]+)/){
		$si = $POSTMATCH;
		$distance++;
	    }
	    $symbolic_features{37} = $distance;
	}
    }
########## CONJOINED JJ IN ########################################
    if($prior =~ /\/(VBN|JJ)\s+([^\s\/]+)\/IN/ && $following =~ /\/(VBN|JJ)\s+([^\s\/]+)\/IN/){
	$symbolic_features{42} = "yes";
    }

############ CONJOINED NN RB #####################################
    if($prior =~ /\/(NN|NNS|NNP)\s+((.|\s)*?)\/RB/ && $following =~ /\/(NN|NNS|NNP)\s+((.|\s)*?)\/RB/){
	$symbolic_features{43} = "yes";
    }

############ CONJOINED CD IN #####################################
    if($prior =~ /\/CD\s+((.|\s)*?)\/IN/ && $following =~ /\/CD\s+((.|\s)*?)\/IN/){
	$symbolic_features{44} = "yes";
    }

############ CONJOINED NN IN #####################################
    if($prior =~ /\/(NN|NNS|NNP)\s+((.|\s)*?)\/IN/ && $following =~ /\/(NN|NNS|NNP)\s+((.|\s)*?)\/IN/){
	$symbolic_features{45} = "yes";
    }

    if(($following_vbp) == 1 && ($preceding_vbp == 1)){
	$symbolic_features{21} = "yes";
    }
    if(($following_vbz) == 1 && ($preceding_vbz == 1)){
	$symbolic_features{22} = "yes";
    }
    if(($following_vbd == 1|$following_vbn == 1) && ($preceding_vbn == 1|$preceding_vbd == 1)){
	$symbolic_features{23} = "yes";
    }

    if(($following_nn == 1|$following_nns == 1|$following_prp == 1) && ($preceding_nn == 1|$preceding_nns == 1|$preceding_prp == 1)){
	$symbolic_features{24} = "yes";
    }

    if($following_cd == 1 && $preceding_cd == 1){
	$symbolic_features{25} = "yes";
    }

    if($following_det == 1 && $preceding_det == 1){
	$symbolic_features{26} = "yes";
    }

    if($following_jj == 1 && $preceding_jj == 1){
	$symbolic_features{27} = "yes";
    }

    if($preceding_rb == 1){
	$symbolic_features{28} = "yes";
    }
    if($preceding_no == 1){
	$symbolic_features{29} = "yes";
    }

    if($preceding_not == 1){
	$symbolic_features{30} = "yes";
    }

    if($preceding_either == 1){
	$symbolic_features{31} = "yes";
    }

    if($preceding_neither == 1){
	$symbolic_features{32} = "yes";
    }

    if($preceding_adverbs == 1){
	$symbolic_features{33} = "yes";
    }

    if($preceding_prepositions == 1){
	$symbolic_features{34} = "yes";
    }

    if($immediately_following_adjective == 1 && $immediately_preceding_adjective == 1){
	$symbolic_features{38} = "yes";
    }

    if($immediately_following_noun == 1 && $immediately_preceding_noun == 1){
	$symbolic_features{39} = "yes";
    }

    if($immediately_following_det == 1 && $immediately_preceding_det == 1){
	$symbolic_features{40} = "yes";
    }

    if($immediately_following_cd == 1 && $immediately_preceding_cd == 1){
	$symbolic_features{41} = "yes";
    }

############ Sentence position
    my $normalised_sentence_position = int(10 * ($num_preceding_words / ($num_preceding_words + $num_following_words)));
    $numeric_features{1} = $normalised_sentence_position;


# Try to print all numerical features at the end of the vector, and all
# symbolic features at the beginning
# The programs calling this function first print the potential coordinator (F1)
# and finally print the classification (F)
# F2 is 5th word to the left of the instance
# F3 is 4th word to the left of the instance
# F4 is 3rd word to the left of the instance
# F5 is 2nd word to the left of the instance
# F6 is 1st word to the left of the instance
# F7 is 1st word to the right of the instance
# F8 is 2nd word to the right of the instance
# F9 is 3rd word to the right of the instance
# F10 is 4th word to the right of the instance
# F11 is 5th word to the right of the instance

    my $f;
    foreach $f (sort NumSort (keys(%symbolic_features))){
#	$vector .= "S".$f." ".$symbolic_features{$f}." ";
	$vector .= $symbolic_features{$f}." ";
    }
    foreach $f (sort NumSort (keys(%numeric_features))){
#	$vector .= "N".$f." ".$numeric_features{$f}." ";
	$vector .= $numeric_features{$f}." ";
    }
    $vector =~ s/\s+$//g;

#    print STDERR "$vector\n";# exit;
#    if($features{1} ne "NA"){
    if($symbolic_features{45} eq "yes"){
#	exit;
    }
    return($vector);
}
1;

sub NumSort{
    $a <=> $b;
}
