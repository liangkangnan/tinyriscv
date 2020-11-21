RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = timer_int


CFLAGS += -DSIMULATION
#CFLAGS += -Os
#ASM_SRCS +=
#LDFLAGS +=
#INCLUDES += -I.

C_SRCS := \
	main.c \


COMMON_DIR = ../../bsp
TOOLCHAIN_DIR = ../../..
include ../../bsp/common.mk
