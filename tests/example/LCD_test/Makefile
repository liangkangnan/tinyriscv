RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = LCD_test

#CFLAGS += -DSIMULATION
#CFLAGS += -O2
#ASM_SRCS +=
#LDFLAGS +=

INCLUDES += -I ./LCD


C_SRCS := \
	main.c \
	LCD/lcd.c \
	LCD/lcd_init.c \


COMMON_DIR = ..
TOOLCHAIN_DIR = ../../..
include ../common.mk

