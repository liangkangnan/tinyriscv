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
    input wire we_i,
    input wire[`MemAddrBus] raddr_i,
    input wire[`MemAddrBus] waddr_i,
    input wire[`RegBus] data_i,

    // from clint
    input wire clint_we_i,
    input wire[`MemAddrBus] clint_raddr_i,
    input wire[`MemAddrBus] clint_waddr_i,
    input wire[`RegBus] clint_data_i,

    // to clint
    output reg[`RegBus] clint_data_o,

    // to ex
    output reg[`RegBus] data_o

    );


    reg[`DoubleRegBus] cycle;
    reg[`RegBus] mtvec;
    reg[`RegBus] mcause;
    reg[`RegBus] mepc;


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
                    default: begin

                    end
                endcase
            end
        end
    end

    // read reg
    // ex模块读CSR寄存器
    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end else begin
            case (raddr_i[11:0])
                `CSR_CYCLE: begin
                    data_o <= cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    data_o <= cycle[63:32];
                end
                `CSR_MTVEC: begin
                    data_o <= mtvec;
                end
                `CSR_MCAUSE: begin
                    data_o <= mcause;
                end
                `CSR_MEPC: begin
                    data_o <= mepc;
                end
                default: begin
                    data_o <= `ZeroWord;
                end
            endcase
        end
    end

    // read reg
    // clint模块读CSR寄存器
    always @ (*) begin
        if (rst == `RstEnable) begin
            clint_data_o <= `ZeroWord;
        end else begin
            case (clint_raddr_i[11:0])
                `CSR_CYCLE: begin
                    clint_data_o <= cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    clint_data_o <= cycle[63:32];
                end
                `CSR_MTVEC: begin
                    clint_data_o <= mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_data_o <= mcause;
                end
                `CSR_MEPC: begin
                    clint_data_o <= mepc;
                end
                default: begin
                    clint_data_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule
