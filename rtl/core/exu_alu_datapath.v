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

`include "defines.v"


`define DATAPATH_MUX_WIDTH  (32+32+16)


module exu_alu_datapath(

    input wire clk,
    input wire rst_n,

    // ALU
    input wire req_alu_i,
    input wire[31:0] alu_op1_i,
    input wire[31:0] alu_op2_i,
    input wire alu_op_add_i,
    input wire alu_op_sub_i,
    input wire alu_op_sll_i,
    input wire alu_op_slt_i,
    input wire alu_op_sltu_i,
    input wire alu_op_xor_i,
    input wire alu_op_srl_i,
    input wire alu_op_sra_i,
    input wire alu_op_or_i,
    input wire alu_op_and_i,

    // BJP
    input wire req_bjp_i,
    input wire[31:0] bjp_op1_i,
    input wire[31:0] bjp_op2_i,
    input wire bjp_op_beq_i,
    input wire bjp_op_bne_i,
    input wire bjp_op_blt_i,
    input wire bjp_op_bltu_i,
    input wire bjp_op_bge_i,
    input wire bjp_op_bgeu_i,
    input wire bjp_op_jump_i,
    input wire[31:0] bjp_jump_op1_i,
    input wire[31:0] bjp_jump_op2_i,

    // MEM
    input wire req_mem_i,
    input wire[31:0] mem_op1_i,
    input wire[31:0] mem_op2_i,

    // CSR
    input wire req_csr_i,
    input wire[31:0] csr_op1_i,
    input wire[31:0] csr_op2_i,
    input wire csr_csrrw_i,
    input wire csr_csrrs_i,
    input wire csr_csrrc_i,

    output wire[31:0] alu_res_o,
    output wire[31:0] bjp_res_o,
    output wire bjp_cmp_res_o

    );

    wire[31:0] mux_op1;
    wire[31:0] mux_op2;
    wire op_add;
    wire op_sub;
    wire op_sll;
    wire op_slt;
    wire op_sltu;
    wire op_xor;
    wire op_srl;
    wire op_sra;
    wire op_or;
    wire op_and;
    wire op_beq;
    wire op_bne;
    wire op_blt;
    wire op_bltu;
    wire op_bge;
    wire op_bgeu;

    // 异或
    wire[31:0] xor_res = mux_op1 ^ mux_op2;
    // 或
    wire[31:0] or_res = mux_op1 | mux_op2;
    // 与
    wire[31:0] and_res = mux_op1 & mux_op2;
    // 加、减
    wire[31:0] add_op1 = req_bjp_i? bjp_jump_op1_i: mux_op1;
    wire[31:0] add_op2 = req_bjp_i? bjp_jump_op2_i: mux_op2;
    wire[31:0] add_sub_res = add_op1 + (op_sub? (-add_op2): add_op2);
    // 左移
    wire[31:0] sll_res = mux_op1 << mux_op2[4:0];
    // 逻辑右移
    wire[31:0] srl_res = mux_op1 >> mux_op2[4:0];
    // 算数右移
    wire[31:0] sr_shift_mask = 32'hffffffff >> mux_op2[4:0];
    wire[31:0] sra_res = (srl_res & sr_shift_mask) | ({32{mux_op1[31]}} & (~sr_shift_mask));

    // 有符号数比较
    wire op1_ge_op2_signed = ($signed(mux_op1) >= $signed(mux_op2));
    // 无符号数比较
    wire op1_ge_op2_unsigned = (mux_op1 >= mux_op2);

    wire op1_neq_op2 = (|xor_res);
    wire op1_eq_op2 = (~op1_neq_op2);

    wire cmp_res_eq = op_beq & op1_eq_op2;
    wire cmp_res_neq = op_bne & op1_neq_op2;
    wire cmp_res_lt = op_blt & (~op1_ge_op2_signed);
    wire cmp_res_ltu = op_bltu & (~op1_ge_op2_unsigned);
    wire cmp_res_gt = op_bge & op1_ge_op2_signed;
    wire cmp_res_gtu = op_bgeu & op1_ge_op2_unsigned;

    wire[31:0] slt_res = (~op1_ge_op2_signed)? 32'h1: 32'h0;
    wire[31:0] sltu_res = (~op1_ge_op2_unsigned)? 32'h1: 32'h0;

    reg[31:0] alu_datapath_res;

    always @ (*) begin
        alu_datapath_res = 32'h0;
        case (1'b1)
            op_xor:  alu_datapath_res = xor_res;
            op_or:   alu_datapath_res = or_res;
            op_and:  alu_datapath_res = and_res;
            op_add:  alu_datapath_res = add_sub_res;
            op_sub:  alu_datapath_res = add_sub_res;
            op_sll:  alu_datapath_res = sll_res;
            op_srl:  alu_datapath_res = srl_res;
            op_sra:  alu_datapath_res = sra_res;
            op_slt:  alu_datapath_res = slt_res;
            op_sltu: alu_datapath_res = sltu_res;
        endcase
    end

    assign alu_res_o = alu_datapath_res;

    assign bjp_res_o = alu_datapath_res;

    assign bjp_cmp_res_o = cmp_res_eq | cmp_res_neq | cmp_res_lt | cmp_res_ltu | cmp_res_gt | cmp_res_gtu;

    assign {mux_op1,
            mux_op2,
            op_add,
            op_sub,
            op_sll,
            op_slt,
            op_sltu,
            op_xor,
            op_srl,
            op_sra,
            op_or,
            op_and,
            op_beq,
            op_bne,
            op_blt,
            op_bltu,
            op_bge,
            op_bgeu
            } = ({`DATAPATH_MUX_WIDTH{req_alu_i}} & {
                  alu_op1_i,
                  alu_op2_i,
                  alu_op_add_i,
                  alu_op_sub_i,
                  alu_op_sll_i,
                  alu_op_slt_i,
                  alu_op_sltu_i,
                  alu_op_xor_i,
                  alu_op_srl_i,
                  alu_op_sra_i,
                  alu_op_or_i,
                  alu_op_and_i,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0
                 }) |
                ({`DATAPATH_MUX_WIDTH{req_bjp_i}} & {
                  bjp_op1_i,
                  bjp_op2_i,
                  1'b1,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  bjp_op_beq_i,
                  bjp_op_bne_i,
                  bjp_op_blt_i,
                  bjp_op_bltu_i,
                  bjp_op_bge_i,
                  bjp_op_bgeu_i
                 }) |
                ({`DATAPATH_MUX_WIDTH{req_mem_i}} & {
                  mem_op1_i,
                  mem_op2_i,
                  1'b1,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0
                 }) |
                ({`DATAPATH_MUX_WIDTH{req_csr_i}} & {
                  csr_op1_i,
                  csr_op2_i,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  csr_csrrw_i | csr_csrrs_i,
                  csr_csrrc_i,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0,
                  1'b0
                 });

endmodule
