package LRE;
use English;
# use strict;

sub new{
    my ($class_name) = @_;
    my ($self) = {};

    $by = "<w ([^>]+)>by<\/w>";
    $any_past_tense_be = "<w ([^>]+)>(was|were)<\/w>";
    $any_future_tense_be = "<w ([^>]+)>(will|is|are)<\/w>";
    $going = "<w ([^>]+)>(going)<\/w>";
    $will = "<w ([^>]+)>(will)<\/w>";
    $be = "<w ([^>]+)>(be)<\/w>";
    $being = "<w ([^>]+)>(being)<\/w>";
    $been = "<w ([^>]+)>(been)<\/w>";
    $have = "<w ([^>]+)>(have)<\/w>";

    $any_present_tense_be = "<w ([^>]+)>(am|is|are)<\/w>";
    $any_perfect_have = "<w ([^>]+)>(have|has|had)<\/w>";
    $any_kind_of_word = "<w c\=\"w\" p\=\"([^\"]+)\">([^<]+)<\/w>";
    $any_kind_of_possessive = "<w c\=\"aposs\" p\=\"([^\"]+)\">([^<]+)<\/w>";
    $any_kind_of_verb = "<w c\=\"w\" p\=\"(VBG|VBN|VBP|VBD|VB|VBZ)\">([^<]+)<\/w>";
    $any_kind_of_modal = "<w c\=\"w\" p\=\"MD\">([^<]+)<\/w>";
    $vb_verb = "<w c\=\"w\" p\=\"VB\">([^<]+)<\/w>";
$vbp_verb = "<w c\=\"w\" p\=\"VBP\">([^<]+)<\/w>";
    $vbz_verb = "<w c\=\"w\" p\=\"VBZ\">([^<]+)<\/w>";
    $vbg_verb = "<w c\=\"w\" p\=\"VBG\">([^<]+)<\/w>";
    $vbd_verb = "<w c\=\"w\" p\=\"VBD\">([^<]+)<\/w>";
    $vbn_verb = "<w c\=\"w\" p\=\"VBN\">([^<]+)<\/w>";
    $any_kind_of_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([^<]+)<\/w>";
    $nnp_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNP|NNPS)\">([^<]+)<\/w>";
    $any_kind_of_possPron = "<w c\=\"w\" p\=\"PRP\\\$\">([^<]+)<\/w>";
    $any_kind_of_pron = "<w c\=\"w\" p\=\"PRP\">([^<]+)<\/w>";
    $singular_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NN|NNP)\">([^<]+)<\/w>";
    $plural_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNPS)\">([^<]+)<\/w>";
    $any_kind_of_determiner = "<w c\=\"w\" p\=\"DT\">([^<]+)<\/w>";
    $any_kind_of_adj1 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
    $any_kind_of_adj2 = "<w c\=\"(w|hyw)\" p\=\"(JJS|JJ|VBN)\">([^<]+)<\/w>";
    $any_kind_of_subordinator = "<PC ([^>]+)>(that|which)<\/PC>";
    $any_right_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"ES([^\"]+)\">([^<]+)<\/PC>";
    $any_left_subordination_boundary = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">([^<]+)<\/PC>";
    $any_phrasal_coordinator = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CC|CM)([^\"]+)\">([^<]+)<\/PC>";
    $any_coordinator = "<PC ID\=\"([0-9]+)\" CLASS\=\"C([^\"]+)\">([^<]+)<\/PC>";
    $any_kind_of_prep = "<w c\=\"w\" p\=\"IN\">([^<]+)<\/w>";
    $any_kind_of_rp = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>"; # used in "snap off"
    $any_kind_of_adverb = "<w c\=\"w\" p\=\"(RB)\">([^<]+)<\/w>";
    $special_adverb = "<w ([^>]+)>day<\/w>(\\\s+)<w ([^>]+)>after<\/w>(\\\s+)<w ([^>]+)>day<\/w>";
    $any_kind_of_number = "<w c\=\"(w|cd|abbr)\" p\=\"CD\">([^<]+)<\/w>";
    $any_kind_of_clncin_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"(CLN|CIN)\">([^<]+)<\/PC>";
    $any_kind_of_pc = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">([^<]+)<\/PC>";
    $subordinating_that = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">that<\/PC>";
    $rp_word = "<w c\=\"w\" p\=\"RP\">([^<]+)<\/w>";
    $with = "<w c\=\"w\" p\=\"IN\">with<\/w>";
    $to = "<w c\=\"w\" p\=\"TO\">to<\/w>";
    $of = "<w c\=\"w\" p\=\"IN\">of<\/w>";
    $not = "<w c\=\"w\" p\=\"RB\">not<\/w>";;
    $only = "<w c\=\"w\" p\=\"RB\">only<\/w>";
    $that = "<([^>]+)>that<\/([^>]+)>";
    $left_quote = "<w c\=\"lquote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">\'<\/w>";
    $any_kind_of_sentence_boundary = "<w c\=\"\.\" sb\=\"ttrruuee\" p\=\"([^\"]+)\">([^<]+)<\/w>";
    $exclamation_mark = "<w c\=\"\.\" p\=\"\.\">\!<\/w>";
    $base_np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*";
    $np = "($any_kind_of_number|$any_kind_of_determiner|$any_kind_of_possessive|$any_kind_of_adj1|$any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron|\\\s)*($any_kind_of_noun|$any_kind_of_possPron|$any_kind_of_pron)";
    $wh_word = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">wh([^<]+)<\/PC>";
    $whose = "<w c\=\"w\" p\=\"WP\\\$\">wh([^<]+)<\/w>";
    $colon = "<PC ID\=\"([0-9]+)\" CLASS\=\"SS([^\"]+)\">\:<\/PC>";
    $semicolon = "<([^>]+)>\;([^<]*)<\/([^>]+)>";
    $comma = "<PC ID\=\"([0-9]+)\" CLASS\=\"([^\"]+)\">\,<\/PC>";
    $hyphen = "<w c\=\"([^\"]+)\" p\=\"\:\">\-<\/w>";
    $quotes = "<w c\=\"(l|r)quote\" qut\=\"([^\"]+)\" p\=\"([^\"]+)\">([^<]+)<\/w>";
    $pound = "<w c\=\"what\" p\=\"([^\"]+)\">\£<\/w>";
    $unclassified_comma = "<w c\=\"cm\" p\=\"\,\">\,<\/w>";
    $er_noun = "<w c\=\"(w)\" p\=\"(NN)\">([^<]+)er<\/w>";
    $bound_jj = "<w c\=\"(w)\" p\=\"(JJ)\">bound<\/w>";
    $html_pound = "<w c\=\"amp\" p\=\"CC\">\&amp\;<\/w><w c\=\"sym\" p\=\"\#\">\#<\/w><w c\=\"cd\" p\=\"CD\">163<\/w><w c\=\"cm\" p\=\"\:\">\;<\/w>";
    $uc_pron = "<w c\=\"w\" p\=\"PRP\">([A-Z])([^<]*)<\/w>";
    $lc_noun = "<w c\=\"(w|hyw|abbr)\" p\=\"(NNS|NNP|NN)\">([a-z])([^<]+)<\/w>";
    $concessive_conjunction = "((<w ([^>]+)>even<\/w>\\\s*)*)<w c\=\"w\" p\=\"([^\"]+)\">(though|although)<\/w>";
# n.b. the word "still" has been removed from $adversative_conjunction
    $adversative_conjunction = "<w c\=\"w\" p\=\"([^\"]+)\">(albeit|although|but|however|nevertheless|yet)<\/w>";
# Possibly, the phrase "worked out" should be included as a $ccv_comp_verb
    $ccv_comp_verb = "<w c\=\"([^\"]+)\" p\=\"(JJ|NN|VB|VBD|VBG|VBN|VBP|VBZ)\">(accept|accepted|acknowledg|acknowledge|add|added|admission|admit|admitted|admitting|agree|allegation|allege|alleging|announce|announc|answer|answered|apparent|appreciate|appreciated|argue|arguing|ask|aske|asked|aware|belief|believe|believing|certain|claim|claimed|clear|complain|complained|concern|concerned|conclude|concluding|confirm|confirmed|convinced|convinc|decide|deciding|demonstrate|demonstrat|denied|deny|disappoint|disappointed|disclose|disclosing|discover|discovered|doubt|dread|emerge|emerged|emphasising|emphasise|ensur|ensure|establish|established|expect|expectation|expected|explain|explained|fear|feared|feel|felt|find|found|given|guess|guessed|illustrat|illustrate|indicate|indicated|infer|inferring|inferred|inference|insist|insisted|intimate|intimating|hear|held|hold|hope|hoping|implie|imply|is|know|knew|known|learn|learned|maintain|maintained|manner|mean|meant|noting|note|obvious|order|ordered|plain|possible|promising|promise|protested|protest|prov|prove|providing|provide|recording|realise|realising|recognis|recognise|recogniz|recognize|recommend|recommended|read|realis|realise|record|recorded|relate|relating|remain|report|reported|retort|retorted|reveal|revealed|rule|ruling|said|satisfie|satisfy|saw|say|scale|see|show|shown|showed|state|stating|suggest|suggested|suspect|suspected|tell|terrified|testify|testifie|think|thought|told|view|warn|warned|was|way)((s|d|ing)?)<\/w>";

    bless($self, $class_name);
    return($self);
}
package main{
     $RegEx = LRE->new();
}
1;
