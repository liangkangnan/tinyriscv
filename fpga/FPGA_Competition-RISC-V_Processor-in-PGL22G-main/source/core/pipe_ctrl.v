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

// 流水线控制模块
// 发出暂停、冲刷流水线信号
module pipe_ctrl(

    input wire clk,
    input wire rst_n,

    input wire stall_from_id_i,
    input wire stall_from_ex_i,
    input wire stall_from_jtag_i,
    input wire stall_from_clint_i,
    input wire jump_assert_i,
    input wire[31:0] jump_addr_i,

    output wire flush_o,
    output wire[`STALL_WIDTH-1:0] stall_o,
    output wire[31:0] flush_addr_o

    );

    assign flush_addr_o = jump_addr_i;
    assign flush_o = jump_assert_i | stall_from_clint_i;

    reg[`STALL_WIDTH-1:0] stall;

    always @ (*) begin
        if (stall_from_ex_i | stall_from_clint_i) begin
            stall[`STALL_EX] = 1'b1;
            stall[`STALL_ID] = 1'b1;
            stall[`STALL_IF] = 1'b1;
            stall[`STALL_PC] = 1'b1;
        end else if (stall_from_id_i) begin
            stall[`STALL_EX] = 1'b0;
            stall[`STALL_ID] = 1'b0;
            stall[`STALL_IF] = 1'b1;
            stall[`STALL_PC] = 1'b1;
        end else begin
            stall[`STALL_EX] = 1'b0;
            stall[`STALL_ID] = 1'b0;
            stall[`STALL_IF] = 1'b0;
            stall[`STALL_PC] = 1'b0;
        end
    end

    assign stall_o = stall;

endmodule
