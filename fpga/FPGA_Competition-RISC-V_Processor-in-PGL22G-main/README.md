## 2022全国大学生嵌入式芯片与系统设计大赛FPGA创新设计竞赛紫光同创杯RISCV赛题作品
赛题链接：http://www.fpgachina.cn/file/ueditor/file/20220823/1661266791195040472.pdf  

我们做的东西简单来说就是移植了开源的tinyriscv处理器到紫光的板子上，JTAG下载程序到板子上跑coremark，运行了FreeRTOS。做了差不多两个月，最后摸了个国三回家。
刚学FPGA的时候做的（当时连串口是啥都不知道），都是脏活累活，主要工作量都集中在研究紫光的PDS软件和读他的技术文档（国产板子说实话有点难用）。
## FPGA Innovation Design Competition:RISC-V-Processor based Hardware and-Software Design
  
This is our repo for FPGA Innovation Design Competition,we made a RISC-V CPU processor-based software and hardware design in PGL22G FPGA development board and the Maximum operating frequency up to 47MHz, performance up to 1.915CoreMark/MHz, consuming 0.3392w power.
## Description
The main branch is the source project file in Pango Design Suit, th master branch is Tinyriscv's source file.

## Use
To use  this riscv, pleace open the project in Pango Design Suit, and the folllowing steps are the same as which in tinyriscv. Refer to https://gitee.com/liangkangnan/tinyriscv

## Our CoreMark score

<div align=center><img src="https://user-images.githubusercontent.com/88324880/200857709-a5850a39-aaee-4670-8823-e8374b26d1ce.png" width="800"></div>

<div align=center><img src="https://user-images.githubusercontent.com/88324880/200857735-09c6642c-8d8c-4518-aadf-78cfc79a0218.png" width="600"></div>

`Reference:https://gitee.com/liangkangnan/tinyriscv#https://liangkangnan.gitee.io`
