# Perl module to receive full PoS tagged text and merge this annotation with 
# information about manually classified signs
# Modifications begun: 19/7/2012
package MergeAnnotations;
use English;
use strict;


sub merge{
    my ($pos_tag_ref, $pc_classes_ref) = @_;
    my $structural_complexity = 0;
    my $merged_xml = "";
    my $full_merged_xml;

    my $i;
    my $n;
    my $pos_tagged_file_contains_paired_apostrophes;

    my @pos_tagged = @$pos_tag_ref;
    my %pc_classes = %$pc_classes_ref;


    for($i=0; $i < @pos_tagged; $i++){
	my $pos_line = @pos_tagged[$i];
	my $temp_pos_line = $pos_line;


#	print STDERR ">>>>>>>>>>>>>>>>> $pos_line\n";
	if($pos_line =~ />\'\'</){
	    $pos_tagged_file_contains_paired_apostrophes = 1;
#	    print STDERR "$pos_line\n";exit;
	}

	$temp_pos_line =~ s/<w ([^>]+)>(\[|\])<\/w>//g;
# Added 12/02/2013 to remove [ and ] from plain text input, since these
# characters are not preserved in manually annotated keyfiles.

	while(1){
	    if($temp_pos_line =~ /<s ([^>]+)>((.|\s)*?)<\/s>/){
		my $sentence = $2;
		my $pos_tagged_sentence = $&;
		my $open_s_tag = "<s ".$1.">";
		my $close_s_tag = "</s>";
		$pos_tagged_sentence =~ s/>\"</>\'\'</g;
		$temp_pos_line = $POSTMATCH;
		$sentence =~ s/<\/w>//g; 
		$sentence =~ s/<w ([^>]+)>//g;
#		print STDERR "\n$sentence\n"; exit;
		if($sentence =~ /women\'s/){
		    print STDERR "$pos_line\n";
#		    exit;
		}
		
		my $temp_sentence = $sentence;
		my $new_sentence = "";
		while($temp_sentence =~ /([^\[]+)\(/g){
		    $temp_sentence =~ s/([^\[]+)\(/$1\[\(\]/;
		}
		while($temp_sentence =~ /([^\[]+)\)(\s|\'|\"|\.|\:|\;|\,)/g){
		    $temp_sentence =~ s/([^\[]+)\)(\s|\'|\"|\.|\:|\;|\,)/$1\[\)\]$2/;
		}
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
		my $merged_xml = " ".$temp_sentence." ";
		my $original_sentence = $merged_xml;
		
		open(PROBLEM, ">/home/richard/FIRST/WP7_TestingAndEvaluation/corpora/temp.txt");
#		my $print_original_sentence = $original_sentence;
#		$print_original_sentence =~ s/\[([\:\;\,\(\) abcdehilnortuw]+)\]/$1/g;
#		$print_original_sentence =~ s/^\s+//;
#		print PROBLEM "$print_original_sentence\n";
#		close(PROBLEM);
		
#		$print_original_sentence =~ s/\&(\s+)/\&amp\;$1/g;
#		$print_original_sentence =~ s/\&(\s+)$/\&amp\;$1/g;
#		$print_original_sentence =~ s/</\&lt\;/g;

#		print("<SENTENCE>\n<ORIGINAL>$print_original_sentence<\/ORIGINAL>\n");exit;
		
		while($temp_sentence =~ /\[([\:\;\,\(\) abcdehilnortuw]+)\]/ig){
		    my $current_pc = $&;
		    my $prior = $PREMATCH;
		    my $rest = $POSTMATCH;
		    
		    my $untagged_prior = $prior;
		    my $untagged_rest = $rest;
		    $untagged_prior =~ s/\[([\:\;\,\(\) abcdehilnortuw]+)\]/$1/ig;
		    $untagged_rest =~ s/\[([\:\;\,\(\) abcdehilnortuw]+)\]/$1/ig;







		    $consult_sentence = $untagged_prior.$current_pc.$untagged_rest;
		    

# Stripping non-alphanumerics to force matching
		    $consult_sentence =~ s/([^A-Za-z0-9\(\)\,\;\:\[\]])//g;
		    
# Convert '' back into " in $consult_sentence

		    if($pos_tagged_file_contains_paired_apostrophes == 0){
			$consult_sentence =~ s/>\'\'</>\"</g;
		    }

		    
#		    print STDERR "Trying to find \[$consult_sentence\] in \%pc\_classes\n";


		    $consult_class = $pc_classes{$consult_sentence};
		    if($consult_class eq ""){
#			print STDERR "COULD NOT FIND A CLASS FOR $consult_sentence\n";exit;
		    }

		    if($consult_class eq ""){
			if($consult_sentence =~ /\?(\'|\")\s*/){
			    my $new_consult_sentence = $POSTMATCH;
			    $consult_class = $pc_classes{$new_consult_sentence};
			}
			elsif($consult_sentence =~ /\!\s+([a-z])/){
			    my $new_post_consult_sentence = $1.$POSTMATCH;
			    my $new_pre_consult_sentence = $PREMATCH."!";
			    my $consult_class1 = $pc_classes{$new_post_consult_sentence};
			    my $consult_class2 = $pc_classes{$new_pre_consult_sentence};
			}
			if($consult_sentence =~ /^\s*\*\s*/){
			    my $new_consult_sentence = $POSTMATCH;
			    $consult_class = $pc_classes{$new_consult_sentence};
			}
		    }
#		    print STDERR "Consult class is $consult_class\n";exit;
		    if($consult_class !~ /([A-Za-z0-9]+)/){
			$consult_class = "UNKNOWN";
			if($consult_sentence =~ /^([0-9]+)/ | $consult_sentence =~ /^(CochraneDatabaseSystRev2004|Thismayshownarrowing|\(Thesehelptoregulatethemotility|Thesehelptoregulatethemotility|Thesechromosomechangesonlyoccurintheleukaemiacell|\(Thesechromosomechangesonlyoccurintheleukaemiacell|Forexample\[\,\]nasalsymptomsifyou|Forexample\,nasalsymptomsifyou|OnceyourhCGlevelshavereturnedtonormal|Aftera\[while\],findingthatnothingmorehappened,shedecided|Afterawhile\[,\]findingthatnothingmorehappened,shedecided|Afterawhile,findingthatnothingmorehappened\[,\]shedecided|Afterawhile,findingthatnothingmorehappened,shedecided||Afterawhile,finding\[that\]nothingmorehappened,shedecided|Sotheysaydownonthemhard)/){
			}
			else{
			    die "CANNOT MATCH SIGN IN $consult_sentence\n";exit;
			}
		    }
		    
		    $n++;
		    $merged_xml =~ s/\[([\:\;\,\(\) abcdehilnortuw]+)\]/<PC ID\=\"$n\" CLASS\=\"$consult_class\">$1<\/PC>/i;
		    
# Now nested while loops to add POS tags into $xml_taqged_sentence
		}
#		print STDERR "XML TAGGED SENT IS NOW $merged_xml\n";exit;
		
		$pos_tagged_sentence =~ s/ pws\=\"no\"/ pws\=\"nnoo\"/g;
		$pos_tagged_sentence =~ s/ pws\=\"yes\"/ pws\=\"yyeess\"/g;
		$pos_tagged_sentence =~ s/ sb\=\"true\"/ sb\=\"ttrruuee\"/g;
		$pos_tagged_sentence =~ s/ sb\=\"false\"/ sb\=\"ffaallssee\"/g;
		
#		my $constructed_xml_tagged_sentence = "";



#		print STDERR "POS TAGGED SENTENCE IS NOW \[$pos_tagged_sentence\]\n";exit;

		while($pos_tagged_sentence =~ /((\s|\')*)<w ([^>]+)>([^<]+)<\/w>((\'|\s)*)/g){
		    my $word = $1.$4.$5;
		    my $open_tag = "<w ".$3.">";
		    my $substitution = $1.$open_tag.$4."</w>".$5;

#		    print STDERR "W \[$word\]\n";

# replace $word followed by anything except "</w>" by $substitution
# Dealing with "in" as a special case to prevent erroneous tagging of words
# like "dropp[in]g
		    if($word eq "in"){
#			$word = " ".$word." ";
#			$substitution = " ".$substitution." ";
#			print STDERR "$word ++++ $substitution\n";exit;
		    }





# The place to correct XML tokenisation/tagging errors for different words
# These conditions ensure that words are only substituted by tagged versions when they
#  are not substrings of longer words.
		    while($merged_xml =~ /\Q$word\E/g){
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
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "him"){
			    if($follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "PC "){
			    if($precedes_word =~ /<$/){ # && $follows_word =~ /^ ID/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "unit"){
			    if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "in"){ # Experimental: maybe delete
			    if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "In"){ # Experimental: maybe delete
			    if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "up"){
			    if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "or"){
			    if($precedes_word =~ /([a-z]+)$/ | $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "f"){
			    if($precedes_word =~ /([a-z]+)$/ | $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			
			elsif($word eq "d"){
			    if($precedes_word =~ /([A-Za-z]+)$/ | $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "b"){
			    if($precedes_word =~ /([A-Za-z]+)$/ | $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "S"){
			    if($precedes_word =~ /([A-Z]+)$/ && $follows_word =~ /^([A-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "l"){
			    if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "L"){
			    if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "A"){
			    if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    elsif($precedes_word =~ /(\`|\"|\'|\s|>)$/ && $follows_word =~ /^([a-zA-Z\"\=]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
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
#				print STDERR "FW \[$follows_word\]\nPW \[$precedes_word\]\n";exit;
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "he"){
			    if($precedes_word =~ /([a-z]+)$/ && $follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "capture"){
			    if($follows_word =~ /^([a-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}

			elsif($word eq "-"){
			    if($precedes_word =~ /([A-Za-z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "."){
			    if($precedes_word =~ /([A-Za-z>\.]+)$/ && $follows_word =~ /^\./){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}

			elsif($word eq "/"){
			    if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "or"){
			    print STDERR "P \[$precedes_word\]\nF \[$follows_word\]\n";
			    if($precedes_word =~ /([<a-zA-Z]+)$/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
			elsif($word eq "'"){
			    if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
			    }
			    else{
				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
				last;
			    }
			}
#			elsif($word eq "\""){
#			    print STDERR "got speech\nPRE $precedes_word\nFOL $follows_word\n";exit;
#			    if($precedes_word =~ /([<a-zA-Z]+)$/ && $follows_word =~ /^([A-Za-z]+)/){
#			    }
#			    else{
#				$merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
#				last;
#			    }
#			}
			else{
			    $merged_xml =~ s/\Q$precedes_word$word\E/$precedes_word$substitution/;
			    last;
			}
		    }
		    
		}
#		exit;



#		print STDERR "Detagging PC markables\n";
		$merged_xml =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w>(\s+)<w ([^>]+)>([^<]+)<\/w><\/PC>/<PC$1>$3$4$6<\/PC>/g;
		$merged_xml =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w><\/PC>/<PC$1>$3<\/PC>/g;
#		$merged_xml =~ s/<PC([^>]+)><w ([^>]+)>([^<]+)<\/w>(\s+)([^<]+)<\/PC>/<PC$1>$3$4$5<\/PC>/g;
		$merged_xml =~ s/<PC([^>]+)><w ([^>]+)>(\,|\;|\:)<\/w>(\s+)(and|but|or|that|what|when|where|which|while|who)<\/PC>/<PC$1>$3$4$5<\/PC>/ig;

#		print STDERR "XML SENT:\n\t$merged_xml\n";

		$merged_xml =~ s/pws\=\"([^\"]+)\" //g;
		$merged_xml =~ s/id\=\"([^\"]+)\" //g;
# Post-correcting errors caused by tokens separated by no spaces
		$merged_xml =~ s/(\s+)cannot(\s+)/$1<w c\=\"w\" p\=\"MD\">can<\/w><w c\=\"w\" p\=\"RB\">not<\/w>$2/g;
		$merged_xml =~ s/<w ([^>]+)>ca<\/w><w ([^>]+)>n<w ([^>]+)>\'<\/w>t<\/w>/<w $1>ca<\/w><w $2>n\'t<\/w>/g;
		$merged_xml =~ s/<w ([^>]+)>origina<w ([^>]+)>l<\/w>ly<\/w>/<w $1>originally<\/w>/g;

#		$merged_xml =~ s/c\=\"([^\"]+)\" //g;




# Correcting the tagging of verbs with pronominal arguments:
		$merged_xml =~ s/<w c\=\"w\" p\=\"NN\">([^<]+)<\/w>(\s+)<w c\=\"w\" p\=\"PRP\">it<\/w>/<w c\=\"w\" p\=\"VBP\">$1<\/w>$2<w c\=\"w\" p\=\"PRP\">it<\/w>/g;
# Some sentences contain erroneous repeated potential coordinators. The
# following pattern removes the repeated ones
		$merged_xml =~ s/<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">(and|but|or|\,\s+and|\,\s+but|\,\s+or)<\/PC>(\s+)<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\3<\/PC>/<PC ID\=\"$1\" CLASS\=\"$2\">$3<\/PC>/g;
		$merged_xml =~ s/Engl<w c\=\"([^\"]+)\" p\=\"([^\"]+)\">and<\/w>/<w c\=\"w\" p\=\"NNP\">England<\/w>/g;
		
		$merged_xml =~ s/([0-9]+)<w c\=\"([^\"]+)\" sb\=\"([^\"]+)\" p\=\"([^\"]+)\">\.<\/w>([0-9]+)/$1\.$5/g;
		$merged_xml =~ s/<\/w>\,<w/<\/w><w c\=\"cm" p\=\"\,\">\,<\/w><w/g;
		$merged_xml =~ s/ f<w([^>]+)>or<\/w> / <w c\=\"w\" p\=\"IN\">for<\/w> /g;
		$merged_xml =~ s/(\'|\`)(i|he|she|you|they|it)<w /<w c\=\"lquote\" qut\=\"d\" pws\=\"nnoo\" id\="w0\" p\=\"\'\'\">$1<\/w><w c\=\"w\" p\=\"PRP\">$2<\/w><w /ig;
		$merged_xml =~ s/ \"(i|he|she|you|they|it)<w / <w c\=\"lquote\" qut\=\"d\" pws\=\"nnoo\" id\="w0\" p\=\"\'\'\">\"<\/w><w c\=\"w\" p\=\"PRP\">$1<\/w><w /ig;
		$merged_xml =~ s/ (i|he|she|you|they|it)<w / <w c\=\"w\" p\=\"PRP\">$1<\/w><w /ig;

		$full_merged_xml .= $open_s_tag.$merged_xml.$close_s_tag;
#		print STDERR "\n\n>>>>> $merged_xml\n\n<<<<< $full_merged_xml\n";exit;

	    }
	    elsif($temp_pos_line =~ /^./){
		$temp_pos_line = $POSTMATCH;
	    }
	    else{
		last;
	    }
	    
	    
	}
    
    
    
    }
#    print STDERR "$full_merged_xml <<<<<\n";exit;
    return($full_merged_xml);
}
1;
