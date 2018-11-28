#!/bin/bash
#run.sh 
#version:2.0

export LTPROOT="${PWD}"
echo $LTPROOT | grep kylintest > /dev/null 2>&1
if [ $? -gt 0 ]; then
	echo "please run run.sh script in right directory!"
	exit 0
fi

clear
cat <<-END >&2






				/*********************************************************************************/
				*				请选择对应测试项:				 *
				*			->	1.U盘拷贝测试		<-			 *
				*			->	2.Unixbench 测试	<-			 *
				*			->	3.STREAM 测试		<-			 *
				*			->	4.iozone 测试		<-			 *
				*			->	5.lmbench 测试		<-			 *
				*			->	6.iperf 测试		<-			 *
				*			->	7.specjvm 测试		<-			 *
				*			->	8.串口测试		<-			 *
				*			->	9.所有项测试		<-			 *
				*  q:退出
				/*********************************************************************************/






END


Diskcptest()
{
	mkdir -p result/udisk/
	echo "				U盘拷贝测试开始!"

	eval $(awk '($1 == "udisk:"){printf("udisk=%s",$2)}' paraconfig)
	eval $(awk '($1 == "udiskfile:"){printf("udiskfile=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ucount:"){printf("ucount=%d",$2)}' paraconfig)
	eval $(awk '($1 == "udiskdir:"){printf("udiskdir=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ufiledir:"){printf("ufiledir=%s",$2)}' paraconfig)

	mkdir -p $udiskdir
	mount /dev/$udisk $udiskdir


	for ((k=1; k<=$ucount; k++))
	do
		echo "第 $k 次数据拷贝!" | tee -a result/udisk/udiskresult

		echo "从硬盘向U盘拷贝文件:" | tee -a result/udisk/udiskresult
		cp $ufiledir/$udiskfile  $udiskdir &>> result/result-${resultdate}
		rm $ufiledir/$udiskfile

		echo "从u盘向硬盘拷贝文件:" | tee -a result/udisk/udiskresult
		cp $udiskdir/$udiskfile  $ufiledir
		rm $udiskdir/$udiskfile

		echo -e "第 $k 次数据拷贝结束!\n" | tee -a result/udisk/udiskresult

	done
	umount $udiskdir

	echo -e "				U盘拷贝测试结束!\n"
}

UnixBench()
{
	mkdir -p result/unixbench

	unixdate=`date +%F`
	eval $(awk '($1 == "unixcount:"){printf("unixcount=%s",$2)}' paraconfig)
	unixthreads=`awk '($1 == "unixthreads:"){for(i=2;i<=NF;i++) printf "-c "$i" "}' paraconfig`

	cd software
	tar -xvf UnixBench5.1.3.tar > /dev/null 2>&1
	cd UnixBench/
	make clean > /dev/null 2>&1
	make

	for ((k=1; k<=$unixcount; k++))
	do
	echo -e "第 $k 次unixbench测试，总共测试 $unixcount 次\n" 
	
	./Run $unixthreads
	
	done
	cp -rf results/*  ../../result/unixbench/
	cd ../../

	echo -e "				UnixBench测试结束!\n"
}

STREAM()
{
	mkdir -p result/stream
	streamdate=`date +%F`

	eval $(awk '($1 == "streamthreads:"){printf("streamthreads=%d",$2)}' paraconfig)

	cd software
	tar -xvf STREAM-32.tar.bz2 > /dev/null 2>&1
	cd stream

	sti=2
	while [ $streamthreads -ne 0 ]
	do
		gcc -O -fopenmp -DTHREAD_NBR=$streamthreads -o stream_$streamthreads stream_d.c second_wall.c -lm
		./stream_$streamthreads | tee ../../result/stream/${streamdate}-${streamthreads}

		sti=$(($sti+1))
		eval $(awk '($1 == "streamthreads:"){printf("streamthreads=%d",$'$sti')}' ../../paraconfig)
	done

	cd ../..
	echo -e "\n				STREAM测试结束!\n" 
}

Iozone()
{
	mkdir -p result/iozone
	iozonedate=`date +%F`

	eval $(awk '($1 == "iozonecount:"){printf("iozonecount=%s",$2)}' paraconfig)

	cd software
	tar -xvf iozone3_483.tar > /dev/null 2>&1
	cd iozone3_483/src/current/
	
	aarch=$(uname -m)
	if [ $aarch == x86_64 ]; then
		make linux-AMD64 > /dev/null 2>&1
	elif [ $aarch == aarch64 ]; then
		make linux-arm > /dev/null 2>&1
	fi

	eval $(awk '($1 == "MemTotal:"){printf("memsize=%d",$2*2/1048576)}' /proc/meminfo)

	for ((k=1; k<=$iozonecount; k++))
	do
		echo -e "第 $k 次iozone测试,总共测试 $iozonecount 次 \n"
		echo -e "iozone -a -i 0 -i 1 -i 2 -f /tmp/iozone -n ${memsize}G -g ${memsize}G -Rb result/iozone/${iozonedate}-${k}.iozone\n"

		#./iozone -a -i 0 -i 1 -i 2 -f /tmp/iozone -n ${memsize}G -g ${memsize}G -Rb | tee ../../../../result/iozone/${iozonedate}-${k}.iozone
		./iozone -a -i 0 -i 1 -i 2 -f /tmp/iozone -n ${memsize}G -g ${memsize}G -Rb ../../../../result/iozone/${iozonedate}-${k}.iozone

	done

	cd ../../../../
	echo -e "				Iozone测试结束!\n"

}

Lmbench()
{
	mkdir -p result/lmbench

	MB=""
	eval $(awk '($1 == "lmmemsize:"){printf("MB=%s",$2)}' paraconfig)

	rm -rf software/lmbench  > /dev/null 2>&1
	cd software
	tar -jxvf LMBENCH-3.0-a9-32.tar.bz2 > /dev/null 2>&1
	cd lmbench/lmbench-3.0-a9

	aarch=$(uname -m)
	if [ $aarch == aarch64 ]; then
		sed -i 's/arm/aarch/' scripts/gnu-os
	fi

#	if [ -r /proc/meminfo ]; then
#		TMP=`grep 'MemTotal:' /proc/meminfo | awk '{print $2}'`
#		if [ "X$TMP" != X ]; then
#			memsize=`echo $TMP / 1024 | bc 2>/dev/null`
#		fi

		#内存如果大于16G，则lmbench测试使用10G内存测试
#		if [ $memsize -gt 16384 ]; then
#			MB=10240
#		fi
#	fi

	make results  << EOF


${MB}








no

EOF

	make see
	cp -r results/* ../../../result/lmbench/

	cd ../../../ 	
}

Iperf()
{
	mkdir -p result/iperf
	iperfdate=`date +%F`

	eval $(awk '($1 == "ipaddr:"){printf("ipaddr=%s",$2)}' paraconfig)
	eval $(awk '($1 == "bandwidth:"){printf("bandwidth=%s",$2)}' paraconfig)
	eval $(awk '($1 == "iperftime:"){printf("iperftime=%d",$2)}' paraconfig)
	lost_rate=`ping -c 10 -w 10 ${ipaddr} \
		| grep 'packet loss' \
		| awk -F'packet loss' '{ print $1 }' \
		| awk '{ print $NF }' \
		| sed 's/%//g'`

	if [ $lost_rate -eq 100 ]; then
		echo -e "网络不通,请配置好网络环境\n"
		return 1
	fi



	iperf -s | tee -a result/iperf/${iperfdate}_iperf_tcp &
	iperf -c $ipaddr -i 1 -t $iperftime | tee -a result/iperf/${iperfdate}_iperf_tcp

	killall iperf

	iperf -u -s | tee -a result/iperf/${iperfdate}_iperf_udp &
	iperf -u -c $ipaddr -i 1 -t $iperftime -b $bandwidth | tee -a result/iperf/${iperfdate}_iperf_udp

	killall iperf

	echo -e "iperf 测试结束!\n"
}

Specjvm()
{
	#运行此测试需要java环境，安装java及对应版本的jdk
	#apt-get install openjdk-8-jdk

	mkdir -p result/specjvm

	dirnow=`pwd`
	aarch=$(uname -m)
	eval $(awk '($1 == "specjvmins:"){printf("specjvmins=%s",$2)}' paraconfig)
	rm $specjvmins/SPECjvm2008/ -rf  &> /dev/null
	cd software
	tar -xvf specjvm2008.tar > /dev/null 2>&1
	cd specjvm2008/
	java -jar SPECjvm2008_1_01_setup.jar -i console <<EOF
1








Y
${specjvmins}/SPECjvm2008
Y



EOF


#	if [ $aarch == x86_64 ]; then
#		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#	elif [ $aarch == aarch64 ]; then
#		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
#	fi
#
#	export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:/lib.dt.jar
#	export PATH=$JAVA_HOME/bin:$PATH

	rm $specjvmins/SPECjvm2008/run-specjvm.sh &> /dev/null
	cp run-specjvm.sh $specjvmins/SPECjvm2008/
	cd $specjvmins/SPECjvm2008/
	#java -jar SPECjvm2008.jar -ikv
	chmod +x run-specjvm.sh

	eval $(awk '($1 == "specXmx:"){printf("specXmx=%d",$2)}' $dirnow/paraconfig)
	eval $(awk '($1 == "specthreads:"){printf("specthreads=%d",$2)}' $dirnow/paraconfig)

	sti=2
	while [ $specthreads -ne 0 ]
	do
		./run-specjvm.sh $specXmx $specthreads
		sti=$(($sti+1))
		eval $(awk '($1 == "specthreads:"){printf("specthreads=%d",$'$sti')}' $dirnow/paraconfig)
	done

	cp results/* -rf $dirnow/result/specjvm/
#	rm run-specjvm.sh
	cd $dirnow

	echo -e "\nspecjvm 测试结束!\n"
}

Ttytest()
{
	mkdir -p result/ttytest/

	eval $(awk '($1 == "testcom1:"){printf("testcom1=%s",$2)}' paraconfig)
	eval $(awk '($1 == "testcom2:"){printf("testcom2=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ttytime:"){printf("ttytime=%d",$2)}' paraconfig)

	if [ $testcom1 == "NULL" -o $testcom2 == "NULL" ]
	then
		return 0
	fi


	cd software/
	tar -xvf ttytest.tar > /dev/null 2>&1
	cd ttytest/

	gcc -o com com.c

	./com $testcom1 $testcom2 $ttytime | tee -a ../../result/ttytest/result-${resultdate}

	cd ../../

	echo -e "tty 测试结束!\n"
}

resultdate=`date +%F`
echo -n "请输入对应号码(选项之间以空格间隔): "
read options
echo -e "\n"

for number in $options
do
	if [ $number == q ];then
		exit 0
	elif [ $number == 1 ];then
		echo -e "				U盘拷贝测试:\n"
		Diskcptest
	elif [ $number == 2 ];then
		echo -e "				Unixbench测试:\n"
		UnixBench
	elif [ $number == 3 ];then
		echo -e "				STREAM测试:\n"
		STREAM
	elif [ $number == 4 ];then
		echo -e "				iozone测试:\n"
		Iozone
	elif [ $number == 5 ];then
		echo -e "				lmbench测试:\n"
		Lmbench
	elif [ $number == 6 ];then
		echo -e "				iperf测试:\n"
		Iperf
	elif [ $number == 7 ];then
		echo -e "				specjvm测试:\n"
		Specjvm
	elif [ $number == 8 ];then
		echo -e "				串口测试:\n"
		Ttytest


	elif [ $number == 9 ];then
		echo -e "				所有选项依次测试!\n"
	
		echo -e "				U盘拷贝测试:\n"
		Diskcptest

		echo -e "                          Unixbench循环测试:\n"
		UnixBench

		echo -e "                          STREAM循环测试:\n"
		STREAM

		echo -e "                          iozone循环测试:\n"
		Iozone

		echo -e "                          lmbench测试:\n"
		Lmbench

		echo -e "                          iperf测试:\n"
		Iperf

		echo -e "                          specjvm测试:\n"
		Specjvm

		echo -e "                          串口测试:\n"
		Ttytest

	else
		echo -e"\nerror: Please input the correct options!\n"
	fi
done

echo -e "\n\n测试结果记录在 result 目录下！\n"
exit 0
