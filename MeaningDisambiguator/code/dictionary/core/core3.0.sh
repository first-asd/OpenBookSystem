#
# Shell script to execute the project 'core3.0'
#

# Specify the memory maximum to use (in MB)
MEMORY=256
# Specify the path to java
JAVA=java

# Obtain the abslute path to the JPM application
if [[ -h $0 ]];
then
        BIN=`readlink $0`
        BIN=`dirname $BIN`
else
        BIN=`dirname $0`
fi
# Specify the path of the jpm library
LIB=$BIN/dist/lib

for f in $LIB/*.jar
do
  libs=$libs$f:
done &&
echo $BIN;
libs="$libs"$BIN/dist/first.jar &&
$JAVA -Xmx"$MEMORY"m -classpath "classes:$libs" es.ua.first.First -W "$BIN" "$@"
