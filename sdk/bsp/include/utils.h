#ifndef _UTILS_H_
#define _UTILS_H_

#define CPU_FREQ_HZ   (50000000)  // 50MHz
#define CPU_FREQ_MHZ  (50)        // 50MHz


#define read_csr(reg) ({ unsigned long __tmp; \
  asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
  __tmp; })

#define write_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrw " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrw " #reg ", %0" :: "r"(val)); })


#ifdef SIMULATION
#define set_test_pass() asm("li x27, 0x01")
#define set_test_fail() asm("li x27, 0x00")
#endif


uint64_t get_cycle_value();
void busy_wait(uint32_t us);

#endif
