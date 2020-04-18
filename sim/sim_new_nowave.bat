..\tools\BinToMem_CLI.exe %1 %2
iverilog -s tinyriscv_soc_tb -o out.vvp -I ..\rtl\core tinyriscv_soc_tb.v ..\rtl\core\defines.v ..\rtl\core\ex.v ..\rtl\core\id.v ..\rtl\core\tinyriscv.v ..\rtl\core\pc_reg.v ..\rtl\core\id_ex.v ..\rtl\core\ctrl.v ..\rtl\core\regs.v ..\rtl\perips\ram.v ..\rtl\perips\rom.v ..\rtl\core\if_id.v ..\rtl\core\div.v ..\rtl\core\rib.v ..\rtl\core\clint.v ..\rtl\core\csr_reg.v ..\rtl\debug\jtag_dm.v ..\rtl\debug\jtag_driver.v ..\rtl\debug\jtag_top.v ..\rtl\perips\timer.v ..\rtl\perips\uart_tx.v ..\rtl\perips\gpio.v ..\rtl\soc\tinyriscv_soc_top.v
vvp out.vvp
