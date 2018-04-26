version:  3.1

综述：

run.sh: 测试执行脚本。

```shell
./run.sh
```

**测试所用配置文件在$configs$目录中，分别可测试1天、2天、4天。选择一个配置文件拷贝到主目录下，命名为$paraconfig$。**

**测试时所用到的参数，在$paraconfig$文件中。开始测试前一定要先设置好适当的参数。**

### 一、测试界面

### 二、测试项目

1. U盘拷贝测试

   - U盘测试参数：

     udisk：dev下的U盘分区号，例如：sdb1；

     udiskfile：运行U盘测试时，拷贝的文件；

     ufiledir：udiskfile所在目录，须是绝对路径；

     ucount：拷贝循环次数；

     udiskdir：U盘挂在目录，须是绝对路径。

   - 测试时间记录在runtime/udisk/udisktime文件中；

2. Unixbench测试

   - 测试命令，

     ./Run  -c  x

     其中x表示测试线程数；

   - Unixbench测试共进行1线程、4线程、8线程、16线程四轮测试；

   - 测试时间记录在runtime/unixbench/unixbenchtime文件中;

   - 测试结果分别记录在result/unixbench/目录下的run-c-1、run-c-4、run-c-8、run-c-16文件中。

3. Stream测试

   - stream测试参数：

     streamthread：stream测试时的线程数；

     streamcount：stream测试轮数。

   - stream编译：

     ```shell
     gcc -O -fopenmp -DTHREAD_NBR=$streamthread -o stream_d stream_d.c second_wall.c -lm
     ```

   - stream测试命令：

     ```shell
     ./stream_d
     ```

   - 测试时间记录在runtime/stream/streamtime文件中；

   - 测试结果记录在result/stream/streamresult文件中。

4. Iozone测试

   - iozone测试命令：

     ```shell
     iozone  -a  -i  0  -i  1  -i  2  -f  iozone.testfile  -n  XG  -g  XG  -Rb  iozoneresult
     ```

     其中，

     iozone.testfile为iozone测试文件；

     X为内存大小的2倍；

     iozone-test.xls为iozone测试结果记录文件。

   - 测试时间记录在runtime/iozone/iozonetime文件中；

   - 测试结果记录在result/iozone/iozoneresult文件中。

5. Lmbench测试

   - 测试时间记录在runtime/lmbench/lmbenchtime文件中；
   - 测试结果记录在result/lmbench/目录下。

6. Iperf测试

   iperf测试分为TCP测试和UDP测试。

   - TCP测试

     测试参数：

     ipaddr：iperf测试服务器ip地址；

     iperftime：iperf测试时间。

     测试命令：

     ```shell
     iperf  -c  ipaddr  -i  1  -t  iperftime
     ```

     如果需要双向测试，则

     ```shell
     iperf  -s
     ```

     开启服务，然后再另外服务端开启iperf客户端测试。

   - UDP测试

     测试参数：

     ipaddr：iperf测试服务器ip地址；

     iperftime：iperf测试时间；

     bandwidth：udp测试时的带宽。

     测试命令：

     ```shell
     iperf  -u  -c  ipaddr  -i  1  -t  iperftime  -b  bandwidth
     ```

     如果需要双向测试，则

     ```shell
     iperf  -u  -s
     ```

     开启服务，然后再另外服务端开启iperf客户端测试。

   - 测试时间记录在runtime/iperf/iperftime文件中；

   - 测试结果记录在result/iperf/iperfresult文件中。

7. Specjvm测试

   进行specjvm测试，需要java环境。若无，安装java及对应版本的jdk。

   ```shell
   apt-get install java
   apt-get install openjdk-8-jdk
   ```

   - 测试参数：

     specjvmins：specjvm安装目录，须绝对路径，默认为/SPECjvm2008。

   - 安装specjvm：

     ```shell
     java -jar SPECjvm2008_1_01_setup.jar -i console
     ```

   - 测试命令：

     ```shell
     ./run-specjvm.sh
     ```

   - 测试时间记录在runtime/specjvm/specjvmtime文件中；

   - 测试结果记录在result/specjvm/目录中。

8. 串口测试

   串口测试可以测试两个串口或者单个串口。两个串口测试时，需要将两个串口对连。单串口测试时，需要将该串口的Rx和Tx短接。

   - 测试参数：

     testcom1：测试串口1;

     testcom2：测试串口2;

     如果，为单串口测试，则testcom1和testcom2为同一个串口。如果不想运行串口测试程序，则可将两个参数都设置成NULL。

   - ttytime：测试时间，单位为min。

   - 测试命令：

     ```shell
     ./com  testcom1  testcom2  ttytime
     ```

   - 测试时间记录在runtime/ttytest/ttytime文件中。

9. 运行所有测试项
