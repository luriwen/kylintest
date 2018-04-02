#!/bin/bash
#run.sh 
#version:2.0

export LTPROOT="${PWD}"
echo $LTPROOT | grep kylintest > /dev/null 2>&1
if [ $? -gt 0 ]; then
	echo "please run run.sh script in right directory!"
	exit 0
fi

outecho()
{
	echo "/*************************************************************************************************/"
}

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
	outecho
	mkdir -p runtime/udisk/
	mkdir -p result/udisk/
	echo "				U盘拷贝测试开始!"

	eval $(awk '($1 == "udisk:"){printf("udisk=%s",$2)}' paraconfig)
	eval $(awk '($1 == "udiskfile:"){printf("udiskfile=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ucount:"){printf("ucount=%d",$2)}' paraconfig)
	eval $(awk '($1 == "udiskdir:"){printf("udiskdir=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ufiledir:"){printf("ufiledir=%s",$2)}' paraconfig)

	mkdir -p $udiskdir
	mount /dev/$udisk $udiskdir

	echo "u盘拷贝数据开始时间:" >> runtime/udisk/udisktime
	date >> runtime/udisk/udisktime

	for ((k=1; k<=$ucount; k++))
	do
		outecho
		echo "第 $k 次数据拷贝!"
		echo "第 $k 次数据拷贝!" >> result/udisk/udiskresult

		echo "从硬盘向U盘拷贝文件:" >> result/udisk/udiskresult
		cp $ufiledir/$udiskfile  $udiskdir
		rm $ufiledir/$udiskfile

		echo "从u盘向硬盘拷贝文件:" >> result/udisk/udiskresult
		cp $udiskdir/$udiskfile  $ufiledir
		rm $udiskdir/$udiskfile

		echo "第 $k 次数据拷贝结束!" >> result/udisk/udiskresult
		echo "第 $k 次数据拷贝结束!"
		outecho
	done
	umount $udiskdir

	echo "u盘拷贝数据结束时间:" >> runtime/udisk/udisktime
	date >> runtime/udisk/udisktime
	echo "				U盘拷贝测试结束!"
	outecho
}

UnixBench()
{
	mkdir -p result/unixbench
	mkdir -p runtime/unixbench

	outecho
	echo "				UnixBench测试开始!"
	echo "UnixBench测试开始时间:" >> runtime/unixbench/unixbenchtime
	date >> runtime/unixbench/unixbenchtime
	

	cd software
	tar -xvf UnixBench5.1.3.tar > /dev/null 2>&1
	cd UnixBench/
	make 

	outecho
	echo "					1线程测试:					"
	./Run -c 1 >> ../../result/unixbench/run-c-1
	outecho
	
	outecho
	echo "					4线程测试:					"
	./Run -c 4 >> ../../result/unixbench/run-c-4
	outecho

	outecho
	echo "					8线程测试:					"
	./Run -c 8 >> ../../result/unixbench/run-c-8
	outecho

	outecho
	echo "					16线程测试:					"
	./Run -c 16 >> ../../result/unixbench/run-c-16
	outecho
	cd ..
	cd ..

	echo "UnixBench测试结束时间:" >> runtime/unixbench/unixbenchtime
	date >> runtime/unixbench/unixbenchtime
	echo "				UnixBench测试结束!"
	outecho
}

STREAM()
{
	mkdir -p result/stream
	mkdir -p runtime/stream

	eval $(awk '($1 == "streamcount:"){printf("streamcount=%d",$2)}' paraconfig)
	eval $(awk '($1 == "streamthread:"){printf("streamthread=%d",$2)}' paraconfig)

	outecho
	echo "				STREAM测试开始!"
	echo "STREAM测试开始时间:" >> runtime/stream/streamtime
	date >> runtime/stream/streamtime

	for ((j=1; j<=$streamcount; j++))
	do
		cd software
		tar -xvf STREAM-32.tar.bz2 > /dev/null 2>&1
		cd stream
		gcc -O -fopenmp -DTHREAD_NBR=$streamthread -o stream_d stream_d.c second_wall.c -lm

		outecho
		echo "第 $j 次测试开始！"
		echo "第 $j 次测试结果:" >> ../../result/stream/streamresult
		./stream_d >> ../../result/stream/streamresult
		cd ../..
		echo "第 $j 次测试结束！"
		outecho
	done

	echo "STREAM测试结束时间:" >> runtime/stream/streamtime
	date >> runtime/stream/streamtime
	echo "				STREAM测试结束!" 
	outecho
}

Iozone()
{
	mkdir -p result/iozone
	mkdir -p runtime/iozone

	outecho
	echo "				Iozone测试开始!"
	echo "Iozone测试开始时间:" >> runtime/iozone/iozonetime
	date >> runtime/iozone/iozonetime
	
	cd software
	tar -xvf iozone3_326.tar > /dev/null 2>&1
	cd iozone3_326/src/current/
	
	aarch=$(uname -m)
	if [ $aarch == x86_64 ]; then
		make linux-AMD64 > /dev/null 2>&1
	elif [ $aarch == aarch64 ]; then
		make linux-arm > /dev/null 2>&1
	fi

	eval $(awk '($1 == "MemTotal:"){printf("memsize=%d",$2*2/1048576)}' /proc/meminfo)
	echo "iozone -a -i 0 -i 1 -i 2 -f result/iozone/iozone.testfile -n ${memsize}G -g ${memsize}G -Rb result/iozone/iozoneresult"
	./iozone -a -i 0 -i 1 -i 2 -f ../../../../result/iozone/iozone.testfile -n ${memsize}G -g ${memsize}G -Rb ../../../../result/iozone/iozoneresult

	cd ../../../../
	echo "Iozone测试结束时间:" >> runtime/iozone/iozonetime
	date >> runtime/iozone/iozonetime
	echo "				Iozone测试结束!"
	outecho
}

Lmbench()
{
	mkdir -p result/lmbench
	mkdir -p runtime/lmbench

	outecho
	echo "				lmbench测试开始"
	echo "lmbench测试开始时间:" >> runtime/lmbench/lmbenchtime
	date >> runtime/lmbench/lmbenchtime

	cd software
	tar -jxvf LMBENCH-3.0-a9-32.tar.bz2 > /dev/null 2>&1
	cd lmbench/lmbench-3.0-a9
	make results

	echo "lmbench测试结束时间:" >> runtime/lmbench/lmbenchtime
	date >> runtime/lmbench/lmbenchtime

	make see
	cp -r results/* ../../../result/lmbench/
	cd ../../../ 	
}

Iperf()
{
	mkdir -p result/iperf
	mkdir -p runtime/iperf

	outecho
	eval $(awk '($1 == "ipaddr:"){printf("ipaddr=%s",$2)}' paraconfig)
	eval $(awk '($1 == "bandwidth:"){printf("bandwidth=%s",$2)}' paraconfig)
	eval $(awk '($1 == "iperftime:"){printf("iperftime=%d",$2)}' paraconfig)
	lost_rate=`ping -c 10 -w 10 ${ipaddr} \
		| grep 'packet loss' \
		| awk -F'packet loss' '{ print $1 }' \
		| awk '{ print $NF }' \
		| sed 's/%//g'`

	if [ $lost_rate -eq 100 ]; then
		echo "网络不通,请配置好网络环境"
		return 1
	fi

	echo "iperf  测试开始"
	echo "iperf TCP测试开始时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime


	iperf -s >> result/iperf/iperfresult &
	iperf -c $ipaddr -i 1 -t $iperftime >> result/iperf/iperfresult
	echo "iperf TCP测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime
	killall iperf

	echo "iperf UDP测试开始时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime
	iperf -u -s >> result/iperf/iperfresult &
	iperf -u -c $ipaddr -i 1 -t $iperftime -b $bandwidth >> result/iperf/iperfresult
	echo "iperf UDP测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime

	killall iperf

	echo "iperf测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime


}

Specjvm()
{
	#运行此测试需要java环境，安装java及对应版本的jdk
	#apt-get install java
	#apt-get install openjdk-8-jdk

	mkdir -p result/specjvm
	mkdir -p runtime/specjvm

	echo "specjvm  测试开始"
	echo "specjvm 测试开始时间" >> runtime/specjvm/specjvmtime
	date >> runtime/specjvm/specjvmtime
	dirnow=`pwd`
	aarch=$(uname -m)
	eval $(awk '($1 == "specjvmins:"){printf("specjvmins=%s",$2)}' paraconfig)
	cd software
	tar -xvf specjvm2008.tar > /dev/null 2>&1
	cd specjvm2008/
	java -jar SPECjvm2008_1_01_setup.jar -i console <<EOF
1








Y
$specjvmins/SPECjvm2008
Y



EOF


	if [ $aarch == x86_64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	elif [ $aarch == aarch64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
	fi

	export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:/lib.dt.jar
	export PATH=$JAVA_HOME/bin:$PATH

	cp run-specjvm.sh $specjvmins/SPECjvm2008/
	cd $specjvmins/SPECjvm2008/
#	java -jar SPECjvm2008.jar -ikv
	chmod +x run-specjvm.sh
	./run-specjvm.sh

	cp results/* -r $dirnow/result/specjvm/
	rm run-specjvm.sh
	cd $dirnow

	echo "specjvm 测试结束"
	echo "specjvm 测试结束时间" >> runtime/specjvm/specjvmtime
	date >> runtime/specjvm/specjvmtime
}

Ttytest()
{
	mkdir -p result/ttytest/
	mkdir -p runtime/ttytest/

	eval $(awk '($1 == "testcom1:"){printf("testcom1=%s",$2)}' paraconfig)
	eval $(awk '($1 == "testcom2:"){printf("testcom2=%s",$2)}' paraconfig)
	eval $(awk '($1 == "ttytime:"){printf("ttytime=%d",$2)}' paraconfig)

	if [ $testcom1 == "NULL" -o $testcom2 == "NULL" ]
	then
		return 0
	fi

	echo "tty 测试开始"
	echo "tty 测试开始时间" >> runtime/ttytest/ttytime
	date >> runtime/ttytest/ttytime

	cd software/
	tar -xvf ttytest.tar > /dev/null 2>&1
	cd ttytest/

	gcc -o com com.c

	./com $testcom1 $testcom2 $ttytime

	cd ../../

	echo "tty 测试结束"
	echo "tty 测试结束时间" >> runtime/ttytest/ttytime
	date >> runtime/ttytest/ttytime
}

echo -n "请输入对应号码:"
read number

if [ $number == 1 ];then
	echo "				U盘拷贝测试:				"
	Diskcptest
fi

if [ $number == 2 ];then
	echo "				Unixbench测试:"
	UnixBench
fi

if [ $number == 3 ];then
	echo "				STREAM测试:"
	STREAM
fi

if [ $number == 4 ];then
	echo "				iozone测试:"
	Iozone
fi

if [ $number == 5 ];then
	echo "				lmbench测试:"
	Lmbench
fi

if [ $number == 6 ];then
	echo "				iperf测试:"
	Iperf
fi

if [ $number == 7 ];then
	echo "				specjvm测试:"
	Specjvm
fi

if [ $number == 8 ];then
	echo "				串口测试:"
	Ttytest
fi

if [ $number == 9 ];then
	echo "				1-9所有选项依次测试!"
	
	echo "				U盘拷贝测试:					"
	Diskcptest

	echo "                          Unixbench循环测试:"
	UnixBench

	echo "                          STREAM循环测试:"
	STREAM

	echo "                          iozone循环测试:"
	Iozone

	echo "                          lmbench测试:"
	Lmbench

	echo "                          iperf测试:"
	Iperf

	echo "                          specjvm测试:"
	Specjvm

	echo "                          串口测试:"
	Ttytest
fi

if [ $number == q ];then
	exit 0
fi

exit 0
