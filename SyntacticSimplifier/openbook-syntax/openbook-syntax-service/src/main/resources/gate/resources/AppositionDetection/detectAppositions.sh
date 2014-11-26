#!/bin/sh

#echo `pwd`
cd `dirname $0`

#echo `pwd`
#echo "syntactic_simplifier_xml.pl $*"
#echo "------------"
#echo `head -n 5 $1`
#echo "------------"
#echo `head -n 5 $2`
#echo "------------"

###perl syntactic_simplifier_xml.pl $* 2>&1 #/dev/null
#perl syntactic_simplifier_xml.pl $* 2>/dev/null
perl tag_noun_modifiers.pl $* 2>/dev/null
#perl delete_noun_modifiers.pl #$* 2>/dev/null


