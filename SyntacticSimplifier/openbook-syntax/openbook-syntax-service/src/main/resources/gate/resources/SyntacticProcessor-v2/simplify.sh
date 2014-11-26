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
#perl syntactic_simplifier_xml.pl
perl SSCCV_CCV_simplifier_xml.pl $* 2>$1.rules.err | sed -r 's%"yyeess" c="w" p="NNP">%%g' | sed -r 's%"yyeess"( (c|qut|p)="[^" ]+")+>%%g' | sed -r 's%"yyeess[^>]+>%%g' >$1.rules.out
##perl syntactic_simplifier_xml.pl $* 2>/dev/null
cat $1.rules.out

#to delete: 
rm "$1.rules.err"
rm "$1.rules.out"

##rm $1 $2 "$1.*" 2>/dev/null
rm "$1.post.xml"

