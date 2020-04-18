#include <stdint.h>

#include "../include/gpio.h"
#include "../include/utils.h"


int main()
{
    while (1) {
        GPIO_REG(GPIO_DATA) ^= 0x1;
        busy_wait(500 * 1000);  // delay 500ms
    }
}
