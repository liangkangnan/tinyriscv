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

// CSR寄存器模块
module csr_reg(

    input wire clk,
    input wire rst,

    // form ex
    input wire we_i,                        // ex模块写寄存器标志
    input wire[`MemAddrBus] raddr_i,        // ex模块读寄存器地址
    input wire[`MemAddrBus] waddr_i,        // ex模块写寄存器地址
    input wire[`RegBus] data_i,             // ex模块写寄存器数据

    // from clint
    input wire clint_we_i,                  // clint模块写寄存器标志
    input wire[`MemAddrBus] clint_raddr_i,  // clint模块读寄存器地址
    input wire[`MemAddrBus] clint_waddr_i,  // clint模块写寄存器地址
    input wire[`RegBus] clint_data_i,       // clint模块写寄存器数据

    output wire global_int_en_o,            // 全局中断使能标志

    // to clint
    output reg[`RegBus] clint_data_o,       // clint模块读寄存器数据
    output wire[`RegBus] clint_csr_mtvec,   // mtvec
    output wire[`RegBus] clint_csr_mepc,    // mepc
    output wire[`RegBus] clint_csr_mstatus, // mstatus

    // to ex
    output reg[`RegBus] data_o              // ex模块读寄存器数据

    );

    reg[`DoubleRegBus] cycle;
    reg[`RegBus] mtvec;
    reg[`RegBus] mcause;
    reg[`RegBus] mepc;
    reg[`RegBus] mie;
    reg[`RegBus] mstatus;
    reg[`RegBus] mscratch;

    assign global_int_en_o = (mstatus[3] == 1'b1)? `True: `False;

    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;

    // cycle counter
    // 复位撤销后就一直计数
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            cycle <= {`ZeroWord, `ZeroWord};
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    // write reg
    // 写寄存器操作
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mtvec <= `ZeroWord;
            mcause <= `ZeroWord;
            mepc <= `ZeroWord;
            mie <= `ZeroWord;
            mstatus <= `ZeroWord;
            mscratch <= `ZeroWord;
        end else begin
            // 优先响应ex模块的写操作
            if (we_i == `WriteEnable) begin
                case (waddr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= data_i;
                    end
                    `CSR_MIE: begin
                        mie <= data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= data_i;
                    end
                    default: begin

                    end
                endcase
            // clint模块写操作
            end else if (clint_we_i == `WriteEnable) begin
                case (clint_waddr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= clint_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= clint_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= clint_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= clint_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= clint_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= clint_data_i;
                    end
                    default: begin

                    end
                endcase
            end
        end
    end

    // read reg
    // ex模块读CSR寄存器
    always @ (*) begin
        if ((waddr_i[11:0] == raddr_i[11:0]) && (we_i == `WriteEnable)) begin
            data_o = data_i;
        end else begin
            case (raddr_i[11:0])
                `CSR_CYCLE: begin
                    data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    data_o = mcause;
                end
                `CSR_MEPC: begin
                    data_o = mepc;
                end
                `CSR_MIE: begin
                    data_o = mie;
                end
                `CSR_MSTATUS: begin
                    data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    data_o = mscratch;
                end
                default: begin
                    data_o = `ZeroWord;
                end
            endcase
        end
    end

    // read reg
    // clint模块读CSR寄存器
    always @ (*) begin
        if ((clint_waddr_i[11:0] == clint_raddr_i[11:0]) && (clint_we_i == `WriteEnable)) begin
            clint_data_o = clint_data_i;
        end else begin
            case (clint_raddr_i[11:0])
                `CSR_CYCLE: begin
                    clint_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    clint_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    clint_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_data_o = mcause;
                end
                `CSR_MEPC: begin
                    clint_data_o = mepc;
                end
                `CSR_MIE: begin
                    clint_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    clint_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    clint_data_o = mscratch;
                end
                default: begin
                    clint_data_o = `ZeroWord;
                end
            endcase
        end
    end

endmodule
