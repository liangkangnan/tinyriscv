..\tools\BinToMem_CLI.exe %1 %2
iverilog -s openriscv_core_tb -o out.vvp -I ..\rtl openriscv_core_tb.v ..\rtl\defines.v ..\rtl\ex.v ..\rtl\id.v ..\rtl\openriscv_core.v ..\rtl\pc_reg.v ..\rtl\regs.v ..\rtl\sim_ram.v ..\rtl\if_id.v
vvp out.vvp
