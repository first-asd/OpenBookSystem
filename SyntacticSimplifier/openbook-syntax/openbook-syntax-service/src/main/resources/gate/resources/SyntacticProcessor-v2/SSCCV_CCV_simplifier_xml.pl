# Program processes an input file, extracts sentences, converts sentences which
# contain > 0 potential coordinators into lists of sentences by means of
# recursively using the function "simplify"
#
# Program expects ARGV[0] to be an input file and ARGV[1] to be a training or
# testing file providing sentences and class labels for instances of potential
# coordinators.
# Note, this means that the program calling the ML classifier should produce
# output in a format identical to that produced by human annotators 
use English;
use strict;
use AssessStructuralComplexity; #
use SimplifySSCCV;#
#use SimplifySSMV;
#use SimplifySSMN;
#use SimplifySSMP;
#use SimplifySSMA;
use SimplifyCCV;#
#use SimplifyCMV1;
#use SimplifyCMV1a;
#use SimplifyCMV2;
#use SimplifyCMN1;
#use SimplifyCMN2;
#use SimplifyCMN4;
#use SimplifyCMP;
#use SimplifyCMA1;
#use SimplifyCMAdv;
#use SimplifyCIN;
#use SimplifyCLV;
#use SimplifyCLN;
#use SimplifyCLA;
#use SimplifyCLQ;
#use SimplifyCLP;
#use SimplifyCPA;
use MergeAnnotations;#

my $assessment = "CORRECT";

my $input_file = @ARGV[0];
my $classified_file = @ARGV[1];
my $output_dir = "./syntactically_simplified/";
my $file_label = "";
my $output_file;
#my $ttt2_dir = "/home/richard/TTT2/scripts";
my $ttt2_dir = "/apps/TTT2/scripts";
#my $ttt2_models_dir = "/home/richard/TTT2/models";
my $ttt2_models_dir = "/apps/TTT2/models";
#my $wp3_programs_dir = "/home/richard/FIRST/WP3_ProcessingStructuralComplexity/programs/";
my $wp3_programs_dir = "./"; 
#deprecated?	#my $wp3_dir = "/home/richard/FIRST/WP3_ProcessingStructuralComplexity/";
#deprecated?	#my $wp7_programs_dir = "/home/richard/FIRST/WP7_TestingAndEvaluation/programs";
#my $tagger_logfile = $wp3_programs_dir."tagger_logfile.txt";
my $tagger_logfile = $wp3_programs_dir."tagger_logfile.txt";
#deprecated?	#my $tagger_folder = "/home/richard/Brill_tagger/RULE_BASED_TAGGER_V1.14/Bin_and_Data/";

my $verbosity = 0;

my $number_sentences_simplified = 0;
my $number_long_simplified_sentences = 0;

$file_label = $input_file;
$file_label =~ s/\.(txt|xml|html)//;
while($file_label =~ /\//g)
{
    $file_label = $POSTMATCH;
}
my $graph_output_file = "./".$file_label."\.dot";
# print STDERR "$graph_output_file\n";exit;

my @RuleApplicationClasses = ("CCV", "CMV1", "CMN1", "CMP", "CMA1", "SSCCV", "SSMN", "SSMA", "SSMP", "SSMV");
my $rac;
foreach $rac (@RuleApplicationClasses){
    my $rac_file_name = "RuleApplications.".$rac.".txt";

    open(RAC, ">$rac_file_name");
    print RAC "";
    close(RAC);
}

open(TEMP_LOG, ">./num_coordinators_subordination_boundaries.txt");
print TEMP_LOG "";
close(TEMP_LOG);
open(TEMP_LOG, ">./num_subordinators.txt");
print TEMP_LOG "";
close(TEMP_LOG);
open(TEMP_LOG, ">./num_coordinators.txt");
print TEMP_LOG "";
close(TEMP_LOG);
open(TEMP_LOG, ">./sentence_lengths.txt");
print TEMP_LOG "";
close(TEMP_LOG);
open(TEMP_LOG, ">./sentence_complexity_indices.txt");
print TEMP_LOG "SENTENCE\tLENGTH\t#COORD\t#SUBORD\t#COORDSUBORD\tTOTAL COMPLEXITY\n";
close(TEMP_LOG);


open(ERROR_FILE, ">./CCV_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_CCV = 0;

open(ERROR_FILE, ">./CMN1_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_CMN1 = 0;

open(ERROR_FILE, ">./CMV1_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_CMV1 = 0;

open(ERROR_FILE, ">./CMA1_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_CMA1 = 0;

open(ERROR_FILE, ">./CMP_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_CMP = 0;

open(ERROR_FILE, ">./SSCCV_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_SSCCV = 0;

open(ERROR_FILE, ">./SSMN_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_SSMN = 0;

open(ERROR_FILE, ">./SSMA_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_SSMA = 0;

open(ERROR_FILE, ">./SSMP_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_SSMP = 0;

open(ERROR_FILE, ">./SSMV_errors.txt");
print ERROR_FILE "";
close(ERROR_FILE);
my $num_calls_SSMV = 0;


chomp($input_file);
if($input_file =~ /\/([^\/]+)$/){
    $file_label = $1;
    $output_file = $output_dir.$file_label.".simplified";

    print STDERR "OUTPUT TO $output_file\n";
}

my $simplified_output = "";
open(GRAPH, ">$graph_output_file");
print GRAPH "";
close(GRAPH);

my %pc_classes = ();
open(CF, $classified_file);
while(<CF>){
    my $cfl = $_;
    chomp($cfl);
    if($cfl =~ /\{((.|\s|\t|\t)*?)\} ([0-9]+) ([A-Za-z0-9]+)$/){
	my $pc_sent = $1;
	my $pc_class = $4;

# Changing encoding of the annotated sentences to force a match with the
# encoding used by the TTT2
	$pc_sent =~ s/Â£/\&amp\;\#163\;/g;
	$pc_sent =~ s/\&\#/\&amp\;\#/g;
	$pc_sent =~ s/([^A-Za-z0-9\(\)\,\;\:\[\]])//g;

	if($pc_sent =~ /financialaid/){
#	    print STDERR "PC SENT IS \[$pc_sent\]\n";exit;
	}
	$pc_classes{$pc_sent} = $pc_class;


    }
}
close(CF);

my $pos_tag_file = $input_file.".post.xml";
$pos_tag_file =~ s/\/corpora\//\/corpora\/annotated\/pos\_tagged\//;

my @pos_tagged = ();
if(-e $pos_tag_file){
    open(POS_TAG_FILE, $pos_tag_file);
    while(<POS_TAG_FILE>){
	my $pos_line = $_;
	chomp($pos_line);
	push(@pos_tagged, $pos_line);
    }
    close(POS_TAG_FILE);
#    print STDERR "Finished part of speech tagging at $pos_tag_file\n";exit;
}
else{
    my ($start_time) = `date`;
    print STDERR "Started part of speech tagging at $start_time\n";
    my %sent_pos = ();
    print STDERR "cat $input_file | $ttt2_dir/preparetxt | $ttt2_dir/tokenise | $ttt2_dir/postag -m $ttt2_models_dir/pos";
    @pos_tagged = `cat $input_file | $ttt2_dir/preparetxt | $ttt2_dir/tokenise | $ttt2_dir/postag -m $ttt2_models_dir/pos`;
    my ($finish_time) = `date`;
#    print STDERR "Finished part of speech tagging at $finish_time\n$pos_tag_file\n";
    
    
    my $i;
    open(POS_TAG_FILE, ">$pos_tag_file");
    for($i=0; $i < @pos_tagged; $i++){
	my $posti = @pos_tagged[$i];
	print POS_TAG_FILE "$posti";
    }
    close(POS_TAG_FILE);
}



print("<\?xml version\=\"1\.0\" encoding\=\"UTF\-8\"\?>\n<TEXT>\n");

my $pos_tag_ref = \@pos_tagged;
my $pc_classes_ref = \%pc_classes;

my $constructed_xml_tagged_sentence = MergeAnnotations::merge($pos_tag_ref, $pc_classes_ref);
# print STDERR "$constructed_xml_tagged_sentence\n";exit;


my $pos_tagged_file_contains_paired_apostrophes = 0;
my $n=0;
my $i;

while($constructed_xml_tagged_sentence =~ /<s ([^>]+)>((.|\s)*?)<\/s>/g){
    print STDERR "$&\n";
    my $xml_tagged_sentence = $2;



    my $original_sentence = $xml_tagged_sentence;
    my $print_original_sentence = $original_sentence;

    print STDERR "\[$print_original_sentence\]\n";

    $print_original_sentence =~ s/\[([\:\;\, abcdehilnortuw]+)\]/$1/g;
    $print_original_sentence =~ s/^\s+//;
    $print_original_sentence =~ s/<([^>]+)>//g;
    $print_original_sentence =~ s/\&(\s+)/\&amp\;$1/g;
    $print_original_sentence =~ s/\&(\s+)$/\&amp\;$1/g;
    $print_original_sentence =~ s/</\&lt\;/g;

#    print("<SENTENCE>\n<ORIGINAL>$print_original_sentence<\/ORIGINAL>\n");

#    $print_original_sentence =~ s/\[([\:\;\,\(\) abcdehilnortuw]+)\]/$1/g;
    $print_original_sentence =~ s/^\s+//;
    print PROBLEM "$print_original_sentence\n";
    close(PROBLEM);
    
    $print_original_sentence =~ s/<([^>]+)>//g;
    $print_original_sentence =~ s/\&(\s+)/\&amp\;$1/g;
    $print_original_sentence =~ s/\&(\s+)$/\&amp\;$1/g;
    $print_original_sentence =~ s/</\&lt\;/g;

    $assessment = "CORRECT";
#    if($xml_tagged_sentence =~ /\"(CCV|SSCCV)\"/){
    if($xml_tagged_sentence =~ /\"SSCCV\"/){
	$assessment = "INCORRECT";
    }
    print("<SENTENCE ASSESSMENT\=\"$assessment\"><ORIGINAL>$print_original_sentence<\/ORIGINAL>\n");

    my @simplified_sentences = ();
    
    if($verbosity == 1){
	print("ORIGINAL $xml_tagged_sentence\n");
    }

    open(TAGGED_SENTENCES, ">>./fully_xml_tagged_input.xml");
    print TAGGED_SENTENCES "$xml_tagged_sentence\n";
    close(TAGGED_SENTENCES);
    
    my $structural_complexity = AssessStructuralComplexity::assessment($xml_tagged_sentence);
    
#    die "STRUCTURAL COMPLEXITY $structural_complexity\n";

    my @working_set = ("$xml_tagged_sentence");
    
    my $ws_size = 1;

    while(@working_set != 0){
	my $si = pop(@working_set);
	
	my $new_si = "";
	my $old_si = $si;
	
	while(1){
	    if($old_si =~ /^<([^>]+)>/){
		$new_si .= $&;
		$old_si = $POSTMATCH;
	    }
	    elsif($old_si =~ /^\"/){
		$new_si .= "''";
		$old_si = $POSTMATCH;
	    }
	    elsif($old_si =~ /^(.|\s)/){
		$new_si .= $&;
		$old_si = $POSTMATCH;
	    }
	    else{
		$si = $new_si;
		last;
	    }
	}
	
	print STDERR "SI IS\n$si\n";

	my %pushed_onto_working_set = ();
	
	my $pcs_this_si = 0;
	while($si =~ /<PC /g){
	    $pcs_this_si++;
	}
	print STDERR "Number of potential coordinators\: $pcs_this_si\n";
	
	my $divided_once = 0;
	
# Be aware that if rewrite rules do not exist for any of the classes specified
# in the regEx below, some sentences will not be simplified or added to the
# final set of simplified sentences to be printed

# Ordered list of classes to be simplified
#		my @pc_classes = ("SSCCV", "SSMV", "SSMN", "SSMP", "SSMA", "CCV", "CMV1", "CMV2", "CMN1", "CMN2", "CMN4", "CMP", "CMA1", "CMAdv", "CIN", "CLV", "CLN", "CLA", "CLQ", "CLP", "CPA");
	my @pc_classes = ("CCV", "CMV1", "CMV2", "CMN1", "CMN2", "CMN4", "CMP", "CMA1", "CMAdv", "CIN", "CLV", "CLN", "CLA", "CLQ", "CLP", "CPA");
# UNCOMMENT THE FOLLOWING LINE AND COMMENT THE PREVIOUS ONE
	@pc_classes = ("CCV", "CMV1", "CMN1", "CMP", "CMA1"); 
	@pc_classes = ("CCV"); 

# Ordered list of types of potential coordinator
# The patterns below currently cover > 95% of the cases in the meter corpus (first half). It may be necessary
# to handle more cases in order to deal effectively with those constituting 95%
#		my @pc_patterns = ("(and|but|or|that|when|which|who)","(\,)(\\\s+)(and|but|who)","(\,|\:)");
# I am tempted not to rewrite "when", "which", "who", or "that" but to exploit the classification of these
# subordinators when rewriting the coordinators. So @pc_patterns becomes
# May remove ";" from @pc_patterns, below:
	my @pc_patterns = ("(and|but|or)","(\,)(\\\s+)(and|but)","(\,|\;)");
# First processing leftmost subordination boundaries
	my $p;

	my $simpler_pair_ref;
	  
# Now processing coordination
	my $c;
	for($c=0; $c < @pc_classes; $c++){
	    my $pcc = @pc_classes[$c];
	    
	    my $p;
	    for($p=0; $p < @pc_patterns; $p++){
		my $pcp = @pc_patterns[$p];
		
		my $pc_match_pattern = "<PC ID\=\"([0-9]+)\" CLASS\=\"$pcc\">$pcp<\/PC>";
		
		
# BE AWARE THERE ARE 2 TYPES OF REWRITING.
# REWRITING COORDINATION INVOLVES WORKING FROM RIGHT TO LEFT.
# REWRITING SUBORDINATION INVOLVES WORKING FROM LEFT TO RIGHT.
		if($si =~ /$pc_match_pattern/i){
		    my $precedes_pc;
		    my $follows_pc;
		    my $this_pc = $&;
		    
		    my $precedes_sc = $PREMATCH;
		    my $follows_sc = $POSTMATCH;
		    
		    
		    while($si =~ /$pc_match_pattern/ig){
			$precedes_pc = $PREMATCH;
			$follows_pc = $POSTMATCH;
		    }


#			    print STDERR "\n\nPPC $precedes_pc\nFPC $follows_pc\n";




		    if($pcc eq "CCV"){
			unless($divided_once == 1){
			    $simpler_pair_ref = SimplifyCCV::simplify($si, $precedes_pc, $follows_pc, $this_pc);
			    $divided_once = 1;
			    $num_calls_CCV++;
			}
		    }

		    

#			    print STDERR "\t+++ $simpler_pair_ref +++\n\t+++From $si +++\n";
		    if($simpler_pair_ref != 0){
			my @simpler_pair = @$simpler_pair_ref;
			my $si1 = @simpler_pair[0];
			my $si2 = @simpler_pair[1];
# Reversing order of returned sentences to improve
# flow of simplified sentences
#				my $si1 = @simpler_pair[1];
#				my $si2 = @simpler_pair[0];




			my $num_output_pcs = 0;
			while($si1 =~ /<PC /g){
			    $num_output_pcs++;
			}
			while($si1 =~ /<PC /g){
			    $num_output_pcs++;
			}				
			print STDERR "\nINPUT SI was \n$si\nPC PAT IS $this_pc\nPC CLASS IS $pcc\n\tS1 is $si1\n\tS2 is $si2\nNumber potential coordinators in output sentences\: $num_output_pcs\nType c to continue\: \n";



#				my $q=0;
#				while($q==0){
#				    my $input = <STDIN>;
#				    chomp($input);
#				    if($input =~ /c/){
#					$q = 1;
#				    }
#				}

# Failure to check these conditions leads to infinite recursion
			unless($pushed_onto_working_set{$si1} == 1){
			    push(@working_set, $si1);
			    $pushed_onto_working_set{$si1} = 1;
			}
			unless($pushed_onto_working_set{$si2} == 1){
			    push(@working_set, $si2);
			    $pushed_onto_working_set{$si2} = 1;

			}

			

			$ws_size = @working_set;
#				print STDERR "Working set\:\n";
			my $ews;
			foreach $ews (@working_set){
			    my $print_ews = $ews;
			    $print_ews =~ s/<w ([^>]+)>([^<]+)<\/w>/$2/g;
#				    print STDERR ">>> $ews\n";
			}

			if($ws_size > 33){
#				    print STDERR "working set suspiciously big $ws_size\nPC $pc_match_pattern\nXML $xml_tagged_sentence\n";
			    my $z;
			    for($z=0; $z < @simplified_sentences; $z++){
				my $print_ews = @simplified_sentences[$z];
				$print_ews =~ s/<w ([^>]+)>([^<]+)<\/w>/$2/g;
			    }
#				    exit;
			}
		    }
		}	
		else{ # if this particular potential coordinator is not in working set member $si
		    my $already_pushed_this_sent = 0;
		    my $k;
		    for($k=0; $k < @simplified_sentences; $k++){
			my $ssk = @simplified_sentences[$k];
			$ssk =~ s/\{([^}]+)\}//g;
			$ssk =~ s/^\s+//;
			$ssk =~ s/\s+$//;
			my $match_si = $si;
			$match_si =~ s/\{([^\}]+)\}//g;
			$match_si =~ s/^\s+//;
			$match_si =~ s/\s+$//;
			
			if($match_si eq $ssk){
			    $already_pushed_this_sent = 1;
			}
		    }
		    unless($already_pushed_this_sent == 1){
#				unless($si =~ /CLASS\=\"(SSCCV|SSMV|SSMN|SSMP|SSMA|CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\"/){



#				unless($si =~ /CLASS\=\"(CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\"/){
#				unless($si =~ /CLASS\=\"(CCV|CMV1|CMN1|CMP|CMA1)\"/){

# more restrictive filter in order to prevent sentences that still contain subordination boundaries from
# entering the final set of simplified sentences
#				unless($si =~ /CLASS\=\"(SSCCV|SSMN|CCV|CMV1|CMN1|CMP|CMA1)\"/){


#				unless($si =~ /CLASS\=\"(CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\"/){
# UNCOMMENT THE FOLLOWING LINE AND COMMENT THE PRECEDING ONE


			unless($si =~ /CLASS\=\"(CCV)\">(and|but|or|\,\s+and|\,\s+but|\,)</i){
#				unless(1 == 0){
			    push(@simplified_sentences, $si);
			}		
		    }
		    
		}
		
	    }
	}
    }



### NOW @working_set = @simplified_sentences and we apply the preceding process to the subordinating classes #####################################
#	    push(@working_set, @simplified_sentences);
    @working_set = @simplified_sentences;
    @simplified_sentences = ();


    while(@working_set != 0){
	my $si = pop(@working_set);
	
	my $new_si = "";
	my $old_si = $si;
	
	while(1){
	    if($old_si =~ /^<([^>]+)>/){
		$new_si .= $&;
		$old_si = $POSTMATCH;
	    }
	    elsif($old_si =~ /^\"/){
		$new_si .= "''";
		$old_si = $POSTMATCH;
	    }
	    elsif($old_si =~ /^(.|\s)/){
		$new_si .= $&;
		$old_si = $POSTMATCH;
	    }
	    else{
		$si = $new_si;
		last;
	    }
	}
#		print STDERR "SI IS\n$si\n";exit;
	
	my %pushed_onto_working_set = ();

	my $pcs_this_si = 0;
	while($si =~ /<PC /g){
	    $pcs_this_si++;
	}
	print STDERR "Number of potential coordinators\: $pcs_this_si\n";
	
	my $divided_once = 0;
	
# Be aware that if rewrite rules do not exist for any of the classes specified
# in the regEx below, some sentences will not be simplified or added to the
# final set of simplified sentences to be printed

# Ordered list of classes to be simplified
# Note that in the annotated corpus, sentence initial SS_ classes have not been
# annotated. This motivates future inclusion of "ES" classes as triggers for
# simplification
#		my @pc_classes = ("SSCCV", "SSMV", "SSMN", "SSMP", "SSMA", "CCV", "CMV1", "CMV2", "CMN1", "CMN2", "CMN4", "CMP", "CMA1", "CMAdv", "CIN", "CLV", "CLN", "CLA", "CLQ", "CLP", "CPA");
#		my @pc_classes = ("SSCCV", "SSMV", "SSMN", "SSMP", "SSMA");
# UNCOMMENT THE FOLLOWING LINE AND COMMENT THE PREVIOUS ONE
# Important that SSMA precedes SSMP
	my @pc_classes = ("SSCCV", "SSMN", "SSMA", "SSMP", "SSMV"); 
	@pc_classes = ("SSCCV");

# Ordered list of types of potential coordinator
# The patterns below currently cover > 95% of the cases in the meter corpus (first half). It may be necessary
# to handle more cases in order to deal effectively with those constituting 95%
#		my @pc_patterns = ("(and|but|or|that|when|which|who)","(\,)(\\\s+)(and|but|who)","(\,|\:)");
# I am tempted not to rewrite "when", "which", "who", or "that" but to exploit the classification of these
# subordinators when rewriting the coordinators. So @pc_patterns becomes
#		my @pc_patterns = ("(and|but|or)","(\,)(\\\s+)(and|but)","(\,)");
# Seems that class SSCCV "that" is too difficult to simplify, so removing "that"
#
#
# May remove ";" from @pc_patterns, below
	my @pc_patterns = ("(and|but|or|that|which|who)","(\,)(\\\s+)(and|but|which|who)","(\,|\;)");
#		my @pc_patterns = ("(and|but|or)","(\,)(\\\s+)(and|but)","(\,)");
# First processing leftmost subordination boundaries
	my $p;
	
	my $simpler_pair_ref;
	  

# Note: sentences that cannot be processed by the relevant simplify function
# cannot be added to @simplified_sentences because they still contain the
# tagged PC. It is vital that whenever a simplify function is called, it is
# able to return sentences that no longer contain the tagged PC that triggered
# the function 
# Catch-all flags are:
#     SSCCV-25a;

# Now processing coordination
	my $c;
	for($c=0; $c < @pc_classes; $c++){
	    my $pcc = @pc_classes[$c];
	    
	    my $p;
	    for($p=0; $p < @pc_patterns; $p++){
		my $pcp = @pc_patterns[$p];
		
		my $pc_match_pattern = "<PC ID\=\"([0-9]+)\" CLASS\=\"$pcc\">$pcp<\/PC>";
		
# BE AWARE THERE ARE 2 TYPES OF REWRITING.
# REWRITING COORDINATION INVOLVES WORKING FROM RIGHT TO LEFT.
# REWRITING SUBORDINATION INVOLVES WORKING FROM LEFT TO RIGHT.
		if($si =~ /$pc_match_pattern/i){
		    my $precedes_pc;
		    my $follows_pc;
		    my $this_pc = $&;
		    
		    my $precedes_sc = $PREMATCH;
		    my $follows_sc = $POSTMATCH;
		    
		    while($si =~ /$pc_match_pattern/ig){
			$precedes_pc = $PREMATCH;
			$follows_pc = $POSTMATCH;
		    }
		    
		    
#			    print STDERR "PPC $precedes_pc\nFPC $follows_pc\n";
		    
		    
		    
		    if($pcc eq "SSCCV"){
			unless($divided_once == 1){
			    
			    $simpler_pair_ref = SimplifySSCCV::simplify($si, $precedes_sc, $follows_sc, $this_pc);
			    $divided_once = 1;
			    $num_calls_SSCCV++;
			}
		    }

		    
		    

#			    print STDERR "\t+++ $simpler_pair_ref +++\n\t+++From $si +++\n";
		    if($simpler_pair_ref != 0){
			my @simpler_pair = @$simpler_pair_ref;
#				my $si1 = @simpler_pair[0];
#				my $si2 = @simpler_pair[1];
# Reversing order of returned sentences to improve
# flow of simplified sentences
			my $si1 = @simpler_pair[1];
			my $si2 = @simpler_pair[0];
			
			my $num_output_pcs = 0;
			while($si1 =~ /<PC /g){
			    $num_output_pcs++;
			}
			while($si1 =~ /<PC /g){
			    $num_output_pcs++;
			}				
			print STDERR "\nINPUT SI was \n$si\nPC PAT IS $this_pc\nPC CLASS IS $pcc\n\tS1 is $si1\n\tS2 is $si2\nNumber potential coordinators in output sentences\: $num_output_pcs\nType c to continue\: \n";
			if($si =~ /st<w/){
			    exit;
			}
			
			
			
#				my $q=0;
#				while($q==0){
#				    my $input = <STDIN>;
#				    chomp($input);
#				    if($input =~ /c/){
#					$q = 1;
#				    }
#				}

# Failure to check these conditions leads to infinite recursion
			unless($pushed_onto_working_set{$si1} == 1){
			    push(@working_set, $si1);
			    $pushed_onto_working_set{$si1} = 1;
			}
			unless($pushed_onto_working_set{$si2} == 1){
			    push(@working_set, $si2);
			    $pushed_onto_working_set{$si2} = 1;
			}
			
			
			
			$ws_size = @working_set;
#				print STDERR "Working set\:\n";
			my $ews;
			foreach $ews (@working_set){
			    my $print_ews = $ews;
			    $print_ews =~ s/<w ([^>]+)>([^<]+)<\/w>/$2/g;
			    print STDERR ">>> $ews\n";
			}
			
			if($ws_size > 33){
#				    print STDERR "working set suspiciously big $ws_size\nPC $pc_match_pattern\nXML $xml_tagged_sentence\n";
			    my $z;
			    for($z=0; $z < @simplified_sentences; $z++){
				my $print_ews = @simplified_sentences[$z];
				$print_ews =~ s/<w ([^>]+)>([^<]+)<\/w>/$2/g;
#					if($print_ews =~ /tormentors/){
#					    print STDERR "\~\-\~\-\~\-\~\-\~\-$print_ews\n";
#					}
			    }
#				    exit;
			}
		    }
		}	
		else{ # if this particular potential coordinator is not in working set member $si
		    my $already_pushed_this_sent = 0;
		    my $k;
		    for($k=0; $k < @simplified_sentences; $k++){
			my $ssk = @simplified_sentences[$k];
			$ssk =~ s/\{([^}]+)\}//g;
			$ssk =~ s/^\s+//;
			$ssk =~ s/\s+$//;
			my $match_si = $si;
			$match_si =~ s/\{([^\}]+)\}//g;
			$match_si =~ s/^\s+//;
			$match_si =~ s/\s+$//;
			
			if($match_si eq $ssk){
			    $already_pushed_this_sent = 1;
			}
		    }
		    unless($already_pushed_this_sent == 1){
#				unless($si =~ /CLASS\=\"(SSCCV|SSMV|SSMN|SSMP|SSMA|CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\"/){
#				unless($si =~ /CLASS\=\"(SSCCV|SSMN)\"/){

#				unless($si =~ /CLASS\=\"(SSCCV|SSMV|SSMN|SSMP|SSMA|CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\"/){
# UNCOMMENT THE FOLLOWING LINE AND COMMENT THE PRECEDING ONE
#				unless($si =~ /CLASS\=\"(SSCCV|SSMN|SSMA|SSMP|SSMV|CCV|CMV1|CMN1|CMP|CMA1)\"/){


# Necessary to ensure that ONLY sentences that still contain classes-patterns intended to be removed
# blocked from entering @simplified_sentences. Failure to specify classes AND patterns below causes
# blocking of sentences containing instances that were never intended to be removed.

#			unless($si =~ /CLASS\=\"(SSCCV|SSMN|SSMA|SSMP|SSMV|CCV|CMV1|CMN1|CMP|CMA1)\">(and|but|or|that|which|who|\,\s+and|\,\s+but|\,\s+which|\,)</i){
			unless($si =~ /CLASS\=\"(SSCCV|CCV)\">(and|but|or|that|which|who|\,\s+and|\,\s+but|\,\s+which|\,\s+who|\,)</i){
#				unless(1 == 0){
			    push(@simplified_sentences, $si);
			}
			else{
#				    print STDERR "NOT PUSHING \[$si\]\nalready pushed \= $already_pushed_this_sent\n";
			}
		    }
		}
	    }
	}
    }




#######################################################################################################################



    my $ss_size = @simplified_sentences;

#	    $sentence =~ s/<\/w>//g; 
#	    $sentence =~ s/<w ([^>]+)>//g;
#	    print STDERR "\nORIGINAL SENTENCE\n$sentence\n"; 
#	    print STDERR "FINISHED SIMPLIFYING\n\tSS SIZE is $ss_size\n";
# Just printing simplified versions for sentences that contain the types of PC
# specified above

    
    if($verbosity == 1){
	print("FINAL SET OF SIMPLIFIED SENTENCES\n");
	my $x;
	foreach $x (@simplified_sentences){
	    print("\t\[$x\]\n");
	}
    }
    
    if($xml_tagged_sentence =~ /\"UNKNOWN\"/){
	print STDERR "Lacking information on some potential coordinators\n";
    }
#	    elsif($xml_tagged_sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"(SSCCV|SSMV|SSMN|SSMP|SSMA|CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\">/){ # |CMV2|CMN1|CMN4|CMA1|CIN|CLV|CLN|CMAdv|CLA|CLQ|CLP|CMP|CPA)\">/){
    elsif($xml_tagged_sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"(SSMN|SSCCV|SSMA|SSMP|SSMV|CCV|CMV1|CMV2|CMN1|CMN2|CMN4|CMP|CMA1|CMAdv|CIN|CLV|CLN|CLA|CLQ|CLP|CPA)\">/){
#		print STDERR "ORIGINAL SENTENCE: $xml_tagged_sentence\n";
#		print STDERR "ORIGINAL SENTENCE: $original_sentence\n";
	my $j=0;
	my $print_sentence = $xml_tagged_sentence;
	
	$print_sentence =~ s/<([^>]+)>//g;
	
	my %printed_sentences = ();
	
	
	my $sss = @simplified_sentences;
	if($sss > 1){ # For debugging, easier to impose this condition
#		    print("\n$print_sentence\n");
	    print("<SIMPLIFIED>\n");
	    $number_sentences_simplified++;
	    $simplified_output = "";
	    
	    my %printed_this_sentence = ();
	    $printed_this_sentence{$print_sentence} = 1;
	    
	    for($j=0; $j < @simplified_sentences; $j++){
		my $simplified_sentence = @simplified_sentences[$j];
		my $ps = $simplified_sentence;
		my $fps = format_sentence($ps);
		$fps =~ s/<([^>]+)>//g;
		my $raw_sentence = $fps;
		$raw_sentence =~ s/\{([^\s]+)\} //g;
		
#			print STDERR "\t>>> $simplified_sentence\n";
		print STDERR "\t>>> $fps\n";
		if($fps =~ /([A-Za-z0-9]+)/){
#			    print("\t$fps\n");
		    
		    
		    
		    unless($printed_this_sentence{$raw_sentence} == 1){
			if($fps =~ /^\s*\{([^\s]+)\}/){
			    
			    my $derivation = "";
			    my $temp_fps = $fps;
			    while($temp_fps =~ /\{([^\s]+)\} /g){
				$derivation .= ", $1";
			    }
			    $derivation =~ s/^\, //;
			    my $print_fps = $fps;
			    $print_fps =~ s/\{([^\s]+)\} //g;
			    
			    my $new_print_fps = "";
			    my $old_print_fps = $print_fps;
			    
			    
#				    print STDERR "HERE $pos_tagged_file_contains_paired_apostrophes\n$old_print_fps";# exit;
			    if($pos_tagged_file_contains_paired_apostrophes == 0){
				while(1){
				    if($old_print_fps =~ /^\'\'/){
					$new_print_fps .= "\"";
					$old_print_fps = $POSTMATCH;
				    }
				    elsif($old_print_fps =~ /^<([^>]+)>/){
					$new_print_fps .= $&;
					$old_print_fps = $POSTMATCH;
				    }
				    
				    elsif($old_print_fps =~ /^(.|\s)/){
					$new_print_fps .= $&;
					$old_print_fps = $POSTMATCH;
				    }
				    else{
					$print_fps = $new_print_fps;
					last;
				    }
				}
			    }
			    
			    print("\t<S DERIVATION\=\"$derivation\">$print_fps<\/S>\n");
			    
#			    exit;

			    $printed_this_sentence{$raw_sentence} = 1;
			    
			    if($fps =~ /((\{([^\}]+)\}\s+)*)/){
				my $final_simplified_sentence = $POSTMATCH;
				$simplified_output .= " <START> ".$final_simplified_sentence." <END> ";
			    }
			}
		    }
		    
		}
		
		my $ssj_length = sentence_length($ps);
		if($ssj_length > 25){
		    $number_long_simplified_sentences++;
		}
	    }
#		    my @graph;
# Comment out next line for efficiency unless testing graph output
#		    my @graph = `perl ./reformatting_redundancy.pl "$simplified_output"`;
#		    open(GRAPH, ">>$graph_output_file");
#		    my $arc;
#		    print STDERR "$simplified_output\n";
#		    foreach $arc (@graph){
#			print GRAPH "$arc";
#		    }
#		    print GRAPH "\n";
#		    close(GRAPH);

#		    exit;

	    print("<\/SIMPLIFIED>\n");
	}
    }
    elsif($xml_tagged_sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"COMBINATORY\">/){
    }
    elsif($xml_tagged_sentence =~ /<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">/){
	my $xts_class = $2;
#		if($xts_class =~ /^(C|S)/){
	if($xts_class =~ /^(C)/){
	    unless($xts_class eq "(SPECIAL|CLAdv)"){
#			print STDERR "########################## No rules to handle $xts_class\n";exit;
	    }
	}
    }
    print STDERR "FINISHED PROCESSING THIS SENTENCE\n";
    print("<\/SENTENCE>\n");
}

print STDERR "Altogether\, $number_sentences_simplified sentences simplified\n";
print STDERR "$number_long_simplified_sentences of the output simplified sentences are still more than 25 words long\n";


my ($CCV_error_info) = `wc -l ./CCV_errors.txt`;
my $CCV_error_number = 0;
if($CCV_error_info =~ /^([0-9]+)/){
    $CCV_error_number = $1;
}
if($num_calls_CCV > 0){
    my $CCV_error_rate = $CCV_error_number / $num_calls_CCV;
    print STDERR "$num_calls_CCV calls to SimplifyCCV\n$CCV_error_number complex strings could not be simplified\n$CCV_error_rate complex strings could not be simplified\n\n";
}

my ($CMN1_error_info) = `wc -l ./CMN1_errors.txt`;
my $CMN1_error_number = 0;
if($CMN1_error_info =~ /^([0-9]+)/){
    $CMN1_error_number = $1;
}
if($num_calls_CMN1 > 0){
    my $CMN1_error_rate = $CMN1_error_number / $num_calls_CMN1;
    print STDERR "$num_calls_CMN1 calls to SimplifyCMN1\n$CMN1_error_number complex strings could not be simplified\n$CMN1_error_rate complex strings could not be simplified\n\n";
}

my ($CMV1_error_info) = `wc -l ./CMV1_errors.txt`;
my $CMV1_error_number = 0;
if($CMV1_error_info =~ /^([0-9]+)/){
    $CMV1_error_number = $1;
}
if($num_calls_CMV1 > 0){
    my $CMV1_error_rate = $CMV1_error_number / $num_calls_CMV1;
    print STDERR "$num_calls_CMV1 calls to SimplifyCMV1\n$CMV1_error_number complex strings could not be simplified\n$CMV1_error_rate complex strings could not be simplified\n\n";
}

my ($CMA1_error_info) = `wc -l ./CMA1_errors.txt`;
my $CMA1_error_number = 0;
if($CMA1_error_info =~ /^([0-9]+)/){
    $CMA1_error_number = $1;
}
if($num_calls_CMA1 > 0){
    my $CMA1_error_rate = $CMA1_error_number / $num_calls_CMA1;
    print STDERR "$num_calls_CMA1 calls to SimplifyCMA1\n$CMA1_error_number complex strings could not be simplified\n$CMA1_error_rate complex strings could not be simplified\n\n";
}

my ($CMP_error_info) = `wc -l ./CMP_errors.txt`;
my $CMP_error_number = 0;
if($CMP_error_info =~ /^([0-9]+)/){
    $CMP_error_number = $1;
}
if($num_calls_CMP > 0){
    my $CMP_error_rate = $CMP_error_number / $num_calls_CMP;
    print STDERR "$num_calls_CMP calls to SimplifyCMP\n$CMP_error_number complex strings could not be simplified\n$CMP_error_rate complex strings could not be simplified\n\n";
}

my ($SSCCV_error_info) = `wc -l ./SSCCV_errors.txt`;
my $SSCCV_error_number = 0;
if($SSCCV_error_info =~ /^([0-9]+)/){
    $SSCCV_error_number = $1;
}
if($num_calls_SSCCV > 0){
    my $SSCCV_error_rate = $SSCCV_error_number / $num_calls_SSCCV;
    print STDERR "$num_calls_SSCCV calls to SimplifySSCCV\n$SSCCV_error_number complex strings could not be simplified\n$SSCCV_error_rate complex strings could not be simplified\n\n";
}

my ($SSMN_error_info) = `wc -l ./SSMN_errors.txt`;
my $SSMN_error_number = 0;
if($SSMN_error_info =~ /^([0-9]+)/){
    $SSMN_error_number = $1;
}
if($num_calls_SSMN > 0){
    my $SSMN_error_rate = $SSMN_error_number / $num_calls_SSMN;
    print STDERR "$num_calls_SSMN calls to SimplifySSMN\n$SSMN_error_number complex strings could not be simplified\n$SSMN_error_rate complex strings could not be simplified\n\n";
}

my ($SSMA_error_info) = `wc -l ./SSMA_errors.txt`;
my $SSMA_error_number = 0;
if($SSMA_error_info =~ /^([0-9]+)/){
    $SSMA_error_number = $1;
}
if($num_calls_SSMA > 0){
    my $SSMA_error_rate = $SSMA_error_number / $num_calls_SSMA;
    print STDERR "$num_calls_SSMA calls to SimplifySSMA\n$SSMA_error_number complex strings could not be simplified\n$SSMA_error_rate complex strings could not be simplified\n\n";
}

my ($SSMP_error_info) = `wc -l ./SSMP_errors.txt`;
my $SSMP_error_number = 0;
if($SSMP_error_info =~ /^([0-9]+)/){
    $SSMP_error_number = $1;
}
if($num_calls_SSMP > 0){
    my $SSMP_error_rate = $SSMP_error_number / $num_calls_SSMP;
    print STDERR "$num_calls_SSMP calls to SimplifySSMP\n$SSMP_error_number complex strings could not be simplified\n$SSMP_error_rate complex strings could not be simplified\n\n";
}

my ($SSMV_error_info) = `wc -l ./SSMV_errors.txt`;
my $SSMV_error_number = 0;
if($SSMV_error_info =~ /^([0-9]+)/){
    $SSMV_error_number = $1;
}
if($num_calls_SSMV > 0){
    my $SSMV_error_rate = $SSMV_error_number / $num_calls_SSMV;
    print STDERR "$num_calls_SSMV calls to SimplifySSMV\n$SSMV_error_number complex strings could not be simplified\n$SSMV_error_rate complex strings could not be simplified\n\n";
}

print("<\/TEXT>\n");

# Step 1: Sentence splitting
# Step 2: PoS tagging
# Step 3: Finding class for all potential coordinators in all sentences from
#         the key file by sentence matching


# Tempted to delete the words "both" and "including" from the final generated
# sentences
sub format_sentence{
    my ($sentence) = @_;

#    print STDERR "KKKKKKKKKKKKKKKKKKKKK $sentence\n";exit;

    $sentence =~ s/^\s+//;
    $sentence =~ s/\s+$//;
# May delete the following line:
#    $sentence =~ s/<w ([^>]+)>(both|including)<\/w>//ig;

    while($sentence =~ /<w ([^>]+)>(including)<\/w>/g){
	my $p_inc = $PREMATCH;
#	print STDERR "$p_inc\n";exit;
	if($p_inc =~ /NNS\">([^<]+)<\/w>(\s*)$/){
	}
	elsif($p_inc =~ /NNS\">([^<]+)<\/w>(\s*)<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>(\s*)<w c\=\"w\" p\=\"NN\">([^<]+)<\/w>(\s*)$/){
	}
	else{
	    $sentence =~ s/\Q$p_inc\E<w ([^>]+)>(including)<\/w>/$p_inc/i;
	}
    }
    if($sentence  =~ /^([\s\{\}A-Za-z0-9\-]*)<w ([^>]+)>([a-z])/){
	my $first_letter = $3;
	my $initial_capital = uc($first_letter);
#	print STDERR "INPUT SENTENCE IS \[$sentence\]\n";
#	print STDERR "\t>>> INITIAL CAPITAL IS $initial_capital\n";
	$sentence =~ s/^([\s\{\}A-Za-z0-9\-]*)<w ([^>]+)>$first_letter/$1<w $2>$initial_capital/;

    }
    $sentence =~ s/(\s*)(<w ([^>]+)>(\.|\!|\?)<\/w>)(\s*)$/$2/;
    if($sentence =~ /<w ([^>]+)>(\.|\!|\?)<\/w>\s*$/){
	$sentence =~ s/\s*$//;
    }
    elsif($sentence =~ /(\.|\!|\?)\s+/){
	$sentence =~ s/\s*$//;
    }

#    print STDERR "$sentence\n";exit;
    if($sentence =~ /([0-9A-Za-z]+)<\/w>(\s*)$/){
	$sentence .= "<w c=\".\" sb=\"ttrruuee\" p=\".\">.</w>";
    }

    $sentence =~ s/([\s]+)/ /g;
    return($sentence);
}

sub sentence_length{
    my($sentence) = @_;
    my $sentence_length = 0;
    while($sentence =~ /<w ([^>]+)>([^<]+)<\/w>/g){
	my $word = $1;
	if($word =~ /([A-Za-z0-9]+)/){
	    $sentence_length++;
	}
    }
    return($sentence_length);
}
