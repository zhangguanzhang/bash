#!/bin/bash

trap 'exec 5>&-;exec 5<&-;exit 0' 2

max_process=2

pipe=`mktemp -u tmp.XXXX`
mkfifo $pipe
exec 5<>$pipe
rm -f $pipe

seq $max_process >&5

start=`date +%s`

for i in {1..10};do
	read -u5
	{
		echo $i;sleep 2;
		echo >&5
	}&
done
wait
echo 'Time:' "$((`date +%s`-start))"

exec 5>&-;exec 5<&-
