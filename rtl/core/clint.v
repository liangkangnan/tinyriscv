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
    input wire rst_n,

    // from core
    input wire[`INT_WIDTH-1:0] int_flag_i,      // 中断输入信号

    // from exu
    input wire inst_ecall_i,                    // ecall指令
    input wire inst_ebreak_i,                   // ebreak指令
    input wire inst_mret_i,                     // mret指令
    input wire[31:0] inst_addr_i,               // 指令地址
    input wire jump_flag_i,
    input wire mem_access_misaligned_i,

    // from csr_reg
    input wire[31:0] csr_mtvec_i,               // mtvec寄存器
    input wire[31:0] csr_mepc_i,                // mepc寄存器
    input wire[31:0] csr_mstatus_i,             // mstatus寄存器

    // to csr_reg
    output reg csr_we_o,                        // 写CSR寄存器标志
    output reg[31:0] csr_waddr_o,               // 写CSR寄存器地址
    output reg[31:0] csr_wdata_o,               // 写CSR寄存器数据

    // to pipe_ctrl
    output wire stall_flag_o,                   // 流水线暂停标志
    output wire[31:0] int_addr_o,               // 中断入口地址
    output wire int_assert_o                    // 中断标志

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
    reg[31:0] inst_addr;
    reg[31:0] cause;

    wire global_int_en = csr_mstatus_i[3];

    assign stall_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? 1'b1: 1'b0;

    // 将跳转标志放在流水线上传递
    wire pc_state_jump_flag;
    gen_rst_0_dff #(1) pc_state_dff(clk, rst_n, jump_flag_i, pc_state_jump_flag);

    wire if_state_jump_flag;
    gen_rst_0_dff #(1) if_state_dff(clk, rst_n, pc_state_jump_flag, if_state_jump_flag);

    wire id_state_jump_flag;
    gen_rst_0_dff #(1) id_state_dff(clk, rst_n, if_state_jump_flag, id_state_jump_flag);

    wire ex_state_jump_flag;
    gen_rst_0_dff #(1) ex_state_dff(clk, rst_n, id_state_jump_flag, ex_state_jump_flag);

    wire[3:0] state_jump_flag = {pc_state_jump_flag, if_state_jump_flag, id_state_jump_flag, ex_state_jump_flag};
    // 如果流水线没有冲刷完成则不响应中断
    wire inst_addr_valid = (~(|state_jump_flag)) | ex_state_jump_flag;


    // 中断仲裁逻辑
    always @ (*) begin
        // 同步中断
        if (inst_ecall_i | inst_ebreak_i | mem_access_misaligned_i) begin
            int_state = S_INT_SYNC_ASSERT;
        // 异步中断
        end else if ((int_flag_i != `INT_NONE) & global_int_en & inst_addr_valid) begin
            int_state = S_INT_ASYNC_ASSERT;
        // 中断返回
        end else if (inst_mret_i) begin
            int_state = S_INT_MRET;
        // 无中断响应
        end else begin
            int_state = S_INT_IDLE;
        end
    end

    // 写CSR寄存器状态切换
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_state <= S_CSR_IDLE;
            cause <= 32'h0;
            inst_addr <= 32'h0;
        end else begin
            case (csr_state)
                S_CSR_IDLE: begin
                    case (int_state)
                        // 同步中断
                        S_INT_SYNC_ASSERT: begin
                            csr_state <= S_CSR_MEPC;
                            // 在中断处理函数里会将中断返回地址加4
                            inst_addr <= inst_addr_i;
                            cause <= inst_ebreak_i? 32'd3:
                                     inst_ecall_i? 32'd11:
                                     mem_access_misaligned_i? 32'd4:
                                     32'd10;
                        end
                        // 异步中断
                        S_INT_ASYNC_ASSERT: begin
                            csr_state <= S_CSR_MEPC;
                            inst_addr <= inst_addr_i;
                            // 定时器中断
                            cause <= 32'h80000004;
                        end
                        // 中断返回
                        S_INT_MRET: begin
                            csr_state <= S_CSR_MSTATUS_MRET;
                        end
                    endcase
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
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_we_o <= 1'b0;
            csr_waddr_o <= 32'h0;
            csr_wdata_o <= 32'h0;
        end else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                S_CSR_MEPC: begin
                    csr_we_o <= 1'b1;
                    csr_waddr_o <= {20'h0, `CSR_MEPC};
                    csr_wdata_o <= inst_addr;
                end
                // 写中断产生的原因
                S_CSR_MCAUSE: begin
                    csr_we_o <= 1'b1;
                    csr_waddr_o <= {20'h0, `CSR_MCAUSE};
                    csr_wdata_o <= cause;
                end
                // 关闭全局中断
                S_CSR_MSTATUS: begin
                    csr_we_o <= 1'b1;
                    csr_waddr_o <= {20'h0, `CSR_MSTATUS};
                    csr_wdata_o <= {csr_mstatus_i[31:4], 1'b0, csr_mstatus_i[2:0]};
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    csr_we_o <= 1'b1;
                    csr_waddr_o <= {20'h0, `CSR_MSTATUS};
                    csr_wdata_o <= {csr_mstatus_i[31:4], csr_mstatus_i[7], csr_mstatus_i[2:0]};
                end
                default: begin
                    csr_we_o <= 1'b0;
                    csr_waddr_o <= 32'h0;
                    csr_wdata_o <= 32'h0;
                end
            endcase
        end
    end

    reg in_int_context;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_int_context <= 1'b0;
        end else begin
            if (csr_state == S_CSR_MSTATUS_MRET) begin
                in_int_context <= 1'b0;
            end else if (csr_state != S_CSR_IDLE) begin
                in_int_context <= 1'b1;
            end
        end
    end

    assign int_assert_o = (csr_state == S_CSR_MCAUSE) | (csr_state == S_CSR_MSTATUS_MRET);
    assign int_addr_o = (csr_state == S_CSR_MCAUSE)? csr_mtvec_i:
                        (csr_state == S_CSR_MSTATUS_MRET)? csr_mepc_i:
                        32'h0;

endmodule
