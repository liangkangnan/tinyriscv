
RISCV_TOOLS_PATH := $(TOOLCHAIN_DIR)/tools/gnu-mcu-eclipse-riscv-none-gcc-8.2.0-2.2-20190521-0004-win64/bin
RISCV_TOOLS_PREFIX := riscv-none-embed-

RISCV_GCC     := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)gcc)
RISCV_AS      := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)as)
RISCV_GXX     := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)g++)
RISCV_OBJDUMP := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)objdump)
RISCV_GDB     := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)gdb)
RISCV_AR      := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)ar)
RISCV_OBJCOPY := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)objcopy)
RISCV_READELF := $(abspath $(RISCV_TOOLS_PATH)/$(RISCV_TOOLS_PREFIX)readelf)

.PHONY: all
all: $(TARGET)

ASM_SRCS += $(COMMON_DIR)/start.S
ASM_SRCS += $(COMMON_DIR)/trap_entry.S
C_SRCS += $(COMMON_DIR)/init.c
C_SRCS += $(COMMON_DIR)/trap_handler.c
C_SRCS += $(COMMON_DIR)/lib/utils.c
C_SRCS += $(COMMON_DIR)/lib/xprintf.c
C_SRCS += $(COMMON_DIR)/lib/uart.c

LINKER_SCRIPT := $(COMMON_DIR)/link.lds

INCLUDES += -I$(COMMON_DIR)

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles -Wl,--gc-sections -Wl,--check-sections

ASM_OBJS := $(ASM_SRCS:.S=.o)
C_OBJS := $(C_SRCS:.c=.o)

LINK_OBJS += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(TARGET).dump $(TARGET).bin

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -mcmodel=$(RISCV_MCMODEL) -ffunction-sections -fdata-sections -fno-builtin-printf -fno-builtin-malloc

$(TARGET): $(LINK_OBJS) $(LINK_DEPS) Makefile
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	$(RISCV_OBJCOPY) -O binary $@ $@.bin
	$(RISCV_OBJDUMP) --disassemble-all $@ > $@.dump

$(ASM_OBJS): %.o: %.S
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(CLEAN_OBJS)
