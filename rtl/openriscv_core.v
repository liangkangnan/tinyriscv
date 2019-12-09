 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
                                                                         
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

`include "defines.v"

// CPU core module
module openriscv_core (

    input wire clk,
    input wire rst

);

    // pc_reg
	wire[`SramAddrBus] pc_pc_o;
	wire pc_re_o;

    // if_id
	wire[`SramBus] if_inst_o;
    wire[`SramAddrBus] if_inst_addr_o;

    // id
    wire id_reg1_re_o;
    wire[`RegAddrBus] id_reg1_raddr_o;
    wire id_reg2_re_o;
    wire[`RegAddrBus] id_reg2_raddr_o;
    wire[`SramBus] id_inst_o;
    wire id_inst_valid_o;
    wire id_reg_we_o;
    wire[`RegAddrBus] id_reg_waddr_o;
    wire id_sram_re_o;
    wire id_sram_we_o;
    wire[`SramAddrBus] id_pc_o;
    wire[`SramAddrBus] id_inst_addr_o;

    // ex
    wire[`RegBus] ex_reg_wdata_o;
    wire[`SramBus] ex_sram_wdata_o;
    wire[`SramAddrBus] ex_sram_raddr_o;
    wire[`SramAddrBus] ex_sram_waddr_o;
    wire ex_jump_flag_o;
    wire[`RegBus] ex_jump_addr_o;

    // regs
    wire[`RegBus] regs_rdata1_o;
    wire[`RegBus] regs_rdata2_o;

    // sim_ram
    wire[`SramBus] ram_pc_rdata_o;
    wire[`SramBus] ram_ex_rdata_o;

    sim_ram u_sim_ram(
        .clk(clk),
        .rst(rst),
        .we_i(id_sram_we_o),
        .waddr_i(ex_sram_waddr_o),
        .wdata_i(ex_sram_wdata_o),
        .pc_re_i(pc_re_o),
        .pc_raddr_i(pc_pc_o),
        .pc_rdata_o(ram_pc_rdata_o),
        .ex_re_i(id_sram_re_o),
        .ex_raddr_i(ex_sram_raddr_o),
        .ex_rdata_o(ram_ex_rdata_o)
    );

    pc_reg u_pc_reg(
        .clk(clk),
        .rst(rst),
        .pc_o(pc_pc_o),
        .re_o(pc_re_o),
        .jump_flag_ex_i(ex_jump_flag_o),
        .jump_addr_ex_i(ex_jump_addr_o)
    );

    regs u_regs(
        .clk(clk),
        .rst(rst),
        .we(id_reg_we_o),
        .waddr(id_reg_waddr_o),
        .wdata(ex_reg_wdata_o),
        .re1(id_reg1_re_o),
        .raddr1(id_reg1_raddr_o),
        .rdata1(regs_rdata1_o),
        .re2(id_reg2_re_o),
        .raddr2(id_reg2_raddr_o),
        .rdata2(regs_rdata2_o)
    );

    if_id u_if_id(
        .clk(clk),
        .rst(rst),
        .inst_i(ram_pc_rdata_o),
        .inst_addr_i(pc_pc_o),
        .inst_o(if_inst_o),
        .inst_addr_o(if_inst_addr_o),
        .jump_flag_ex_i(ex_jump_flag_o)
    );

    id u_id(
        .clk(clk),
        .rst(rst),
        .inst_i(if_inst_o),
        .inst_addr_o(id_inst_addr_o),
        .inst_addr_i(if_inst_addr_o),
        .jump_flag_ex_i(ex_jump_flag_o),
        .reg1_re_o(id_reg1_re_o),
        .reg1_raddr_o(id_reg1_raddr_o),
        .reg2_re_o(id_reg2_re_o),
        .reg2_raddr_o(id_reg2_raddr_o),
        .inst_o(id_inst_o),
        .inst_valid_o(id_inst_valid_o),
        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        .sram_re_o(id_sram_re_o),
        .sram_we_o(id_sram_we_o)
    );

    ex u_ex(
        .clk(clk),
        .rst(rst),
        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),
        .inst_valid_i(id_inst_valid_o),
        .reg1_rdata_i(regs_rdata1_o),
        .reg2_rdata_i(regs_rdata2_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .sram_rdata_i(ram_ex_rdata_o),
        .sram_wdata_o(ex_sram_wdata_o),
        .sram_raddr_o(ex_sram_raddr_o),
        .sram_waddr_o(ex_sram_waddr_o),
        .jump_flag_o(ex_jump_flag_o),
        .jump_addr_o(ex_jump_addr_o)
    );

endmodule
