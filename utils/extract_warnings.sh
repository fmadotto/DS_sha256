#!/bin/sh
currdir=$(pwd)
egrep -i "^warning" ../build/vv/vivado.log > ./warnings.txt
num=$(egrep -i "^warning" ../build/vv/vivado.log | wc -l)
echo "$num warnings extracted in $currdir/warnings.txt"
