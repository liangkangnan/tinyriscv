###1.Introduction

This opensource project is a tiny riscv processor core which written by verilog. It is very simple and easy to understand. Tinyriscv has the following characteristics:

1)Implemented RV32I instruction set.

2)Use three-stage flow line.

3)Can run simple C program.

###2.How to use

Tinyriscv run on windows platform, it Compiled and simulated with iverilog. Before to use, you need install these tools below:

1)iverilog

Download from http://bleyer.org/icarus/](http://bleyer.org/icarus/, install it and add to system environment PATH.

2)GNU Toolchain

Download from BaiduNetDisk https://pan.baidu.com/s/1bYgslKxHMjtiZtIPsB2caQ, extraction code is 9n3c, decompress it into tools directory.

3)make tool

Download from BaiduNetDisk https://pan.baidu.com/s/1nFaUIwv171PDXuF7TziDFg, extraction code is 9ntc, decompress it and add to system environment PATH.

Take the &quot;add&quot; instruction as an example to show how to use:

Open the CMD and go to the sim directory and run command below:

**sim\_new\_nowave.bat ..\tests\isa\generated\rv32ui-p-add.bin inst.data**

You can see the following print if it run successfully:

E:\OpenSource\mygitee\open\tinyriscv\sim>sim_new_nowave.bat ..\tests\isa\generat
ed\rv32ui-p-add.bin inst.data

E:\OpenSource\mygitee\open\tinyriscv\sim>..\tools\BinToMem_CLI.exe ..\tests\isa\
generated\rv32ui-p-add.bin inst.data

E:\OpenSource\mygitee\open\tinyriscv\sim>iverilog -s openriscv_core_tb -o out.vv
p -I ..\rtl openriscv_core_tb.v ..\rtl\defines.v ..\rtl\ex.v ..\rtl\id.v ..\rtl\
openriscv_core.v ..\rtl\pc_reg.v ..\rtl\regs.v ..\rtl\sim_ram.v ..\rtl\if_id.v

E:\OpenSource\mygitee\open\tinyriscv\sim>vvp out.vvp
test running...
WARNING: openriscv_core_tb.v:63: $readmemh(inst.data): Not enough words in the f
ile for the requested range [0:2047].
VCD info: dumpfile openriscv_core_tb.vcd opened for output.
~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~
~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~
~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~
~~~~~~~~~ #####   ######       #       #~~~~~~~~~
~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~
~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
