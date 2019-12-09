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

// pc reg module
module pc_reg (

    input wire clk,
    input wire rst,

    input wire jump_flag_ex_i,
    input wire[`RegBus] jump_addr_ex_i,

	output reg[`SramAddrBus] pc_o,
	output reg re_o

);

    reg[`SramAddrBus] offset;

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            pc_o <= `ZeroWord;
            offset <= `ZeroWord;
        end else if (jump_flag_ex_i == `JumpEnable) begin
            pc_o <= jump_addr_ex_i;
            offset <= jump_addr_ex_i + 4'h4;
        end else begin
            pc_o <= offset;
            offset <= offset + 4'h4;
        end
    end

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            re_o <= `ReadDisable;
        end else begin
            re_o <= `ReadEnable;
        end
    end

endmodule
