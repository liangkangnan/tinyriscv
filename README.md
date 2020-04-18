# 1.初衷

本开源项目的初衷是本人想入门RISC-V，熟悉RISC-V的指令内容和汇编语法。

本人对RISC-V很感兴趣，很看好RISC-V的发展前景，觉得RISC-V就是CPU界中的Linux。由于RISC-V是这两年才开始迅速发展的，因此关于RISC-V的学习参考资料目前还很少，特别是适合入门的资料，因此学习起来进度很缓慢，于是萌生了自己从零开始写RISC-V处理器核的想法。

本人是一名FPGA小白，为了快速入门、深入掌握RISC-V，我开始了学习FPGA和verilog的&quot;艰难&quot;历程。我工作的内容是和嵌入式软件相关的，平时根本不会接触到FPGA，也不会用到RISC-V，因此只能用业余时间来学习RISC-V。

网上有不少关于RISC-V的开源项目，但是大多都写得很&quot;高深&quot;，对于我这种小白来说学习起来是非常吃力的，不太适合入门。本项目目前的代码量非常少，是很简单易懂的，对于想入门RISC-V的同学来说是一个很好的参考，希望能够吸引更多的同学参与到RISC-V的学习中来，促进RISC-V的发展，如果能起到抛砖引玉的作用的话那就更好了，也许说是砖的话就有点夸大了，但哪怕是起到一颗沙子的作用，也就足矣。

# 2.介绍

本项目实现的是一个单核32位的小型RISC-V处理器核(tinyriscv)，采用verilog语言编写。tinyriscv有以下特点：

1. 支持RV32IM指令集，通过RISC-V指令兼容性测试；
3. 采用三级流水线，即取指，译码，执行；
4. 可以运行C语言程序；
5. 支持JTAG，可以通过openocd读写内存(在线更新程序)；
6. 支持中断；
6. 支持总线；

项目中的各目录说明：

**rtl**：该目录包含tinyriscv的所有verilog源码；

**sim**：该目录包含仿真的顶层testbench代码和批处理bat文件；

**tests**：该目录包含测试程序源码，其中example目录为C语言程序例程源码，isa目录为RV32指令测试源码；

**tools**：该目录包含编译汇编和c语言程序所需GNU工具链和将二进制文件转成仿真所需的mem格式文件的工具BinToMem。BinToMem\_CLI.exe需要在cmd窗口下执行，BinToMem\_GUI.exe提供图形界面，双击即可运行；

**pic**：存放图片；

tinyriscv的整体框架如下：

![tinyriscv整体框架](https://github.com/liangkangnan/tinyriscv/blob/master/pic/arch.jpg)

tinyriscv目前外挂了5个外设，每个外设的空间大小为256MB，地址空间分配如下图所示：

<img src="./pic/addr_alloc.jpg" alt="地址空间分配" style="zoom:70%;" />

# 3.CoreMark测试

目前tinyriscv在Xilinx Artix-7 35T FPGA平台上运行CoreMark跑分程序的结果如下图所示：

![tinyriscv跑分](https://github.com/liangkangnan/tinyriscv/blob/master/pic/tinyriscv_coremark.png)

可知，tinyriscv的跑分成绩为2.4。此成绩是基于指令在rom存储和数据在ram存储的情况下得出的，如果指令和数据都在ram的话跑分上3.0问题应该不大。

选了几款其他MCU的跑分结果如下图所示：

![其他MCU跑分结果](https://github.com/liangkangnan/tinyriscv/blob/master/pic/other_coremark.png)

更多MCU的跑分结果，可以到[coremark](https://www.eembc.org/coremark/scores.php)官网查询。

# 4.如何使用

本项目运行在windows平台，编译仿真工具使用的是iverilog和vpp，波形查看工具使用的是gtkwave。

## 4.1安装环境

在使用之前需要安装以下工具：

1. 安装iverilog工具

可以在这里[http://bleyer.org/icarus/](http://bleyer.org/icarus/)下载，安装过程中记得同意把iverilog添加到环境变量中，当然也可以在安装完成后手动进行添加。安装完成后iverilog、vvp和gtkwave等工具也就安装好了。

2. 安装GNU工具链

可以通过百度网盘下载(链接: https://pan.baidu.com/s/1bYgslKxHMjtiZtIPsB2caQ 提取码: 9n3c)，下载完成后将压缩包解压到本项目的tools目录下。

3. 安装make工具

可以通过百度网盘下载(链接: https://pan.baidu.com/s/1nFaUIwv171PDXuF7TziDFg 提取码: 9ntc)，下载完成后直接解压，然后将make所在的路径添加到环境变量里。

## 4.2运行指令测试程序

下面以add指令为例，说明如何运行指令测试程序。

打开CMD窗口，进入到sim目录，执行以下命令：

```sim_new_nowave.bat ..\tests\isa\generated\rv32ui-p-add.bin inst.data```

如果运行成功的话就可以看到&quot;PASS&quot;的打印。其他指令使用方法类似。

![](https://github.com/liangkangnan/tinyriscv/blob/master/pic/test_output.png)

## 4.3运行C语言程序

C语言程序例程位于tests\example目录里。

下面以simple程序为例进行说明。

首先打开CMD窗口，进入到tests\example\simple目录，执行以下命令清除旧的目标文件：

`make clean`

然后重新编译：

`make`

编译成功之后，进入到sim目录，执行以下命令开始测试：

` .\sim_new_nowave.bat ..\tests\example\simple\simple.bin inst.data`

# 5.未来计划

1. 支持FreeRTOS；

2. 写设计文档；

3. ......

# 6.更新记录

2020-04-18：适当添加代码注释；优化中断管理模块。

2020-04-11：增加CoreMark跑分例程和跑分成绩。

2020-04-05：支持CSR指令。

2020-03-29：重大更新，主要更新如下：

1. 支持RIB(RISC-V Internal Bus)总线；
2. 优化乘法代码，节省了2/3的DSP资源；
3. 优化除法代码，解决了除法模块的BUG；
4. 完善C语言例程、启动代码和链接脚本；
5. 增加一次性对所有指令进行测试的脚本；

2020-03-08：支持中断，为此增加了timer模块来验证。

2020-03-01：支持JTAG，配合openocd可进行内存读写。JTAG文档参考[深入浅出RISC-V调试](https://liangkangnan.gitee.io/2020/03/21/深入浅出RISC-V调试/)。

2020-02-23：支持在Xilinx Artix-7平台上运行。详见[tinyriscv_vivado](https://gitee.com/liangkangnan/tinyriscv_vivado)。

2020-01-13：支持RV32M的除法指令。其C语言实现详见[div](https://gitee.com/liangkangnan/div)。

2020-01-02：支持RV32M的乘法指令。

2019-12-06：第一次发布。


