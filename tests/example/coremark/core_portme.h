//Bob: put some macro here such that the IDE SDK do not need to specify the macro specially
#define FLAGS_STR "-O2 -fno-common -funroll-loops -finline-functions --param max-inline-insns-auto=20 -falign-functions=4 -falign-jumps=4 -falign-loops=4"
#define PERFORMANCE_RUN 1
#define ITERATIONS 10000

#ifndef FESDK_CORE_PORTME_H
#define FESDK_CORE_PORTME_H

#include <stdint.h>
#include <stddef.h>

#include "../include/xprintf.h"

#define HAS_FLOAT 0
#define HAS_TIME_H 1
#define USE_CLOCK 1
#define HAS_STDIO 1
#define HAS_PRINTF 1
#define SEED_METHOD SEED_VOLATILE
#define CORE_TICKS uint64_t
#define ee_u8 uint8_t
#define ee_u16 uint16_t
#define ee_u32 uint32_t
#define ee_s16 int16_t
#define ee_s32 int32_t
#define ee_ptr_int uintptr_t
#define ee_size_t size_t
#define COMPILER_FLAGS FLAGS_STR

#define align_mem(x) (void *)(((ee_ptr_int)(x) + sizeof(ee_u32) - 1) & -sizeof(ee_u32))

#ifdef __GNUC__
# define COMPILER_VERSION "GCC"__VERSION__
#else
# error
#endif

#define MEM_METHOD MEM_STATIC
#define MEM_LOCATION "STATIC"

#define MAIN_HAS_NOARGC 0
#define MAIN_HAS_NORETURN 0

#define MULTITHREAD 1
#define USE_PTHREAD 0
#define USE_FORK 0
#define USE_SOCKET 0

#define default_num_contexts MULTITHREAD

typedef int core_portable;
void portable_init(core_portable *p, int *argc, char *argv[]);
static void portable_fini(core_portable *p) {}

#if !defined(PROFILE_RUN) && !defined(PERFORMANCE_RUN) && !defined(VALIDATION_RUN)
#if (TOTAL_DATA_SIZE==1200)
#define PROFILE_RUN 1
#elif (TOTAL_DATA_SIZE==2000)
#define PERFORMANCE_RUN 1
#else
#define VALIDATION_RUN 1
#endif
#endif

#endif
