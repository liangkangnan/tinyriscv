本目录下都是C语言程序的例程。

目录介绍：

**gpio**: 两个GPIO，一个作为输入、一个作为输出，输出的电平等于输入的电平。

**simple**: 简单的加、减、乘、除运算测试例程。

**timer_int**: 定时器中断测试例程，每500ms翻转一下IO口的电平。在FPGA上运行时需要将其Makefile里的CFLAGS += -DSIMULATION这一行注释掉。

**uart_tx**: 串口发送测试例程，向上位机发送hello world字符串。

**uart_rx：**串口接收测试例程，将接收到的数据发回给上位机(echo)。

**coremark：**已经移植好的coremark跑分测试例程。

**FreeRTOS：**FreeRTOS嵌入式操作系统测试例程，效果：每1s翻转一下IO口的电平。
