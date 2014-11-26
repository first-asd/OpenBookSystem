#!/bin/bash

##determine current dir (for Dash, i.e. /bin/sh in Ubuntu)
#prefix="$( cd "$( dirname "$0" )" && pwd )"

##alternative more robust solution wrt. symlinks (using BASH)
#http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
prefix=$DIR

java -Dgate.home=$prefix/src/main/resources/gate -jar $prefix/target/openbook-syntax-jar-with-dependencies.jar $*
