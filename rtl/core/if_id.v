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

    input wire[`INT_BUS] int_flag_i,        // 外设中断输入信号
    output wire[`INT_BUS] int_flag_o,

    output wire[`InstBus] inst_o,           // 指令内容
    output wire[`InstAddrBus] inst_addr_o   // 指令地址

    );

    wire hold_en = (hold_flag_i >= `Hold_If);

    wire[`InstBus] inst;
    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, `INST_NOP, inst_i, inst);
    assign inst_o = inst;

    wire[`InstAddrBus] inst_addr;
    gen_pipe_dff #(32) inst_addr_ff(clk, rst, hold_en, `ZeroWord, inst_addr_i, inst_addr);
    assign inst_addr_o = inst_addr;

    wire[`INT_BUS] int_flag;
    gen_pipe_dff #(8) int_ff(clk, rst, hold_en, `INT_NONE, int_flag_i, int_flag);
    assign int_flag_o = int_flag;

endmodule
