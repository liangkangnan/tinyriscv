#include <stdint.h>

#include "../include/uart.h"
#include "../include/xprintf.h"



int main()
{
    uart_init();

    while (1) {
        // echo
        xprintf("%c", uart_getc());
    }
}
