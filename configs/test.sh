#!/bin/bash

unixthreads=`awk '($1 == "unixthreads:"){for(i=2;i<=NF;i++) printf "-c "$i" "}' paraconfig`
echo $unixthreads

eval $(awk '($1 == "streamthreads:"){printf("streamthreads=%d",$2)}' paraconfig)
sti=2
while [ $streamthreads -ne 0 ]
do
	echo $streamthreads
	sti=$(($sti+1))
	eval $(awk '($1 == "streamthreads:"){printf("streamthreads=%d",$'$sti')}' paraconfig)
done

MB=""
if [ -r /proc/meminfo ]; then
	TMP=`grep 'MemTotal:' /proc/meminfo | awk '{print $2}'`
	if [ "X$TMP" != X ]; then
		memsize=`echo $TMP / 1024 | bc 2>/dev/null`
		if [ X$memsize = X ]; then
			memsize=`expr $TMP / 1024 2>/dev/null`
		fi
		
		if [ $memsize -gt 4096 ]; then
			MB=10240
		fi
	fi
fi

eval $(awk '($1 == "lmmemsize:"){printf("MB=%s",$2)}' paraconfig)
echo $memsize
echo $MB

echo $0
var=$1
echo $var
