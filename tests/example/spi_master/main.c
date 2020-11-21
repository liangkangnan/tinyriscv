#include <stdint.h>

#include "../include/uart.h"
#include "../include/flash_n25q.h"
#include "../include/xprintf.h"


uint8_t id_data[3];
uint8_t program_data[N25Q_PAGE_SIZE];
uint8_t read_data[N25Q_PAGE_SIZE];


int main()
{
    // 初始化串口
    uart_init();

    // 初始化N25Q flash
    n25q_init();

    // 读N25Q ID号
    n25q_read_id(id_data, 3);
    xprintf("manu id = 0x%x\n", id_data[0]);
    xprintf("device id = 0x%x, 0x%x\n", id_data[1], id_data[2]);

    uint16_t i;
    // 初始化要编程的数据
    for (i = 0; i < N25Q_PAGE_SIZE; i++)
        program_data[i] = 0x55;

    xprintf("start erase subsector...\n");
    // 擦除第0个子扇区
    n25q_subsector_erase(0x00);
    xprintf("start program page...\n");
    // 编程第1页
    n25q_page_program(program_data, N25Q_PAGE_SIZE, 0x01);
    xprintf("start read page...\n");
    // 读第1页
    n25q_read_data(read_data, N25Q_PAGE_SIZE, N25Q_PAGE_TO_ADDR(1));

    xprintf("read data: \n");
    // 打印读出来的数据
    for (i = 0; i < N25Q_PAGE_SIZE; i++)
        xprintf("0x%x\n", read_data[i]);

    while (1);
}
