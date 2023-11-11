#include <stdint.h>

#include "./include/trap_code.h"

extern void timer0_irq_handler() __attribute__((weak));


void interrupt_handler(uint32_t mcause, uint32_t mepc)
{
    // we have only timer0 interrupt here
    timer0_irq_handler();
}

void exception_handler(uint32_t mcause, uint32_t mepc)
{
    if ((mcause != TRAP_BREAKPOINT) && (mcause != TRAP_ECALL_M))
        while (1);
}
