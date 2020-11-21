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


// core local interruptor module
// 核心中断管理、仲裁模块
module clint(

    input wire clk,
    input wire rst,

    // from core
    input wire[`INT_BUS] int_flag_i,         // 中断输入信号

    // from id
    input wire[`InstBus] inst_i,             // 指令内容
    input wire[`InstAddrBus] inst_addr_i,    // 指令地址

    // from ex
    input wire jump_flag_i,
    input wire[`InstAddrBus] jump_addr_i,
    input wire div_started_i,

    // from ctrl
    input wire[`Hold_Flag_Bus] hold_flag_i,  // 流水线暂停标志

    // from csr_reg
    input wire[`RegBus] data_i,              // CSR寄存器输入数据
    input wire[`RegBus] csr_mtvec,           // mtvec寄存器
    input wire[`RegBus] csr_mepc,            // mepc寄存器
    input wire[`RegBus] csr_mstatus,         // mstatus寄存器

    input wire global_int_en_i,              // 全局中断使能标志

    // to ctrl
    output wire hold_flag_o,                 // 流水线暂停标志

    // to csr_reg
    output reg we_o,                         // 写CSR寄存器标志
    output reg[`MemAddrBus] waddr_o,         // 写CSR寄存器地址
    output reg[`MemAddrBus] raddr_o,         // 读CSR寄存器地址
    output reg[`RegBus] data_o,              // 写CSR寄存器数据

    // to ex
    output reg[`InstAddrBus] int_addr_o,     // 中断入口地址
    output reg int_assert_o                  // 中断标志

    );


    // 中断状态定义
    localparam S_INT_IDLE            = 4'b0001;
    localparam S_INT_SYNC_ASSERT     = 4'b0010;
    localparam S_INT_ASYNC_ASSERT    = 4'b0100;
    localparam S_INT_MRET            = 4'b1000;

    // 写CSR寄存器状态定义
    localparam S_CSR_IDLE            = 5'b00001;
    localparam S_CSR_MSTATUS         = 5'b00010;
    localparam S_CSR_MEPC            = 5'b00100;
    localparam S_CSR_MSTATUS_MRET    = 5'b01000;
    localparam S_CSR_MCAUSE          = 5'b10000;

    reg[3:0] int_state;
    reg[4:0] csr_state;
    reg[`InstAddrBus] inst_addr;
    reg[31:0] cause;


    assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? `HoldEnable: `HoldDisable;


    // 中断仲裁逻辑
    always @ (*) begin
        if (rst == `RstEnable) begin
            int_state = S_INT_IDLE;
        end else begin
            if (inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin
                // 如果执行阶段的指令为除法指令，则先不处理同步中断，等除法指令执行完再处理
                if (div_started_i == `DivStop) begin
                    int_state = S_INT_SYNC_ASSERT;
                end else begin
                    int_state = S_INT_IDLE;
                end
            end else if (int_flag_i != `INT_NONE && global_int_en_i == `True) begin
                int_state = S_INT_ASYNC_ASSERT;
            end else if (inst_i == `INST_MRET) begin
                int_state = S_INT_MRET;
            end else begin
                int_state = S_INT_IDLE;
            end
        end
    end

    // 写CSR寄存器状态切换
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            csr_state <= S_CSR_IDLE;
            cause <= `ZeroWord;
            inst_addr <= `ZeroWord;
        end else begin
            case (csr_state)
                S_CSR_IDLE: begin
                    // 同步中断
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        // 在中断处理函数里会将中断返回地址加4
                        if (jump_flag_i == `JumpEnable) begin
                            inst_addr <= jump_addr_i - 4'h4;
                        end else begin
                            inst_addr <= inst_addr_i;
                        end
                        case (inst_i)
                            `INST_ECALL: begin
                                cause <= 32'd11;
                            end
                            `INST_EBREAK: begin
                                cause <= 32'd3;
                            end
                            default: begin
                                cause <= 32'd10;
                            end
                        endcase
                    // 异步中断
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // 定时器中断
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        if (jump_flag_i == `JumpEnable) begin
                            inst_addr <= jump_addr_i;
                        // 异步中断可以中断除法指令的执行，中断处理完再重新执行除法指令
                        end else if (div_started_i == `DivStart) begin
                            inst_addr <= inst_addr_i - 4'h4;
                        end else begin
                            inst_addr <= inst_addr_i;
                        end
                    // 中断返回
                    end else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                S_CSR_MCAUSE: begin
                    csr_state <= S_CSR_IDLE;
                end
                S_CSR_MSTATUS_MRET: begin
                    csr_state <= S_CSR_IDLE;
                end
                default: begin
                    csr_state <= S_CSR_IDLE;
                end
            endcase
        end
    end

    // 发出中断信号前，先写几个CSR寄存器
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            we_o <= `WriteDisable;
            waddr_o <= `ZeroWord;
            data_o <= `ZeroWord;
        end else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                S_CSR_MEPC: begin
                    we_o <= `WriteEnable;
                    waddr_o <= {20'h0, `CSR_MEPC};
                    data_o <= inst_addr;
                end
                // 写中断产生的原因
                S_CSR_MCAUSE: begin
                    we_o <= `WriteEnable;
                    waddr_o <= {20'h0, `CSR_MCAUSE};
                    data_o <= cause;
                end
                // 关闭全局中断
                S_CSR_MSTATUS: begin
                    we_o <= `WriteEnable;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    we_o <= `WriteEnable;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    we_o <= `WriteDisable;
                    waddr_o <= `ZeroWord;
                    data_o <= `ZeroWord;
                end
            endcase
        end
    end

    // 发出中断信号给ex模块
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            int_assert_o <= `INT_DEASSERT;
            int_addr_o <= `ZeroWord;
        end else begin
            case (csr_state)
                // 发出中断进入信号.写完mcause寄存器才能发
                S_CSR_MCAUSE: begin
                    int_assert_o <= `INT_ASSERT;
                    int_addr_o <= csr_mtvec;
                end
                // 发出中断返回信号
                S_CSR_MSTATUS_MRET: begin
                    int_assert_o <= `INT_ASSERT;
                    int_addr_o <= csr_mepc;
                end
                default: begin
                    int_assert_o <= `INT_DEASSERT;
                    int_addr_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule
