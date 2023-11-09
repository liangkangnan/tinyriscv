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


module exu_dispatch(

    input wire clk,
    input wire rst_n,

    input wire[`DECINFO_WIDTH-1:0] dec_info_bus_i,
    input wire[31:0] dec_imm_i,
    input wire[31:0] dec_pc_i,
    input wire[31:0] rs1_rdata_i,
    input wire[31:0] rs2_rdata_i,

    // dispatch to ALU
    output wire req_alu_o,
    output wire[31:0] alu_op1_o,
    output wire[31:0] alu_op2_o,
    output wire alu_op_lui_o,
    output wire alu_op_auipc_o,
    output wire alu_op_add_o,
    output wire alu_op_sub_o,
    output wire alu_op_sll_o,
    output wire alu_op_slt_o,
    output wire alu_op_sltu_o,
    output wire alu_op_xor_o,
    output wire alu_op_srl_o,
    output wire alu_op_sra_o,
    output wire alu_op_or_o,
    output wire alu_op_and_o,

    // dispatch to BJP
    output wire req_bjp_o,
    output wire[31:0] bjp_op1_o,
    output wire[31:0] bjp_op2_o,
    output wire[31:0] bjp_jump_op1_o,
    output wire[31:0] bjp_jump_op2_o,
    output wire bjp_op_jump_o,
    output wire bjp_op_beq_o,
    output wire bjp_op_bne_o,
    output wire bjp_op_blt_o,
    output wire bjp_op_bltu_o,
    output wire bjp_op_bge_o,
    output wire bjp_op_bgeu_o,

    // dispatch to MULDIV
    output wire req_muldiv_o,
    output wire[31:0] muldiv_op1_o,
    output wire[31:0] muldiv_op2_o,
    output wire muldiv_op_mul_o,
    output wire muldiv_op_mulh_o,
    output wire muldiv_op_mulhsu_o,
    output wire muldiv_op_mulhu_o,
    output wire muldiv_op_div_o,
    output wire muldiv_op_divu_o,
    output wire muldiv_op_rem_o,
    output wire muldiv_op_remu_o,

    // dispatch to CSR
    output wire req_csr_o,
    output wire[31:0] csr_op1_o,
    output wire[31:0] csr_addr_o,
    output wire csr_csrrw_o,
    output wire csr_csrrs_o,
    output wire csr_csrrc_o,

    // dispatch to MEM
    output wire req_mem_o,
    output wire[31:0] mem_op1_o,
    output wire[31:0] mem_op2_o,
    output wire[31:0] mem_rs2_data_o,
    output wire mem_op_lb_o,
    output wire mem_op_lh_o,
    output wire mem_op_lw_o,
    output wire mem_op_lbu_o,
    output wire mem_op_lhu_o,
    output wire mem_op_sb_o,
    output wire mem_op_sh_o,
    output wire mem_op_sw_o,

    // dispatch to SYS
    output wire sys_op_nop_o,
    output wire sys_op_mret_o,
    output wire sys_op_ecall_o,
    output wire sys_op_ebreak_o,
    output wire sys_op_fence_o

    );

    wire[`DECINFO_GRP_WIDTH-1:0] disp_info_grp = dec_info_bus_i[`DECINFO_GRP_BUS];

    // ALU info
    wire op_alu = (disp_info_grp == `DECINFO_GRP_ALU);
    wire[`DECINFO_WIDTH-1:0] alu_info = {`DECINFO_WIDTH{op_alu}} & dec_info_bus_i;
    // ALU op1
    wire alu_op1_pc = alu_info[`DECINFO_ALU_OP1PC];
    wire alu_op1_zero = alu_info[`DECINFO_ALU_LUI];
    wire[31:0] alu_op1 = alu_op1_pc? dec_pc_i: alu_op1_zero? 32'h0: rs1_rdata_i;
    assign alu_op1_o = op_alu? alu_op1: 32'h0;
    // ALU op2
    wire alu_op2_imm = alu_info[`DECINFO_ALU_OP2IMM];
    wire[31:0] alu_op2 = alu_op2_imm? dec_imm_i: rs2_rdata_i;
    assign alu_op2_o = op_alu? alu_op2: 32'h0;
    assign alu_op_lui_o = alu_info[`DECINFO_ALU_LUI];
    assign alu_op_auipc_o = alu_info[`DECINFO_ALU_AUIPC];
    assign alu_op_add_o = alu_info[`DECINFO_ALU_ADD];
    assign alu_op_sub_o = alu_info[`DECINFO_ALU_SUB];
    assign alu_op_sll_o = alu_info[`DECINFO_ALU_SLL];
    assign alu_op_slt_o = alu_info[`DECINFO_ALU_SLT];
    assign alu_op_sltu_o = alu_info[`DECINFO_ALU_SLTU];
    assign alu_op_xor_o = alu_info[`DECINFO_ALU_XOR];
    assign alu_op_srl_o = alu_info[`DECINFO_ALU_SRL];
    assign alu_op_sra_o = alu_info[`DECINFO_ALU_SRA];
    assign alu_op_or_o = alu_info[`DECINFO_ALU_OR];
    assign alu_op_and_o = alu_info[`DECINFO_ALU_AND];
    assign req_alu_o = op_alu;

    // BJP info
    wire op_bjp = (disp_info_grp == `DECINFO_GRP_BJP);
    wire[`DECINFO_WIDTH-1:0] bjp_info = {`DECINFO_WIDTH{op_bjp}} & dec_info_bus_i;
    // BJP op1
    wire bjp_op1_rs1 = bjp_info[`DECINFO_BJP_OP1RS1];
    wire[31:0] bjp_op1 = bjp_op1_rs1? rs1_rdata_i: dec_pc_i;
    assign bjp_jump_op1_o = op_bjp? bjp_op1: 32'h0;
    // BJP op2
    wire[31:0] bjp_op2 = dec_imm_i;
    assign bjp_jump_op2_o = op_bjp? bjp_op2: 32'h0;
    assign bjp_op1_o = op_bjp? rs1_rdata_i: 32'h0;
    assign bjp_op2_o = op_bjp? rs2_rdata_i: 32'h0;
    assign bjp_op_jump_o = bjp_info[`DECINFO_BJP_JUMP];
    assign bjp_op_beq_o = bjp_info[`DECINFO_BJP_BEQ];
    assign bjp_op_bne_o = bjp_info[`DECINFO_BJP_BNE];
    assign bjp_op_blt_o = bjp_info[`DECINFO_BJP_BLT];
    assign bjp_op_bltu_o = bjp_info[`DECINFO_BJP_BLTU];
    assign bjp_op_bge_o = bjp_info[`DECINFO_BJP_BGE];
    assign bjp_op_bgeu_o = bjp_info[`DECINFO_BJP_BGEU];
    assign req_bjp_o = op_bjp;

    // MULDIV info
    wire op_muldiv = (disp_info_grp == `DECINFO_GRP_MULDIV);
    wire[`DECINFO_WIDTH-1:0] muldiv_info = {`DECINFO_WIDTH{op_muldiv}} & dec_info_bus_i;
    // MULDIV op1
    assign muldiv_op1_o = op_muldiv? rs1_rdata_i: 32'h0;
    // MULDIV op2
    assign muldiv_op2_o = op_muldiv? rs2_rdata_i: 32'h0;
    assign muldiv_op_mul_o = muldiv_info[`DECINFO_MULDIV_MUL];
    assign muldiv_op_mulh_o = muldiv_info[`DECINFO_MULDIV_MULH];
    assign muldiv_op_mulhu_o = muldiv_info[`DECINFO_MULDIV_MULHU];
    assign muldiv_op_mulhsu_o = muldiv_info[`DECINFO_MULDIV_MULHSU];
    assign muldiv_op_div_o = muldiv_info[`DECINFO_MULDIV_DIV];
    assign muldiv_op_divu_o = muldiv_info[`DECINFO_MULDIV_DIVU];
    assign muldiv_op_rem_o = muldiv_info[`DECINFO_MULDIV_REM];
    assign muldiv_op_remu_o = muldiv_info[`DECINFO_MULDIV_REMU];
    assign req_muldiv_o = op_muldiv;

    // CSR info
    wire op_csr = (disp_info_grp == `DECINFO_GRP_CSR);
    wire[`DECINFO_WIDTH-1:0] csr_info = {`DECINFO_WIDTH{op_csr}} & dec_info_bus_i;
    // CSR op1
    wire csr_rs1imm = csr_info[`DECINFO_CSR_RS1IMM];
    wire[31:0] csr_rs1 = csr_rs1imm? dec_imm_i: rs1_rdata_i;
    assign csr_op1_o = op_csr? csr_rs1: 32'h0;
    assign csr_addr_o = {{20{1'b0}}, csr_info[`DECINFO_CSR_CSRADDR]};
    assign csr_csrrw_o = csr_info[`DECINFO_CSR_CSRRW];
    assign csr_csrrs_o = csr_info[`DECINFO_CSR_CSRRS];
    assign csr_csrrc_o = csr_info[`DECINFO_CSR_CSRRC];
    assign req_csr_o = op_csr;

    // MEM info
    wire op_mem = (disp_info_grp == `DECINFO_GRP_MEM);
    wire[`DECINFO_WIDTH-1:0] mem_info = {`DECINFO_WIDTH{op_mem}} & dec_info_bus_i;
    assign mem_op_lb_o = mem_info[`DECINFO_MEM_LB];
    assign mem_op_lh_o = mem_info[`DECINFO_MEM_LH];
    assign mem_op_lw_o = mem_info[`DECINFO_MEM_LW];
    assign mem_op_lbu_o = mem_info[`DECINFO_MEM_LBU];
    assign mem_op_lhu_o = mem_info[`DECINFO_MEM_LHU];
    assign mem_op_sb_o = mem_info[`DECINFO_MEM_SB];
    assign mem_op_sh_o = mem_info[`DECINFO_MEM_SH];
    assign mem_op_sw_o = mem_info[`DECINFO_MEM_SW];
    assign mem_op1_o = op_mem? rs1_rdata_i: 32'h0;
    assign mem_op2_o = op_mem? dec_imm_i: 32'h0;
    assign mem_rs2_data_o = op_mem? rs2_rdata_i: 32'h0;
    assign req_mem_o = op_mem;

    // SYS info
    wire op_sys = (disp_info_grp == `DECINFO_GRP_SYS);
    wire[`DECINFO_WIDTH-1:0] sys_info = {`DECINFO_WIDTH{op_sys}} & dec_info_bus_i;
    assign sys_op_nop_o = sys_info[`DECINFO_SYS_NOP];
    assign sys_op_mret_o = sys_info[`DECINFO_SYS_MRET];
    assign sys_op_ecall_o = sys_info[`DECINFO_SYS_ECALL];
    assign sys_op_ebreak_o = sys_info[`DECINFO_SYS_EBREAK];
    assign sys_op_fence_o = sys_info[`DECINFO_SYS_FENCE];

endmodule
