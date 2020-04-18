#include <stdint.h>

#include "include/utils.h"


extern void trap_entry();

extern void timer0_irq_handler() __attribute__((weak));


void trap_handler(uint32_t mcause)
{
    // we have only timer0 interrupt here
    timer0_irq_handler();
}

void _init()
{
    write_csr(mtvec, &trap_entry);
}
