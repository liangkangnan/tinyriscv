#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"



int main()
{
    uart_init();

    xprintf("hello world\n");

    while (1);
}
