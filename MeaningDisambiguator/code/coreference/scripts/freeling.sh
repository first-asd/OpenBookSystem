#!/bin/bash

if [[ "$1" == "dep" ]]
then
    cat $2 | /home/imoreno/tools/freeling3.0/bin/analyze -f /home/imoreno/tools/freeling3.0/share/freeling/config/es.cfg  --outf dep --nec --noloc --nortk --nortkcon > $3
else
    cat $1 | /home/imoreno/tools/freeling3.0/bin/analyze -f /home/imoreno/tools/freeling3.0/share/freeling/config/es.cfg  --outf shallow --nec --noloc --nortk --nortkcon > $2
fi
    