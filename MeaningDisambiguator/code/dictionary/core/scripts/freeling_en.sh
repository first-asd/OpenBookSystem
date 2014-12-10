#!/bin/sh

MFS="MFS"

if [ $2 = MFS ]; then
    cat $1 | $4/bin/analyze -f $4/share/freeling/config/en.cfg --nortk --nortkcon --outf tagged --sense all --fsplit $5  > $3
else
    cat $1 | $4/bin/analyze -f $4/share/freeling/config/en.cfg --nortk --nortkcon --outf tagged --sense ukb --fsplit $5  > $3
fi

#opción noloc: es para que no junte palabras como "Después_de"
#opción nortk: es para que no separe palabras como "Pidiéndole" en pidiendo + le
#opcion nortkcon: es para que no separe contracciones como del al.
#  MFS  cat $1 | ssh lcanales@intime "/home/mse/tools/freeling3.0/bin/analyze -f /home/mse/tools/freeling3.0/share/freeling/config/en.cfg --nortk --nortkcon --outf tagged --sense all --fsplit /home/mse/tools/freeling3.0/share/freeling/en/splitter_first.dat" > $3
#  UKB  cat $1 | ssh lcanales@intime "/home/mse/tools/freeling3.0/bin/analyze -f /home/mse/tools/freeling3.0/share/freeling/config/en.cfg --nortk --nortkcon --outf tagged --sense ukb --fsplit /home/mse/tools/freeling3.0/share/freeling/en/splitter_first.dat" > $3
