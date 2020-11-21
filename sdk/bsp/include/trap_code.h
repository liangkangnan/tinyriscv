#ifndef _TRAP_CODE_H_
#define _TRAP_CODE_H_

#define TRAP_USER_SW            (0x80000000)
#define TRAP_MACH_SW            (0x80000003)
#define TRAP_USER_TIMER         (0x80000004)
#define TRAP_MACH_TIMER         (0x80000007)
#define TRAP_USER_EXT           (0x80000008)
#define TRAP_MACH_EXT           (0x8000000B)
#define TRAP_INST_ADDR_MISA     (0x00000000)
#define TRAP_ILLEGAL_INST       (0x00000002)
#define TRAP_BREAKPOINT         (0x00000003)
#define TRAP_LOAD_ADDR_MISA     (0x00000004)
#define TRAP_STORE_ADDR_MISA    (0x00000006)
#define TRAP_ECALL_U            (0x00000008)
#define TRAP_ECALL_S            (0x00000009)
#define TRAP_ECALL_M            (0x0000000B)

#endif
