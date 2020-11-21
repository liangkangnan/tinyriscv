

SHELL=cmd

export RISCV_TARGET       ?= tinyriscv
export RISCV_PREFIX       ?= ../../../../tools/gnu-mcu-eclipse-riscv-none-gcc-8.2.0-2.2-20190521-0004-win64/bin/riscv-none-embed-

CURDIR = $(shell echo %cd%)

export ROOTDIR    = $(subst \,/,$(CURDIR))
export TARGETDIR ?= $(ROOTDIR)/riscv-target


default: all


all:
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32i RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32i run -C $(ROOTDIR)/riscv-test-suite/rv32i
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32im RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32im run -C $(ROOTDIR)/riscv-test-suite/rv32im
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32Zicsr RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32Zicsr run -C $(ROOTDIR)/riscv-test-suite/rv32Zicsr
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32Zifencei RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32Zifencei run -C $(ROOTDIR)/riscv-test-suite/rv32Zifencei

clean:
	clean -C $(ROOTDIR)/riscv-test-suite/rv32i
	clean -C $(ROOTDIR)/riscv-test-suite/rv32im
	clean -C $(ROOTDIR)/riscv-test-suite/rv32Zicsr
	clean -C $(ROOTDIR)/riscv-test-suite/rv32Zifencei

