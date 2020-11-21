#ifndef _TIMER_H_
#define _TIMER_H_

#define TIMER0_BASE   (0x20000000)
#define TIMER0_CTRL   (TIMER0_BASE + (0x00))
#define TIMER0_COUNT  (TIMER0_BASE + (0x04))
#define TIMER0_VALUE  (TIMER0_BASE + (0x08))

#define TIMER0_REG(addr) (*((volatile uint32_t *)addr))

#endif
