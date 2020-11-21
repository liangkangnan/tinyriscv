#include <stdint.h>


extern void timer0_irq_handler() __attribute__((weak));


void trap_handler(uint32_t mcause, uint32_t mepc)
{
    // we have only timer0 interrupt here
    timer0_irq_handler();
}
