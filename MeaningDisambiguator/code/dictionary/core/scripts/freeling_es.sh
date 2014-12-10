#!/bin/sh

MFS="MFS"

if [ $2 = MFS ]; then
    cat $1 | $4/bin/analyze -f $4/share/freeling/config/es.cfg --nortk --nortkcon --noloc --outf tagged --sense all --fsplit $5 > $3
else
    cat $1 | $4/bin/analyze -f $4/share/freeling/config/es.cfg --nortk --nortkcon --noloc --outf tagged --sense ukb --fsplit $5 > $3
fi

#opción noloc: es para que no junte palabras como "Después_de"
#opción nortk: es para que no separe palabras como "Pidiéndole" en pidiendo + le
#opcion nortkcon: es para que no separe contracciones como del al.
