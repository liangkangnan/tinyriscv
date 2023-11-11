 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "../core/defines.v"

// tinyriscv soc顶层模块
module tinyriscv_soc_top(

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

    // master 0 interface
    wire[31:0] m0_addr_i;
    wire[31:0] m0_data_i;
    wire[3:0] m0_sel_i;
    wire m0_req_vld_i;
    wire m0_rsp_rdy_i;
    wire m0_we_i;
    wire m0_req_rdy_o;
    wire m0_rsp_vld_o;
    wire[31:0] m0_data_o;

    // master 1 interface
    wire[31:0] m1_addr_i;
    wire[31:0] m1_data_i;
    wire[3:0] m1_sel_i;
    wire m1_req_vld_i;
    wire m1_rsp_rdy_i;
    wire m1_we_i;
    wire m1_req_rdy_o;
    wire m1_rsp_vld_o;
    wire[31:0] m1_data_o;

    // master 2 interface
    wire[31:0] m2_addr_i;
    wire[31:0] m2_data_i;
    wire[3:0] m2_sel_i;
    wire m2_req_vld_i;
    wire m2_rsp_rdy_i;
    wire m2_we_i;
    wire m2_req_rdy_o;
    wire m2_rsp_vld_o;
    wire[31:0] m2_data_o;

    // master 3 interface
    wire[31:0] m3_addr_i;
    wire[31:0] m3_data_i;
    wire[3:0] m3_sel_i;
    wire m3_req_vld_i;
    wire m3_rsp_rdy_i;
    wire m3_we_i;
    wire m3_req_rdy_o;
    wire m3_rsp_vld_o;
    wire[31:0] m3_data_o;

    // slave 0 interface
    wire[31:0] s0_data_i;
    wire s0_req_rdy_i;
    wire s0_rsp_vld_i;
    wire[31:0] s0_addr_o;
    wire[31:0] s0_data_o;
    wire[3:0] s0_sel_o;
    wire s0_req_vld_o;
    wire s0_rsp_rdy_o;
    wire s0_we_o;

    // slave 1 interface
    wire[31:0] s1_data_i;
    wire s1_req_rdy_i;
    wire s1_rsp_vld_i;
    wire[31:0] s1_addr_o;
    wire[31:0] s1_data_o;
    wire[3:0] s1_sel_o;
    wire s1_req_vld_o;
    wire s1_rsp_rdy_o;
    wire s1_we_o;

    // slave 2 interface
    wire[31:0] s2_data_i;
    wire s2_req_rdy_i;
    wire s2_rsp_vld_i;
    wire[31:0] s2_addr_o;
    wire[31:0] s2_data_o;
    wire[3:0] s2_sel_o;
    wire s2_req_vld_o;
    wire s2_rsp_rdy_o;
    wire s2_we_o;

    // slave 3 interface
    wire[31:0] s3_data_i;
    wire s3_req_rdy_i;
    wire s3_rsp_vld_i;
    wire[31:0] s3_addr_o;
    wire[31:0] s3_data_o;
    wire[3:0] s3_sel_o;
    wire s3_req_vld_o;
    wire s3_rsp_rdy_o;
    wire s3_we_o;

    // slave 4 interface
    wire[31:0] s4_data_i;
    wire s4_req_rdy_i;
    wire s4_rsp_vld_i;
    wire[31:0] s4_addr_o;
    wire[31:0] s4_data_o;
    wire[3:0] s4_sel_o;
    wire s4_req_vld_o;
    wire s4_rsp_rdy_o;
    wire s4_we_o;

    // jtag
    wire jtag_halt_req_o;
    wire jtag_reset_req_o;
    wire[4:0] jtag_reg_addr_o;
    wire[31:0] jtag_reg_data_o;
    wire jtag_reg_we_o;
    wire[31:0] jtag_reg_data_i;

    // tinyriscv
    wire[`INT_WIDTH-1:0] int_flag;
    wire rst_n;
    wire jtag_rst_n;

    // timer0
    wire timer0_int;

    // gpio
    wire[1:0] io_in;
    wire[31:0] gpio_ctrl;
    wire[31:0] gpio_data;

    assign int_flag = {{(`INT_WIDTH-1){1'b0}}, timer0_int};

    // 复位控制模块例化
    rst_ctrl u_rst_ctrl(
        .clk(clk),
        .rst_ext_i(rst_ext_i),
        .rst_jtag_i(jtag_reset_req_o),
        .core_rst_n_o(rst_n),
        .jtag_rst_n_o(jtag_rst_n)
    );

    // 低电平点亮LED
    // 低电平表示已经halt住CPU
    assign halted_ind = ~jtag_halt_req_o;

    // tinyriscv处理器核模块例化
    tinyriscv_core u_tinyriscv_core(
        .clk(clk),
        .rst_n(rst_n),

        // 指令总线
        .ibus_addr_o(m0_addr_i),
        .ibus_data_i(m0_data_o),
        .ibus_data_o(m0_data_i),
        .ibus_we_o(m0_we_i),
        .ibus_sel_o(m0_sel_i),
        .ibus_req_valid_o(m0_req_vld_i),
        .ibus_req_ready_i(m0_req_rdy_o),
        .ibus_rsp_valid_i(m0_rsp_vld_o),
        .ibus_rsp_ready_o(m0_rsp_rdy_i),

        // 数据总线
        .dbus_addr_o(m1_addr_i),
        .dbus_data_i(m1_data_o),
        .dbus_data_o(m1_data_i),
        .dbus_we_o(m1_we_i),
        .dbus_sel_o(m1_sel_i),
        .dbus_req_valid_o(m1_req_vld_i),
        .dbus_req_ready_i(m1_req_rdy_o),
        .dbus_rsp_valid_i(m1_rsp_vld_o),
        .dbus_rsp_ready_o(m1_rsp_rdy_i),

        .jtag_halt_i(jtag_halt_req_o),
        .int_i(int_flag)
    );

    // 指令存储器
    rom #(
        .DP(`ROM_DEPTH)
    ) u_rom(
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(s0_addr_o),
        .data_i(s0_data_o),
        .sel_i(s0_sel_o),
        .we_i(s0_we_o),
        .data_o(s0_data_i),
        .req_valid_i(s0_req_vld_o),
        .req_ready_o(s0_req_rdy_i),
        .rsp_valid_o(s0_rsp_vld_i),
        .rsp_ready_i(s0_rsp_rdy_o)
    );

    // 数据存储器
    ram #(
        .DP(`RAM_DEPTH)
    ) u_ram(
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(s1_addr_o),
        .data_i(s1_data_o),
        .sel_i(s1_sel_o),
        .we_i(s1_we_o),
        .data_o(s1_data_i),
        .req_valid_i(s1_req_vld_o),
        .req_ready_o(s1_req_rdy_i),
        .rsp_valid_o(s1_rsp_vld_i),
        .rsp_ready_i(s1_rsp_rdy_o)
    );

    // timer模块例化
    timer timer_0(
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(s2_addr_o),
        .data_i(s2_data_o),
        .sel_i(s2_sel_o),
        .we_i(s2_we_o),
        .data_o(s2_data_i),
        .req_valid_i(s2_req_vld_o),
        .req_ready_o(s2_req_rdy_i),
        .rsp_valid_o(s2_rsp_vld_i),
        .rsp_ready_i(s2_rsp_rdy_o),
        .int_sig_o(timer0_int)
    );

    // uart模块例化
    uart uart_0(
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(s3_addr_o),
        .data_i(s3_data_o),
        .sel_i(s3_sel_o),
        .we_i(s3_we_o),
        .data_o(s3_data_i),
        .req_valid_i(s3_req_vld_o),
        .req_ready_o(s3_req_rdy_i),
        .rsp_valid_o(s3_rsp_vld_i),
        .rsp_ready_i(s3_rsp_rdy_o),
        .tx_pin(uart_tx_pin),
        .rx_pin(uart_rx_pin)
    );

    // io0
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
    assign io_in[0] = gpio[0];
    // io1
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
    assign io_in[1] = gpio[1];

    // gpio模块例化
    gpio gpio_0(
        .clk(clk),
        .rst_n(rst_n),
        .addr_i(s4_addr_o),
        .data_i(s4_data_o),
        .sel_i(s4_sel_o),
        .we_i(s4_we_o),
        .data_o(s4_data_i),
        .req_valid_i(s4_req_vld_o),
        .req_ready_o(s4_req_rdy_i),
        .rsp_valid_o(s4_rsp_vld_i),
        .rsp_ready_i(s4_rsp_rdy_o),
        .io_pin_i(io_in),
        .reg_ctrl(gpio_ctrl),
        .reg_data(gpio_data)
    );

    // jtag模块例化
    jtag_top #(
        .DMI_ADDR_BITS(6),
        .DMI_DATA_BITS(32),
        .DMI_OP_BITS(2)
    ) u_jtag_top(
        .clk(clk),
        .jtag_rst_n(jtag_rst_n),
        .jtag_pin_TCK(jtag_TCK),
        .jtag_pin_TMS(jtag_TMS),
        .jtag_pin_TDI(jtag_TDI),
        .jtag_pin_TDO(jtag_TDO),
        .reg_we_o(jtag_reg_we_o),
        .reg_addr_o(jtag_reg_addr_o),
        .reg_wdata_o(jtag_reg_data_o),
        .reg_rdata_i(jtag_reg_data_i),
        .mem_we_o(m2_we_i),
        .mem_addr_o(m2_addr_i),
        .mem_wdata_o(m2_data_i),
        .mem_rdata_i(m2_data_o),
        .mem_sel_o(m2_sel_i),
        .req_valid_o(m2_req_vld_i),
        .req_ready_i(m2_req_rdy_o),
        .rsp_valid_i(m2_rsp_vld_o),
        .rsp_ready_o(m2_rsp_rdy_i),
        .halt_req_o(jtag_halt_req_o),
        .reset_req_o(jtag_reset_req_o)
    );

    // rib总线模块例化
    rib #(
        .MASTER_NUM(3),
        .SLAVE_NUM(5)
    ) u_rib(
        .clk(clk),
        .rst_n(rst_n),

        // master 0 interface
        .m0_addr_i(m0_addr_i),
        .m0_data_i(m0_data_i),
        .m0_sel_i(m0_sel_i),
        .m0_req_vld_i(m0_req_vld_i),
        .m0_rsp_rdy_i(m0_rsp_rdy_i),
        .m0_we_i(m0_we_i),
        .m0_req_rdy_o(m0_req_rdy_o),
        .m0_rsp_vld_o(m0_rsp_vld_o),
        .m0_data_o(m0_data_o),

        // master 1 interface
        .m1_addr_i(m1_addr_i),
        .m1_data_i(m1_data_i),
        .m1_sel_i(m1_sel_i),
        .m1_req_vld_i(m1_req_vld_i),
        .m1_rsp_rdy_i(m1_rsp_rdy_i),
        .m1_we_i(m1_we_i),
        .m1_req_rdy_o(m1_req_rdy_o),
        .m1_rsp_vld_o(m1_rsp_vld_o),
        .m1_data_o(m1_data_o),

        // master 2 interface
        .m2_addr_i(m2_addr_i),
        .m2_data_i(m2_data_i),
        .m2_sel_i(m2_sel_i),
        .m2_req_vld_i(m2_req_vld_i),
        .m2_rsp_rdy_i(m2_rsp_rdy_i),
        .m2_we_i(m2_we_i),
        .m2_req_rdy_o(m2_req_rdy_o),
        .m2_rsp_vld_o(m2_rsp_vld_o),
        .m2_data_o(m2_data_o),

        // master 3 interface
        .m3_addr_i(m3_addr_i),
        .m3_data_i(m3_data_i),
        .m3_sel_i(m3_sel_i),
        .m3_req_vld_i(m3_req_vld_i),
        .m3_rsp_rdy_i(m3_rsp_rdy_i),
        .m3_we_i(m3_we_i),
        .m3_req_rdy_o(m3_req_rdy_o),
        .m3_rsp_vld_o(m3_rsp_vld_o),
        .m3_data_o(m3_data_o),

        // slave 0 interface
        .s0_data_i(s0_data_i),
        .s0_req_rdy_i(s0_req_rdy_i),
        .s0_rsp_vld_i(s0_rsp_vld_i),
        .s0_addr_o(s0_addr_o),
        .s0_data_o(s0_data_o),
        .s0_sel_o(s0_sel_o),
        .s0_req_vld_o(s0_req_vld_o),
        .s0_rsp_rdy_o(s0_rsp_rdy_o),
        .s0_we_o(s0_we_o),

        // slave 1 interface
        .s1_data_i(s1_data_i),
        .s1_req_rdy_i(s1_req_rdy_i),
        .s1_rsp_vld_i(s1_rsp_vld_i),
        .s1_addr_o(s1_addr_o),
        .s1_data_o(s1_data_o),
        .s1_sel_o(s1_sel_o),
        .s1_req_vld_o(s1_req_vld_o),
        .s1_rsp_rdy_o(s1_rsp_rdy_o),
        .s1_we_o(s1_we_o),

        // slave 2 interface
        .s2_data_i(s2_data_i),
        .s2_req_rdy_i(s2_req_rdy_i),
        .s2_rsp_vld_i(s2_rsp_vld_i),
        .s2_addr_o(s2_addr_o),
        .s2_data_o(s2_data_o),
        .s2_sel_o(s2_sel_o),
        .s2_req_vld_o(s2_req_vld_o),
        .s2_rsp_rdy_o(s2_rsp_rdy_o),
        .s2_we_o(s2_we_o),

        // slave 3 interface
        .s3_data_i(s3_data_i),
        .s3_req_rdy_i(s3_req_rdy_i),
        .s3_rsp_vld_i(s3_rsp_vld_i),
        .s3_addr_o(s3_addr_o),
        .s3_data_o(s3_data_o),
        .s3_sel_o(s3_sel_o),
        .s3_req_vld_o(s3_req_vld_o),
        .s3_rsp_rdy_o(s3_rsp_rdy_o),
        .s3_we_o(s3_we_o),

        // slave 4 interface
        .s4_data_i(s4_data_i),
        .s4_req_rdy_i(s4_req_rdy_i),
        .s4_rsp_vld_i(s4_rsp_vld_i),
        .s4_addr_o(s4_addr_o),
        .s4_data_o(s4_data_o),
        .s4_sel_o(s4_sel_o),
        .s4_req_vld_o(s4_req_vld_o),
        .s4_rsp_rdy_o(s4_rsp_rdy_o),
        .s4_we_o(s4_we_o)
    );

endmodule
