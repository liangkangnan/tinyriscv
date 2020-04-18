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

// 将指令向译码模块传递
module if_id(

    input wire clk,
    input wire rst,

    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址

    input wire[`Hold_Flag_Bus] hold_flag_i, // 流水线暂停标志

    output reg[`InstBus] inst_o,            // 指令内容
    output reg[`InstAddrBus] inst_addr_o    // 指令地址

    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= `ZeroWord;
        // 流水线暂停时传递默认值
        end else if (hold_flag_i >= `Hold_If) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= inst_addr_i;
        end else begin
            inst_o <= inst_i;
            inst_addr_o <= inst_addr_i;
        end
    end

endmodule
