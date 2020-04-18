#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"


static void uart_putc(uint8_t c)
{
    while (UART0_REG(UART0_STATUS) & 0x1);
    UART0_REG(UART0_TXDATA) = c;
}

// 115200bps, 8 N 1
void uart_init()
{
    UART0_REG(UART0_CTRL) = 0x1;

    xdev_out(uart_putc);
}
