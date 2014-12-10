#!/bin/sh

export PATH=$PATH:$4/cmd:$4/bin

utf8-tokenize.perl $1 | tree-tagger -token -lemma $4/lib/bulgarian.par > $3

#export PATH=$PATH:/home/mse/first/tree-tagger/cmd:/home/mse/first/tree-tagger/bin
#export PATH=$PATH:/home/lcanales/Documentos/PROYECTOS_GPLSI/FIRST/Tree-tagger-BG/cmd:/home/lcanales/Documentos/PROYECTOS_GPLSI/FIRST/Tree-tagger-BG/bin
#utf8-tokenize.perl $1 | tree-tagger -token -lemma /home/lcanales/Documentos/PROYECTOS_GPLSI/FIRST/Tree-tagger-BG/lib/bulgarian.par > $3
#cat $1 | "tree-tagger-bulgarian" > $3
#cat $1 | "tree-tagger-bulgarian" > $3
#utf8-tokenize.perl $1 | tree-tagger -token -lemma /home/mse/first/tree-tagger/lib/bulgarian.par > $3