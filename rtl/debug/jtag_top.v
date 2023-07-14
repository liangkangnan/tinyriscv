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

// JTAG顶层模块
module jtag_top #(
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2)(

    input wire clk,
    input wire jtag_rst_n,

    input wire jtag_pin_TCK,
    input wire jtag_pin_TMS,
    input wire jtag_pin_TDI,
    output wire jtag_pin_TDO,

    output wire reg_we_o,
    output wire[4:0] reg_addr_o,
    output wire[31:0] reg_wdata_o,
    input wire[31:0] reg_rdata_i,

    output wire mem_we_o,
    output wire[31:0] mem_addr_o,
    output wire[31:0] mem_wdata_o,
    input wire[31:0] mem_rdata_i,
    output wire[3:0] mem_sel_o,

    output wire req_valid_o,
    input wire req_ready_i,
    input wire rsp_valid_i,
    output wire rsp_ready_o,

    output wire halt_req_o,
    output wire reset_req_o

    );

    parameter DM_RESP_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;

    // jtag_driver输出信号
    wire dtm_ack_o;
    wire dtm_req_valid_o;
    wire[DTM_REQ_BITS - 1:0] dtm_req_data_o;

    // jtag_dm输出信号
    wire dm_ack_o;
    wire[DM_RESP_BITS-1:0] dm_resp_data_o;
    wire dm_resp_valid_o;
    wire dm_halt_req_o;
    wire dm_reset_req_o;

    jtag_driver #(
        .DMI_ADDR_BITS(DMI_ADDR_BITS),
        .DMI_DATA_BITS(DMI_DATA_BITS),
        .DMI_OP_BITS(DMI_OP_BITS)
    ) u_jtag_driver(
        .rst_n(jtag_rst_n),
        .jtag_TCK(jtag_pin_TCK),
        .jtag_TDI(jtag_pin_TDI),
        .jtag_TMS(jtag_pin_TMS),
        .jtag_TDO(jtag_pin_TDO),
        .dm_resp_i(dm_resp_valid_o),
        .dm_resp_data_i(dm_resp_data_o),
        .dtm_ack_o(dtm_ack_o),
        .dm_ack_i(dm_ack_o),
        .dtm_req_valid_o(dtm_req_valid_o),
        .dtm_req_data_o(dtm_req_data_o)
    );

    jtag_dm #(
        .DMI_ADDR_BITS(DMI_ADDR_BITS),
        .DMI_DATA_BITS(DMI_DATA_BITS),
        .DMI_OP_BITS(DMI_OP_BITS)
    ) u_jtag_dm(
        .clk(clk),
        .rst_n(jtag_rst_n),
        .dm_ack_o(dm_ack_o),
        .dtm_req_valid_i(dtm_req_valid_o),
        .dtm_req_data_i(dtm_req_data_o),
        .dtm_ack_i(dtm_ack_o),
        .dm_resp_data_o(dm_resp_data_o),
        .dm_resp_valid_o(dm_resp_valid_o),
        .dm_reg_we_o(reg_we_o),
        .dm_reg_addr_o(reg_addr_o),
        .dm_reg_wdata_o(reg_wdata_o),
        .dm_reg_rdata_i(reg_rdata_i),
        .dm_mem_we_o(mem_we_o),
        .dm_mem_addr_o(mem_addr_o),
        .dm_mem_wdata_o(mem_wdata_o),
        .dm_mem_rdata_i(mem_rdata_i),
        .dm_mem_sel_o(mem_sel_o),
        .req_valid_o(req_valid_o),
        .req_ready_i(req_ready_i),
        .rsp_valid_i(rsp_valid_i),
        .rsp_ready_o(rsp_ready_o),
        .dm_halt_req_o(halt_req_o),
        .dm_reset_req_o(reset_req_o)
    );

endmodule
