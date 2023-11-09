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

`define CPU_RESET_ADDR       32'h0           // CPU复位地址
`define CPU_CLOCK_HZ         50000000        // CPU时钟(50MHZ)
`define INST_MEM_START_ADDR  32'h0           // 指令存储器起始地址
`define INST_MEM_END_ADDR    32'h0fffffff    // 指令存储器结束地址
`define JTAG_RESET_FF_LEVELS 5

`define ROM_DEPTH     1024                   // 指令存储器深度，单位为word(4字节)
`define RAM_DEPTH     4096                   // 数据存储器深度，单位为word(4字节)

`define INT_WIDTH    8
`define INT_NONE     8'h0

`define STALL_WIDTH  4
`define STALL_PC     2'd0
`define STALL_IF     2'd1
`define STALL_ID     2'd2
`define STALL_EX     2'd3

`define INST_NOP     32'h00000013
`define INST_MRET    32'h30200073
`define INST_ECALL   32'h00000073
`define INST_EBREAK  32'h00100073

// 指令译码信息
`define DECINFO_GRP_BUS           2:0
`define DECINFO_GRP_WIDTH         3
`define DECINFO_GRP_ALU           `DECINFO_GRP_WIDTH'd1
`define DECINFO_GRP_BJP           `DECINFO_GRP_WIDTH'd2
`define DECINFO_GRP_MULDIV        `DECINFO_GRP_WIDTH'd3
`define DECINFO_GRP_CSR           `DECINFO_GRP_WIDTH'd4
`define DECINFO_GRP_MEM           `DECINFO_GRP_WIDTH'd5
`define DECINFO_GRP_SYS           `DECINFO_GRP_WIDTH'd6

`define DECINFO_ALU_BUS_WIDTH     (`DECINFO_GRP_WIDTH+14)
`define DECINFO_ALU_LUI           (`DECINFO_GRP_WIDTH+0)
`define DECINFO_ALU_AUIPC         (`DECINFO_GRP_WIDTH+1)
`define DECINFO_ALU_ADD           (`DECINFO_GRP_WIDTH+2)
`define DECINFO_ALU_SUB           (`DECINFO_GRP_WIDTH+3)
`define DECINFO_ALU_SLL           (`DECINFO_GRP_WIDTH+4)
`define DECINFO_ALU_SLT           (`DECINFO_GRP_WIDTH+5)
`define DECINFO_ALU_SLTU          (`DECINFO_GRP_WIDTH+6)
`define DECINFO_ALU_XOR           (`DECINFO_GRP_WIDTH+7)
`define DECINFO_ALU_SRL           (`DECINFO_GRP_WIDTH+8)
`define DECINFO_ALU_SRA           (`DECINFO_GRP_WIDTH+9)
`define DECINFO_ALU_OR            (`DECINFO_GRP_WIDTH+10)
`define DECINFO_ALU_AND           (`DECINFO_GRP_WIDTH+11)
`define DECINFO_ALU_OP2IMM        (`DECINFO_GRP_WIDTH+12)
`define DECINFO_ALU_OP1PC         (`DECINFO_GRP_WIDTH+13)

`define DECINFO_BJP_BUS_WIDTH     (`DECINFO_GRP_WIDTH+8)
`define DECINFO_BJP_JUMP          (`DECINFO_GRP_WIDTH+0)
`define DECINFO_BJP_BEQ           (`DECINFO_GRP_WIDTH+1)
`define DECINFO_BJP_BNE           (`DECINFO_GRP_WIDTH+2)
`define DECINFO_BJP_BLT           (`DECINFO_GRP_WIDTH+3)
`define DECINFO_BJP_BGE           (`DECINFO_GRP_WIDTH+4)
`define DECINFO_BJP_BLTU          (`DECINFO_GRP_WIDTH+5)
`define DECINFO_BJP_BGEU          (`DECINFO_GRP_WIDTH+6)
`define DECINFO_BJP_OP1RS1        (`DECINFO_GRP_WIDTH+7)

`define DECINFO_MULDIV_BUS_WIDTH  (`DECINFO_GRP_WIDTH+8)
`define DECINFO_MULDIV_MUL        (`DECINFO_GRP_WIDTH+0)
`define DECINFO_MULDIV_MULH       (`DECINFO_GRP_WIDTH+1)
`define DECINFO_MULDIV_MULHSU     (`DECINFO_GRP_WIDTH+2)
`define DECINFO_MULDIV_MULHU      (`DECINFO_GRP_WIDTH+3)
`define DECINFO_MULDIV_DIV        (`DECINFO_GRP_WIDTH+4)
`define DECINFO_MULDIV_DIVU       (`DECINFO_GRP_WIDTH+5)
`define DECINFO_MULDIV_REM        (`DECINFO_GRP_WIDTH+6)
`define DECINFO_MULDIV_REMU       (`DECINFO_GRP_WIDTH+7)

`define DECINFO_CSR_BUS_WIDTH     (`DECINFO_GRP_WIDTH+16)
`define DECINFO_CSR_CSRRW         (`DECINFO_GRP_WIDTH+0)
`define DECINFO_CSR_CSRRS         (`DECINFO_GRP_WIDTH+1)
`define DECINFO_CSR_CSRRC         (`DECINFO_GRP_WIDTH+2)
`define DECINFO_CSR_RS1IMM        (`DECINFO_GRP_WIDTH+3)
`define DECINFO_CSR_CSRADDR       `DECINFO_GRP_WIDTH+4+12-1:`DECINFO_GRP_WIDTH+4

`define DECINFO_MEM_BUS_WIDTH     (`DECINFO_GRP_WIDTH+8)
`define DECINFO_MEM_LB            (`DECINFO_GRP_WIDTH+0)
`define DECINFO_MEM_LH            (`DECINFO_GRP_WIDTH+1)
`define DECINFO_MEM_LW            (`DECINFO_GRP_WIDTH+2)
`define DECINFO_MEM_LBU           (`DECINFO_GRP_WIDTH+3)
`define DECINFO_MEM_LHU           (`DECINFO_GRP_WIDTH+4)
`define DECINFO_MEM_SB            (`DECINFO_GRP_WIDTH+5)
`define DECINFO_MEM_SH            (`DECINFO_GRP_WIDTH+6)
`define DECINFO_MEM_SW            (`DECINFO_GRP_WIDTH+7)

`define DECINFO_SYS_BUS_WIDTH     (`DECINFO_GRP_WIDTH+5)
`define DECINFO_SYS_ECALL         (`DECINFO_GRP_WIDTH+0)
`define DECINFO_SYS_EBREAK        (`DECINFO_GRP_WIDTH+1)
`define DECINFO_SYS_NOP           (`DECINFO_GRP_WIDTH+2)
`define DECINFO_SYS_MRET          (`DECINFO_GRP_WIDTH+3)
`define DECINFO_SYS_FENCE         (`DECINFO_GRP_WIDTH+4)

// 最长的那组
`define DECINFO_WIDTH             `DECINFO_CSR_BUS_WIDTH

// CSR寄存器地址
`define CSR_CYCLE       12'hc00
`define CSR_CYCLEH      12'hc80
`define CSR_MTVEC       12'h305
`define CSR_MCAUSE      12'h342
`define CSR_MEPC        12'h341
`define CSR_MIE         12'h304
`define CSR_MSTATUS     12'h300
`define CSR_MSCRATCH    12'h340

