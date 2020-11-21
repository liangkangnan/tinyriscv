#include <stdint.h>

#include "../../bsp/include/uart.h"
#include "../../bsp/include/xprintf.h"



int main()
{
    uart_init();

    xprintf("hello world\n");

    while (1);
}
