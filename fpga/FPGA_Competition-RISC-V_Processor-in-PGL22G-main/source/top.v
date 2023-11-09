module top(
    input wire clk,
    input wire rst_ext_i,

    output wire halted_ind,  // jtag是否已经halt住CPU信号

    output wire uart_tx_pin, // UART发送引脚
    input wire uart_rx_pin,  // UART接收引脚

    inout wire[1:0] gpio,    // GPIO引脚

    input wire jtag_TCK,     // JTAG TCK引脚
    input wire jtag_TMS,     // JTAG TMS引脚
    input wire jtag_TDI,     // JTAG TDI引脚
    output wire jtag_TDO     // JTAG TDO引脚

   );
wire clkin;
tinyriscv_soc_top l1 (
    .clk(clkin1),
    .rst_ext_i(rst_ext_i),
    .halted_ind(halted_ind),
    .uart_tx_pin(uart_tx_pin),
    .uart_rx_pin(uart_rx_pin),
    .gpio(gpio),
    .jtag_TCK(jtag_TCK),
    .jtag_TMS(jtag_TMS),
    .jtag_TDI(jtag_TDI),
    .jtag_TDO(jtag_TDO)
    );
pll pll1(
    .clkin1(clk),
    .pll_lock(),
    .clkout0(clkin1)
);
endmodule