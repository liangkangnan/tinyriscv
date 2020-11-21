RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = freertos


# RTL仿真时打开这行注释
#CFLAGS += -DSIMULATION
CFLAGS += -Os
ASM_SRCS := ../../Source/portable/RISC-V/portASM.S
#LDFLAGS +=
INCLUDES += -I. -I../../Source/portable/RISC-V -I../../Source/include -I../../../

C_SRCS := \
	main.c \
	./blinky_demo/main_blinky.c \
	../../Source/list.c \
	../../Source/tasks.c \
	../../Source/queue.c \
	../../Source/portable/MemMang/heap_1.c \
	../../Source/portable/RISC-V/port.c \


COMMON_DIR = ../../..
TOOLCHAIN_DIR = ../../../../..
include ../../../common.mk
