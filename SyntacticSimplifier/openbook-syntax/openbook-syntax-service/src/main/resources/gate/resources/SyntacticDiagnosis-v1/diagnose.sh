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
#perl SSCCV_CCV_simplifier_xml.pl $* 2>$1.rules.err | sed -r 's%"yyeess" c="w" p="NNP">%%g' | sed -r 's%"yyeess"( (c|qut|p)="[^" ]+")+>%%g' | sed -r 's%"yyeess[^>]+>%%g' >$1.rules.out

myF=`echo $1 | sed -r 's%^.+/%%'`

perl verbose_syntactic_simplifier_xml.pl $* 2>$myF.rules.err | sed -r 's%"yyeess" c="w" p="NNP">%%g' | sed -r 's%"yyeess"( (c|qut|p)="[^" ]+")+>%%g' | sed -r 's%"yyeess[^>]+>%%g' >$myF.rules.out

##perl syntactic_simplifier_xml.pl $* 2>/dev/null
#cat $1.rules.out

cat "guidance.$myF"

##rm $1 $2 "$1.*" 2>/dev/null
rm "$1.post.xml"


