RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = GAMEtest

#CFLAGS += -DSIMULATION
#CFLAGS += -O2
#ASM_SRCS +=
#LDFLAGS +=

INCLUDES += -I./LCD -I./game -I/PS2


C_SRCS := \
	main.c \
	LCD/lcd.c \
	LCD/lcd_init.c \
	PS2/PS2.c \
	game/snake.c \
	game/game.c \
	game/menu.c \
	game/g2048.c


COMMON_DIR = ..
TOOLCHAIN_DIR = ../../..
include ../common.mk

