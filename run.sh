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
		echo "第 $k 次数据拷贝!" | tee -a result/udisk/udiskresult | tee -a result/result-${resultdate}

		echo "从硬盘向U盘拷贝文件:" | tee -a result/udisk/udiskresult | tee -a result/result-${resultdate}
		cp $ufiledir/$udiskfile  $udiskdir &>> result/result-${resultdate}
		rm $ufiledir/$udiskfile

		echo "从u盘向硬盘拷贝文件:" | tee -a result/udisk/udiskresult | tee -a result/result-${resultdate}
		cp $udiskdir/$udiskfile  $ufiledir &>> result/result-${resultdate}
		rm $udiskdir/$udiskfile

		echo "第 $k 次数据拷贝结束!" | tee -a result/udisk/udiskresult
		outecho

		echo "" | tee -a result/result-${resultdate}
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

	unixdate=`date +%F`
	eval $(awk '($1 == "unixcount:"){printf("unixcount=%s",$2)}' paraconfig)

	outecho
	echo "UnixBench测试:" | tee -a result/result-${resultdate}
	echo "UnixBench测试开始时间:" >> runtime/unixbench/unixbenchtime
	date >> runtime/unixbench/unixbenchtime
	

	cd software
	tar -xvf UnixBench5.1.3.tar > /dev/null 2>&1
	cd UnixBench/
	make 

	for ((k=1; k<=$unixcount; k++))
	do
	outecho
	echo "第 $k 次unixbench测试，总共测试 $unixcount 次" | tee -a  ../../result/result-${resultdate}
	echo "" | tee -a ../../result/result-${resultdate}

	echo "1线程测试:" | tee -a ../../result/result-${resultdate}
	./Run -c 1 | tee ../../result/unixbench/${unixdate}-run-c-1-${k}
	cat ../../result/unixbench/${unixdate}-run-c-1-${k} | grep -A100 "Benchmark Run" >> ../../result/result-${resultdate}
	echo "" | tee -a ../../result/result-${resultdate}
	outecho
	
	outecho
	echo "4线程测试:" | tee -a ../../result/result-${resultdate}
	./Run -c 4 | tee ../../result/unixbench/${unixdate}-run-c-4-${k} 
	cat ../../result/unixbench/${unixdate}-run-c-4-${k} | grep -A100 "Benchmark Run" >> ../../result/result-${resultdate}
	echo "" | tee -a ../../result/result-${resultdate}
	outecho

	outecho
	echo "8线程测试:" | tee -a ../../result/result-${resultdate}
	./Run -c 8 | tee ../../result/unixbench/${unixdate}-run-c-8-${k}
	cat ../../result/unixbench/${unixdate}-run-c-8-${k} | grep -A100 "Benchmark Run" >> ../../result/result-${resultdate}
	echo "" | tee -a ../../result/result-${resultdate}
	outecho

	outecho
	echo "16线程测试:" | tee -a ../../result/result-${resultdate}
	./Run -c 16 | tee  ../../result/unixbench/${unixdate}-run-c-16-${k}
	cat ../../result/unixbench/${unixdate}-run-c-16-${k} | grep -A100 "Benchmark Run" >> ../../result/result-${resultdate}
	echo "" | tee -a ../../result/result-${resultdate}
	outecho
	done
	echo "" | tee -a ../../result/result-${resultdate}
	cd ../../

	echo "UnixBench测试结束时间:" >> runtime/unixbench/unixbenchtime
	date >> runtime/unixbench/unixbenchtime
	echo "				UnixBench测试结束!"
	outecho
}

STREAM()
{
	mkdir -p result/stream
	mkdir -p runtime/stream
	streamdate=`date +%F`

	eval $(awk '($1 == "streamcount:"){printf("streamcount=%d",$2)}' paraconfig)
	eval $(awk '($1 == "streamthread:"){printf("streamthread=%d",$2)}' paraconfig)

	outecho
	echo "STREAM测试:" | tee -a result/result-${resultdate}
	echo "STREAM测试开始时间:" > runtime/stream/streamtime
	date >> runtime/stream/streamtime

	cd software
	tar -xvf STREAM-32.tar.bz2 > /dev/null 2>&1
	cd stream
	gcc -O -fopenmp -DTHREAD_NBR=$streamthread -o stream_d stream_d.c second_wall.c -lm

	for ((j=1; j<=$streamcount; j++))
	do
		outecho
		echo "第 $j 次stream测试,总共测试 $streamcount 次." | tee -a ../../result/result-${resultdate}
		echo "第 $j 次测试结果:" >> ../../result/stream/${streamdate}-${j}
		./stream_d | tee ../../result/stream/${streamdate}-${j} | tee -a ../../result/result-${resultdate}
		echo "" | tee -a ../../result/result-${resultdate}
		echo "第 $j 次测试结束！"
		outecho
	done

	cd ../..
	echo "STREAM测试结束时间:" >> runtime/stream/streamtime
	date >> runtime/stream/streamtime
	echo "				STREAM测试结束!" 
	outecho
}

Iozone()
{
	mkdir -p result/iozone
	mkdir -p runtime/iozone
	iozonedate=`date +%F`

	outecho
	echo "Iozone测试:" | tee -a result/result-${resultdate}
	echo "Iozone测试开始时间:" >> runtime/iozone/iozonetime
	date >> runtime/iozone/iozonetime
	
	eval $(awk '($1 == "iozonecount:"){printf("iozonecount=%s",$2)}' paraconfig)

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

	for ((k=1; k<=$iozonecount; k++))
	do
		echo "第 $k 次iozone测试,总共测试 $iozonecount 次 " | tee -a ../../../../result/result-${resultdate}
		echo "iozone -a -i 0 -i 1 -i 2 -f result/iozone/iozone.testfile -n ${memsize}G -g ${memsize}G -R result/iozone/${iozonedate}-${k}.iozone" | tee -a ../../../../result/result-${resultdate}
		echo "" | tee -a ../../../../result/result-${resultdate}

		./iozone -a -i 0 -i 1 -i 2 -f ../../../../result/iozone/iozone.testfile -n ${memsize}G -g ${memsize}G -R | tee ../../../../result/iozone/${iozonedate}-${k}.iozone

		echo "" | tee -a  ../../../../result/result-${resultdate}
		cat ../../../../result/iozone/${iozonedate}-${k}.iozone | grep -A100 "Excel output is below:" >> ../../../../result/result-${resultdate}
		echo "" | tee -a  ../../../../result/result-${resultdate}
	done

	cd ../../../../
	echo "" | tee -a result/result-${resultdate}
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
	echo "lmbench 测试:" | tee -a result/result-${resultdate}
	echo "lmbench测试开始时间:" >> runtime/lmbench/lmbenchtime
	date >> runtime/lmbench/lmbenchtime

	cd software
	tar -jxvf LMBENCH-3.0-a9-32.tar.bz2 > /dev/null 2>&1
	cd lmbench/lmbench-3.0-a9
	make results  << EOF











	no

EOF

	echo "lmbench测试结束时间:" >> ../../../runtime/lmbench/lmbenchtime
	date >> ../../../runtime/lmbench/lmbenchtime

	make see
	cp -r results/* ../../../result/lmbench/

	echo " " | tee -a ../../../result/result-${resultdate}
	cat results/lmbench/summary.out >> ../../../result/result-${resultdate}
	echo " " | tee -a ../../../result/result-${resultdate}
	cd ../../../ 	
}

Iperf()
{
	mkdir -p result/iperf
	mkdir -p runtime/iperf
	iperfdate=`date +%F`

	outecho
	echo "iperf测试:" | tee -a result/result-${resultdate}
	eval $(awk '($1 == "ipaddr:"){printf("ipaddr=%s",$2)}' paraconfig)
	eval $(awk '($1 == "bandwidth:"){printf("bandwidth=%s",$2)}' paraconfig)
	eval $(awk '($1 == "iperftime:"){printf("iperftime=%d",$2)}' paraconfig)
	lost_rate=`ping -c 10 -w 10 ${ipaddr} \
		| grep 'packet loss' \
		| awk -F'packet loss' '{ print $1 }' \
		| awk '{ print $NF }' \
		| sed 's/%//g'`

	if [ $lost_rate -eq 100 ]; then
		echo "网络不通,请配置好网络环境" | tee -a result/result-${resultdate}
		echo "" | tee -a result/result-${resultdate}
		return 1
	fi

	echo "iperf TCP测试开始时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime


	iperf -s | tee -a result/iperf/${iperfdate}_iperf_tcp &
	iperf -c $ipaddr -i 1 -t $iperftime | tee -a result/iperf/${iperfdate}_iperf_tcp
	echo "iperf TCP测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime

	echo "1. iperf TCP 测试：" >> result/result-${resultdate}
	echo "[ ID] Interval       Transfer     Bandwidth" >> result/result-${resultdate}
	tail -n1 result/iperf/${iperfdate}_iperf_tcp >> result/result-${resultdate}
	echo "" | tee -a result/result-${resultdate}

	killall iperf

	echo "iperf UDP测试开始时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime
	iperf -u -s | tee -a result/iperf/${iperfdate}_iperf_udp &
	iperf -u -c $ipaddr -i 1 -t $iperftime -b $bandwidth | tee -a result/iperf/${iperfdate}_iperf_udp
	echo "iperf UDP测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime

	echo "2. iperf UDP 测试：" >> result/result-${resultdate}
	echo "[ ID] Interval       Transfer     Bandwidth" >> result/result-${resultdate}
	tail -n2 result/iperf/${iperfdate}_iperf_udp >> result/result-${resultdate}
	echo "" | tee -a result/result-${resultdate}

	killall iperf

	echo "iperf测试结束时间:" >> runtime/iperf/iperftime
	date >> runtime/iperf/iperftime


}

Specjvm()
{
	#运行此测试需要java环境，安装java及对应版本的jdk
	#apt-get install openjdk-8-jdk

	mkdir -p result/specjvm
	mkdir -p runtime/specjvm

	echo "specjvm 测试:" | tee -a result/result-${resultdate}
	echo "specjvm 测试开始时间" >> runtime/specjvm/specjvmtime
	date >> runtime/specjvm/specjvmtime
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


	if [ $aarch == x86_64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	elif [ $aarch == aarch64 ]; then
		export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
	fi

	export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:/lib.dt.jar
	export PATH=$JAVA_HOME/bin:$PATH

	rm $specjvmins/SPECjvm2008/run-specjvm.sh &> /dev/null
	cp run-specjvm.sh $specjvmins/SPECjvm2008/
	cd $specjvmins/SPECjvm2008/
	#java -jar SPECjvm2008.jar -ikv
	chmod +x run-specjvm.sh
	./run-specjvm.sh

	cp results/* -r $dirnow/result/specjvm/
	rm run-specjvm.sh
	cd $dirnow
	cat result/specjvm/SPECjvm2008.001/SPECjvm2008.001.summary >> result/result-${resultdate}
	echo "" | tee -a result/result-${resultdate}

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

	echo "tty 测试" | tee -a result/result-${resultdate}
	echo "tty 测试开始时间" >> runtime/ttytest/ttytime
	date >> runtime/ttytest/ttytime

	cd software/
	tar -xvf ttytest.tar > /dev/null 2>&1
	cd ttytest/

	gcc -o com com.c

	./com $testcom1 $testcom2 $ttytime | tee -a ../../result/result-${resultdate}

	cd ../../

	echo "" | tee -a result/result-${resultdate}
	echo "tty 测试结束"
	echo "tty 测试结束时间" >> runtime/ttytest/ttytime
	date >> runtime/ttytest/ttytime
}

resultdate=`date +%F`
echo -n "请输入对应号码(选项之间以空格间隔): "
read options
echo ""

for number in $options
do
	if [ $number == q ];then
		exit 0
	elif [ $number == 1 ];then
		echo "				U盘拷贝测试:				"
		Diskcptest
	elif [ $number == 2 ];then
		echo "				Unixbench测试:"
		UnixBench
	elif [ $number == 3 ];then
		echo "				STREAM测试:"
		STREAM
	elif [ $number == 4 ];then
		echo "				iozone测试:"
		Iozone
	elif [ $number == 5 ];then
		echo "				lmbench测试:"
		Lmbench
	elif [ $number == 6 ];then
		echo "				iperf测试:"
		Iperf
	elif [ $number == 7 ];then
		echo "				specjvm测试:"
		Specjvm
	elif [ $number == 8 ];then
		echo "				串口测试:"
		Ttytest


	elif [ $number == 9 ];then
		echo "				所有选项依次测试!"
	
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

	else
		echo ""
		echo "error: Please input the correct options!"
	fi
done

echo ""
echo "测试结果位于result目录！"
echo ""
exit 0
