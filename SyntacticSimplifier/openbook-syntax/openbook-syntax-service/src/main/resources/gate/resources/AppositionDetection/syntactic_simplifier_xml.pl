# Program processes an input file, extracts sentences, converts sentences which
# contain > 0 potential coordinators into lists of sentences by means of
# recursively using the function "simplify"
#
# Program expects ARGV[0] to be an input file and ARGV[1] to be a training or
# testing file providing sentences and class labels for instances of potential
# coordinators.
# Note, this means that the program calling the ML classifier should produce
# output in a format identical to that produced by human annotators 
# In order to have PoS tagged output, set $print_word_tokens = 1;
use English;
use strict;
use AssessStructuralComplexity;
use SimplifySSCCV;
use SimplifySSMV;
use SimplifySSMN;
use SimplifySSMP;
use SimplifySSMA;
use SimplifyCCV;
use SimplifyCMV1;
use SimplifyCMV1a;
use SimplifyCMV2;
use SimplifyCMN1;
use SimplifyCMN2;
use SimplifyCMN4;
use SimplifyCMP;
use SimplifyCMA1;
use SimplifyCMAdv;
use SimplifyCIN;
use SimplifyCLV;
use SimplifyCLN;
use SimplifyCLA;
use SimplifyCLQ;
use SimplifyCLP;
use SimplifyCPA;

my $input_file = @ARGV[0];
my $classified_file = @ARGV[1];
my $output_dir = "./syntactically_simplified/";
my $file_label = "";
my $output_file;
my $ttt2_dir = "/home/richard/TTT2/scripts";
my $ttt2_models_dir = "/home/richard/TTT2/models";
my $wp3_programs_dir = "/home/richard/FIRST/WP3_ProcessingStructuralComplexity/programs/";
my $wp3_dir = "/home/richard/FIRST/WP3_ProcessingStructuralComplexity/";
my $wp7_programs_dir = "/home/richard/FIRST/WP7_TestingAndEvaluation/programs";

my $tagger_logfile = $wp3_programs_dir."tagger_logfile.txt";
my $tagger_folder = "/home/richard/Brill_tagger/RULE_BASED_TAGGER_V1.14/Bin_and_Data/";

my $verbosity = 0;

my $number_sentences_simplified = 0;
my $number_long_simplified_sentences = 0;

my $print_word_tokens = 0;

$file_label = $input_file;
$file_label =~ s/\.(txt|xml|html)//;
while($file_label =~ /\//g)
{
    $file_label = $POSTMATCH;
}
my $graph_output_file = "./".$file_label."\.dot";
# print STDERR "$graph_output_file\n";exit;


open(TAGGED_SENTENCES, ">./fully_xml_tagged_input.xml");
print TAGGED_SENTENCES "<\?xml version\=\"1\.0\" encoding\=\"UTF\-8\"\?>\n<TEXT>\n";
close(TAGGED_SENTENCES);

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
# Removing spaces before ".", ",", ":", and ";"
	$pc_sent =~ s/([a-zA-Z]+)(\s+)(\[?)(\,|\.|\:)/$1$3$4/g;

	$pc_classes{$pc_sent} = $pc_class;

	if($pc_sent =~ /FLAUNTED/){
	    print STDERR "\%pc\_classes CONTAINS \[$pc_sent\]\n";
	}

	if($pc_sent =~ /They started /){
#	    print STDERR "\[$pc_sent\]\t$pc_class\n";
	}
    }
}
close(CF);

my $pos_tag_file = $input_file.".post.xml";
$pos_tag_file =~ s/\/corpora\//\/corpora\/annotated\/pos\_tagged\//;

# Does the part of speech tagged file already exist? If so, consult it and put
# it's contents in the array @pos_tagged (and exit). If not, PoS tag the file
# from scratch and send to @pos_tagged. 
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

my $constructed_xml_tagged_sentence = "";
my $printed_original_sentence = 0;

my $pos_tagged_file_contains_paired_apostrophes = 0;
my $n=0;
my $i;
for($i=0; $i < @pos_tagged; $i++){
    my $pos_line = @pos_tagged[$i];
    my $temp_pos_line = $pos_line;


#    print STDERR ">>>>>>>>>>>>>>>>> $pos_line\n";
    if($pos_line =~ />\'\'</){
	$pos_tagged_file_contains_paired_apostrophes = 1;
#	print STDERR "$pos_line\n";exit;
    }

    $temp_pos_line =~ s/<w ([^>]+)>(\[|\])<\/w>//g;
# Added 12/02/2013 to remove [ and ] from plain text input, since these
# characters are not preserved in manually annotated keyfiles.

    $printed_original_sentence = 0;
    while(1){
	if($temp_pos_line =~ /<s ([^>]+)>((.|\s)*?)<\/s>/){
	    my $sentence = $2;
	    my $pos_tagged_sentence = $&;
	    $pos_tagged_sentence =~ s/>\"</>\'\'</g;
	    $temp_pos_line = $POSTMATCH;
	    $sentence =~ s/<\/w>//g; 
	    $sentence =~ s/<w ([^>]+)>//g;
	    print STDERR "\n$sentence\n"; 
	    if($sentence =~ /women\'s/){
		print STDERR "$pos_line\n";
#		exit;
	    }



	    my $temp_sentence = $sentence;
	    my $new_sentence = "";
	    while($temp_sentence =~ /([^\[]+)(\,|\;|\:)(\s+)(and|an\'|but|or|that|what|when|where|which|while|who)(\s|\'|\"|\.|\)|\:|\;|\,)/ig){
		$temp_sentence =~ s/([^\[]+)(\,|\;|\:)(\s+)(and|an\'|but|or|that|what|when|where|which|while|who)(\s|\'|\.|\)|\:|\;|\"|\,)/$1\[$2 $4\]$5/i;
	    }
	    while($temp_sentence =~ /(\s|\'|\()(and|an\'|but|or|that|what|when|where|which|while|who)(\s|\'|\.|\)|\:|\;|\"|\,)/ig){
		$n++;
		$temp_sentence =~ s/(\s|\'|\"|\()(and|an\'|but|or|that|what|when|where|which|while|who)(\s|\'|\.|\)|\:|\;|\"|\,)/$1\[$2\]$3/i;
	    }
	    while($temp_sentence =~ /([^\[]+)(\:|\;|\,)(\s|\'|\"|\.|\)|\:|\;)/ig){
		$n++;
		$temp_sentence =~ s/([^\[]+)(\:|\;|\,)(\s|\'|\"|\.|\)|\:|\;)/$1\[$2\]$3/i;
	    }


	    my $consult_class = "UNKNOWN";
	    my $consult_sentence;
	    my $xml_tagged_sentence = " ".$temp_sentence." ";
	    my $original_sentence = $xml_tagged_sentence;

	    open(PROBLEM, ">/home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt");
	    my $print_original_sentence = $original_sentence;
	    $print_original_sentence =~ s/\[([\:\;\, abcdehilnortuw]+)\]/$1/g;
	    $print_original_sentence =~ s/^\s+//;
	    print PROBLEM "$print_original_sentence\n";
	    close(PROBLEM);

	    $print_original_sentence =~ s/\&(\s+)/\&amp\;$1/g;
	    $print_original_sentence =~ s/\&(\s+)$/\&amp\;$1/g;
	    $print_original_sentence =~ s/</\&lt\;/g;

	    unless($print_word_tokens == 1){
		print("<SENTENCE>\n<ORIGINAL>$print_original_sentence<\/ORIGINAL>\n");
	    }

	    while($temp_sentence =~ /\[([\:\;\, abcdehilnortuw]+)\]/ig){
		my $current_pc = $&;
		my $prior = $PREMATCH;
		my $rest = $POSTMATCH;

		my $untagged_prior = $prior;
		my $untagged_rest = $rest;
		$untagged_prior =~ s/\[([\:\;\, abcdehilnortuw]+)\]/$1/ig;
		$untagged_rest =~ s/\[([\:\;\, abcdehilnortuw]+)\]/$1/ig;







		$consult_sentence = $untagged_prior.$current_pc.$untagged_rest;

# Convert '' back into " in $consult_sentence

		if($pos_tagged_file_contains_paired_apostrophes == 0){
		    $consult_sentence =~ s/>\'\'</>\"</g;
		}
		print STDERR "Trying to find \[$consult_sentence\] in \%pc\_classes\n";

		$consult_class = $pc_classes{$consult_sentence};
		if($consult_class !~ /([A-Za-z0-9]+)/){
		    $consult_class = "UNKNOWN";
		}

		$n++;
		$xml_tagged_sentence =~ s/\[([\:\;\, abcdehilnortuw]+)\]/<PC ID\=\"$n\" CLASS\=\"$consult_class\">$1<\/PC>/i;

# Now nested while loops to add POS tags into $xml_taqged_sentence
	    }
#	    print STDERR "XML TAGGED SENT IS NOW $xml_tagged_sentence\n";exit;

	    $pos_tagged_sentence =~ s/ pws\=\"no\"/ pws\=\"nnoo\"/g;
	    $pos_tagged_sentence =~ s/ pws\=\"yes\"/ pws\=\"yyeess\"/g;
	    $pos_tagged_sentence =~ s/ sb\=\"true\"/ sb\=\"ttrruuee\"/g;
	    $pos_tagged_sentence =~ s/ sb\=\"false\"/ sb\=\"ffaallssee\"/g;

#	    my $constructed_xml_tagged_sentence = "";



#	    print STDERR "POS TAGGED SENTENCE IS NOW \[$pos_tagged_sentence\]\n";exit;

	    while($pos_tagged_sentence =~ /((\s|\')*)<w ([^>]+)>([^<]+)<\/w>((\'|\s)*)/g){
		my $word = $1.$4.$5;
		my $open_tag = "<w ".$3.">";
		my $substitution = $1.$open_tag.$4."</w>".$5;


#		print STDERR "W \[$word\]\n";

# replace $word followed by anything except "</w>" by $substitution
# Dealing with "in" as a special case to prevent erroneous tagging of words
# like "dropp[in]g
		if($word eq "in"){
#		    $word = " ".$word." ";
#		    $substitution = " ".$substitution." ";
#		    print STDERR "$word ++++ $substitution\n";exit;
		}





# The place to correct XML tokenisation/tagging errors for different words
# These conditions ensure that words are only substituted by tagged versions when they
#  are not substrings of longer words.
		while($xml_tagged_sentence =~ /\Q$word\E/g){
		    my $precedes_word = $PREMATCH;
		    my $follows_word = $POSTMATCH;



		    if($follows_word =~ /^(\s*)([s]?)<\/w/){
		    }

		    elsif($precedes_word =~ /\=\"([^\"]*)$/){
		    }
# Following condition intended to stop words that are substrings of longer words from being tagged in the longer
# word. MAY BE DANGEROUS.
		    elsif($precedes_word =~ /([a-z]+)$/){
		    }
		    elsif($word eq "it"){
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "PC "){
			if($precedes_word =~ /<$/){ # && $follows_word =~ /^ ID/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "him"){
			if($follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "unit"){
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "in"){ # Experimental: maybe delete
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "In"){ # Experimental: maybe delete
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "up"){
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "or"){
			if($precedes_word =~ /([a-z]+)$/ | $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "f"){
			if($precedes_word =~ /([a-z]+)$/ | $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }

		    elsif($word eq "d"){
			if($precedes_word =~ /([A-Za-z]+)$/ | $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "b"){
			if($precedes_word =~ /([A-Za-z]+)$/ | $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "S"){
			if($precedes_word =~ /([A-Z]+)$/ && $follows_word =~ /^([A-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "l"){
			if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "L"){
			if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "A"){
			if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			elsif($precedes_word =~ /(\`|\"|\'|\s|>)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "I"){
			if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			}
			elsif($precedes_word =~ /(>|\s)$/ && $follows_word =~ /^n/){
			}
			elsif($follows_word =~ /^D\=\"/){
			}
			else{
#			    print STDERR "FW \[$follows_word\]\nPW \[$precedes_word\]\n";exit;
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "he"){
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "it"){
			if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "capture"){
			if($follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "register"){
			if($follows_word =~ /^([a-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }

		    elsif($word eq "-"){
			if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "."){
			if($precedes_word =~ /([A-Za-z>\.]+)$/ && $follows_word =~ /^\./){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }

		    elsif($word eq "/"){
			if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "or"){
			print STDERR "P \[$precedes_word\]\nF \[$follows_word\]\n";
			if($precedes_word =~ /([<a-zA-Z]+)$/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    elsif($word eq "'"){
			if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			}
			else{
			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
#		    elsif($word eq "\""){
#			print STDERR "got speech\nPRE $precedes_word\nFOL $follows_word\n";exit;
#			if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
#			}
#			else{
#			    $xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
#			    last;
#			}
#		    }
		    else{
			$xml_tagged_sentence =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			last;
		    }
		}

	    }
#	    exit;



	    print STDERR "Detagging PC markables\n";
	    $xml_tagged_sentence =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w>(\s+)<w ([^>]+)>([^<]+)<\/w><\/PC>/<PC$1>$3$4$6<\/PC>/g;
	    $xml_tagged_sentence =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w><\/PC>/<PC$1>$3<\/PC>/g;
#	    $xml_tagged_sentence =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w>(\s+)([^<]+)<\/PC>/<PC$1>$3$4$5<\/PC>/g;
	    $xml_tagged_sentence =~ s/<PC([^>]+)><w ([^>]+)>(\,|\;|\:)<\/w>(\s+)(and|but|or|that|what|when|where|which|while|who)<\/PC>/<PC$1>$3$4$5<\/PC>/ig;

#	    print STDERR "XML SENT:\n\t$xml_tagged_sentence\n";

	    $xml_tagged_sentence =~ s/pws\=\"([^\"]+)\" //g;
	    $xml_tagged_sentence =~ s/id\=\"([^\"]+)\" //g;
# Post-correcting errors caused by tokens separated by no spaces
	    $xml_tagged_sentence =~ s/(\s+)cannot(\s+)/$1<w c\=\"w\" p\=\"MD\">can<\/w><w c\=\"w\" p\=\"RB\">not<\/w>$2/g;
	    $xml_tagged_sentence =~ s/<w ([^>]+)>ca<\/w><w ([^>]+)>n<w ([^>]+)>\'<\/w>t<\/w>/<w $1>ca<\/w><w $2>n\'t<\/w>/g;
	    $xml_tagged_sentence =~ s/<w ([^>]+)>origina<w ([^>]+)>l<\/w>ly<\/w>/<w $1>originally<\/w>/g;

#	    $xml_tagged_sentence =~ s/c\=\"([^\"]+)\" //g;




# Correcting the tagging of verbs with pronominal arguments:
	    $xml_tagged_sentence =~ s/<w c\=\"w\" p\=\"NN\">([^<]+)<\/w>(\s+)<w c\=\"w\" p\=\"PRP\">it<\/w>/<w c\=\"w\" p\=\"VBP\">$1<\/w>$2<w c\=\"w\" p\=\"PRP\">it<\/w>/g;
# Some sentences contain erroneous repeated potential coordinators. The
# following pattern removes the repeated ones
	    $xml_tagged_sentence =~ s/<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">(and|but|or|\,\s+and|\,\s+but|\,\s+or)<\/PC>(\s+)<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\3<\/PC>/<PC ID\=\"$1\" CLASS\=\"$2\">$3<\/PC>/g;
	    $xml_tagged_sentence =~ s/Engl<w c\=\"([^\"]+)\" p\=\"([^\"]+)\">and<\/w>/<w c\=\"w\" p\=\"NNP\">England<\/w>/g;

	    $xml_tagged_sentence =~ s/([0-9]+)<w c\=\"([^\"]+)\" sb\=\"([^\"]+)\" p\=\"([^\"]+)\">\.<\/w>([0-9]+)/$1\.$5/g;
	    $xml_tagged_sentence =~ s/<\/w>\,<w/<\/w><w c\=\"cm" p\=\"\,\">\,<\/w><w/g;
	    $xml_tagged_sentence =~ s/ f<w([^>]+)>or<\/w> / <w c\=\"w\" p\=\"IN\">for<\/w> /g;
	    $xml_tagged_sentence =~ s/(\'|\`)(i|he|she|you|they|it)<w /<w c\=\"lquote\" qut\=\"d\" pws\=\"nnoo\" id\="w0\" p\=\"\'\'\">$1<\/w><w c\=\"w\" p\=\"PRP\">$2<\/w><w /ig;
	    $xml_tagged_sentence =~ s/ \"(i|he|she|you|they|it)<w / <w c\=\"lquote\" qut\=\"d\" pws\=\"nnoo\" id\="w0\" p\=\"\'\'\">\"<\/w><w c\=\"w\" p\=\"PRP\">$1<\/w><w /ig;
	    $xml_tagged_sentence =~ s/ (i|he|she|you|they|it)<w / <w c\=\"w\" p\=\"PRP\">$1<\/w><w /ig;

	    if(1==1){
#	    if($consult_sentence =~ /FLAUNTED/){
#		print STDERR "POS TAGGED $pos_tagged_sentence\nCOMBI TAGGED $xml_tagged_sentence\n";exit;
#		exit;
	    }

#	    print STDERR "STARTING TO SIMPLIFY\:\n$xml_tagged_sentence\n";exit;
#	    print STDERR "STARTING TO SIMPLIFY\:\n$pos_tagged_sentence\n";
	 
	    if($xml_tagged_sentence =~ /FLAUNTED/){
#		print STDERR "XML $xml_tagged_sentence\n";exit;
	    }


	    my @simplified_sentences = ();

	    if($verbosity == 1){
		print("ORIGINAL $xml_tagged_sentence\n");
	    }

	    if($print_word_tokens == 1){
		if($printed_original_sentence == 0){
		    print("<SENTENCE>\n<ORIGINAL>$xml_tagged_sentence<\/ORIGINAL>\n");
		    $printed_original_sentence = 1;
		}
	    }

	    open(TAGGED_SENTENCES, ">>./fully_xml_tagged_input.xml");
	    print TAGGED_SENTENCES "$xml_tagged_sentence\n";
	    close(TAGGED_SENTENCES);

	    my $structural_complexity = AssessStructuralComplexity::assessment($xml_tagged_sentence);

	    my @working_set = ("$xml_tagged_sentence");
	    my $ws_size = 1;

	    if($xml_tagged_sentence =~ /pharmacy/ && $xml_tagged_sentence =~ /difficult/){
#		print STDERR "$xml_tagged_sentence\n";
#		exit;
	    }

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
			    elsif($pcc eq "CMV1"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMV1::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
#				$simpler_pair_ref = SimplifyCMV1a::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $num_calls_CMV1++;
				}
			    }
			    elsif($pcc eq "CMV2"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMV2::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CMN1"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMN1::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				    $num_calls_CMN1++;
				}
			    }
			    elsif($pcc eq "CMN2"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMN2::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CMN4"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMN4::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CMP"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMP::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				    $num_calls_CMP++;
				}
			    }
			    elsif($pcc eq "CMA1"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMA1::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				    $num_calls_CMA1++;
				}
			    }
			    elsif($pcc eq "CMAdv"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCMAdv::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CIN"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCIN::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CLV"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCLV::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CLN"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCLN::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CLA"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCLA::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CLQ"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCLQ::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CLP"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCLP::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
				}
			    }
			    elsif($pcc eq "CPA"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifyCPA::simplify($si, $precedes_pc, $follows_pc, $this_pc);
				    $divided_once = 1;
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


				unless($si =~ /CLASS\=\"(CCV|CMV1|CMN1|CMP|CMA1)\">(and|but|or|\,\s+and|\,\s+but|\,)</i){
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
#		@pc_classes = ("");

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
		my @pc_patterns = ("(and|but|or|that|which|who)","(\,)(\\\s+)(and|but|which)","(\,|\;)");
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
			    elsif($pcc eq "SSMV"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifySSMV::simplify($si, $precedes_sc, $follows_sc, $this_pc);
				    $divided_once = 1;
				    $num_calls_SSMV++;
				}
			    }
			    elsif($pcc eq "SSMN"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifySSMN::simplify($si, $precedes_sc, $follows_sc, $this_pc);
				    $divided_once = 1;
				    $num_calls_SSMN++;
				}
			    }
			    elsif($pcc eq "SSMP"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifySSMP::simplify($si, $precedes_sc, $follows_sc, $this_pc);
				    $divided_once = 1;
				    $num_calls_SSMP++;
				}
			    }
			    elsif($pcc eq "SSMA"){
				unless($divided_once == 1){
				    $simpler_pair_ref = SimplifySSMA::simplify($si, $precedes_sc, $follows_sc, $this_pc);
				    $divided_once = 1;
				    $num_calls_SSMA++;
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

				unless($si =~ /CLASS\=\"(SSCCV|SSMN|SSMA|SSMP|SSMV|CCV|CMV1|CMN1|CMP|CMA1)\">(and|but|or|that|which|who|\,\s+and|\,\s+but|\,\s+which|\,)</i){
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

		unless($print_word_tokens == 1){
		    $print_sentence =~ s/<([^>]+)>//g;
		}

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

			unless($print_word_tokens == 1){
			    $fps =~ s/<([^>]+)>//g;
			}
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
		    unless($xts_class eq "SPECIAL"){
			unless($xts_class eq "CMP2"){
			    unless($xts_class =~ /^CL/){
				print STDERR "########################## No rules to hanle $xts_class\n";exit;
			    }
			}
		    }
		}
	    }
	    print STDERR "FINISHED PROCESSING THIS SENTENCE\n";
	    print("<\/SENTENCE>\n");
	}
	elsif($temp_pos_line =~ /^./){
	    $temp_pos_line = $POSTMATCH;
	}
	else{
	    last;
	}


    }


    
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

open(TAGGED_SENTENCES, ">>./fully_xml_tagged_input.xml");
print TAGGED_SENTENCES "</TEXT>\n";
close(TAGGED_SENTENCES);

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
