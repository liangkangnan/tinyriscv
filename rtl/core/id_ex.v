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

// 将译码结果向执行模块传递
module id_ex(

    input wire clk,
    input wire rst,

    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址
    input wire reg_we_i,                    // 写通用寄存器标志
    input wire[`RegAddrBus] reg_waddr_i,    // 写通用寄存器地址
    input wire[`RegBus] reg1_rdata_i,       // 通用寄存器1读数据
    input wire[`RegBus] reg2_rdata_i,       // 通用寄存器2读数据
    input wire csr_we_i,                    // 写CSR寄存器标志
    input wire[`MemAddrBus] csr_waddr_i,    // 写CSR寄存器地址
    input wire[`RegBus] csr_rdata_i,        // CSR寄存器读数据

    input wire[`Hold_Flag_Bus] hold_flag_i, // 流水线暂停标志

    output reg[`InstBus] inst_o,            // 指令内容
    output reg[`InstAddrBus] inst_addr_o,   // 指令地址
    output reg reg_we_o,                    // 写通用寄存器标志
    output reg[`RegAddrBus] reg_waddr_o,    // 写通用寄存器地址
    output reg[`RegBus] reg1_rdata_o,       // 通用寄存器1读数据
    output reg[`RegBus] reg2_rdata_o,       // 通用寄存器2读数据
    output reg csr_we_o,                    // 写CSR寄存器标志
    output reg[`MemAddrBus] csr_waddr_o,    // 写CSR寄存器地址
    output reg[`RegBus] csr_rdata_o         // CSR寄存器读数据

    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= `ZeroWord;
            reg_we_o <= `WriteDisable;
            reg_waddr_o <= `ZeroWord;
            reg1_rdata_o <= `ZeroWord;
            reg2_rdata_o <= `ZeroWord;
            csr_we_o <= `WriteDisable;
            csr_waddr_o <= `ZeroWord;
            csr_rdata_o <= `ZeroWord;
        end else begin
            // 流水线暂停时传递默认值
            if (hold_flag_i >= `Hold_Id) begin
                inst_o <= `INST_NOP;
                inst_addr_o <= inst_addr_i;
                reg_we_o <= `WriteDisable;
                reg_waddr_o <= `ZeroWord;
                reg1_rdata_o <= `ZeroWord;
                reg2_rdata_o <= `ZeroWord;
                csr_we_o <= `WriteDisable;
                csr_waddr_o <= `ZeroWord;
                csr_rdata_o <= `ZeroWord;
            end else begin
                inst_o <= inst_i;
                inst_addr_o <= inst_addr_i;
                reg_we_o <= reg_we_i;
                reg_waddr_o <= reg_waddr_i;
                reg1_rdata_o <= reg1_rdata_i;
                reg2_rdata_o <= reg2_rdata_i;
                csr_we_o <= csr_we_i;
                csr_waddr_o <= csr_waddr_i;
                csr_rdata_o <= csr_rdata_i;
            end
        end
    end

endmodule
