本分支(pango-bram-withspi)是在bram分支的基础上
- 移植到紫光同创PGL22G的FPGA开发板上，将ROM和RAM换成紫光同创IP，添加SPI外设（这部分更改可以在fpga\FPGA_Competition-RISC-V_Processor-in-PGL22G-main的Pango Design Suite工程文件中找到）
- 添加spi屏幕外设与PS2外设相关的驱动代码，移植小游戏（这部分更改可以在tests\example中找到）

