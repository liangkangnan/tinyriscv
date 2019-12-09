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

// identify module
module id (

	input wire clk,
	input wire rst,
	input wire[`SramBus] inst_i,             // inst content
    input wire[`SramAddrBus] inst_addr_i,    // inst addr
    input wire jump_flag_ex_i,

    // to regs
    output reg reg1_re_o,                    // reg1 read enable
    output reg[`RegAddrBus] reg1_raddr_o,    // reg1 read addr
    output reg reg2_re_o,                    // reg2 read enable
    output reg[`RegAddrBus] reg2_raddr_o,    // reg2 read addr
    output reg reg_we_o,                     // reg write enable
    output reg[`RegAddrBus] reg_waddr_o,     // reg write addr

    // to ex
    output reg[`SramBus] inst_o,
    output reg inst_valid_o,                 // inst is valid flag
    output reg[`SramAddrBus] inst_addr_o,

    // to sram
    output reg sram_re_o,                    // ram read enable
    output reg sram_we_o                     // ram write enable

);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];


    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `ZeroWord;
            reg_we_o <= `WriteDisable;
            sram_we_o <= `WriteDisable;
            reg1_re_o <= `ReadDisable;
            reg2_re_o <= `ReadDisable;
            sram_re_o <= `ReadDisable;
            inst_valid_o <= `InstInvalid;
        end else if (jump_flag_ex_i == `JumpEnable && inst_i != `INST_NOP) begin
            inst_valid_o <= `InstValid;
            sram_we_o <= `WriteDisable;
            reg_we_o <= `WriteDisable;
            inst_o <= `INST_NOP;
        end else begin
            inst_o <= inst_i;
            inst_addr_o <= inst_addr_i;

            case (opcode)
                `INST_TYPE_I: begin
                    case (funct3)
                        `INST_ADDI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLTI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLTIU: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_XORI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_ORI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_ANDI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLLI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SRI: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            sram_we_o <= `WriteDisable;
                        end
                        default: begin
                            inst_valid_o <= `InstInvalid;
                        end
                    endcase
                end
                `INST_TYPE_R: begin
                    case (funct3)
                        `INST_ADD_SUB: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLL: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLT: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SLTU: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_XOR: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_SR: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_OR: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_AND: begin
                            inst_valid_o <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                        end
                        default: begin
                            inst_valid_o <= `InstInvalid;
                        end
                    endcase
                end
                `INST_TYPE_L: begin
                    case (funct3)
                        `INST_LB: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            sram_re_o <= `ReadEnable;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_LH: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            sram_re_o <= `ReadEnable;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_LW: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            sram_re_o <= `ReadEnable;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_LBU: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            sram_re_o <= `ReadEnable;
                            sram_we_o <= `WriteDisable;
                        end
                        `INST_LHU: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            sram_re_o <= `ReadEnable;
                            sram_we_o <= `WriteDisable;
                        end
                        default: begin
                            inst_valid_o <= `InstInvalid;
                        end
                    endcase
                end
                `INST_TYPE_S: begin
                    case (funct3)
                        `INST_SB: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteEnable;
                            sram_re_o <= `ReadEnable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_SH: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteEnable;
                            sram_re_o <= `ReadEnable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_SW: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_re_o <= `ReadEnable;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteEnable;
                            reg_we_o <= `WriteDisable;
                        end
                        default: begin
                            inst_valid_o <= `InstInvalid;
                        end
                    endcase
                end
                `INST_TYPE_B: begin
                    case (funct3)
                        `INST_BEQ: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_BNE: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_BLT: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_BGE: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_BLTU: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        `INST_BGEU: begin
                            inst_valid_o <= `InstValid;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            reg1_raddr_o <= rs1;
                            reg2_raddr_o <= rs2;
                            sram_we_o <= `WriteDisable;
                            reg_we_o <= `WriteDisable;
                        end
                        default: begin
                            inst_valid_o <= `InstInvalid;
                        end
                    endcase
                end
                `INST_JAL: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteEnable;
                    reg_waddr_o <= rd;
                end
                `INST_JALR: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteEnable;
					reg1_re_o <= `ReadEnable;
					reg1_raddr_o <= rs1;
                    reg_waddr_o <= rd;
                end
                `INST_LUI: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteEnable;
                    reg_waddr_o <= rd;
                end
                `INST_AUIPC: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteEnable;
                    reg_waddr_o <= rd;
                end
                `INST_NOP: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteDisable;
                end
                `INST_FENCE: begin
                    inst_valid_o <= `InstValid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteDisable;
                end
                default: begin
                    inst_valid_o <= `InstInvalid;
                    sram_we_o <= `WriteDisable;
                    reg_we_o <= `WriteDisable;
                end
            endcase
        end
    end

endmodule
