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

// inst fetch module
module if_id (

    input wire clk,
    input wire rst,

    input wire[`SramBus] inst_i,            // inst content
    input wire[`SramAddrBus] inst_addr_i,   // inst addr

    input wire jump_flag_ex_i,

    output reg[`SramBus] inst_o,
    output reg[`SramAddrBus] inst_addr_o

);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `ZeroWord;
            inst_addr_o <= `ZeroWord;
        end else if (jump_flag_ex_i == `JumpEnable) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= `ZeroWord;
        end else begin
            inst_o <= inst_i;
            inst_addr_o <= inst_addr_i;
        end
    end

endmodule
