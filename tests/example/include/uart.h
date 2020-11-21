#ifndef _UART_H_
#define _UART_H_

#define UART0_BASE      (0x30000000)
#define UART0_CTRL      (UART0_BASE + (0x00))
#define UART0_STATUS    (UART0_BASE + (0x04))
#define UART0_BAUD      (UART0_BASE + (0x08))
#define UART0_TXDATA    (UART0_BASE + (0x0c))
#define UART0_RXDATA    (UART0_BASE + (0x10))

#define UART0_REG(addr) (*((volatile uint32_t *)addr))

void uart_init();
void uart_putc(uint8_t c);
uint8_t uart_getc();

#endif
