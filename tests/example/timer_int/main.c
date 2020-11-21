#include <stdint.h>

#include "../include/timer.h"
#include "../include/gpio.h"
#include "../include/utils.h"


static volatile uint32_t count;


int main()
{
    count = 0;

#ifdef SIMULATION
    TIMER0_REG(TIMER0_VALUE) = 500;     // 10us period
    TIMER0_REG(TIMER0_CTRL) = 0x07;     // enable interrupt and start timer

    while (1) {
        if (count == 2) {
            TIMER0_REG(TIMER0_CTRL) = 0x00;   // stop timer
            count = 0;
            // TODO: do something
            set_test_pass();
            break;
        }
    }
#else
    TIMER0_REG(TIMER0_VALUE) = 500000;  // 10ms period
    TIMER0_REG(TIMER0_CTRL) = 0x07;     // enable interrupt and start timer

    GPIO_REG(GPIO_CTRL) |= 0x1;  // set gpio0 output mode

    while (1) {
        // 500ms
        if (count == 50) {
            count = 0;
            GPIO_REG(GPIO_DATA) ^= 0x1; // toggle led
        }
    }
#endif

    return 0;
}

void timer0_irq_handler()
{
    TIMER0_REG(TIMER0_CTRL) |= (1 << 2) | (1 << 0);  // clear int pending and start timer

    count++;
}
