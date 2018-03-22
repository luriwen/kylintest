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
				*			->	3.STREAM 测试	<-			 *
				*			->	4.iozone 测试	<-			 *
				*			->	5.lmbench 测试	<-			 *
				*			->	7.所有项测试		<-			 *
				/*********************************************************************************/






END


diskcptest()
{
	outecho
	echo "				U盘拷贝测试开始!"
cat<<-END >&2
		usage:										
					mkdir -p /opt/Udisk /opt/sata				
					mount /dev/sda* /sata/					
					mount /dev/sdb* /Udisk/					
					dd if=/dev/sdb* of=/opt/sata/Udisktest bs=10G count=5	
					dd if=/dev/sda* of=/opt/Udisk/satatest bs=10G count=5	
					rm -rf /opt/sata /opt/Udisk
END

	echo -n "请输入dev下U盘分区号(例如:sdb1):"
	read sdb
	echo -n "请输入dev下硬盘分区号,(例如:sda2):"
	read sda
	
	echo "硬盘拷贝数据开始时间:" >> runtime/diskdd.txt
	date "+%s">> runtime/diskdd.txt	

	for ((k=1; k<=20; k++))
	do
		outecho
		echo "				第 $k 次数据拷贝!" >> diskddresult.txt 2>&1
		echo "                          第 $k 次数据拷贝!"
		mkdir -p /opt/udisk /opt/sata
		mount /dev/$sdb /opt/udisk
		mount /dev/$sda /opt/sata

		echo "				从硬盘向U盘拷贝3G大数据:" >> diskddresult.txt 2>&1
		dd if=/dev/$sda of=/opt/udisk/udisktest bs=1G count=3 >> diskddresult.txt 2>&1
		echo "拷贝数据大小:" >> diskddresult.txt 2>&1
		du -sh /opt/udisk/udisktest >> diskddresult.txt 2>&1
		rm /opt/udisk/udisktest

		echo "				/dev/zero下向U盘内拷贝3G大数据:" >> diskddresult.txt 2>&1
		dd if=/dev/zero of=/opt/udisk/udisktest bs=1G count=3 >> diskddresult.txt 2>&1
		echo "拷贝数据大小:" >> diskddresult.txt 2>&1
		du -sh /opt/udisk/udisktest >> diskddresult.txt 2>&1
		rm /opt/udisk/udisktest
		
		echo "				从U盘向硬盘拷贝3G大数据:" >> diskddresult.txt 2>&1
		dd if=/dev/$sdb of=/opt/sata/satatest bs=1G count=3 >> diskddresult.txt 2>&1
		echo "拷贝数据大小:" >> diskddresult.txt 2>&1
		du -sh /opt/sata/satatest >> diskddresult.txt 2>&1
		rm /opt/sata/satatest
		
		echo "				/dev/zero下向硬盘拷贝3G大数据:" >> diskddresult.txt 2>&1
		dd if=/dev/zero of=/opt/sata/satatest bs=1G count=3 >> diskddresult.txt 2>&1
		echo "拷贝数据大小:" >> diskddresult.txt 2>&1
		du -sh /opt/sata/satatest >> diskddresult.txt 2>&1
		rm /opt/sata/satatest

		umount /opt/udisk
		umount /opt/sata
		rm -rf /opt/udisk /opt/sata
		echo "				第 $k 次数据拷贝结束!" >> diskddresult.txt 2>&1
		echo "                          第 $k 次数据拷贝结束!"
		outecho
	done
	echo "硬件拷贝数据结束时间:" >> runtime/diskdd.txt
	date "+%s">> runtime/diskdd.txt
	echo "				U盘拷贝测试结束!"
	outecho
}

UnixBench()
{
	mkdir -p result/UnixBench
	mkdir -p runtime/UnixBench

	outecho
	echo "				UnixBench测试开始!"
	echo "UnixBench测试开始时间:" >> runtime/UnixBench/UnixBenchtest.txt
	date "+%s">> runtime/UnixBench/UnixBenchtest.txt
	

	cd software
	tar -xvf UnixBench5.1.3.tar
	cd UnixBench/
	make 

	outecho
	echo "					1线程测试:					"
	./Run -c 1 >> ../../result/UnixBench/run-c-1.txt
	outecho
	
	outecho
	echo "					4线程测试:					"
	./Run -c 4 >> ../../result/UnixBench/run-c-4.txt
	outecho

	outecho
	echo "					8线程测试:					"
	./Run -c 8 >> ../../result/UnixBench/run-c-8.txt
	outecho

	outecho
	echo "					16线程测试:					"
	./Run -c 16 >> ../../result/UnixBench/run-c-16.txt
	outecho
	cd ..
	cd ..

	echo "UnixBench测试结束时间:" >> runtime/UnixBench/UnixBenchtest.txt
	date "+%s">> runtime/UnixBench/UnixBenchtest.txt
	echo "				UnixBench测试结束!"
	outecho
}

STREAM()
{
	mkdir -p result/stream
	mkdir -p runtime/stream

	outecho
	echo "				STREAM测试开始!"
	echo "STREAM测试开始时间:" >> runtime/runtime/STREAMtest.txt
	date "+%s">> runtime/runtime/STREAMtest.txt

	for ((j=1; j<=5; j++))
	do
		cd software
		tar -xvf STREAM-32.tar.bz2 > /dev/null
		cd stream
		gcc -O -fopenmp -DTHREAD_NBR=16 -o stream_d stream_d.c second_wall.c -lm

		outecho
		echo "第 $j 次测试开始！"
		echo "第 $j 次测试结果:" >> ../../result/stream/STREAM.txt
		./stream_d >> ../../result/stream/STREAM.txt
		cd ../..
		echo "第 $j 次测试结束！"
		outecho
	done

	echo "STREAM测试结束时间:" >> runtime/stream/STREAMtest.txt
	date "+%s">> runtime/stream/STREAMtest.txt
	echo "				STREAM测试结束!" 
	outecho
}

Iozone()
{
	mkdir -p result/iozone
	mkdir -p runtime/iozone

	outecho
	echo "				Iozone测试开始!"
	echo "Iozone测试开始时间:" >> runtime/iozone/Iozonetest.txt
	date "+%s">> runtime/iozone/Iozonetest.txt
	
	cd software
	tar -xvf iozone3_326.tar
	cd iozone3_326/src/current/
	make linux-arm

	echo "iozone -a -i 0 -i 1 -i 2 -f result/iozone/iozone.testfile -n 8G -g 8G -Rb result/iozone/iozone-test.xls"
	./iozone -a -i 0 -i 1 -i 2 -f ../../../../result/iozone/iozone.testfile -n 8G -g 8G -Rb ../../../../result/iozone/iozone-test.xls

	cd ../../../../
	echo "Iozone测试结束时间:" >> runtime/iozone/Iozonetest.txt
	date "+%s">> runtime/iozone/Iozonetest.txt
	echo "				Iozone测试结束!"
	outecho
}

Lmbench()
{
	mkdir -p result/lmbench
	mkdir -p runtime/lmbench

	outecho
	echo "				lmbench测试开始"
	echo "lmbench测试开始时间:" >> runtime/lmbench/lmbenchtest.txt
	date "+%s">> runtime/lmbench/lmbenchtest.txt

	cd software
	tar -jxvf LMBENCH-3.0-a9-32.tar.bz2
	cd lmbench/lmbench-3.0-a9
	make results

	echo "lmbench测试结束时间:" >> runtime/lmbench/lmbenchtest.txt
	date "+%s">> runtime/lmbench/lmbenchtest.txt

	make see
	cp -r results/* ../../../result/lmbench 
}


echo -n "请输入对应号码:"
read number


if [ $number -eq 1 ];then
	echo "				U盘拷贝测试:				"
	diskcptest
fi

if [ $number -eq "2" ];then
	echo "				Unixbench测试:"
	UnixBench
fi

if [ $number -eq "3" ];then
	echo "				STREAM测试:"
	STREAM
fi

if [ $number -eq "4" ];then
	echo "				iozone测试:"
	Iozone
fi

if [ $number -eq "5" ];then
	echo "				lmbench测试:"
	Lmbench
fi


if [ $number -eq "7" ];then
	echo "				1-6所有选项依次测试!"
	
	echo "				U盘拷贝测试:					"
	diskcptest

	echo "                          Unixbench循环测试:"
	UnixBench

	echo "                          STREAM循环测试:"
	STREAM

	echo "                          iozone循环测试:"
	Iozone

	echo "                          lmbench测试:"
	Lmbench

fi

